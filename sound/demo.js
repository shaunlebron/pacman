
// ─── ROM TABLES ──────────────────────────────────────────────────────────────

// Base frequency lookup table.  scott.asm ROM 0x3BB8, 16 entries.
// Index 0 = silence; indices 1–15 are roughly a semitone apart.
// Used by song parser: baseFreq = FREQ_TBL[note5 & 0x0F]  (scott.asm 0x2DD0–0x2DD4)
const FREQ_TBL = [
  0x00, 0x57, 0x5C, 0x61, 0x67, 0x6D, 0x74, 0x7B,
  0x82, 0x8A, 0x92, 0x9A, 0xA3, 0xAD, 0xB8, 0xC3,
];

// Duration lookup table.  scott.asm ROM 0x3BB0, 8 entries (frames @ 60 Hz).
// Entry = 2^index.  Used by song parser: dur = DUR_TBL[(byte >> 5) & 7]  (scott.asm 0x2DBD–0x2DC3)
const DUR_TBL = [1, 2, 4, 8, 16, 32, 64, 128];

// 8 WSG waveforms × 32 unsigned 4-bit samples (0–15).
// Verbatim dump of the 82S126 sound PROM (file: 82s126.1m), read sequentially,
// one byte per sample.  doc/pie/namcowsg3.cxx setSoundPROM() reads them the same way.
// Output formula: (sample - 8) / 8  — centering from namcowsg3.cxx:
//   sound_wave_data_[i] = (int)*prom++ - 8;
const WAVES = [
  // 0 – sine
  [ 7,  9, 10, 11, 12, 13, 13, 14, 14, 14, 13, 13, 12, 11, 10,  9,
    7,  5,  4,  3,  2,  1,  1,  0,  0,  0,  1,  1,  2,  3,  4,  5],
  // 1 – complex
  [ 7, 12, 14, 14, 13, 11,  9, 10, 11, 11, 10,  9,  6,  4,  3,  5,
    7,  9, 11, 10,  8,  5,  4,  3,  3,  4,  5,  3,  1,  0,  0,  2],
  // 2 – double-frequency sine
  [ 7, 10, 12, 13, 14, 13, 12, 10,  7,  4,  2,  1,  0,  1,  2,  4,
    7, 11, 13, 14, 13, 11,  7,  3,  1,  0,  1,  3,  7, 14,  7,  0],
  // 3 – complex
  [ 7, 13, 11,  8, 11, 13,  9,  6, 11, 14, 12,  7,  9, 10,  6,  2,
    7, 12,  8,  4,  5,  7,  2,  0,  3,  8,  5,  1,  3,  6,  3,  1],
  // 4 – sawtooth variant
  [ 0,  8, 15,  7,  1,  8, 14,  7,  2,  8, 13,  7,  3,  8, 12,  7,
    4,  8, 11,  7,  5,  8, 10,  7,  6,  8,  9,  7,  7,  8,  8,  7],
  // 5 – zigzag
  [ 7,  8,  6,  9,  5, 10,  4, 11,  3, 12,  2, 13,  1, 14,  0, 15,
    0, 15,  1, 14,  2, 13,  3, 12,  4, 11,  5, 10,  6,  9,  7,  8],
  // 6 – triangle
  [ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
   15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0],
  // 7 – sawtooth (two cycles per period)
  [ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15],
];

