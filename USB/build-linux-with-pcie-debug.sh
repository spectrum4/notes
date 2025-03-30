#!/usr/bin/env bash

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"
SCRIPT_DIR="$(pwd)"

# Set desired volume name
VOLUME_NAME="casesensitive"
REPO_PATH="/Volumes/${VOLUME_NAME}/linux"

# Set raspberry pi linux repo branch name
BRANCH_NAME="rpi-6.6.y"

# Step 1: Find the APFS container for the main macOS volume
main_disk=$(diskutil info "Macintosh HD" | awk -F: '/APFS Container/ {gsub(/^[ \t]+/, "", $2); print $2}')

if [ -z "$main_disk" ]; then
  echo "❌ Could not find APFS container for 'Macintosh HD'."
  echo "Make sure the volume exists and is mounted."
  exit 1
fi

echo "✅ Found APFS container: $main_disk"

# Step 2: Check if volume already exists
if diskutil list "$main_disk" | grep -q "${VOLUME_NAME}"; then
  echo "⚠️ Volume '${VOLUME_NAME}' already exists in $main_disk."
else

  # Step 3: Create the case-sensitive volume
  echo "🚀 Creating case-sensitive APFS volume '${VOLUME_NAME}'..."
  diskutil apfs addVolume "$main_disk" APFSX "${VOLUME_NAME}"

  if [ $? -eq 0 ]; then
    echo "✅ Volume '${VOLUME_NAME}' created successfully at /Volumes/${VOLUME_NAME}"
  else
    echo "❌ Failed to create volume."
    exit 1
  fi
fi

if [ -d "${REPO_PATH}" ]; then

  cd "${REPO_PATH}"

  echo "⚠️ Directory '${REPO_PATH}' already exists."
  echo "🚀 Fetching latest commits..."
  git fetch origin

  echo "🔄 Aborting any in-progress Git operations (if any)..."
  git am --abort 2>/dev/null || true
  git rebase --abort 2>/dev/null || true
  git cherry-pick --abort 2>/dev/null || true
  git merge --abort 2>/dev/null || true

  echo "🔁 Resetting working directory..."
  git reset --hard

  echo "🧹 Cleaning untracked and ignored files..."
  git clean -fdx

  echo "✅ Repository reset to a clean state."
else
  echo "🚀 Cloning github.com/raspberrypi/linux into ${REPO_PATH} ..."
  git clone git@github.com:raspberrypi/linux.git "${REPO_PATH}"
  cd "${REPO_PATH}"
fi

echo "🚀 Checking out branch ${BRANCH_NAME}..."
git switch "${BRANCH_NAME}" || git switch -c "${BRANCH_NAME}" --track "origin/${BRANCH_NAME}"

echo "🔁 Resetting working directory..."
git reset --hard origin/rpi-5.15.y

# Apply patch 1 and 2
git am "${SCRIPT_DIR}/patches/patch-1.patch" "${SCRIPT_DIR}/patches/patch-2.patch"

# Generate dynamic commit

for width in l w b q; do
  git grep -l "\(read\|write\)${width}" | grep '\.\(c\|h\)$' | while read -r file; do
    if ! grep -q "pete_\(read\|write\)${width}" "$file"; then
      echo "processing $file..."
      sed "s/\bread${width}(/pete_&/g" "$file" \
      | sed "s/\bwrite${width}(/pete_&/g" \
      | sed "s/_pete_read${width}/_read${width}/g" \
      | sed "s/_pete_write${width}/_write${width}/g" > y

      grep -n "pete_\(read\|write\)${width}" y | sed 's/:.*//' | while read -r line; do
        sed "${line}s%pete_read${width}(%&\"${file}:${line}\", %g" y \
        | sed "${line}s%pete_write${width}(%&\"${file}:${line}\", %g" > x
        mv x y
      done

      mv y "$file"
    fi
  done
done

git add -u
git commit -m "Use wrappers (see full commit for bash one-liner)

Executed under Linux, using GNU sed (does not work with macOS sed!!)"

echo "✅ Applied dynamic commit."

Apply patch 4 and 5
git am "${SCRIPT_DIR}/patches/patch-4.patch" "${SCRIPT_DIR}/patches/patch-5.patch"
