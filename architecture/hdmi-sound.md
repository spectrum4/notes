# HDMI audio output on Raspberry Pi 400 — a reference from Circle

This document describes, in register-level detail, how the Circle library
(`~/git/circle`) drives HDMI audio on the Raspberry Pi 4 / Pi 400 (BCM2711).
It is intended as a porting reference for adding HDMI sound to **spectrum4**.
All paths below are under `~/git/circle/`.

The key source files:

| File | Role |
|------|------|
| `lib/sound/hdmisoundbasedevice.cpp` | HDMI-specific hardware init + DMA glue |
| `include/circle/sound/hdmisoundbasedevice.h` | Public class interface |
| `lib/sound/soundbasedevice.cpp` | IEC958 sub-frame framing (shared with S/PDIF) |
| `include/circle/sound/soundbasedevice.h` | IEC958 constants |
| `include/circle/bcm2835.h` | HDMI block base addresses per SoC |
| `include/circle/dmacommon.h` | DREQ numbers |
| `lib/dma4channel.cpp` | Pi 4 DMA engine (DMA4/DMA-lite) used to feed MAI FIFO |

The driver is explicitly documented as **HDMI0 only on Pi 4** — HDMI1 is not
supported (`hdmisoundbasedevice.h:40`).


## 1. Big picture

HDMI audio on BCM2711 is produced by three cooperating blocks:

1. **MAI** ("Multi-Audio Interface") — a 32-bit FIFO at `ARM_HD_BASE` that
   accepts IEC958 (S/PDIF) sub-frames. The MAI has its own DREQ line and is
   fed by a cyclic DMA channel.
2. **HDMI audio packetizer** at `ARM_HDMI_BASE` — wraps the IEC958 stream
   into HDMI Audio Sample Packets, inserts the audio InfoFrame, and manages
   the **CTS/N clock-recovery** values so the sink can reproduce the audio
   clock from the TMDS pixel clock.
3. **HDMI TX PHY** at `ARM_PHY_BASE` — has a per-block power-down bit that
   must be cleared to actually drive audio over the cable.

So the pipeline is:

```
user samples  ─▶ IEC958 framing ─▶ DMA (cyclic, 2 buffers) ─▶ MAI_DATA FIFO
                (software)                                       │
                                                                 ▼
                                                         MAI hardware
                                                                 │
                                                                 ▼
                                                     HDMI audio packetizer
                                                     (with Audio InfoFrame
                                                      + CRP/CTS/N values)
                                                                 │
                                                                 ▼
                                                          HDMI TX PHY
                                                                 │
                                                                 ▼
                                                        HDMI0 connector
```

**Critical prerequisite**: the HDMI video path must already be up. The driver
checks `RegRamPacketConfig.Enable` at startup and refuses to run otherwise —
that bit is set by the VideoCore firmware as part of bringing up HDMI video
(framebuffer) via the mailbox interface. If spectrum4 does not already
initialise an HDMI framebuffer, that must be done first. The audio driver
piggybacks on the running HDMI link.


## 2. Base addresses (Pi 4 / BCM2711)

From `include/circle/bcm2835.h:378-382`:

```c
#define ARM_IO_BASE     0xFE000000
#define ARM_HDMI_BASE   (ARM_IO_BASE + 0xF00700)   // 0xFEF00700
#define ARM_HD_BASE     (ARM_IO_BASE + 0xF20000)   // 0xFEF20000
#define ARM_PHY_BASE    (ARM_IO_BASE + 0xF00F00)   // 0xFEF00F00
#define ARM_RAM_BASE    (ARM_IO_BASE + 0xF01B00)   // 0xFEF01B00
```

Note these differ from Pi 1–3 addresses. Pi 5 uses different offsets again
(irrelevant here).


## 3. Register map (Pi 4)

All offsets below are absolute byte addresses. Sources:
`hdmisoundbasedevice.cpp:52-119`.

### 3.1 MAI registers (at `ARM_HD_BASE`)

