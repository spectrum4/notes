#!/bin/bash -eu

set -x

cd ~/git/spectrum4

tup -k 2>&1 | grep 'FAIL: co_temp_5_' > x
test_number_hex="$(cat x | sed -n 's/^FAIL: co_temp_5_\([a-f0-9]*\).*/\1/p' | sort -u)"
line_number="$((0x${test_number_hex} + 25))"

cat src/spectrum128k/tests/test_co_temp_5.sh > y
sed -n ${line_number}p y | while read attr_t mask_t p_flag a d f attr_t_upd mask_t_upd p_flag_upd a_upd f_upd b_upd c_upd h_upd l_upd; do
  new_a="$(cat x | sed -n s'/.*Register A unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_a}" ]; then
    a_upd="${new_a}"
  fi
  new_b="$(cat x | sed -n s'/.*Register B unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_b}" ]; then
    b_upd="${new_b}"
  fi
  new_c="$(cat x | sed -n s'/.*Register C unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_c}" ]; then
    c_upd="${new_c}"
  fi
  new_h="$(cat x | sed -n s'/.*Register H unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_h}" ]; then
    h_upd="${new_h}"
  fi
  new_l="$(cat x | sed -n s'/.*Register L unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_l}" ]; then
    l_upd="${new_l}"
  fi
  new_f="$(cat x | sed -n s'/.*Register F unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_f}" ]; then
    f_upd="${new_f}"
  fi
  new_a="$(cat x | sed -n s'/.*Register A changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_a}" ]; then
    a_upd="${new_a}"
  fi
  new_b="$(cat x | sed -n s'/.*Register B changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_b}" ]; then
    b_upd="${new_b}"
  fi
  new_c="$(cat x | sed -n s'/.*Register C changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_c}" ]; then
    c_upd="${new_c}"
  fi
  new_h="$(cat x | sed -n s'/.*Register H changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_h}" ]; then
    h_upd="${new_h}"
  fi
  new_l="$(cat x | sed -n s'/.*Register L changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_l}" ]; then
    l_upd="${new_l}"
  fi
  new_f="$(cat x | sed -n s'/.*Register F changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_f}" ]; then
    f_upd="${new_f}"
  fi
  new_attr_t="$(cat x | sed -n s'/.*0x1C8F unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_attr_t}" ]; then
    attr_t_upd="${new_attr_t}"
  fi
  new_mask_t="$(cat x | sed -n s'/.*0x1C90 unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_mask_t}" ]; then
    mask_t_upd="${new_mask_t}"
  fi
  new_p_flag="$(cat x | sed -n s'/.*0x1C91 unchanged from \(0x..\).*/\1/p')"
  if [ -n "${new_p_flag}" ]; then
    p_flag_upd="${new_p_flag}"
  fi
  new_attr_t="$(cat x | sed -n s'/.*0x1C8F changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_attr_t}" ]; then
    attr_t_upd="${new_attr_t}"
  fi
  new_mask_t="$(cat x | sed -n s'/.*0x1C90 changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_mask_t}" ]; then
    mask_t_upd="${new_mask_t}"
  fi
  new_p_flag="$(cat x | sed -n s'/.*0x1C91 changed from 0x.. to \(0x..\).*/\1/p')"
  if [ -n "${new_p_flag}" ]; then
    p_flag_upd="${new_p_flag}"
  fi
  echo ${attr_t} ${mask_t} ${p_flag} ${a} ${d} ${f} ${attr_t_upd} ${mask_t_upd} ${p_flag_upd} ${a_upd} ${f_upd} ${b_upd} ${c_upd} ${h_upd} ${l_upd} | tr 'ABCDEF' 'abcdef' > z
done

cat y | sed -n "1,${line_number}p" | sed '$d' > src/spectrum128k/tests/test_co_temp_5.sh
cat z >> src/spectrum128k/tests/test_co_temp_5.sh
cat y | sed -n "${line_number},\$p" | sed 1d >> src/spectrum128k/tests/test_co_temp_5.sh

cat x