// ─── SONG DATA ───────────────────────────────────────────────────────────────
// Songs play on channels 1 and 2 simultaneously; channel 3 has no song data.
// vecoven-article: "Songs are played on voices 1 and 2 simultaneously."
//
// Song addresses from scott.asm:
//   SONG_TABLE_1 (ch1) at ROM 0x9685 — four 2-byte little-endian pointers
//   SONG_TABLE_2 (ch2) at ROM 0x967D — same layout
// (Also listed in vecoven-article as SONG_TABLE_1 EQU 9685, SONG_TABLE_2 EQU 967d)
//
// Each channel entry:
//   voice1: true  → hardware voice 1, IY→CH1_FREQ0 (scott.asm 0x2D13)
//           false → hardware voice 2/3, IY→CH2_FREQ1 (scott.asm 0x2D24)
//   base:   ROM start address, used to resolve F0 loop targets
//   data:   raw ROM bytes
//
// ── Note byte format ─────────────────────────────────────────────────────────
// vecoven-article "Regular byte": upper 3 bits = duration, lower 5 bits = W_DIR
// scott.asm 0x2DA5–0x2DC3 (process regular byte):
//   bits[7:5] → duration index into DUR_TBL  (scott.asm 0x2DBD–0x2DC3)
//   bits[4:0] = 0 → sustain (keep current baseFreq / dirByte)
//   bits[4:0] ≠ 0 → new note: W_DIR = byte; baseFreq = FREQ_TBL[bits[3:0]]
//                              (scott.asm 0x2DA6, 0x2DCE–0x2DD4)
//
// ── Frequency shift ──────────────────────────────────────────────────────────
// scott.asm 0x2DD7–0x2DE5 (compute wave frequency):
//   shift = (W_DIR & 0x10 ? 1 : 0) + W_4   where W_4 is set by F2 byte
//   freqReg = baseFreq << shift              (0x2EE4–0x2EE6: djnz add hl,hl)
//
// ── Special bytes ────────────────────────────────────────────────────────────
// vecoven-article "Special bytes" / scott.asm 0x2D82 jump table + handlers:
//   F0 lo hi  → loop: i = (hi<<8|lo) - base           (scott.asm 0x2F55)
//   F1 xx     → set waveform 0–7                       (scott.asm 0x2F65)
//   F2 xx     → set W_4 (freq shift base)              (scott.asm 0x2F77)
//   F3 xx     → set volume 0–15 (reset each note)      (scott.asm 0x2F89)
//   F4 xx     → set volume decay type                  (scott.asm 0x2F9B)
//   FF        → end of song                            (scott.asm 0x2FAD)
//
// ── Volume decay types ───────────────────────────────────────────────────────
// scott.asm 0x2F22–0x2F50 (volume routines):
//   0 = constant; 1 = –1/frame; 2 = –1/2 frames; 3 = –1/4 frames; 4 = –1/8 frames
const SONGS = [
  {
    name: 'Startup',
    // ch1 at ROM 0x96B6 (SONG_TABLE_1[0]); ch2 at ROM 0x9695 (SONG_TABLE_2[0])
    channels: [
      { voice1: true,  base: 0x96B6, data: [
        0xF1,0x02, 0xF2,0x03, 0xF3,0x0A, 0xF4,0x02,
        0x50,0x70, 0x86,0x90, 0x81,0x90, 0x86,0x90,
        0x68,0x6A, 0x6B,0x68, 0x6A,0x68, 0x66,0x6A,
        0x68,0x66, 0x65,0x68, 0x86,0x81, 0x86,0xFF,
      ]},
      { voice1: false, base: 0x9695, data: [
        0xF1,0x00, 0xF2,0x02, 0xF3,0x0A, 0xF4,0x00,
        0x41,0x43,0x45, 0x86,0x8A,0x88,0x8B,
        0x6A,0x6B,0x71, 0x6A,0x88,0x8B,
        0x6A,0x6B,0x71, 0x6A,0x6B,0x71, 0x73,0x75,
        0x96,0x95,0x96, 0xFF,
      ]},
    ],
  },
  {
    name: 'Act 1',
    // ch1 at ROM 0x9719 (SONG_TABLE_1[1]); ch2 at ROM 0x96D6 (SONG_TABLE_2[1])
    channels: [
      { voice1: true,  base: 0x9719, data: [
        0xF1,0x03, 0xF2,0x03, 0xF3,0x0A, 0xF4,0x02,
        0x70,0x66,0x70,0x46,0x50,0x86,0x90,
        0x70,0x66,0x70,0x46,0x50,0x86,0x90,
        0x70,0x66,0x70,0x46,0x50,0x86,0x90,
        0x70,0x61,0x70,0x41,0x50,0x81,0x90,
        0xF4,0x00, 0xA6,0xA4,0xA2,0xA1,
        0xF4,0x01, 0x86,0x89,0x8B,0x81,0x74,0x71,0x6B,0x69,0xA6,0xFF,
      ]},
      { voice1: false, base: 0x96D6, data: [
        0xF1,0x00, 0xF2,0x02, 0xF3,0x0A, 0xF4,0x00,
        0x69,0x6B,0x69,0x86, 0x61,0x64,0x65,0x86,
        0x86,0x64,0x66,0x64, 0x61,0x69,0x6B,0x69,
        0x86,0x61,0x64,0x64, 0xA1,0x70,0x71,0x74,
        0x75,0x35,0x76,0x30, 0x50,0x35,0x76,0x30,
        0x50,0x54,0x56,0x54, 0x51,0x6B,0x69,0x6B,
        0x69,0x6B,0x91,0x6B, 0x69,0x66,
        0xF2,0x01, 0x74,0x76,0x74,0x71,0x74,0x71,0x6B,0x69,0xA6,0xA6,0xFF,
      ]},
    ],
  },
  {
    name: 'Pac-Man Startup',
    // Pac-Man song index 0: ch1=0x3BD4, ch2=0x3C58.
    // This is the original Pac-Man startup/attract jingle (ends FF, plays once).
    // Ms. Pac-Man reuses it verbatim as its "Act 2" opening phrase:
    //   SONG_TABLE_1[2] at 0x9689 → 0x3BD4
    //   SONG_TABLE_2[2] at 0x967D → 0x3C58
    // scott.asm mislabels these "act 2 song" because they sit in the Pac-Man
    // ROM area; the #if MSPACMAN conditionals in the sound file clarify the split.
    channels: [
      { voice1: true,  base: 0x3BD4, data: [
        // scott.asm 0x3BD4
        0xF1,0x02, 0xF2,0x03, 0xF3,0x0F, 0xF4,0x01,
        0x82,0x70,0x69, 0x82,0x70,0x69,
        0x83,0x70,0x6A, 0x83,0x70,0x6A,
        0x82,0x70,0x69, 0x82,0x70,0x69,
        0x89,0x8B,0x8D,0x8E,0xFF,
      ]},
      { voice1: false, base: 0x3C58, data: [
        // scott.asm 0x3C58
        0xF1,0x00, 0xF2,0x02, 0xF3,0x0F, 0xF4,0x00,
        0x42,0x50,0x4E,0x50, 0x49,0x50,0x46,0x50,
        0x4E,0x49,0x70,0x66,0x70,
        0x43,0x50,0x4F,0x50, 0x4A,0x50,0x47,0x50,
        0x4F,0x4A,0x70,0x67,0x70,
        0x42,0x50,0x4E,0x50, 0x49,0x50,0x46,0x50,
        0x4E,0x49,0x70,0x66,0x70,
        0x45,0x46,0x47,0x50, 0x47,0x48,0x49,0x50,
        0x49,0x4A,0x4B,0x50, 0x6E,0xFF,
      ]},
    ],
  },
  {
    name: 'Pac-Man Cutscene',
    // Pac-Man song index 1: ch1=0x3BF3, ch2=0x3C95.
    // This is the music that loops during all original Pac-Man cutscenes/intermissions.
    // Ms. Pac-Man's Act 2 slot points to song index 0 (Startup above), not this one.
    // scott.asm labels these "act 2 song / act 2 song (2nd half)" because they
    // sit adjacent to the Startup data in ROM — the labeling is misleading.
    // Pac-Man SONG_TABLE_1[1] at 0x3BCA → 0x3BF3; SONG_TABLE_2[1] at 0x3BCE → 0x3C95.
    // F0 loop: ch1 → 0x3BFB (index 8), ch2 → 0x3C9D (index 8).
    channels: [
      { voice1: true,  base: 0x3BF3, data: [
        // scott.asm 0x3BF3 "act 2 song" — ch1 main loop
        0xF1,0x02, 0xF2,0x03, 0xF3,0x0F, 0xF4,0x01,  // setup
        0x67,0x50,0x30,0x47,0x30,0x67,0x50,0x30,      // ← F0 loop target (index 8 = 0x3BFB)
        0x47,0x30,0x67,0x50,0x30,0x47,0x30,
        0x4B,0x10,0x4C,0x10,0x4D,0x10,0x4E,0x10,0x67,
        0x50,0x30,0x47,0x30,0x67,0x50,0x30,0x47,0x30,
        0x67,0x50,0x30,0x47,0x30,
        0x4B,0x10,0x4C,0x10,0x4D,0x10,0x4E,0x10,0x67,
        0x50,0x30,0x47,0x30,0x67,0x50,0x30,0x47,0x30,
        0x67,0x50,0x30,0x47,0x30,
        0x4B,0x10,0x4C,0x10,0x4D,0x10,0x4E,0x10,
        0x77,0x20,0x4E,0x10,0x4D,0x10,0x4C,0x10,
        0x4A,0x10,0x47,0x10,0x46,0x10,
        0x65,0x30,0x66,0x30,0x67,0x40,0x70,
        0xF0,0xFB,0x3B,  // loop back to 0x3BFB (index 8)
      ]},
      { voice1: false, base: 0x3C95, data: [
        // scott.asm 0x3C95 "act 2 song (2nd half)" — ch2 main loop
        0xF1,0x01, 0xF2,0x01, 0xF3,0x0F, 0xF4,0x00,  // setup
        0x26,0x67,0x26,0x67,0x26,0x67,0x23,0x44,      // ← F0 loop target (index 8 = 0x3C9D)
        0x42,0x47,0x30,0x67,0x2A,0x8B,0x70,
        0x26,0x67,0x26,0x67,0x26,0x67,0x23,0x44,0x42,
        0x47,0x30,0x67,0x23,0x84,0x70,
        0x26,0x67,0x26,0x67,0x26,0x67,0x23,0x44,0x42,0x47,
        0x30,0x67,0x29,0x6A,0x2B,0x6C,0x30,0x2C,0x6D,0x40,
        0x2B,0x6C,0x29,0x6A,0x67,0x20,
        0x29,0x6A,0x40,0x26,0x87,0x70,
        0xF0,0x9D,0x3C,  // loop back to 0x3C9D (index 8)
      ]},
    ],
  },
  {
    name: 'Act 3',
    // ch1 at ROM 0x9772 (SONG_TABLE_1[3]); ch2 at ROM 0x974F (SONG_TABLE_2[3])
    channels: [
      { voice1: true,  base: 0x9772, data: [
        0xF1,0x02, 0xF2,0x03, 0xF3,0x0A, 0xF4,0x02,
        0x65,0x90,0x68,0x70, 0x68,0x67,0x66,0x65,
        0x90,0x61,0x70,0x61, 0x65,0x68,0x66,0x90,
        0x63,0x90,0x86,0x90, 0x85,0x90,0x85,0x70,
        0x86,0x68,0x65,0xFF,
      ]},
      { voice1: false, base: 0x974F, data: [
        0xF1,0x00, 0xF2,0x02, 0xF3,0x0A, 0xF4,0x00,
        0x65,0x64,0x65,0x88, 0x67,0x88,
        0x61,0x63,0x64,0x85, 0x64,0x85,
        0x6A,0x69,0x6A,0x8C,
        0x75,0x93,0x90,0x91, 0x90,0x91,
        0x70,0x8A,0x68,0x71,0xFF,
      ]},
    ],
  },
];

