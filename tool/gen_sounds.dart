// Synthesises the game's placeholder sound effects from scratch.
//
//     dart run tool/gen_sounds.dart [output-dir]
//
// Everything is built in code from sine waves and filtered noise. There are no
// recordings, samples or external services, so the files are free to ship.
// Output is 16-bit mono 44.1 kHz WAV, written to assets/sounds/ by default.
// The noise uses fixed seeds, so re-running the script rewrites the same files.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int rate = 44100;
const double twoPi = 2 * math.pi;

/// Partials above this frequency are skipped to avoid aliasing.
const double maxPartialHz = 0.42 * rate;

void main(List<String> args) {
  final out = Directory(args.isNotEmpty ? args.first : _defaultOutDir())
    ..createSync(recursive: true);

  final sounds = <String, Float64List Function()>{
    'plop_1': () => plop(from: 320, to: 520, seconds: 0.115, seed: 1),
    'plop_2': () => plop(from: 380, to: 620, seconds: 0.100, seed: 2),
    'plop_3': () => plop(from: 450, to: 740, seconds: 0.090, seed: 3),
    'grow': grow,
    'goal': goal,
    'win': win,
    'lose': lose,
    'tick': tick,
    'click': click,
    'coin': coin,
  };

  for (final MapEntry(key: name, value: build) in sounds.entries) {
    final samples = build();
    final file = File('${out.path}/$name.wav')
      ..writeAsBytesSync(encodeWav(samples));
    var peak = 0.0;
    var sum = 0.0;
    for (final s in samples) {
      peak = math.max(peak, s.abs());
      sum += s * s;
    }
    final rms = math.sqrt(sum / samples.length);
    stdout.writeln(
      '${name.padRight(7)} '
      '${(samples.length * 1000 / rate).round().toString().padLeft(5)} ms '
      '${file.lengthSync().toString().padLeft(7)} bytes  '
      'peak ${_db(peak)} dBFS  rms ${_db(rms)} dBFS',
    );
  }
  stdout.writeln('Wrote ${sounds.length} files to ${out.path}');
}

String _defaultOutDir() {
  final script = Platform.script;
  if (script.scheme == 'file' && script.path.endsWith('.dart')) {
    final root = File.fromUri(script).parent.parent;
    return '${root.path}/assets/sounds';
  }
  return 'assets/sounds';
}

String _db(double x) =>
    (20 * math.log(math.max(x, 1e-9)) / math.ln10).toStringAsFixed(1);

// ---------------------------------------------------------------- the sounds

/// An item dropping into the hole: a soft rising "bloop", like an air bubble
/// closing, over a tiny low thud. Short, round, no harsh highs: it is played
/// up to a dozen times a second.
Float64List plop({
  required double from,
  required double to,
  required double seconds,
  required int seed,
}) {
  final buf = _buffer(seconds);
  final glide = seconds * 0.65;
  tone(
    buf,
    at: 0,
    length: seconds,
    // Ease-out glide: rises fast, then settles.
    hz: (t) {
      final x = math.min(1.0, t / glide);
      return from * math.pow(to / from, 1 - (1 - x) * (1 - x));
    },
    env: pluck(0.004, seconds * 0.33),
    partials: const [Partial(1, 1), Partial(2, 0.10, 30)],
  );
  // A little low body so it lands with some weight.
  tone(
    buf,
    at: 0,
    length: 0.05,
    hz: (_) => from * 0.5,
    env: pluck(0.002, 0.012),
    gain: 0.3,
  );
  // A whisper of contact noise.
  noise(
    buf,
    at: 0,
    length: 0.012,
    cutoff: (_) => 1800,
    env: pluck(0.0005, 0.003),
    lowPass: true,
    gain: 0.12,
    seed: seed,
  );
  return finish(buf, peak: 0.5);
}

/// The hole grows: an upward noise swoosh, a rising tone and a sparkly
/// C-major chime arpeggio on top.
Float64List grow() {
  const len = 0.55;
  final buf = _buffer(len);
  noise(
    buf,
    at: 0,
    length: len,
    cutoff: (t) => 350.0 * math.pow(5200 / 350, math.min(1.0, t / 0.45)),
    env: (t) => t < 0.3 ? _smooth(t / 0.3) : math.exp(-(t - 0.3) / 0.08),
    q: 0.45,
    gain: 0.5,
    seed: 11,
  );
  final c4 = note('C4');
  tone(
    buf,
    at: 0,
    length: 0.5,
    hz: (t) => c4 * math.pow(4, math.min(1.0, t / 0.42)),
    env: (t) => _smooth(t / 0.06) * (t < 0.3 ? 1 : math.exp(-(t - 0.3) / 0.07)),
    partials: const [Partial(1, 1), Partial(2, 0.3), Partial(3, 0.12)],
    gain: 0.3,
    release: 0.05,
  );
  const notes = ['C6', 'E6', 'G6', 'C7'];
  for (var k = 0; k < notes.length; k++) {
    final at = 0.16 + 0.065 * k;
    final hz = note(notes[k]);
    tone(
      buf,
      at: at,
      length: len - at,
      hz: (_) => hz,
      env: pluck(0.002, 0.11),
      partials: chime,
      gain: 0.2 + 0.03 * k,
      release: 0.04,
    );
  }
  return finish(buf, peak: 0.7);
}

