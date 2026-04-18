# DMA on the Raspberry Pi 400 (BCM2711)

Companion to `hdmi-sound.md`. Covers the three DMA engines available on
the BCM2711, how to choose between them, and a register-level setup
reference for the two that matter to us (DMA-Lite and DMA4).

Sources — all in `~/git/circle`, plus `Broadcom BCM2711 ARM Peripherals.pdf`
in `~/docs/`:

| File | Role |
|------|------|
| `include/circle/dmacommon.h` | Legacy DMA register offsets + DREQ enum |
| `include/circle/dmachannel.h` | Legacy DMA public interface |
| `lib/dmachannel.cpp` | Legacy DMA (channels 0–10) implementation |
| `include/circle/dma4channel.h` | DMA4 public interface + control block layout |
| `lib/dma4channel.cpp` | DMA4 implementation, full register map |
| `include/circle/machineinfo.h` | Channel allocator + per-SoC channel limits |
| `lib/machineinfo.cpp` | Default channel-availability bitmap, DTB overrides |
| `include/circle/bcm2711int.h` | DMA IRQ numbers (GIC SPIs) on Pi 4 |
| `include/circle/bcm2835.h` | `ARM_DMA_BASE`, `GPU_IO_BASE`, `BUS_ADDRESS()` |

Scope: driving audio to the HDMI MAI FIFO. The same engines handle xHCI,
SD, framebuffer, etc., and the channel-allocation story generalises.


## 1. Three DMA engines on BCM2711

The ARM cores on the Pi 400 see three distinct DMA engines, all mapped
into the same peripheral register block (`ARM_DMA_BASE = ARM_IO_BASE +
0x7000 = 0xFE007000`), one 256-byte window per channel.

### 1.1 Channel map

| Channels | Engine  | Control-block format | Peripheral address width |
|----------|---------|----------------------|--------------------------|
| 0–6      | **Legacy "normal" DMA** | 8 × u32 (32 bytes) | 32-bit bus (30-bit RAM) |
| 7–10     | **DMA-Lite**            | 8 × u32 (32 bytes) | 32-bit bus (30-bit RAM) |
| 11–14    | **DMA4** ("large address") | 8 × u32 (64 bytes) | 40-bit physical |

Channels 0–10 share one hardware design — the "Lite" channels are just
smaller (fewer internal buffers, no 2D mode) and are gated by the
`DEBUG.LITE` bit (`lib/dmachannel.cpp:152-153, 197, 238`). They're programmed
the same way.

Channels 11–14 are the genuinely new DMA4 engine introduced on BCM2711:
40-bit addressing, wider internal datapaths, different control-block
layout.

### 1.2 Which channels ARM can actually use

Some channels are owned by the VideoCore firmware. The default Circle
availability bitmap for Pi 4 is `0x71F5` (`machineinfo.cpp:171`):

```
bit 0 = ch 0  (1 = free)            0x71F5 = 0111 0001 1111 0101
bit 1 = ch 1  (0 = VPU)                      └──── ch 14 free
…                                             └── ch 12,13 free
bit 14 = ch 14                                 └── ch 11 = VPU
```

Decoded: channels 0, 2, 4, 5, 6, 7, 8, 12, 13, 14 are free. Channels 1,
3, 9, 10, 11, 15 are claimed by VC firmware by default. **The DTB can
override this** — Circle queries the `brcm,dma-channel-mask` property and
`PROPTAG_GET_DMA_CHANNELS` mailbox tag before trusting the default
(`machineinfo.cpp:200-225`). spectrum4 should do the same if we want to
be robust to firmware-version changes; otherwise just picking one of
`{7, 8, 12, 13, 14}` is reliably safe on Pi 400.

### 1.3 IRQ routing on Pi 4

From `bcm2711int.h:37-51`:

| Channel | GIC SPI | Note |
|---------|---------|------|
| 0   | 80 | |
| 1   | 81 | |
| 2   | 82 | |
| 3   | 83 | |
| 4   | 84 | |
| 5   | 85 | |
| 6   | 86 | |
| 7,8 | 87 | **shared** — ISR must check per-channel status |
| 9,10| 88 | **shared** |
| 11  | 89 | dedicated |
| 12  | 90 | dedicated |
| 13  | 91 | dedicated |
| 14  | 92 | dedicated |