// ─── EFFECT DATA ─────────────────────────────────────────────────────────────
// Effect tables in ROM (vecoven-article: EFFECT_TABLE_* constants):
//   Channel 1: ROM 0x3B30  (2 effects)
//   Channel 2: ROM 0x3B40  (8 effects)
//   Channel 3: ROM 0x3B80  (6 effects)
//
// Each effect is 8 bytes.  vecoven-article "Effects are encoded with 8 bytes":
//   [0] T0: bits[6:4]=freq shift, bits[2:0]=waveform        (scott.asm 0x2EDC–0x2EE3)
//   [1] T1: BASE_FREQ initial value (8-bit unsigned)         (scott.asm 0x2E34: E_TABLE1)
//   [2] T2: FREQ_INC per frame (signed 8-bit)               (scott.asm 0x2E38: E_TABLE2)
//   [3] T3: bits[6:0]=duration in frames, bit7=bounce flag  (scott.asm 0x2E3C/0x2E40)
//   [4] T4: BASE_FREQ delta applied once per cycle (signed)  (scott.asm 0x2E44: E_TABLE4)
//   [5] T5: cycle count (0=infinite loop)                   (scott.asm 0x2E48: E_TABLE5)
//   [6] T6: bits[7:4]=vol decay type, bits[3:0]=initial vol (scott.asm 0x2E4C/0x2E50)
//   [7] T7: vol delta applied once per cycle (signed)        (scott.asm 0x2E54: E_TABLE7)
const SFX = [
  // Channel 1 effects — voice1:true because ch1 uses CH1_FREQ0 (scott.asm 0x2D13)
  { ch:1, voice1:true,  name:'extra life',          d:[0x73,0x20,0x00,0x0C,0x00,0x0A,0x1F,0x00] },
  { ch:1, voice1:true,  name:'credit',              d:[0x72,0x20,0xFB,0x87,0x00,0x02,0x0F,0x00] },
  // Channel 2 effects — voice1:false because ch2 uses CH2_FREQ1 (scott.asm 0x2D24)
  { ch:2, voice1:false, name:'siren (base)',         d:[0x59,0x01,0x06,0x08,0x00,0x00,0x02,0x00] },
  { ch:2, voice1:false, name:'siren lv2 (155 dots)', d:[0x59,0x01,0x06,0x09,0x00,0x00,0x02,0x00] },
  { ch:2, voice1:false, name:'siren lv3 (179 dots)', d:[0x59,0x02,0x06,0x0A,0x00,0x00,0x02,0x00] },
  { ch:2, voice1:false, name:'siren lv4 (12 dots)',  d:[0x59,0x03,0x06,0x0B,0x00,0x00,0x02,0x00] },
  { ch:2, voice1:false, name:'siren reset',          d:[0x59,0x04,0x06,0x0C,0x00,0x06,0x02,0x00] },
  { ch:2, voice1:false, name:'energizer eaten',      d:[0x24,0x00,0x06,0x08,0x02,0x00,0x0A,0x00] },
  { ch:2, voice1:false, name:'eyes returning',       d:[0x36,0x07,0x87,0x6F,0x00,0x00,0x04,0x00] },
  { ch:2, voice1:false, name:'(unused)',             d:[0x70,0x04,0x00,0x00,0x00,0x00,0x08,0x00] },
  // Channel 3 effects — same voice2/3 hardware path as ch2 (scott.asm 0x2D35: IY→CH3_FREQ1)
  { ch:3, voice1:false, name:'dot eat 1',            d:[0x1C,0x70,0x8B,0x08,0x00,0x01,0x06,0x00] },
  { ch:3, voice1:false, name:'dot eat 2',            d:[0x1C,0x70,0x8B,0x08,0x00,0x01,0x06,0x00] },
  { ch:3, voice1:false, name:'fruit eaten',          d:[0x56,0x0C,0xFF,0x8C,0x00,0x02,0x08,0x00] },
  { ch:3, voice1:false, name:'ghost eaten (blue)',   d:[0x56,0x00,0x02,0x0A,0x07,0x03,0x0C,0x00] },
  { ch:3, voice1:false, name:'ghosts bumping',       d:[0x36,0x38,0xFE,0x12,0xF8,0x04,0x0F,0xFC] },
  { ch:3, voice1:false, name:'fruit bouncing',       d:[0x22,0x01,0x01,0x06,0x00,0x01,0x07,0x00] },
];