/// One goal type fully collected: a bright two-note bell, G5 then C6.
Float64List goal() {
  const len = 0.42;
  final buf = _buffer(len);
  final g5 = note('G5');
  final c6 = note('C6');
  tone(
    buf,
    at: 0,
    length: len,
    hz: (_) => g5,
    env: pluck(0.002, 0.08),
    partials: bell,
    gain: 0.75,
  );
  tone(
    buf,
    at: 0.1,
    length: len - 0.1,
    hz: (_) => c6,
    env: pluck(0.002, 0.14),
    partials: bell,
    release: 0.06,
  );
  return finish(buf, peak: 0.75);
}

/// Level complete: "da-da-da-DAAA" up a C-major arpeggio into a full chord,
/// with a few sparkles over the top.
Float64List win() {
  const len = 1.25;
  final buf = _buffer(len);
  final brass = [
    for (var n = 1; n <= 8; n++)
      Partial(n.toDouble(), 1 / math.pow(n, 1.3), 1.5 * (n - 1)),
  ];

  void voice(
    String name,
    double at,
    double length,
    double gain,
    double Function(double t) env, {
    bool vibrato = false,
    double release = 0.03,
  }) {
    final f0 = note(name);
    // Two voices a few cents apart for warmth.
    for (final detune in const [-0.0025, 0.0025]) {
      tone(
        buf,
        at: at,
        length: length,
        hz: (t) {
          var f = f0 * (1 + detune);
          if (vibrato && t > 0.2) {
            f *=
                1 +
                0.003 *
                    _smooth((t - 0.2) / 0.2) *
                    math.sin(twoPi * 5.5 * (t - 0.2));
          }
          return f;
        },
        env: env,
        partials: brass,
        gain: gain / 2,
        release: release,
      );
    }
  }

  final short = pluck(0.006, 0.12);
  voice('C5', 0.00, 0.13, 0.5, short);
  voice('E5', 0.09, 0.13, 0.5, short);
  voice('G5', 0.18, 0.13, 0.5, short);

  const chordAt = 0.3;
  double chordEnv(double t) =>
      _smooth(t / 0.01) * (0.6 + 0.4 * math.exp(-t / 0.1)) * math.exp(-t / 1.2);
  for (final (name, gain) in const [
    ('C5', 0.28),
    ('E5', 0.24),
    ('G5', 0.24),
    ('C6', 0.30),
  ]) {
    voice(
      name,
      chordAt,
      len - chordAt,
      gain,
      chordEnv,
      vibrato: true,
      release: 0.3,
    );
  }

  for (final (at, name) in const [
    (0.32, 'E7'),
    (0.42, 'C7'),
    (0.53, 'G7'),
    (0.66, 'E7'),
    (0.80, 'C8'),
  ]) {
    final hz = note(name);
    tone(
      buf,
      at: at,
      length: 0.3,
      hz: (_) => hz,
      env: pluck(0.001, 0.07),
      partials: chime,
      gain: 0.06,
      release: 0.05,
    );
  }
  return finish(buf, peak: 0.8);
}

/// Time's up: a gentle, muted "wah-wah-waah" stepping down by semitones.
/// The wah is a low-pass with a soft formant that opens and closes per note.
Float64List lose() {
  const len = 0.9;
  final buf = _buffer(len);
  final saw = [for (var n = 1; n <= 16; n++) Partial(n.toDouble(), 1 / n)];
  const notes = [('F4', 0.0, 0.25), ('E4', 0.27, 0.25), ('D#4', 0.54, 0.36)];

  for (var k = 0; k < notes.length; k++) {
    final (name, at, length) = notes[k];
    final last = k == notes.length - 1;
    final f0 = note(name);

    double cutoff(double t) {
      final x = t / length;
      return x < 0.4
          ? 300 + 1000 * _smooth(x / 0.4)
          : 1300 - 850 * _smooth((x - 0.4) / 0.6);
    }

    tone(
      buf,
      at: at,
      length: length,
      hz: (t) {
        if (!last) return f0;
        // Sad vibrato, then a small droop at the very end.
        final wobble = t > 0.08
            ? 0.012 *
                  _smooth((t - 0.08) / 0.1) *
                  math.sin(twoPi * 5 * (t - 0.08))
            : 0.0;
        final droop = 0.03 * _smooth((t - (length - 0.18)) / 0.18);
        return f0 * (1 + wobble) * (1 - droop);
      },
      env: (t) => _smooth(t / 0.03) * math.exp(-t / 0.6),
      partials: saw,
      filter: (t, hz) {
        final fc = cutoff(t);
        final lp = 1 / math.sqrt(1 + math.pow(hz / fc, 4));
        final d = (hz - fc) / (0.3 * fc);
        return lp * (1 + 1.2 * math.exp(-d * d));
      },
      gain: last ? 0.55 : 0.5,
      release: 0.05,
    );
  }
  return finish(buf, peak: 0.5);
}