| Name | Offset | Addr | Purpose |
|------|--------|------|---------|
| `MAI_CONTROL`    | 0x10 | 0xFEF20010 | Reset/flush/enable, channel count, status |
| `MAI_THRESHOLD`  | 0x14 | 0xFEF20014 | DREQ and PANIC watermarks |
| `MAI_FORMAT`     | 0x18 | 0xFEF20018 | Sample rate code + audio format (PCM) |
| `MAI_DATA`       | 0x1C | 0xFEF2001C | 32-bit write-only FIFO port (DMA dest) |
| `MAI_SAMPLERATE` | 0x20 | 0xFEF20020 | M/N ratio: `audio_clk × M / N = Fs × 128` |

### 3.2 HDMI packetizer registers (at `ARM_HDMI_BASE`)

| Name | Offset | Addr | Purpose |
|------|--------|------|---------|
| `MAI_CHANNEL_MAP`     | 0x9C | 0xFEF0079C | Maps MAI channels → IEC958 subframes |
| `MAI_CONFIG`          | 0xA0 | 0xFEF007A0 | Channel mask + bit/format reversal |
| `AUDIO_PACKET_CONFIG` | 0xB8 | 0xFEF007B8 | CEA layout, B-frame marker, zero-data flags |
| `RAM_PACKET_CONFIG`   | 0xBC | 0xFEF007BC | Master enable + per-packet identifier bits |
| `RAM_PACKET_STATUS`   | 0xC4 | 0xFEF007C4 | Echoes per-packet active status |
| `CRP_CONFIG`          | 0xC8 | 0xFEF007C8 | External CTS enable, N value (low 20 bits) |
| `CTS_0`               | 0xCC | 0xFEF007CC | CTS clock time-stamp (primary) |
| `CTS_1`               | 0xD0 | 0xFEF007D0 | CTS clock time-stamp (secondary) |

### 3.3 RAM packet buffer (Audio InfoFrame slot, at `ARM_RAM_BASE`)

| Name | Offset | Addr | Purpose |
|------|--------|------|---------|
| `RAM_PACKET_AUDIO_0` | 0x90 | 0xFEF01B90 | AIF header: type/version/length |
| `RAM_PACKET_AUDIO_1` | 0x94 | 0xFEF01B94 | AIF checksum + data byte 1 |
| `RAM_PACKET_AUDIO_2` | 0x98 | 0xFEF01B98 | AIF data bytes |
| ...        | ...  | ...        | ... |
| `RAM_PACKET_AUDIO_8` | 0xB0 | 0xFEF01BB0 | Last AIF slot |

### 3.4 HDMI PHY power-down (at `ARM_PHY_BASE`)

| Name | Offset | Addr | Bit | Purpose |
|------|--------|------|-----|---------|
| `TX_PHY_POWER_DOWN_CTL` | 0x04 | 0xFEF00F04 | bit 4 | `RngGenPowerDown` — clear to enable audio output on PHY |


## 4. Bit-level field definitions

From `hdmisoundbasedevice.cpp`:

### MAI_CONTROL (`HD_BASE + 0x10`)

| Bit | Name | Meaning |
|-----|------|---------|
| 0   | Reset        | Write 1 to reset MAI |
| 1   | ErrorFull    | Write 1 to clear "FIFO full" error |
| 2   | ErrorEmpty   | Write 1 to clear "FIFO empty" error |
| 3   | Enable       | Enable MAI operation |
| 4–8 | ChannelNumber | Number of active channels (use 2) |
| 9   | Flush        | Flush FIFO |
| 11  | Full         | Read-only: FIFO full |
| 12  | WholSample   | Treat each write as a whole sample (stereo pair packing) |
| 13  | ChannelAlign | Enable stereo channel alignment |
| 15  | Delayed      | (used during reset sequence) |

### MAI_FORMAT (`HD_BASE + 0x18`)

| Bits  | Name | Meaning |
|-------|------|---------|
| 8–15  | SampleRate  | Encoded rate (see §6) |
| 16–18 | AudioFormat | `2` = PCM |

### MAI_THRESHOLD (`HD_BASE + 0x14`) — Pi 4 layout

8 bits per field (shift 0, 8, 16, 24):
`DREQ_LOW | DREQ_HIGH | PANIC_LOW | PANIC_HIGH`. Driver uses 0x10 for all four.