// ─── HARDWARE: FREQUENCY ─────────────────────────────────────────────────────
// doc/pie/wsg3.htm: "The chip is clocked at about 96 KHz (3.072 MHz / 32)."
// At each 96 kHz tick the 20-bit phase accumulator increments by the frequency
// register value.  The top 5 bits index into the 32-sample waveform table.
// doc/pie/namcowsg3.cxx playSound(): wave_data[(offset >> 25) & 0x1F]
//
// Voice 1 frequency range differs from voices 2/3.
// vecoven-article: "channel 1 has a 20 bits adder, and therefore frequency range
//   is different. Note that you cannot play songs or effects designed for
//   channel 1 on channel 2 or 3."
//
// The difference comes from which register the Z80 writes to:
//   scott.asm 0x2D13:  ld iy, #CH1_FREQ0   — voice 1 IY starts at nibble 0
//   scott.asm 0x2D24:  ld iy, #CH2_FREQ1   — voice 2 IY starts at nibble 1
//   scott.asm 0x2D35:  ld iy, #CH3_FREQ1   — voice 3 same as voice 2
//
// The Z80 writes the computed HL as 4 nibbles to (IY+0)..(IY+3).
// doc/pie/wsg3.htm register map: voice 1 has 5 nibble slots (regs 0x10–0x14),
//   voices 2/3 have 4 slots (regs 0x16–0x19 / 0x1B–0x1E).
// doc/pie/namcowsg3.cxx getVoice(): for non-voice-1, f <<= 4 after assembling
//   the 4 nibbles — so hardware_freq(voice2/3) = HL << 4 = freqReg × 16,
//   while hardware_freq(voice1) = HL = freqReg.
//
// audio_freq = hardware_freq × 96000 / 2^20
//   voice 1:   freqReg × 96000 / 2^20  ≈ freqReg × 0.0916 Hz  (bass range)
//   voice 2/3: freqReg × 16 × 96000 / 2^20 ≈ freqReg × 1.465 Hz  (melody range)

