import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui';

import '../model/item_kind.dart';
import 'bot.dart';
import 'builder.dart';
import 'generator.dart';
import 'level.dart';

/// Level [number] (1-based): hand-made levels first, then an endless run of
/// generated ones. The clock is set from a bot play-through, which runs on
/// a background isolate the first time a level is asked for.
Future<Level> loadLevel(int number) async {
  final time = _times[number] ?? await _timeInBackground(number);
  return layoutLevel(number).withTime(time);
}

/// Same as [loadLevel], but blocks while the bot plays (for tests/tools).
Level buildLevel(int number) {
  final time = _times[number] ??= clockFor(number, estimateClearTime(layoutLevel(number)));
  return layoutLevel(number).withTime(time);
}

/// Starts working out the clock for [number] so it is ready when needed.
void prefetchLevel(int number) {
  if (!_times.containsKey(number)) unawaited(_timeInBackground(number));
}

/// The map of level [number] without its clock (fresh items every call).
Level layoutLevel(int number) {
  if (number >= 1 && number <= _handmade.length) return _handmade[number - 1](number);
  return generateLevel(number);
}

final _times = <int, double>{};
final _pending = <int, Future<double>>{};

Future<double> _timeInBackground(int number) => _pending[number] ??= _clockAndCache(number);

Future<double> _clockAndCache(int number) async {
  try {
    return _times[number] = await _clockOnIsolate(number);
  } finally {
    _pending.remove(number);
  }
}

// Kept apart so the closure sent to the isolate captures nothing but
// [number].
Future<double> _clockOnIsolate(int number) =>
    Isolate.run(() => clockFor(number, estimateClearTime(layoutLevel(number))));

int get handmadeLevelCount => _handmade.length;

/// Seconds on the clock for a level the bot clears in [botSeconds]: lots of
/// slack early on, tighter later. Rounded up to 5 s.
double clockFor(int number, double? botSeconds) {
  final ease = (1 - (number - 1) / 40).clamp(0.0, 1.0);
  final bot = botSeconds ?? 60;
  final t = bot * (2.3 + 0.9 * ease) + 10 + 8 * ease;
  return ((t / 5).ceil() * 5).clamp(30, 180).toDouble();
}

final _handmade = <Level Function(int)>[
  _appleRings,
  _veggieSpiral,
  _donutParty,
  _fruitTower,
  _toyTown,
  _butterfly,
  _sushiPyramid,
  _sweetTower,
  _heartPicnic,
  _harvest,
  _blockCity,
  _grandBuffet,
];

typedef K = ItemKind;

Level _appleRings(int n) {
  final b = LevelBuilder(10, 15);
  const cx = 5.0, cy = 9.4;
  b.put(K.apple, cx, cy);
  b.rings([K.apple, K.orange], cx, cy, 0.25, 8);
  b.line(K.apple, cx, 2.8, cx, 4.4);
  b.grid(K.lemon, 1.8, 2.6, 4, 4, yaw: math.pi / 2);
  b.grid(K.lemon, 8.2, 2.6, 4, 4, yaw: math.pi / 2);
  b.removeOverlaps();
  return b.build(number: n, theme: MapTheme.pink, goals: [b.all(K.apple)], holeStart: const Offset(cx, 1.4));
}

Level _veggieSpiral(int n) {
  final b = LevelBuilder(12, 17);
  const cx = 6.0, cy = 9.8;
  b.put(K.tomato, cx, cy);
  b.rings(
    [K.tomato, K.carrot, K.tomato, K.carrot, K.onion, K.carrot, K.tomato, K.carrot],
    cx,
    cy,
    0.25,
    9,
    radial: true,
  );
  b.grid(K.broccoli, 1.8, 2.6, 3, 4);
  b.grid(K.broccoli, 10.2, 2.6, 3, 4);
  b.line(K.pepper, 1.0, 16.4, 11.0, 16.4);
  b.removeOverlaps();
  return b.build(number: n, theme: MapTheme.grass, goals: [b.all(K.tomato)]);
}

Level _donutParty(int n) {
  final b = LevelBuilder(12, 17);
  const cx = 6.0, cy = 10.0;
  b.grid(K.donut, cx, cy, 4, 4, layers: 4);
  b.rings([K.macaronPink, K.macaronYellow, K.macaronBlue, K.macaronYellow, K.macaronGreen], cx, cy, 1.3, 7);
  b.grid(K.cupcake, 2.0, 3.0, 3, 4);
  b.grid(K.cocoaMug, 10.0, 3.0, 3, 4);
  b.line(K.cookie, 1.0, 16.2, 11.0, 16.2);
  b.line(K.cookie, 1.0, 15.7, 11.0, 15.7);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.purple,
    goals: [b.all(K.donut), b.all(K.macaronYellow)],
  );
}