/// Countdown tick: a short, bright wood-block click.
Float64List tick() {
  const len = 0.05;
  final buf = _buffer(len);
  tone(
    buf,
    at: 0,
    length: len,
    hz: (_) => 1600,
    env: pluck(0.0006, 0.007),
    partials: const [Partial(1, 1), Partial(2.45, 0.3, 120)],
  );
  noise(
    buf,
    at: 0,
    length: 0.006,
    cutoff: (_) => 3500,
    env: pluck(0.0003, 0.0015),
    q: 0.6,
    gain: 0.25,
    seed: 5,
  );
  return finish(buf, peak: 0.5, fadeIn: 0.0005);
}

/// UI tap: a round, low "tock" with a quick pitch drop.
Float64List click() {
  const len = 0.04;
  final buf = _buffer(len);
  tone(
    buf,
    at: 0,
    length: len,
    hz: (t) => 650 + 550 * math.exp(-t / 0.006),
    env: pluck(0.0008, 0.006),
    partials: const [Partial(1, 1), Partial(2, 0.15, 60)],
  );
  noise(
    buf,
    at: 0,
    length: 0.004,
    cutoff: (_) => 5000,
    env: pluck(0.0002, 0.001),
    lowPass: true,
    gain: 0.12,
    seed: 7,
  );
  return finish(buf, peak: 0.55, fadeIn: 0.0005);
}

/// Coins earned: the classic B5 -> E6 coin, with a metallic shimmer on the
/// "ching".
Float64List coin() {
  const len = 0.36;
  final buf = _buffer(len);
  const square = [
    Partial(1, 1),
    Partial(3, 1 / 3, 6),
    Partial(5, 1 / 5, 10),
    Partial(7, 1 / 7, 14),
  ];
  final b5 = note('B5');
  final e6 = note('E6');
  noise(
    buf,
    at: 0,
    length: 0.006,
    cutoff: (_) => 6000,
    env: pluck(0.0003, 0.0015),
    q: 0.5,
    gain: 0.2,
    seed: 9,
  );
  tone(
    buf,
    at: 0,
    length: 0.075,
    hz: (_) => b5,
    env: pluck(0.001, 0.2),
    partials: square,
    gain: 0.6,
    release: 0.008,
  );
  tone(
    buf,
    at: 0.07,
    length: len - 0.07,
    hz: (_) => e6,
    env: pluck(0.001, 0.12),
    partials: const [
      ...square,
      Partial(2, 0.2, 14),
      Partial(2.76, 0.12, 20),
      Partial(5.4, 0.05, 30),
    ],
    gain: 0.65,
    release: 0.05,
  );
  return finish(buf, peak: 0.6);
}

// ------------------------------------------------------------- timbres

/// Soft bell: mostly fundamental, upper partials fade faster.
const bell = [
  Partial(1, 1),
  Partial(2, 0.35, 10),
  Partial(3, 0.12, 18),
  Partial(4.2, 0.05, 30),
];

/// Glockenspiel-like chime with a slightly inharmonic top.
const chime = [
  Partial(1, 1),
  Partial(2, 0.3, 8),
  Partial(3, 0.1, 14),
  Partial(5.4, 0.04, 25),
];

// ------------------------------------------------------------- synthesis

/// One sine component of a tone.
class Partial {
  const Partial(this.ratio, this.gain, [this.decay = 0]);

  /// Frequency as a multiple of the fundamental.
  final double ratio;
  final double gain;

  /// Extra exponential decay rate in 1/s (upper partials die sooner).
  final double decay;
}