const CHIP_CLOCK = 96_000;  // 3.072 MHz / 32  (doc/pie/wsg3.htm)

// Waveform phase advance per output sample.
// Derived from: audio_freq = hw × CHIP_CLOCK / 2^20,
// and the waveform has 32 steps per cycle, so phase_per_sample = audio_freq / outputRate × 32.
// Combines to: hw × CHIP_CLOCK × 32 / rate / 2^20   (verified against namcowsg3.cxx playSound)
function phaseInc(freqReg, isVoice1, rate) {
  const hw = isVoice1 ? freqReg : freqReg * 16;  // see voice 1 vs 2/3 note above
  return hw * CHIP_CLOCK * 32 / rate / (1 << 20);
}

// ─── SONG PARSER ─────────────────────────────────────────────────────────────
// Interprets one channel's raw song bytes into an array of per-frame register
// snapshots { wave, freqReg, vol }, one entry per 60 Hz VBLANK.
// Logic mirrors the Z80 routine at scott.asm 0x2D44–0x2DB3 (process wave).

function parseSong({ base, data }, maxFrames = 60 * 15) {
  let wave = 0, freqInc = 0, vol = 15, volType = 0;
  let baseFreq = 0, dirByte = 0;
  const frames = [];
  let ticker = 0;
  let loopCount = 0;
  let i = 0;

  while (i < data.length && frames.length < maxFrames) {
    const b = data[i++];

    if (b === 0xFF) break;  // end of song  (scott.asm 0x2FAD)

    if (b === 0xF0) {
      // Jump/loop: next 2 bytes are a little-endian ROM address.
      // Convert to array index by subtracting the channel's ROM base address.
      // scott.asm 0x2F55–0x2F63
      const lo = data[i++], hi = data[i++];
      i = ((hi << 8) | lo) - base;
      if (++loopCount > 3) break;  // cap to avoid infinite render
      continue;
    }

    if (b >= 0xF1 && b <= 0xF4) {
      // Special command bytes — each is followed by one argument byte.
      // scott.asm 0x2F65 (F1), 0x2F77 (F2), 0x2F89 (F3), 0x2F9B (F4)
      const arg = data[i++];
      if      (b === 0xF1) wave    = arg & 0x07;  // waveform select (0–7)
      else if (b === 0xF2) freqInc = arg;          // W_4: base shift amount
      else if (b === 0xF3) vol     = arg & 0x0F;  // note volume (reset each note)
      else if (b === 0xF4) volType = arg;          // volume decay type
      continue;
    }

    // Regular note byte  (scott.asm 0x2DA5–0x2DE5)
    const durIdx = (b >> 5) & 0x07;           // bits[7:5] → DUR_TBL index
    const dur    = DUR_TBL[durIdx];
    const note5  = b & 0x1F;                  // bits[4:0]

    if (note5 !== 0) {
      // New pitch: save byte as W_DIR; look up base frequency.
      // scott.asm 0x2DA6 (W_DIR = byte), 0x2DCE–0x2DD4 (FREQ_TBL lookup)
      dirByte  = b;
      baseFreq = FREQ_TBL[note5 & 0x0F];
    }
    // note5 === 0 → sustain: keep current dirByte and baseFreq unchanged.

    // Compute register value: shift = (W_DIR bit4 ? 1 : 0) + W_4
    // scott.asm 0x2DD7–0x2DE5, then 0x2EE4–0x2EE6 (djnz add hl,hl)
    const shift   = ((dirByte & 0x10) ? 1 : 0) + freqInc;
    const freqReg = baseFreq << shift;
    let   curVol  = vol;  // F3 value is the per-note starting volume

    for (let f = 0; f < dur && frames.length < maxFrames; f++) {
      frames.push({ wave: wave & 7, freqReg, vol: curVol });
      // Volume decay after each frame — rates from scott.asm 0x2F22–0x2F50
      switch (volType) {
        case 1: if (curVol > 0) curVol--; break;                             // –1/frame
        case 2: if ((ticker & 1) === 0 && curVol > 0) curVol--; break;      // –1/2 frames
        case 3: if ((ticker & 3) === 0 && curVol > 0) curVol--; break;      // –1/4 frames
        case 4: if ((ticker & 7) === 0 && curVol > 0) curVol--; break;      // –1/8 frames
      }
      ticker++;
    }
  }
  return frames;
}