All are SPIs (shared peripheral interrupts) on the GIC-400. They're
level-triggered and routed to all four A72 cores by default in Circle;
spectrum4's GIC configuration (in `irq.s`) has the same routing.


## 2. Choosing an engine for HDMI audio

### 2.1 The workload

- **Transfer size per buffer**: Circle's default is `3840 × 4 = 15 360`
  bytes (80 ms of stereo 24-bit-in-32-bit at 48 kHz). Even 200 ms
  chunks are only ~38 KB.
- **Steady-state bandwidth**: 48 000 × 2 × 4 = 384 KB/s. Trivial for
  any engine.
- **Access pattern**: cyclic writes to a single peripheral register
  (`MAI_DATA`) paced by DREQ 10 (HDMI audio FIFO watermark).
- **Latency target**: we want completion IRQs often enough to refill
  the other half of the ping-pong before it underruns. With 80 ms
  buffers, we have tens of milliseconds of slack per refill.

### 2.2 Pros and cons

#### DMA-Lite (channels 7–10) — matches Circle's choice

**Pros.**
- Simple, well-understood: same register layout as legacy DMA, smaller
  control block (32 bytes), 32-bit addressing throughout.
- Plenty of capacity: 64 KB per-transfer max is 4× our worst-case chunk.
- `BUS_ADDRESS()` macro handles RAM addressing — same pattern as
  anywhere else on the chip.
- Usually free (VPU rarely takes these). On Pi 4, channels 7 and 8 are
  both in the default free mask.
- Matches Circle, so porting is a straight transcription.

**Cons.**
- Shared IRQ: channels 7+8 share SPI 87, channels 9+10 share SPI 88.
  Not a problem if we only use one of each pair, but the ISR has to
  read the per-channel `CS.INT` bit to know which fired.
- **Requires buffers in the low 1 GB of physical RAM.** The
  `BUS_ADDRESS` macro does `addr & ~0xC0000000 | GPU_MEM_BASE`, which
  only produces correct results for physical addresses < 0x40000000.
  On a 4 GB Pi 400 this matters — any buffer above 1 GB is unreachable.
- No 2D mode (Lite limitation, irrelevant for audio).
- Max 64 KB per transfer (plenty for audio; would matter for framebuffer
  DMAs).

#### Legacy "normal" DMA (channels 0–6)

**Pros over Lite.**
- Supports 2D memory-copy mode.
- Transfers up to 1 GB per CB.
- Slightly higher bandwidth ceiling (wider internal buffers).

**Cons vs Lite.**
- Same 30-bit RAM address limit (same `BUS_ADDRESS()` macro).
- Channels 1, 3, 5 frequently taken by VC.
- Dedicated IRQs per channel, but there's no real reason to prefer
  these for audio over Lite — the extra capability is wasted.

**Verdict for audio**: not worth the churn. Save these for heavier
DMA consumers (framebuffer, xHCI) that actually need the capacity or
the 2D mode.

#### DMA4 (channels 11–14) — the "large address" engine

**Pros.**
- **40-bit addressing.** Buffers can live anywhere in physical RAM,
  including above 1 GB. On a 4 GB Pi 400 this removes a whole class
  of bugs where heap allocations happen to land above the 1 GB line.
- Dedicated IRQ per channel — ISR can be simpler.
- Bigger transfers (up to 1 GB per CB), wider internal datapaths.
- Channels 12–14 free by default.

**Cons.**
- New control-block format (64 bytes, separate source/dest info words,
  `ADDRESS4_LOW`/`ADDRESS4_HIGH` split). More fields to get right.
- Peripheral addressing uses a different convention:
  `(ioaddr & 0xFFFFFF) + GPU_IO_BASE` for the low 32 bits, plus a fixed
  `FULL35_ADDR_OFFSET = 0x04` in the top bits (`dma4channel.cpp:291`).
  Legacy uses the `BUS_ADDRESS()` macro for RAM and the same mask-and-
  add for I/O.
- Channel 11 is claimed by VPU; don't use it.
- Control-block pointer in `CONBLK_AD` is pre-shifted (`>> 5`), unlike
  legacy where it's a raw bus address.
