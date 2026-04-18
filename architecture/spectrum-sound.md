# ZX Spectrum sound hardware — 48K and 128K

Companion to `hdmi-sound.md`. This document describes how the original
Sinclair machines generate sound, so that we can decide what the spectrum4
emulator needs to feed into the Pi 400's HDMI audio pipeline.

Primary sources (all in-tree, no external lookup required):

- `src/spectrum128k/roms/rom1.s:1700-1803` — the **48K BEEPER routine**,
  including annotated timing (Alvin Albrecht's documented disassembly).
- `src/spectrum128k/roms/rom0.s:158-208` — **128K AY-3-8912 overview**
  (port map, register summary).
- `src/spectrum128k/roms/rom0.s:19095-19272` — **full AY-3-8912 register
  reference** with formulas for tone / noise / envelope periods.

Scope: output only. Microphone (tape) input is out of scope for now.


## 1. Two completely different sound architectures

| Feature | 48K (Issue 1–3) | 128K (+2/+3/128) |
|---------|-----------------|------------------|
| Sound chip | *none* — beeper driven by CPU | AY-3-8912 PSG |
| Output port | `0xFE` bit 4 (EAR) + bit 3 (MIC) | AY via `0xFFFD`/`0xBFFD`; still has beeper on `0xFE` |
| Channels | 1, single-bit | 3 tone + 1 noise, 4-bit volume each, hardware envelope |
| Bit depth | 1 bit (two-level square wave) | 4 bits logarithmic per channel |
| Waveform | Software-timed square wave | Hardware-generated square wave + LFSR noise + envelope |
| Audio clock | CPU-driven (3.5 MHz timing loops) | 1.77345 MHz (= CPU/2) |
| Mixing | None needed | Summing of 3 channels (+ noise) per sample |
| Dedicated audio CPU load | ~100% while beep active | ~0 (chip runs autonomously) |

**The 128K keeps the 48K beeper too.** Port `0xFE` still works and many
games use both — e.g. AY music plus a beeper-driven sampled drum hit.
The final audio is the *sum* of the beeper output and the AY output. Our
emulator has to mix both sources.


## 2. The 48K beeper

### 2.1 Port `0xFE` output bit layout

A single 8-bit port carries border colour, MIC (tape) output, and speaker
output packed together:

```
 bit 7   6   5   4    3    2   1   0
 ┌───┬───┬───┬────┬────┬───┬───┬───┐
 │ – │ – │ – │EAR │MIC │ B2│ B1│ B0│
 └───┴───┴───┴────┴────┴───┴───┴───┘
              speaker  tape   border
```

- **bits 0–2**: border colour (written as a group to `0xFE`).
- **bit 3 (MIC)**: also the "loud speaker" bit — when set, slightly boosts
  the output level seen at the jack (some games exploit this for a crude
  2-bit DAC by driving EAR+MIC together; see §2.4).
- **bit 4 (EAR)**: the main speaker bit. Drives a small internal
  loudspeaker (and the EAR line on the tape socket).

The CPU generates tones by toggling bit 4 in software. There's no internal
oscillator — every transition costs an `OUT (0xFE), A` instruction.

### 2.2 BEEPER routine (`rom1.s:1739-1803`)

The ROM exposes one routine, `BEEPER`, that plays a square wave:

- Input: `HL` = tone period (in T-states, encoded), `DE` = cycle count – 1.
- Output: a 50%-duty-cycle square wave on bit 4 of `0xFE` of exactly
  `DE+1` cycles at the chosen period.

The tone period is encoded so the coarse/medium/fine bits decompose into a
simple formula:

```
Tp (T-states) = 236 + 2048·H + 8·L       (where L's fine bits select
                                          0–3 NOPs in the inner loop)
```

Worked example from the ROM comment:
```
Middle C  → 261.624 Hz
Tp(ms)    = 1/f = 3.822 ms
Tp(T)     = Tp(ms) × 3.5 MHz = 13378 T-states
HL        = (Tp − 236) / 8   = 1643 = 0x066B
DE        = 5 s × f − 1      = 1307 = 0x051B     (5 s of middle C)
```

Core inner logic (registers omitted):

```asm
loop:
    ; low-time: inner loop counting down BC, padded with 0–3 NOPs via IX
    ...
    xor 0x10          ; toggle EAR bit
    out (0xfe), a     ; flip speaker
    ; high-time: same loop again, plus one extra iteration to equalise
    ...
    dec de
    jp (ix)           ; re-enter inner loop at correct NOP offset
```

**Interrupts are disabled** (`DI`) for the whole duration — any 50 Hz
frame interrupt would distort the output. That also means the beeper
blocks execution for the full duration of the tone.

### 2.3 `BEEP dur, pitch` BASIC command

The BASIC `BEEP` command (`rom1.s:1818` onwards) computes `HL` and `DE`
from `pitch` (semitones from middle C) and `dur` (seconds), then calls
`BEEPER`. Formula:

```
f       = 440 × 2^((pitch − 9)/12)    (standard equal-temperament)
HL      = fCPU / (8·f) − 30.125       (see rom1.s:1905-1908 — note the
                                        off-by-a-fraction ROM bug)
DE      = dur × f − 1
```

(For emulator-level accuracy we can ignore the ROM's HL formula and just
reproduce whatever the Z80 writes to `0xFE`; see §4.)

### 2.4 Multi-level tricks (games)

Several late-1980s games achieved 4 pseudo-amplitudes by driving EAR + MIC
independently. The speaker output voltage for the four (EAR, MIC) states,
roughly:

| EAR | MIC | Nominal level |
|-----|-----|---------------|
|  0  |  0  | 0.00 (silent) |
|  0  |  1  | 0.22 (quiet)  |
|  1  |  0  | 0.64 (normal) |
|  1  |  1  | 1.00 (loud)   |

The exact numbers depend on Issue revision and are not specified — if we
later want fidelity for sampled-sound demos (e.g. "Savage" title music),
we'd use the table above, or the ones documented by WoS. For a first
implementation, just treating bit 4 as the output is fine; bit 3 can be
folded in as a 2-bit DAC later.


## 3. The 128K: AY-3-8912 PSG

### 3.1 Access — I/O ports

The AY has an internal "register selected" latch. Two Z80 I/O ports drive
it (`rom0.s:161-164`):

- `OUT (0xFFFD), reg_number` — select register (0–14).
- `OUT (0xBFFD), value` — write value to selected register.
- `IN  (0xFFFD)` → read the selected register.

The usual sequence is: `OUT 0xFFFD, n` then `OUT 0xBFFD, v`. Reads are
also possible but rare.

Port `0xFE` remains fully functional — the beeper is unchanged.

### 3.2 Chip clock

The AY runs at **1.77345 MHz** on the Spectrum 128 (CPU 3.5469 MHz ÷ 2).
All period counters described below use this as the reference.

### 3.3 Register map (summary; full detail in `rom0.s:19098-19272`)

| Reg | Name                  | Width | Purpose |
|-----|-----------------------|-------|---------|
| 0   | Channel A fine        | 8 bit | low 8 bits of 12-bit tone-A period |
| 1   | Channel A coarse      | 4 bit | high 4 bits of tone-A period |
| 2   | Channel B fine        | 8 bit | tone-B period (low) |
| 3   | Channel B coarse      | 4 bit | tone-B period (high) |
| 4   | Channel C fine        | 8 bit | tone-C period (low) |
| 5   | Channel C coarse      | 4 bit | tone-C period (high) |
| 6   | Noise period          | 5 bit | noise-generator divider |
| 7   | Mixer / IO enable     | 8 bit | per-channel tone+noise enables (active-low) |
| 8   | Channel A volume      | 5 bit | 4-bit level + envelope-follow bit |
| 9   | Channel B volume      | 5 bit | 4-bit level + envelope-follow bit |
| 10  | Channel C volume      | 5 bit | 4-bit level + envelope-follow bit |
| 11  | Envelope period fine  | 8 bit | envelope duration (low) |
| 12  | Envelope period coarse| 8 bit | envelope duration (high) |
| 13  | Envelope shape        | 4 bit | envelope waveform (Hold/Alt/Att/Cont) |
| 14  | I/O port A            | 8 bit | RS232/keypad (not audio) |

### 3.4 How each block produces sound

**Tone generators (ch A/B/C).** Each channel counts the input clock down
by 16, then further down by the 12-bit period register. Output toggles
each time the counter reaches 0 — producing a 50%-duty square wave.

```
f_tone = 1_773_450 / (16 × period)       (period = 1..4095)
       ≈ 27.07 Hz .. 110.84 kHz          (period=4095 .. 1)
```

Period = 0 is often treated as period = 1 by hardware.

**Noise generator.** A 17-bit LFSR (polynomial `x^17 + x^14 + 1`) clocked
by the divided input clock:

```
f_noise_tick = 1_773_450 / (16 × noise_period)     (noise_period = 1..31)
```

At each tick the LFSR shifts; its output is a pseudo-random bit stream
that is ANDed with the per-channel noise-enable bit of register 7.

**Mixer (register 7).** Per-channel gating, **active-low**:

```
 bit 7   6   5   4    3    2   1   0
 ┌───┬───┬───┬───┬────┬───┬───┬───┐
 │ – │IO │NC │NB │NA  │TC │TB │TA │
 └───┴───┴───┴───┴────┴───┴───┴───┘
```

- `TA/TB/TC` = 0 → tone for that channel is enabled.
- `NA/NB/NC` = 0 → noise is ORed in for that channel.
- Channel output = `(tone | T_disable) AND (noise | N_disable)`.
  (If both disabled, channel output is constantly 1 → amplitude = volume.)

**Volume (registers 8/9/10).**
- Bits 0–3: linear 0..15 level.
- Bit 4: if set, **ignore bits 0–3 and follow the envelope** instead.

The 4-bit level maps to a **logarithmic amplitude** (≈ 3 dB/step). The
standard emulator table (from the AY-3-8910 datasheet, normalised to
[0, 1]):

| Level | Amplitude | Level | Amplitude |
|-------|-----------|-------|-----------|
| 0  | 0.0000 |  8 | 0.1131 |
| 1  | 0.0100 |  9 | 0.1600 |
| 2  | 0.0140 | 10 | 0.2263 |
| 3  | 0.0200 | 11 | 0.3200 |
| 4  | 0.0283 | 12 | 0.4525 |
| 5  | 0.0400 | 13 | 0.6400 |
| 6  | 0.0565 | 14 | 0.9051 |
| 7  | 0.0800 | 15 | 1.0000 |

Each step is √2× (≈ 3 dB). For a first implementation, linear `level/15`
is acceptable but sounds thin — prefer the log table above.

**Envelope (registers 11/12/13).** A shared 16-bit downcounter further
divided by 16 produces a 0..15 sawtooth that is then reshaped by the 4-bit
shape selector (Hold / Alternate / Attack / Continue bits). Produces
sawtooth-up, sawtooth-down, triangle, or single-shot variants. Details and
the 10 usable shapes: `rom0.s:19195-19253`.

```
envelope_step_rate = 1_773_450 / (256 × env_period)
f_envelope_cycle   = envelope_step_rate / 16
                   = 1_773_450 / (4096 × env_period)
                   ≈ 0.43 Hz .. 28.3 kHz       (env_period = 65535..1)
```

### 3.5 Final mix

Per-sample output from the chip:

```
ch_i_out = max(tone_i, ~Ti) & max(noise, ~Ni)   for i in {A,B,C}
amp_i    = env_i ? envelope_level : volume_i[0..3]
signal   = (log_amp_table[amp_A] · ch_A_out)
         + (log_amp_table[amp_B] · ch_B_out)
         + (log_amp_table[amp_C] · ch_C_out)
```

The Spectrum 128 outputs this as **mono** (the three channels are summed
to a single output at the machine). Common emulator convention is optional
"ABC" or "ACB" pseudo-stereo panning — purely a cosmetic choice, not
hardware-accurate for the 128 (that was a Pentagon thing).


## 4. What the emulator needs to produce

The HDMI audio sink expects a continuous stream of 24-bit signed PCM
samples at a fixed rate (48 kHz is simplest — see `hdmi-sound.md` §6).
There are two reasonable ways to get from the Spectrum's sound state to
that stream:

### 4.1 Sample-driven (recommended for first pass)

Every 1/48000 s, compute one output sample from the current emulator
state:

1. Advance the Z80 emulator enough T-states to cover 1/48000 s of
   elapsed time (= 73 T-states at 3.5 MHz, 74 T-states at 3.5469 MHz).
   This is already what the core needs to do for frame timing.
2. At the end of that window, read:
   - the current state of port `0xFE` bit 4 (beeper), plus bit 3 if we
     care about 2-bit DAC,
   - the current AY channel outputs (sign of each tone counter, noise
     LFSR state, envelope level).
3. Mix:
   ```
   beeper_contribution = (ear_bit ? 0.5 : 0.0) + (mic_bit ? 0.1 : 0.0)
   ay_contribution     = sum over A/B/C of (amp_table[level_i] × gate_i) / 3
   sample              = clip( (beeper + ay) × full_scale )
   ```
   Tune the gains so the loudest possible combined signal just reaches
   full scale without clipping (e.g. beeper 0.35, each AY channel 0.22).
4. Push the 24-bit sample into the HDMI DMA ring.

This gives sample-rate-limited accuracy: beeper transitions that happen
faster than the Nyquist limit (~24 kHz) will alias. For the beeper that
matters — a 10 kHz beeper square wave has meaningful 30 kHz harmonics
that will fold back. For the AY, the chip's own output is band-limited to
~55 kHz anyway, and 48 kHz is fine for the audible range.

If aliasing artefacts turn out to matter in practice (they didn't for
many emulators — Fuse starts here), move to (4.2).

### 4.2 Event-driven with resampling

Track every write to `0xFE` and every AY register write, time-stamped in
Z80 T-states. When the HDMI DMA needs a chunk of `N` samples, walk the
event list and render a high-rate (e.g. 1.77 MHz = native AY tick)
stream, then downsample to 48 kHz with a low-pass filter.

Higher fidelity, more code, more per-chunk CPU. Probably not worth it
before (4.1) is proven.

### 4.3 Where the T-states come from

spectrum4's Z80 emulator already has to tick T-states for video timing.
The sound sampler hooks in at the same place: every 73 T-states (or 74
for 128K), take one sample. That gives us 48 kHz free-of-charge from the
existing frame-timing machinery.


## 5. Implementation plan (sketch)

Four pieces to build, in order:

1. **`ay8912.s`** — register file + three tone counters + noise LFSR +
   envelope state + per-sample tick function that returns a 16-bit signed
   mixed sample. Pure emulation, no hardware dependency. Write tests
   against reference test vectors (there are public AY test tunes with
   known output).

2. **Port `0xFE` tap** — in whatever already handles OUT-to-0xFE for the
   border, record bits 3 and 4. Keep a single "current beeper level" byte
   per Z80 T-state granularity (or just latched until the next write).

3. **Mixer + HDMI feeder** — at 48 kHz tick rate, combine beeper state
   and `ay8912_tick()`, scale to 24 bits, IEC958-frame, push into DMA
   buffer. IEC958 framing is covered in `hdmi-sound.md` §8.

4. **HDMI init** — one-time, per `hdmi-sound.md` §7.

Pieces 1 and 2 can be tested without any HDMI plumbing — render into a
WAV file in an emulator test harness and listen on the Mac. Only piece 3
needs the Pi hardware, and piece 4 is the one-time register dance.


## 6. Notes and caveats

- **Coherent memory**: the DMA ring buffers for HDMI need the same
  coherency treatment as the xHCI ring buffers. The existing coherent
  region is a fine home for them. Two buffers of 384 × N × 4 bytes
  (N = 10 gives Circle's default 3840-word chunks = 80 ms at 48 kHz);
  tune down for lower latency.

- **Sample rate choice**: 48 kHz is HDMI's native rate (most sinks
  pass it through without resampling). 44.1 kHz also works but the MAI
  divisor is less clean. Stick with 48 kHz unless there's a reason not
  to.

- **AY variants**: AY-3-8912 is electrically identical to AY-3-8910 in
  the audio path, just with one I/O port instead of two. The YM2149
  (MSX, CPC) uses a slightly different volume table with 32 envelope
  levels — not relevant for the Spectrum 128.

- **Floating-bus reads of `0xFE`**: unrelated to sound, but worth
  remembering — when implementing input, a read of `0xFE` returns the
  keyboard + EAR-in state, not the last written beeper value.

- **Mic input deferred**: the Spectrum 128 used the EAR line for tape
  loading (the same bit 6 in `IN (0xFE)`). The Pi 400 has no line-in or
  microphone, so this has to become USB audio input or file-backed `.tap`
  emulation. Out of scope for now.