### MAI_SAMPLERATE (`HD_BASE + 0x20`)

| Bits   | Name | Meaning |
|--------|------|---------|
| 0–7    | M | denominator – 1 (8-bit) |
| 8–31   | N | numerator (24-bit) |

The MAI divides `audio_clk` down to produce a `Fs × 128` bit-clock, using
`N / (M+1)`. Circle computes M and N as the best rational approximation of
`audio_clk / Fs` that fits these field widths
(`hdmisoundbasedevice.cpp:371-375`, `rational_best_approximation()` at
line 727 — a direct port of `linux/lib/math/rational.c`).

### MAI_CONFIG (`HDMI_BASE + 0xA0`)

| Bits  | Name | Meaning |
|-------|------|---------|
| 0–1   | ChannelMask    | `0b11` = both L and R active |
| 26    | BitReverse     | Bit-reverse each sub-frame (required) |
| 27    | FormatReverse  | Format-reverse (required) |

### MAI_CHANNEL_MAP (`HDMI_BASE + 0x9C`)

Pi 4 value: `0b00010000`. Maps MAI channel 0 → IEC958 subframe slot for
left, channel 1 → right. (Pi 1–3 uses `0b001000`; different field widths.)

### AUDIO_PACKET_CONFIG (`HDMI_BASE + 0xB8`)

| Bits  | Name | Meaning |
|-------|------|---------|
| 0–9   | CeaMask         | Which CEA channel slots are active; `0b11` = FL+FR |
| 10–13 | BFrameIdentifier | Software-chosen preamble marking block start; Circle uses `0x0F` |
| 24    | ZeroDataOnInactiveChannels | Zero out inactive channel slots |
| 29    | ZeroDataOnSampleFlat | Zero out samples with the "sample_flat" bit set |

### CRP_CONFIG (`HDMI_BASE + 0xC8`) — clock-recovery packet

| Bits  | Name | Meaning |
|-------|------|---------|
| 0–19  | ConfigN            | N value (see §5.2) |
| 24    | ExternalCtsEnable  | Use software-programmed CTS from `CTS_0/1` (must be 1) |

### RAM_PACKET_CONFIG / RAM_PACKET_STATUS (`HDMI_BASE + 0xBC/0xC4`)

| Bit | Name | Meaning |
|-----|------|---------|
| 4   | AudioPacketIdentifier | Enable/broadcast the audio InfoFrame |
| 16  | Enable                | Master enable for RAM packet broadcast (set by video init) |

`RAM_PACKET_STATUS` mirrors `AudioPacketIdentifier` — poll it to confirm the
state change actually took effect.

### TX_PHY_POWER_DOWN_CTL (`PHY_BASE + 0x04`) — Pi 4

| Bit | Name | Meaning |
|-----|------|---------|
| 4   | RngGenPowerDown | Set = PHY audio block powered down. **Clear to enable.** |


## 5. Clocks

Two frequencies are needed:

### 5.1 Audio clock

On Pi 4, Circle does not attempt to read or configure this — it simply
assumes **108 MHz** (`hdmisoundbasedevice.cpp:235`):

```c
m_ulAudioClockRate = 108000000UL;     // Pi 4 / BCM2711
```

There is a `TODO? manage clocks for RASPPI >= 4` comment at line 234,
confirming this is the default established by the VideoCore firmware and
never reprogrammed from the ARM side. Assume the firmware has already set
the HDMI audio clock to 108 MHz when video is up.

(On Pi 1–3 the driver reads the HSM clock divider directly from the
clock-manager registers; see `GetHSMClockRate()` at line 614. Not relevant
for Pi 400.)

### 5.2 Pixel clock

For Pi 4, Circle queries the pixel clock from VideoCore via mailbox:

```c
m_ulPixelClockRate = CMachineInfo::Get()->GetClockRate(CLOCK_ID_PIXEL_BVB);
```

- `CLOCK_ID_PIXEL_BVB = 14` (`include/circle/bcmpropertytags.h:187`).
- Mailbox tag: `PROPTAG_GET_CLOCK_RATE`.
- Fallback when mailbox query fails: 75 MHz (`machineinfo.cpp:432-434`).