// ─── EFFECT PARSER ───────────────────────────────────────────────────────────
// Interprets one effect's 8-byte descriptor into per-frame snapshots.
// Logic mirrors scott.asm 0x2E29–0x2F1D (process effect bis + update_freq).
//
// Per-frame sequence  (scott.asm 0x2ECD–0x2EFB):
//   BASE_FREQ += FREQ_INC  (signed 8-bit wrap)  → 0x2ECD–0x2ED3
//   freqReg = BASE_FREQ << shift                → 0x2EDC–0x2EE6
//   output sample at (freqReg, wave, vol)
//   apply volume decay                          → 0x2F02–0x2F50
//
// Per-cycle end  (scott.asm 0x2E6E–0x2E96):
//   if T5 ≠ 0: decrement; stop when it reaches 0
//   if T5 = 0: repeat indefinitely
//   if bounce (T3 bit7): flip FREQ_INC sign     (scott.asm 0x2E96–0x2EA7)
//     and skip T1/T6 update every other half-cycle  (scott.asm 0x2EA9–0x2EC2)

function parseEffect(d) {
  // T0 byte: bits[6:4]=freq shift, bits[2:0]=waveform  (scott.asm 0x2EDC: and #70)
  const shift  = (d[0] & 0x70) >> 4;
  const wave   = d[0] & 0x07;
  let   t1     = d[1];                               // E_TABLE1: initial BASE_FREQ
  const fi0    = d[2] >= 0x80 ? d[2] - 256 : d[2];  // E_TABLE2: FREQ_INC (signed)
  const dur    = d[3] & 0x7F;                        // E_TABLE3: duration in frames
  const bounce = !!(d[3] & 0x80);                    // E_TABLE3 bit7: bounce flag
  const t4     = d[4] >= 0x80 ? d[4] - 256 : d[4];  // E_TABLE4: BASE_FREQ delta/cycle
  let   t5     = d[5];                               // E_TABLE5: cycle count (0=∞)
  let   volB   = d[6];                               // E_TABLE6: hi=type, lo=vol
  const t7     = d[7] >= 0x80 ? d[7] - 256 : d[7];  // E_TABLE7: vol delta/cycle

  const MAX_FRAMES = t5 === 0 ? 60 * 3 : 60 * 20;  // cap infinite effects at 3 s
  const frames = [];
  let fi = fi0;
  let dirBit = false;
  let ticker = 0;

  while (frames.length < MAX_FRAMES) {
    // Start of cycle: load BASE_FREQ from t1, vol from volB
    let bFreq = t1;
    let eVol  = volB & 0x0F;
    const eType = (volB >> 4) & 0x0F;

    for (let f = 0; f < dur && frames.length < MAX_FRAMES; f++) {
      bFreq = (bFreq + fi) & 0xFF;  // BASE_FREQ += FREQ_INC, 8-bit wrap  (0x2ECD–0x2ED3)
      frames.push({ wave: wave & 7, freqReg: bFreq << shift, vol: eVol });
      // Volume decay  (scott.asm 0x2F22–0x2F50)
      switch (eType) {
        case 1: if (eVol > 0) eVol--; break;
        case 2: if ((ticker & 1) === 0 && eVol > 0) eVol--; break;
        case 3: if ((ticker & 3) === 0 && eVol > 0) eVol--; break;
        case 4: if ((ticker & 7) === 0 && eVol > 0) eVol--; break;
      }
      ticker++;
    }

    // Cycle end: handle repeat count  (scott.asm 0x2E6E–0x2E96)
    if (t5 !== 0) {
      t5--;
      if (t5 === 0) break;
    }

    // Bounce: flip FREQ_INC sign each half-cycle; skip T1/volB update on odd half-cycles.
    // scott.asm 0x2E96 (neg E_TABLE2), 0x2EA3 (bit0 of E_DIR), 0x2EA7/0x2EA9 (branch)
    if (bounce) {
      fi = -fi;
      dirBit = !dirBit;
      if (dirBit) continue;  // odd half: skip T1 and volB update
    }
    t1   = (t1 + t4) & 0xFF;   // BASE_FREQ advances by T4 each full cycle  (0x2EAD–0x2EB6)
    volB = (volB + t7) & 0xFF;  // vol byte advances by T7 each full cycle   (0x2EB9–0x2EBF)
  }
  return frames;
}