- Register offsets within the 256-byte channel window are different
  from legacy (see §3.2).

### 2.3 Decision criteria

Answer these in order:

1. **Will buffers live below 1 GB of physical RAM?** If yes, DMA-Lite
   works. If no (or "unknown / depends on heap allocation order"),
   must use DMA4.
2. **Will any single transfer exceed 64 KB?** If yes, use legacy
   normal or DMA4 — Lite can't do it. For audio we're comfortably
   under this threshold.
3. **Do we care about ISR simplicity?** Lite shares IRQs; DMA4 doesn't.
   With only one audio channel this is a wash.
4. **Is there a specific channel we want?** If yes, request it
   explicitly. Otherwise use the "give me any free Lite channel"
   (resp. DMA4 channel) allocation pattern.

### 2.4 Recommendation for spectrum4 HDMI audio

**Use a DMA4 channel (12, 13, or 14).**

Rationale specific to spectrum4:

- The Pi 400 always has 4 GB of RAM. spectrum4's heap / coherent region
  may or may not stay below 1 GB depending on how memory is laid out
  today *and* how it grows. Committing to DMA4 up-front removes the
  "works until the heap happens to cross 1 GB" failure mode and avoids
  the 30-bit-allocator complication.
- The xHCI coherent region already exists; putting audio buffers there
  costs nothing extra. DMA4 can reach that region regardless of where
  it lives.
- We only need one channel, and three are free (12, 13, 14).
- The control-block format, while larger, is arguably cleaner —
  source/dest info are separated, and the 40-bit address split is
  explicit.

Circle chose Lite because its HDMI audio driver dates from the Pi 3
era and was ported forward; on Pi 4 it relies on control blocks living
in low memory (`new (HEAP_DMA30) TDMAControlBlock`). spectrum4 doesn't
have that heap distinction yet, and building around the 30-bit limit
from day one is not worth it.

The rest of this doc covers DMA4 in detail. §5 has a one-page summary
of Lite in case you disagree with the recommendation.


## 3. DMA4 register reference (channels 11–14)

All offsets given as absolute Pi 4 addresses. Source:
`lib/dma4channel.cpp:29-98`.

### 3.1 Channel base address

```
channel_base(n) = ARM_DMA_BASE + n × 0x100
                = 0xFE007000   + n × 0x100
```

- Channel 12 base: `0xFE007C00`
- Channel 13 base: `0xFE007D00`
- Channel 14 base: `0xFE007E00`

### 3.2 Per-channel register offsets

All offsets relative to the per-channel base.

| Offset | Name           | Role |
|--------|----------------|------|
| 0x00   | `CS`           | Control & status |
| 0x04   | `CONBLK_AD`    | Next control block address (**pre-shifted right 5**) |
| 0x0C   | `DEBUG`        | Version / reset |
| 0x10   | `TI`           | Transfer info (copied from CB on start) |
| 0x14   | `SOURCE_AD`    | Source address low 32 bits |
| 0x18   | `SOURCE_INFO`  | Source stride/size/burst/high-addr |
| 0x1C   | `DEST_AD`      | Destination address low 32 bits |
| 0x20   | `DEST_INFO`    | Destination stride/size/burst/high-addr |
| 0x24   | `LEN`          | Transfer length |
| 0x28   | `NEXTCONBK`    | Next control block (on EOCB cycling) |

Two global registers at `ARM_DMA_BASE + 0xFE0` and `+0xFF0`:
- `DMA_INT_STATUS` (0xFE007FE0): bit-per-channel interrupt-pending.
  Write the bit back to clear.
- `DMA_ENABLE` (0xFE007FF0): bit-per-channel global enable. Must be 1
  for the channel to run.

### 3.3 `CS` bit layout (0xFE007*00)

| Bit | Name | Meaning |
|-----|------|---------|
| 0   | `ACTIVE`        | Channel running. Write 1 to start; hardware clears on completion. |
| 1   | `END`           | Set when the last CB in a chain completed. Write 1 to clear. |
| 2   | `INT`           | IRQ pending for this channel. Write 1 to clear. |
| 10  | `ERROR`         | Transfer error. Read-only; cleared by resetting the channel. |
| 16–19 | `QOS`         | Normal arbitration priority (4 bits). Circle uses 1. |
| 20–23 | `PANIC_QOS`   | Elevated priority when DREQ is asserted in panic (4 bits). Circle uses 15. |
| 28  | `WAIT_FOR_OUTSTANDING_WRITES` | Block completion until all writes drain. Set for safety. |
| 30  | `ABORT`         | Abort current transfer. |
| 31  | `HALT`          | Stop at end of current burst (for clean pause). |