`assert(m_ulPixelClockRate <= 340000000UL)`.

### 5.3 Deriving N and CTS

The HDMI spec defines the relation
`Fs = audio_clk / 128 = (pixel_clk × N) / (128 × CTS)`.
Given fixed audio and pixel clocks and the user's target `Fs`:

```c
u32 nSampleRateMul128 = Fs * 128;
u32 N   = nSampleRateMul128 / 1000;                        // line 378
u32 CTS = (u64)pixel_clk * N / nSampleRateMul128;          // line 379
```

For 48 kHz at 75 MHz pixel clock: `N = 6144`, `CTS = 75000000 × 6144 /
6144000 = 75000`. These values are written to `CRP_CONFIG.N` and both
`CTS_0` and `CTS_1`, together with `CRP_CONFIG.ExternalCtsEnable = 1`.


## 6. Hardware sample-rate code

`MAI_FORMAT.SampleRate` is a small enum, not a raw divisor. Mapping
(`hdmisoundbasedevice.cpp:565-582`):

| Code | Rate (Hz) |
|------|-----------|
| 0 | not indicated |
| 1 | 8 000  |
| 2 | 11 025 |
| 3 | 12 000 |
| 4 | 16 000 |
| 5 | 22 050 |
| 6 | 24 000 |
| 7 | 32 000 |
| 8 | 44 100 |
| 9 | 48 000 |
| 10 | 64 000 |
| 11 | 88 200 |
| 12 | 96 000 |
| 13 | 128 000 |
| 14 | 176 400 |
| 15 | 192 000 |

For a 48 kHz stream: code = 9 (so `MAI_FORMAT = (9 << 8) | (2 << 16)`).


## 7. Initialisation sequence

This is the "cold start" sequence, corresponding to `Start()` +
`RunHDMI()` + the tail of `Start()`
(`hdmisoundbasedevice.cpp:189-295, 366-448`).

### Step 1 — verify HDMI video is up

```c
if (!(read32(RAM_PACKET_CONFIG) & (1 << 16))) {
    // error: "Requires HDMI display with audio support"
}
```

Bit 16 (`Enable`) is set by VideoCore as part of HDMI video init.

### Step 2 — cache the two clocks

```c
audio_clk = 108000000UL;                             // Pi 4 constant
pixel_clk = mbox_get_clock_rate(CLOCK_ID_PIXEL_BVB); // tag 0x00030002, id 14
```

### Step 3 — program MAI core (RunHDMI)

Compute `M`, `N` (MAI sample-rate divisor) and `nN`, `nCTS` (HDMI CRP). Then
write the registers in this order:

```c
// 1. Reset + flush MAI, clear error flags (note: Reset+Flush+Delayed all set)
write32(MAI_CONTROL,
        BIT(0)   /* Reset */
      | BIT(9)   /* Flush */
      | BIT(15)  /* Delayed */
      | BIT(2)   /* clear ErrorEmpty */
      | BIT(1)); /* clear ErrorFull  */

// 2. Fs-to-audio-clk ratio (M in low byte, N in upper 24 bits)
write32(MAI_SAMPLERATE, (N << 8) | ((M - 1) & 0xFF));

// 3. Sample-rate code and PCM audio format
write32(MAI_FORMAT, (rate_code << 8) | (2 << 16));

// 4. Threshold: 0x10 in all four bytes
write32(MAI_THRESHOLD, 0x10101010);

// 5. Stereo, bit+format reversal
write32(MAI_CONFIG, (1 << 26) | (1 << 27) | 0b11);

// 6. Pi 4 channel map
write32(MAI_CHANNEL_MAP, 0b00010000);

// 7. Audio packet config: CEA FL+FR, B-frame = 0x0F,
//    zero on inactive/flat samples
write32(AUDIO_PACKET_CONFIG,
        (0x0F << 10)    /* BFrameIdentifier */
      | (0b11  << 0)    /* CeaMask */
      | (1   << 24)     /* ZeroDataOnInactiveChannels */
      | (1   << 29));   /* ZeroDataOnSampleFlat */

// 8. Clock recovery: external CTS, N
write32(CRP_CONFIG, (nN << 0) | (1 << 24));

// 9. CTS values
write32(CTS_0, nCTS);
write32(CTS_1, nCTS);
```