// ─── RENDERER ────────────────────────────────────────────────────────────────
// Converts per-frame register snapshots into a PCM Float32Array.
// channels: array of { frames, voice1 }
//   frames: array of { wave, freqReg, vol } — one per 60 Hz frame
//   voice1: true = hardware voice 1, false = voice 2/3
// rate: AudioContext.sampleRate — passed in so rendering matches playback rate
//   exactly (avoids browser resampling differences between Safari / Chrome).
// Mixing: doc/pie/namcowsg3.cxx playSound() sums all active voices then the
//   caller divides; here we divide by channel count for equal weighting.

function render(channels, rate) {
  const spf      = rate / 60;  // samples per 60 Hz frame at this output rate
  const nFrames  = Math.max(...channels.map(c => c.frames.length));
  if (!nFrames) return new Float32Array(1);
  const nSamples = Math.ceil(nFrames * spf) | 0;
  const out      = new Float32Array(nSamples);
  const phases   = channels.map(() => 0);

  for (let s = 0; s < nSamples; s++) {
    const fi = (s / spf) | 0;  // which 60 Hz frame does this sample fall in?
    let mix = 0;
    for (let c = 0; c < channels.length; c++) {
      const fr = channels[c].frames[fi];
      if (!fr || !fr.freqReg || !fr.vol) { phases[c] = 0; continue; }
      phases[c] = (phases[c] + phaseInc(fr.freqReg, channels[c].voice1, rate)) % 32;
      const smp = WAVES[fr.wave][phases[c] | 0];    // 0–15
      mix += ((smp - 8) / 8) * (fr.vol / 15);       // (sample-8)/8: namcowsg3.cxx setSoundPROM
    }
    out[s] = mix / channels.length;
  }
  return out;
}