Start sequence: write CB address to `CONBLK_AD`, then write CS =
`WAIT_FOR_OUTSTANDING_WRITES | (PANIC_QOS=15 << 20) | (QOS=1 << 16) |
ACTIVE` (`dma4channel.cpp:460-463`).

### 3.4 `TI` bit layout (transfer info)

Copied here on start from the control block's `nTransferInformation`:

| Bit | Name | Meaning |
|-----|------|---------|
| 0   | `INTEN`     | Raise IRQ on completion (set when a completion routine is registered). |
| 1   | `TDMODE`    | 2D mode (stride-and-count). Not used for audio. |
| 2   | `WAIT_RESP` | Wait for write response from destination before moving on. **Set this for peripheral writes.** |
| 3   | `WAIT_RD_RESP` | Wait for read response. **Set this for peripheral reads.** |
| 9–13 | `PERMAP`   | DREQ number (see `dmacommon.h:26-48`). HDMI audio = 10. |
| 14  | `SRC_DREQ`  | Pace reads from DREQ line. Set for peripheral→RAM. |
| 15  | `DEST_DREQ` | Pace writes from DREQ line. **Set for audio** (RAM→MAI FIFO). |

### 3.5 `SOURCE_INFO` / `DEST_INFO` bit layout

Shared layout; source and dest have identical fields.

| Bits | Name | Meaning |
|------|------|---------|
| 0–7  | `ADDR_HIGH`    | Physical address bits [39:32]. `0x04` for peripheral destinations (see §3.6). |
| 8–11 | `BURST_LEN`    | Beats per burst (0 = single-beat, up to 15 = 16 beats). |
| 12   | `INC`          | Increment address per beat. Set for RAM, clear for peripheral FIFOs. |
| 13–14 | `SIZE`        | Transfer size per beat: `0 = 32-bit`, `1 = 64-bit`, `2 = 128-bit`. |
| 15   | `IGNORE`       | Discard reads / suppress writes (ignored for normal transfers). |
| 16–31 | `STRIDE`      | 16-bit stride, 2D mode only. |

### 3.6 Peripheral address convention (critical)

DMA4 sees a **35-bit physical address space** where:
- ARM-side peripheral MMIO sits in the top bits with a fixed prefix.
- The prefix for "ARM I/O accesses via DMA" is `FULL35_ADDR_OFFSET = 0x04`
  in the `ADDR_HIGH` byte.
- The low 32 bits come from the ARM I/O address, but with the top 8
  bits masked off and `GPU_IO_BASE = 0x7E000000` added instead
  (`dma4channel.cpp:271-273, 313-315`).

So to target `MAI_DATA = 0xFEF2001C` (the HDMI audio FIFO):

```c
u32 dest_low  = (0xFEF2001C & 0xFFFFFF) | 0x7E000000 - 0x7E000000;
                                                    // the mask+add reduces to:
u32 dest_low  = (0xFEF2001C & 0xFFFFFF) + 0x7E000000
              =  0x00F2001C             + 0x7E000000
              =  0x7EF2001C;
u8  dest_high = 0x04;              // FULL35_ADDR_OFFSET
```

This translation is not symmetric with legacy DMA. Legacy uses the same
`(ioaddr & 0xFFFFFF) + GPU_IO_BASE` for the destination register, but
packs the high 32 bits of the address straight into the DEST_INFO field
(`dma4channel.cpp:338` for the non-Pi-4 path).

**For RAM**: just use the physical address directly. DMA4 sees physical
addresses, not bus addresses. `ADDRESS4_LOW(p) = (uintptr)p & 0xFFFFFFFF`
and `ADDRESS4_HIGH(p) = ((uintptr)p >> 32) & 0xFF`
(`dma4channel.cpp:104-106`). No `BUS_ADDRESS()` dance.


## 4. DMA4 control block