### Step 4 — Audio InfoFrame

`SetAudioInfoFrame()` (line 534):

```c
// a. Clear AudioPacketIdentifier and wait for it to go low (100 ms max)
write32(RAM_PACKET_CONFIG, read32(RAM_PACKET_CONFIG) & ~(1 << 4));
wait_for_bit(RAM_PACKET_STATUS, (1 << 4), 0, 100);

// b. Fill the 7 slots. First two are hand-crafted:
write32(RAM_PACKET_AUDIO_0, 0x0A0184);  // type=0x84, version=0x01, length=0x0A
write32(RAM_PACKET_AUDIO_1, 0x0170);    // checksum=0x70, channels-1 = 1 (stereo)
for (reg = RAM_PACKET_AUDIO_2; reg <= RAM_PACKET_AUDIO_8; reg += 4)
    write32(reg, 0);

// c. Enable AudioPacketIdentifier and wait for confirmation
write32(RAM_PACKET_CONFIG, read32(RAM_PACKET_CONFIG) | (1 << 4));
wait_for_bit(RAM_PACKET_STATUS, (1 << 4), 1, 100);
```

The CEA-861 InfoFrame values encode: 2-channel (stereo), PCM refer-to-stream
(format indicated by stream), no channel/coding overrides. The checksum
0x70 is precomputed so the bytes sum to 0.

### Step 5 — set up DMA to MAI_DATA

Use a DMA4 (BCM2711 DMA) channel in **Lite** variant (sufficient bandwidth).

- **Source**: two ping-pong buffers, each `chunk_size * 4` bytes, 32-bit
  aligned. Each cyclic completion swaps buffers; the driver's completion
  routine refills the just-completed buffer.
- **Destination**: physical address of `MAI_DATA` register. On Pi 4, Circle
  converts the ARM-side I/O address to a GPU-bus address by masking to 24
  bits and adding `GPU_IO_BASE` (`dma4channel.cpp:312-316`).
- **DREQ**: `DREQSourceHDMI = 10` (`dmacommon.h:39`).
- **Transfer info**: `TI4_DEST_DREQ | (DREQ << TI4_PERMAP_SHIFT) |
  TI4_WAIT_RD_RESP | TI4_WAIT_RESP`.
- **Source burst**: 128-bit reads, incrementing.
- **Destination**: 32-bit writes, non-incrementing (FIFO).
- **Chunk size** requirement: multiple of `IEC958_SUBFRAMES_PER_BLOCK = 384`
  (2 channels × 192 frames per IEC958 block). Default is `384 × 10 = 3840`
  32-bit words per buffer.

The two control blocks point to each other (cyclic), and the driver's
completion stub is invoked after each buffer drains.

### Step 6 — power up the PHY audio block

```c
write32(TX_PHY_POWER_DOWN_CTL,
        read32(TX_PHY_POWER_DOWN_CTL) & ~(1 << 4));   // clear RngGenPowerDown
```

### Step 7 — enable MAI

```c
write32(MAI_CONTROL,
        (2   << 4)   /* ChannelNumber = 2 */
      | (1   << 12)  /* WholSample */
      | (1   << 13)  /* ChannelAlign */
      | (1   << 3)); /* Enable */
```

At this point the MAI starts asserting DREQ, the DMA engine drains the first
ping-pong buffer into `MAI_DATA`, and audio appears on HDMI0.


## 8. Sound production — the IEC958 sub-frame format

The MAI consumes **32-bit IEC958 sub-frames** (not raw PCM). Each sub-frame
looks like this:

```
 bit 31  30   29   28   27 ── 4   3 ── 0
 ┌────┬────┬────┬────┬──────────┬────────┐
 │ P  │ C  │ U  │ V  │ data[23:0]│preamble│
 └────┴────┴────┴────┴──────────┴────────┘
```

- **`P` (bit 31)**: parity. Even parity over bits 4..30 (parity bit chosen
  so the bits [30:4] plus P have an even count of ones).