Level _fruitTower(int n) {
  final b = LevelBuilder(13, 19);
  const cx = 6.5, cy = 11.2;
  // Central towers of orange slices with jam jars stacked beside them.
  b.grid(K.orangeSlice, cx - 0.3, cy, 3, 3, layers: 12);
  b.column(K.jamJar, cx + 1.1, cy + 0.5, 3);
  b.column(K.jamJar, cx + 1.1, cy - 0.3, 2);
  b.put(K.watermelon, cx - 2.1, cy + 1.2);
  b.put(K.watermelon, cx - 2.5, cy + 0.0);
  b.rings(
    [K.avocado, K.watermelonSlice, K.lemon, K.avocado, K.watermelonSlice, K.lemon, K.avocado],
    cx,
    cy,
    1.9,
    8,
  );
  b.grid(K.orangeSlice, 2.0, 3.0, 3, 3, layers: 4);
  b.grid(K.orangeSlice, 11.0, 3.0, 3, 3, layers: 4);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.pink,
    goals: [b.all(K.avocado), b.all(K.orangeSlice)],
  );
}

Level _toyTown(int n) {
  final b = LevelBuilder(13, 20);
  b.line(K.carRed, 1.0, 4.4, 12.0, 4.4);
  b.line(K.carBlue, 1.0, 10.2, 12.0, 10.2);
  b.line(K.carRed, 1.0, 16.0, 12.0, 16.0);
  b.pyramid(K.blockBlue, 3.2, 7.3, 5);
  b.pyramid(K.blockRed, 9.8, 7.3, 5);
  b.pyramid(K.blockGreen, 3.2, 13.1, 5);
  b.pyramid(K.blockBlue, 9.8, 13.1, 5);
  b.disc(K.duck, 6.5, 7.3, 1.0);
  b.disc(K.ball, 6.5, 13.1, 1.0);
  b.grid(K.blockYellow, 6.5, 18.3, 10, 3, layers: 2);
  b.grid(K.duck, 2.2, 2.0, 4, 2);
  b.grid(K.ball, 10.8, 2.0, 4, 2);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.sand,
    goals: [b.all(K.carRed), b.all(K.blockBlue)],
  );
}

Level _butterfly(int n) {
  final b = LevelBuilder(13, 19);
  const cx = 6.5, cy = 11.2;
  b.disc(K.strawberry, cx - 2.4, cy + 1.4, 1.0);
  b.disc(K.strawberry, cx + 2.4, cy + 1.4, 1.0);
  b.disc(K.kiwiSlice, cx - 2.0, cy - 2.1, 0.75);
  b.disc(K.kiwiSlice, cx + 2.0, cy - 2.1, 0.75);
  b.line(K.greenApple, cx, cy - 2.7, cx, cy + 2.9);
  b.fill(K.orangeSlice, cx, cy, 10.0, 8.6, Shapes.butterfly);
  for (final (x, y) in [(1.2, 4.2), (11.8, 4.2), (1.2, 17.8), (11.8, 17.8), (6.5, 18.0)]) {
    b.put(K.cupcake, x, y);
  }
  b.line(K.lemonSlice, 1.5, 2.6, 11.5, 2.6);
  b.line(K.lemonSlice, 1.5, 3.1, 11.5, 3.1);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.sky,
    goals: [b.all(K.strawberry), b.all(K.greenApple)],
  );
}

Level _sushiPyramid(int n) {
  final b = LevelBuilder(13, 20);
  const cx = 6.5, cy = 11.6;
  b.pyramid(K.maki, cx, cy, 7);
  b.ring(K.wasabi, cx, cy, 1.9);
  b.ring(K.nigiriSalmon, cx, cy, 2.6);
  b.ring(K.wasabi, cx, cy, 3.3);
  b.ring(K.nigiriTamago, cx, cy, 4.0);
  b.line(K.shrimp, 1.5, 17.8, 11.5, 17.8, across: true);
  b.line(K.shrimp, 1.5, 18.6, 11.5, 18.6, across: true);
  for (final (x, y) in [(1.2, 6.6), (11.8, 6.6), (1.2, 15.6), (11.8, 15.6)]) {
    b.put(K.onigiri, x, y, yaw: -0.4);
  }
  b.put(K.soyDish, 1.8, 2.6);
  b.put(K.soyDish, 11.2, 2.6);
  b.grid(K.makiCucumber, 6.5, 3.6, 6, 2, layers: 3);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.ocean,
    goals: [b.all(K.maki), b.all(K.wasabi)],
  );
}