64 bytes, 32-byte aligned. Layout from `dma4channel.h:34-45`:

```c
struct TDMA4ControlBlock
{
    u32  nTransferInformation;      // → TI register
    u32  nSourceAddress;            // → SOURCE_AD (low 32 bits)
    u32  nSourceInformation;        // → SOURCE_INFO
    u32  nDestinationAddress;       // → DEST_AD (low 32 bits)
    u32  nDestinationInformation;   // → DEST_INFO
    u32  nTransferLength;           // → LEN
    u32  nNextControlBlockAddress;  // address >> 5 (for cyclic chaining)
    u32  nReserved;                 // must be 0
} PACKED;
```

`nNextControlBlockAddress` is stored **pre-shifted** (value = address >> 5),
because the DMA engine loads it directly into the `CONBLK_AD` register,
and that register's layout is `[address_bits 39:5] << 5` in bits [34:0].
See `dma4channel.cpp:344-345, 457-458`.

### 4.1 Cyclic chain for the HDMI audio ring

Two control blocks, each pointing to the other:

```
┌─ CB[0] ────────────┐      ┌─ CB[1] ────────────┐
│ TI = DEST_DREQ |   │      │ TI = DEST_DREQ |   │
│      DREQ=10  |   │      │      DREQ=10  |   │
│      WAIT_RD  |   │      │      WAIT_RD  |   │
│      WAIT_RESP|   │      │      WAIT_RESP|   │
│      INTEN        │      │      INTEN        │
│ SRC = &buf[0]     │      │ SRC = &buf[1]     │
│ SRC_INFO = SIZE_128,     │ SRC_INFO = SIZE_128,│
│   INC, BURST=0,          │   INC, BURST=0,    │
│   high = buf[0] >> 32    │   high = buf[1] >> 32 │
│ DST = 0x7EF2001C  │      │ DST = 0x7EF2001C  │
│ DST_INFO = SIZE_32, │    │ DST_INFO = SIZE_32, │
│   !INC, high = 0x04 │    │   !INC, high = 0x04 │
│ LEN = 15360       │      │ LEN = 15360       │
│ NEXT = CB[1] >> 5 │◀────▶│ NEXT = CB[0] >> 5 │
└───────────────────┘      └───────────────────┘
```

Source: `dma4channel.cpp:305-361`.


## 5. Lite / legacy quick reference (channels 0–10)

If you decide to use Lite instead of DMA4, here's the short version.
Full detail in `dmacommon.h:58-103` and `dmachannel.cpp`.

### 5.1 Control block (32 bytes)

```c
struct TDMAControlBlock
{
    u32  nTransferInformation;
    u32  nSourceAddress;            // bus address (bits 30-31 cleared, OR'd with GPU_MEM_BASE)
    u32  nDestinationAddress;       // bus address
    u32  nTransferLength;
    u32  n2DModeStride;
    u32  nNextControlBlockAddress;  // bus address (not shifted)
    u32  nReserved[2];              // must be 0
} PACKED;
```

### 5.2 Addressing

Use the `BUS_ADDRESS()` macro for **both** RAM and control-block
pointers (`bcm2835.h:57`):

```c
#define BUS_ADDRESS(addr) (((addr) & ~0xC0000000) | GPU_MEM_BASE)
// GPU_MEM_BASE = 0 on BCM2711 (uncached, coherent path)
```

This limits buffers to the first 1 GB of physical RAM.

For peripheral I/O (e.g. `MAI_DATA`): same as DMA4 — mask low 24 bits,
add `GPU_IO_BASE = 0x7E000000`. No high-address byte needed.

### 5.3 Transfer info bits (see `dmacommon.h:75-87`)

| Bit | Name | Audio value |
|-----|------|-------------|
| 0    | `INTEN`       | 1 |
| 1    | `TDMODE`      | 0 |
| 3    | `WAIT_RESP`   | 1 |
| 4    | `DEST_INC`    | 0 (FIFO) |
| 5    | `DEST_WIDTH`  | 0 (32-bit) |
| 6    | `DEST_DREQ`   | 1 |
| 8    | `SRC_INC`     | 1 |
| 9    | `SRC_WIDTH`   | 1 (128-bit where supported; 0 on Lite) |
| 10   | `SRC_DREQ`    | 0 |
| 11   | `SRC_IGNORE`  | 0 |
| 12–15 | `BURST_LENGTH` | 0 (use default) |
| 16–20 | `PERMAP`     | 10 (HDMI) |