- **`C` (bit 30)**: channel-status bit for this sub-frame. The IEC958 block
  is 192 frames long; for each of the two channels, the first 40 of those
  frames (5 bytes × 8 bits) carry the 40-bit channel status word.
- **`U` (bit 29)**: user data. Zero.
- **`V` (bit 28)**: validity. Zero = valid.
- **`data[23:0]` (bits 27..4)**: the audio sample, left-justified (24-bit
  signed).
- **`preamble` (bits 3..0)**: Circle writes `0x0F` on the **first** sub-frame
  of each 192-frame block (the "B" frame); `0` elsewhere. The hardware uses
  `AUDIO_PACKET_CONFIG.BFrameIdentifier` to recognise 0x0F as the block
  marker. The M/W preambles for non-first frames are generated by the
  hardware, enabled by `MAI_CONTROL.ChannelAlign`.

### Channel status bytes (what `C` bits encode)

For each channel (IEC958 allows per-channel overrides; Circle writes the
same 5 bytes on both), across the first 40 frames
(`soundbasedevice.cpp:161-165`):

| Byte | Value | Meaning |
|------|-------|---------|
| 0 | `0b00000100` | consumer use, PCM linear, no copyright, no pre-emphasis |
| 1 | `0x00` | category = general |
| 2 | `0x00` | source number irrelevant |
| 3 | `uchFS` | sampling frequency code |
| 4 | `0b1011 | (uchOrigFS<<4)` | 24-bit sample depth + original-Fs code |

For **48 kHz**: `uchFS = 2`, `uchOrigFS = 13`. Other rates in the table at
`soundbasedevice.cpp:146-154`.

Bit *b* of byte *i* goes into the `C` bit of sub-frame
`(i × 8 + b)` for that channel — so this gives a per-subframe bit mask
for the first 40 frames per channel per block.

### How Circle actually builds a buffer

Two stages, split between the queue-feeder and the IEC958 block finisher:

1. **`ConvertSoundFormat()`** (`soundbasedevice.cpp:678-752`, IEC958 case
   at 736) is called when the user's raw samples are dequeued into the
   per-chunk buffer. It:
   - sign-extends the input to a 32-bit signed intermediate,
   - shifts right 4 so the 24-bit data sits in bits 27..4,
   - masks to bits 27..4,
   - sets bit 31 if the parity of the current bit layout is odd
     (so bits [31, 30..4] together have even parity — note `C` is not yet
     set, so parity gets fixed up again in stage 2).

2. **`GetChunkInternal()`** (`soundbasedevice.cpp:790-827`) runs once per
   DMA chunk. For each 384-subframe IEC958 block in the chunk:
   - for subframes 0..39 × 2 (first 40 frames on both channels), overlays
     the channel-status `C` bit from `m_uchIEC958Status[]` and re-computes
     parity;
   - for subframe 0 (start of block) on both channels, ORs in the B-frame
     preamble `0x0F`.

The resulting buffer is what DMA writes, word by word, into `MAI_DATA`.

### Polling-mode alternative

There is also a polling mode (`CHDMISoundBaseDevice` one-arg constructor,
plus `IsWritable()` + `WriteSample()` at `hdmisoundbasedevice.cpp:337-364`).
It writes fully-framed sub-frames one at a time to `MAI_DATA` after
checking `!(MAI_CONTROL.Full)`. For spectrum4 this is the simpler approach
if DMA is not already wired up — latency is higher and CPU cost much
higher, but it avoids all DMA plumbing.


## 9. Stop / teardown sequence

`Cancel()` → `StopHDMI()` (`hdmisoundbasedevice.cpp:450-464`):

```c
// Disable MAI (Enable cleared), keep Delayed + error clears
write32(MAI_CONTROL, (1 << 15) | (1 << 2) | (1 << 1));

// Power down PHY audio block
write32(TX_PHY_POWER_DOWN_CTL,
        read32(TX_PHY_POWER_DOWN_CTL) | (1 << 4));
```

`ResetHDMI()` (`hdmisoundbasedevice.cpp:516-532`), called from the
destructor:

```c
// Remove audio InfoFrame from broadcast
write32(RAM_PACKET_CONFIG,
        read32(RAM_PACKET_CONFIG) & ~(1 << 4));
wait_for_bit(RAM_PACKET_STATUS, (1 << 4), 0, 100);

// Reset/flush MAI
write32(MAI_CONTROL, 1);           // Reset
write32(MAI_CONTROL, 1 << 1);      // clear ErrorFull
write32(MAI_CONTROL, 1 << 9);      // Flush
```


## 10. Porting checklist for spectrum4

Things you will need to build or confirm already exist:

- [ ] **HDMI video up with audio-capable sink**.
      `RAM_PACKET_CONFIG` bit 16 must read as 1 before you touch audio. If
      spectrum4 doesn't yet bring up an HDMI framebuffer, that has to
      happen first — it's done via the VideoCore mailbox
      (`PROPTAG_ALLOCATE_BUFFER`, `PROPTAG_SET_PHYSICAL_WIDTH_HEIGHT`, etc.).
- [ ] **Mailbox** for `PROPTAG_GET_CLOCK_RATE` with `CLOCK_ID_PIXEL_BVB = 14`.
      Fallback: assume 75 MHz.
- [ ] **DMA engine**. BCM2711 DMA-Lite channel (driver default) or normal
      DMA channel with DREQ = 10, cyclic 2-buffer config. If spectrum4
      doesn't have DMA support yet, start with polling mode (§8 final
      paragraph) and add DMA later.
- [ ] **Sample-rate handling**. Pick one rate (48 kHz is simplest, matches
      most displays) and hard-code the M/N, N/CTS, and `MAI_FORMAT` values
      rather than porting the rational-approximation algorithm.
      At 48 kHz, 108 MHz audio clock, 75 MHz pixel clock:
      - `Fs × 128 = 6 144 000` → MAI: `audio_clk / Fs = 2250` →
        `rational_best_approximation(2250, 1, 0xFFFFFF, 0x100)` →
        `N = 2250, M = 1` so `MAI_SAMPLERATE = (2250 << 8) | 0 = 0x0008CA00`.
      - HDMI: `N = 6 144 000 / 1000 = 6144`;
        `CTS = 75 000 000 × 6144 / 6 144 000 = 75000`.
- [ ] **IEC958 framer**. Three pieces:
      1. Build the 5 channel-status bytes once at startup (see §8 table).
      2. For each source sample, produce a sub-frame word: shift data into
         bits 27..4, OR in `C` (if appropriate), OR in `0x0F` preamble on
         frame 0, compute parity → bit 31.
      3. Emit 384 sub-frames per IEC958 block (192 frames × 2 channels).
- [ ] **Cache maintenance**. Before handing a DMA buffer to the engine,
      `CleanAndInvalidateDataCacheRange()` over the buffer range
      (`dma4channel.cpp:354`). Not needed in polling mode.
- [ ] **HDMI0 only**. Don't try to parameterise for HDMI1 — it's a separate
      register block that this driver does not touch.


## 11. Shortest path to "hello tone"

The minimum viable first step, if you want to validate the register
sequence before building out DMA:

1. Bring up HDMI video (framebuffer) via the mailbox, as you already do for
   display output. Confirm `RAM_PACKET_CONFIG & (1 << 16) != 0`.
2. Hard-code for 48 kHz stereo PCM. Precompute and cache the 384 sub-frames
   of one IEC958 block containing a 1 kHz sine (48 samples per cycle × 10
   cycles × 2 channels = 960 sub-frames; round up to a multiple of 384 by
   filling three blocks = 1152 sub-frames, or just play 2 blocks = 768).
3. Run the init in §7 steps 1–4 and 6–7 (skip DMA in step 5; use polling).
4. Loop: spin on `IsWritable()` (`!(MAI_CONTROL & (1 << 11))`), then
   `write32(MAI_DATA, next_subframe)`; wrap the pre-built sub-frame array
   at block boundaries.

If you hear a clean tone through the monitor speakers, you've proven the
clocks, InfoFrame, PHY power-up, and IEC958 framing are all correct, and
adding DMA becomes a bandwidth/CPU optimisation rather than a functional
change.