// ─── PLAYBACK ────────────────────────────────────────────────────────────────

let actx;
function getActx() {
  if (!actx) actx = new AudioContext();  // use browser's native rate
  return actx;
}

function play(pcm, rate) {
  const a = getActx();
  if (a.state === 'suspended') a.resume();
  const buf = a.createBuffer(1, pcm.length, rate);
  buf.copyToChannel(pcm, 0);
  const src = a.createBufferSource();
  src.buffer = buf;
  src.connect(a.destination);
  src.start();
}

// ─── UI ──────────────────────────────────────────────────────────────────────

function addBtn(container, label, onclick) {
  const row = Object.assign(document.createElement('div'), { className: 'row' });
  const lbl = Object.assign(document.createElement('span'), { className: 'lbl', textContent: label });
  const btn = Object.assign(document.createElement('button'), { textContent: '▶', onclick });
  row.append(lbl, btn);
  container.append(row);
}

// Songs
const songDiv = document.getElementById('songs');
for (const song of SONGS) {
  addBtn(songDiv, song.name, () => {
    const rate = getActx().sampleRate;
    const channels = song.channels.map(ch => ({ frames: parseSong(ch), voice1: ch.voice1 }));
    play(render(channels, rate), rate);
  });
}

// SFX grouped by channel
const sfxDivs = { 1: document.getElementById('sfx1'),
                  2: document.getElementById('sfx2'),
                  3: document.getElementById('sfx3') };
for (const sfx of SFX) {
  addBtn(sfxDivs[sfx.ch], sfx.name, () => {
    const rate = getActx().sampleRate;
    play(render([{ frames: parseEffect(sfx.d), voice1: sfx.voice1 }], rate), rate);
  });
}