Level _sweetTower(int n) {
  final b = LevelBuilder(13, 20);
  const cx = 6.5, cy = 12.0;
  final pie = b.put(K.pie, cx, cy);
  b.put(K.cake, cx, cy, on: pie);
  const legs = [K.macaronPink, K.macaronYellow, K.macaronBlue, K.macaronGreen, K.macaronPurple];
  for (var d = 0; d < 4; d++) {
    final a = math.pi / 4 + d * math.pi / 2;
    for (var i = 0; i < 5; i++) {
      final dist = 1.0 + i * 0.4;
      b.tower(
        [for (final k in legs.take(5 - i % 5)) (k, 1)],
        cx + math.cos(a) * dist,
        cy + math.sin(a) * dist,
      );
    }
  }
  b.disc(K.waffle, cx, cy, 2.6);
  b.grid(K.donut, 10.2, 17.6, 4, 3, layers: 2);
  b.grid(K.cocoaMug, 10.4, 4.6, 4, 4);
  b.grid(K.cookie, 2.6, 4.6, 4, 4, layers: 3);
  b.put(K.pie, 2.6, 17.4);
  b.grid(K.cupcake, 2.6, 15.2, 4, 2);
  b.put(K.milkshake, 1.0, 12.4);
  b.put(K.milkshake, 12.0, 12.4);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.purple,
    goals: [b.all(K.cake), b.all(K.cocoaMug)],
  );
}

Level _heartPicnic(int n) {
  final b = LevelBuilder(13, 20);
  b.fill(K.strawberry, 6.5, 12.0, 6.6, 6.0, Shapes.heart);
  b.ring(K.cherry, 6.5, 12.0, 4.0);
  b.ring(K.cherry, 6.5, 12.0, 4.35);
  b.fill(K.lemonSlice, 3.2, 4.8, 3.4, 3.4, Shapes.flower);
  b.fill(K.orangeSlice, 9.8, 4.8, 3.4, 3.4, Shapes.flower);
  b.line(K.banana, 1.2, 18.6, 11.8, 18.6, across: true);
  b.line(K.cherry, 6.5, 2.4, 6.5, 7.0);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.mint,
    goals: [b.all(K.cherry), b.all(K.lemonSlice)],
  );
}

Level _harvest(int n) {
  final b = LevelBuilder(14, 21);
  for (var row = 0; row < 5; row++) {
    b.line(K.corn, 1.2, 3.0 + row * 0.5, 12.8, 3.0 + row * 0.5, across: true);
  }
  b.grid(K.cabbage, 3.6, 12.0, 3, 3, gap: 1.12);
  b.grid(K.pumpkin, 10.3, 12.0, 2, 2, gap: 1.15);
  b.spiral(K.eggplant, 7.0, 17.4, 0.4, 2.8, turns: 2.8);
  b.ring(K.pepper, 10.3, 12.0, 1.9);
  b.ring(K.pepper, 10.3, 12.0, 2.35);
  b.grid(K.tomato, 7.0, 7.6, 14, 3);
  b.grid(K.carrot, 1.4, 17.4, 2, 7, yaw: math.pi / 2);
  b.grid(K.carrot, 12.6, 17.4, 2, 7, yaw: math.pi / 2);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.grass,
    goals: [b.all(K.pumpkin), b.all(K.corn)],
  );
}

Level _blockCity(int n) {
  final b = LevelBuilder(13, 20);
  final rng = math.Random(11);
  const colors = [K.blockRed, K.blockBlue, K.blockGreen, K.blockYellow];
  for (var gy = 0; gy < 3; gy++) {
    for (var gx = 0; gx < 3; gx++) {
      final bx = 2.4 + gx * 4.1, by = 6.4 + gy * 4.4;
      for (var j = 0; j < 3; j++) {
        for (var i = 0; i < 3; i++) {
          final h = 1 + rng.nextInt(4);
          b.tower(
            [(colors[rng.nextInt(4)], h), (K.blockYellow, 1)],
            bx + (i - 1) * 0.38,
            by + (j - 1) * 0.38,
          );
        }
      }
    }
  }
  b.line(K.carYellow, 1.0, 3.4, 12.0, 3.4);
  b.line(K.carBlue, 1.0, 8.6, 12.0, 8.6);
  b.line(K.carRed, 1.0, 13.0, 12.0, 13.0);
  for (final x in [2.0, 6.5, 11.0]) {
    b.put(K.teddy, x, 18.8);
  }
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.sand,
    goals: [b.all(K.blockYellow), b.all(K.teddy)],
  );
}

Level _grandBuffet(int n) {
  final b = LevelBuilder(14, 21);
  b.pyramid(K.maki, 3.6, 16.2, 5);
  b.ring(K.nigiriTamago, 3.6, 16.2, 1.9);
  b.grid(K.donut, 10.4, 16.2, 3, 3, layers: 3);
  b.ring(K.macaronBlue, 10.4, 16.2, 1.7);
  b.ring(K.macaronBlue, 10.4, 16.2, 2.1);
  b.rings([K.apple, K.orange, K.greenApple], 7.0, 9.8, 0.3, 6);
  b.spiral(K.carrot, 3.0, 4.4, 0.3, 2.0, turns: 2.2);
  b.fill(K.strawberry, 11.0, 4.4, 3.6, 3.6, Shapes.heart);
  b.put(K.watermelon, 7.0, 3.6);
  b.put(K.pie, 7.0, 16.2);
  b.removeOverlaps();
  return b.build(
    number: n,
    theme: MapTheme.pink,
    goals: [b.all(K.greenApple), b.all(K.maki), b.all(K.strawberry)],
  );
}