### 5.4 Global + per-channel registers

- `CS(n)`           = `ARM_DMA_BASE + n·0x100 + 0x00`
- `CONBLK_AD(n)`    = `ARM_DMA_BASE + n·0x100 + 0x04` (raw bus address, not shifted)
- `TI(n)`           = offset 0x08
- `SOURCE_AD(n)`    = offset 0x0C
- `DEST_AD(n)`      = offset 0x10
- `TXFR_LEN(n)`     = offset 0x14
- `STRIDE(n)`       = offset 0x18
- `NEXTCONBK(n)`    = offset 0x1C
- `DEBUG(n)`        = offset 0x20 (bit 28 = `LITE`)
- `DMA_INT_STATUS`  = `ARM_DMA_BASE + 0xFE0`
- `DMA_ENABLE`      = `ARM_DMA_BASE + 0xFF0`

### 5.5 Lite-specific limits

- `TXFR_LEN_MAX_LITE = 0xFFFF` (64 KB – 1 per transfer).
- No 2D mode.
- Shared IRQ: channels 7+8 on SPI 87, channels 9+10 on SPI 88.


## 6. Setup sequence for the HDMI audio ring (DMA4)

Assumes:
- One DMA4 channel has been claimed (e.g. channel 13).
- Two audio buffers `buf[0]`, `buf[1]`, each `LEN` bytes, live somewhere
  in coherent memory (physical addresses known).
- Two control blocks `cb[0]`, `cb[1]` live in coherent memory, 32-byte
  aligned (the address must have its low 5 bits clear so the pre-shift
  is lossless).

### 6.1 One-time channel bring-up

```c
#define CH   13
#define BASE (0xFE007000 + CH * 0x100)

// 1. Initial CONBLK_AD = 0 (no active block yet).
write32(BASE + 0x04, 0);

// 2. Global enable for this channel.
u32 en = read32(0xFE007FF0);
write32(0xFE007FF0, en | (1 << CH));
udelay(1000);

// 3. Reset the channel (DEBUG bit 23 self-clears).
write32(BASE + 0x0C, (1 << 23));
udelay(1000);

// 4. Wire up the IRQ. For channel 13 → GIC SPI 91 = IRQ 91+32 = 123.
gic_enable_spi(91);
gic_route_spi_to_cpu(91, 0);   // pick whichever core should handle it
install_isr(91, audio_dma_isr);
```

### 6.2 Fill the two control blocks

```c
void fill_cb(struct dma4_cb *cb, void *buf, struct dma4_cb *next) {
    cb->ti =   (1 << 15)       // DEST_DREQ
             | (10 << 9)       // PERMAP = HDMI
             | (1 << 3)        // WAIT_RD_RESP
             | (1 << 2)        // WAIT_RESP
             | (1 << 0);       // INTEN

    cb->src_ad   = (u32)((u64)buf & 0xFFFFFFFF);
    cb->src_info =   (2 << 13)                   // SIZE_128
                   | (1 << 12)                   // INC
                   | (0 << 8)                    // BURST = 0
                   | (((u64)buf >> 32) & 0xFF);  // high address bits

    cb->dst_ad   = 0x7EF2001C;                   // MAI_DATA
    cb->dst_info =   (0 << 13)                   // SIZE_32
                   | (0 << 12)                   // no INC
                   | (0 << 8)                    // BURST = 0
                   | 0x04;                       // FULL35 offset for peripheral

    cb->len  = LEN;                              // bytes
    cb->next = ((u64)next) >> 5;                 // pre-shifted!
    cb->reserved = 0;
}

fill_cb(&cb[0], buf[0], &cb[1]);
fill_cb(&cb[1], buf[1], &cb[0]);

// Make the CBs visible to the DMA engine.
dc_clean_range(&cb[0], sizeof cb[0]);
dc_clean_range(&cb[1], sizeof cb[1]);
dc_clean_range(buf[0], LEN);
dc_clean_range(buf[1], LEN);
```

### 6.3 Start