/// Adds a tone to [buf], starting [at] seconds in and lasting [length]
/// seconds. [hz] gives the fundamental and [env] the amplitude, both as
/// functions of the time since the tone started. Phase is accumulated, so
/// pitch glides stay click-free. [filter], when given, scales each partial by
/// its current frequency. The last [release] seconds fade smoothly to zero.
void tone(
  Float64List buf, {
  required double at,
  required double length,
  required double Function(double t) hz,
  required double Function(double t) env,
  List<Partial> partials = const [Partial(1, 1)],
  double Function(double t, double hz)? filter,
  double gain = 1,
  double release = 0.01,
}) {
  final start = (at * rate).round();
  final n = (length * rate).round();
  final releaseN = math.max(1, (release * rate).round());
  var phase = 0.0;
  for (var i = 0; i < n; i++) {
    final j = start + i;
    if (j >= buf.length) break;
    final t = i / rate;
    final f = hz(t);
    var v = 0.0;
    for (final p in partials) {
      final pf = f * p.ratio;
      if (pf > maxPartialHz) continue;
      var a = p.gain;
      if (p.decay > 0) a *= math.exp(-p.decay * t);
      if (filter != null) a *= filter(t, pf);
      v += a * math.sin(phase * p.ratio);
    }
    var e = env(t);
    final left = n - i;
    if (left < releaseN) e *= _smooth(left / releaseN);
    if (j >= 0) buf[j] += gain * e * v;
    phase += twoPi * f / rate;
  }
}

/// Adds white noise through a state-variable filter whose [cutoff] may move.
/// Band-pass by default (unity gain at the centre); [lowPass] for a low-pass.
/// [q] is the damping: smaller means a narrower, more resonant band.
void noise(
  Float64List buf, {
  required double at,
  required double length,
  required double Function(double t) cutoff,
  required double Function(double t) env,
  required int seed,
  double q = 0.7,
  bool lowPass = false,
  double gain = 1,
}) {
  final rng = math.Random(seed);
  final start = (at * rate).round();
  final n = (length * rate).round();
  var low = 0.0;
  var band = 0.0;
  for (var i = 0; i < n; i++) {
    final j = start + i;
    if (j >= buf.length) break;
    final t = i / rate;
    // Chamberlin SVF; stable well past the cutoffs used here.
    final fc = math.min(cutoff(t), rate / 7);
    final f = 2 * math.sin(math.pi * fc / rate);
    final x = rng.nextDouble() * 2 - 1;
    low += f * band;
    final high = x - low - q * band;
    band += f * high;
    final y = lowPass ? low : band * q;
    if (j >= 0) buf[j] += gain * env(t) * y;
  }
}

/// Envelope: smooth [attack], then exponential decay with time constant
/// [decay] seconds.
double Function(double t) pluck(double attack, double decay) =>
    (t) => t < attack ? _smooth(t / attack) : math.exp(-(t - attack) / decay);

/// Scales [buf] so its loudest sample hits [peak], with short fades at both
/// ends so playback never starts or stops with a click.
Float64List finish(
  Float64List buf, {
  required double peak,
  double fadeIn = 0.001,
  double fadeOut = 0.006,
}) {
  var top = 0.0;
  for (final s in buf) {
    top = math.max(top, s.abs());
  }
  final scale = top == 0 ? 0.0 : peak / top;
  final inN = math.max(1, (fadeIn * rate).round());
  final outN = math.max(1, (fadeOut * rate).round());
  for (var i = 0; i < buf.length; i++) {
    var g = scale;
    if (i < inN) g *= _smooth(i / inN);
    final left = buf.length - 1 - i;
    if (left < outN) g *= _smooth(left / outN);
    buf[i] *= g;
  }
  return buf;
}

/// Frequency of a note name such as 'A4' (440 Hz) or 'D#4'.
double note(String name) {
  const steps = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2};
  final sharp = name[1] == '#';
  final semis = steps[name[0]]! + (sharp ? 1 : 0);
  final octave = int.parse(name.substring(sharp ? 2 : 1));
  return 440.0 * math.pow(2, (semis + (octave - 4) * 12) / 12);
}

/// Raised-cosine ramp from 0 to 1 over x in [0, 1].
double _smooth(double x) =>
    x <= 0 ? 0 : (x >= 1 ? 1 : 0.5 - 0.5 * math.cos(math.pi * x));

Float64List _buffer(double seconds) => Float64List((seconds * rate).round());

/// 16-bit PCM mono WAV.
Uint8List encodeWav(Float64List samples) {
  final dataBytes = samples.length * 2;
  final b = ByteData(44 + dataBytes);
  void tag(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      b.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  b.setUint32(4, 36 + dataBytes, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  b.setUint32(16, 16, Endian.little); // fmt chunk size
  b.setUint16(20, 1, Endian.little); // PCM
  b.setUint16(22, 1, Endian.little); // mono
  b.setUint32(24, rate, Endian.little);
  b.setUint32(28, rate * 2, Endian.little); // byte rate
  b.setUint16(32, 2, Endian.little); // block align
  b.setUint16(34, 16, Endian.little); // bits per sample
  tag(36, 'data');
  b.setUint32(40, dataBytes, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i] * 32767).round().clamp(-32768, 32767);
    b.setInt16(44 + i * 2, v, Endian.little);
  }
  return b.buffer.asUint8List();
}