```c
// Point the channel at CB[0] (pre-shifted).
write32(BASE + 0x04, ((u64)&cb[0]) >> 5);

// Kick it: WAIT_FOR_OUTSTANDING_WRITES | PANIC_QOS=15 | QOS=1 | ACTIVE.
write32(BASE + 0x00,
          (1  << 28)
        | (15 << 20)
        | (1  << 16)
        | (1  << 0));
```

From now on the DMA engine reads `buf[0]` into `MAI_DATA` at the rate
the HDMI MAI DREQs for. When it hits the end of `buf[0]`, it follows
`cb[0].next` to `cb[1]`, which targets `buf[1]`, and so on cyclically.

### 6.4 Completion IRQ

Each CB fires `INTEN` at end of transfer (because we set TI bit 0).
The ISR:

```c
void audio_dma_isr(void) {
    // Clear global int status for this channel.
    write32(0xFE007FE0, 1 << CH);

    // Clear per-channel INT bit (write-back of read value).
    u32 cs = read32(BASE + 0x00);
    write32(BASE + 0x00, cs);

    // Error check (bit 10 of CS).
    if (cs & (1 << 10)) { audio_dma_error(); return; }

    // Figure out which buffer just completed.
    // Options: (a) track parity in software ("last was 0, so now 1");
    //          (b) read CONBLK_AD to see which CB is *next* up and
    //              deduce which just finished.
    // (a) is simpler and sufficient.
    unsigned just_finished = current_cb; current_cb ^= 1;

    refill_buffer(just_finished);
    dc_clean_range(buf[just_finished], LEN);
}
```

Circle's ISR does exactly this (`dma4channel.cpp:514-559`).

### 6.5 Stop

```c
// Clean halt: bit 30 ABORT or bit 31 HALT, then poll bit 0.
write32(BASE + 0x00, (1 << 30));
while (read32(BASE + 0x00) & 1) { /* spin */ }

// Reset to clear state.
write32(BASE + 0x0C, (1 << 23));
```


## 7. Integration with spectrum4's coherent region

Things to confirm / set up in spectrum4 before the HDMI audio ring will
work:

- [ ] **Control blocks live in coherent (non-cached or explicitly
  managed) memory.** Putting them in the xHCI coherent region is fine;
  they're 64 bytes each, alignment 32 bytes. Two CBs = 128 bytes total.
- [ ] **Audio buffers live in coherent memory.** Two × 15 360 bytes =
  30 KB. Same coherent region is fine.
- [ ] **Physical addresses are known.** DMA4 uses physical addresses
  directly; spectrum4's MMU setup needs to expose the physical address
  of any coherent allocation. (xHCI already does this — use the same
  machinery.)
- [ ] **Cache maintenance.** If the coherent region is mapped as
  device / non-cached memory (as it likely is for xHCI compatibility),
  no explicit `dc civac` needed. If it's normal cached memory, we have
  to clean the CBs after every modification and clean the audio buffer
  after every refill.
- [ ] **GIC SPI routing.** Decide which core handles the DMA IRQ.
  On-the-boot-CPU is simplest; multi-core becomes relevant later.
- [ ] **Channel allocation.** Either:
  - hardcode channel 13 (simple, works), or
  - read `PROPTAG_GET_DMA_CHANNELS` from the mailbox and pick any bit
    in the range 12–14 (robust against firmware changes).


## 8. Testing without audio

DMA4 can be exercised independently of HDMI before wiring up audio:

- **Memcpy test**: configure CB with `TI = 0` (no DREQ, no direction
  bits), source & dest both incrementing in RAM, run one-shot. Confirm
  bytes copy. This validates register offsets, CS start sequence, IRQ
  routing, cache coherency.
- **I/O write at low rate**: point DEST at `GPIO_SET` / `GPIO_CLR`,
  source at a small pattern buffer, DREQ = 0. Toggles a GPIO at full
  DMA speed. Useful for scoping the output and measuring latency.
- **Paced by known DREQ**: once memcpy works, swap to a DREQ-paced
  write to e.g. the PCM FIFO (DREQ = 2) with a DC offset pattern.
  Doesn't require HDMI to be up, so it's a cleaner first test than the
  full audio pipeline.

Any of these is a reasonable milestone before §7's audio ring.
