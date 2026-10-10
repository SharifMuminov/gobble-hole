import 'dart:math' as math;
import 'dart:ui';

import '../model/item_kind.dart';
import 'builder.dart';
import 'level.dart';

/// The items one map theme is made of.
class _Palette {
  const _Palette(this.theme, {required this.small, required this.stack, required this.big});

  final MapTheme theme;

  /// Loose items for rings, spirals, lines and fills.
  final List<ItemKind> small;

  /// Flat items that look good in towers.
  final List<ItemKind> stack;

  /// Large items the hole has to grow for.
  final List<ItemKind> big;
}

const _palettes = [
  _Palette(
    MapTheme.pink,
    small: [ItemKind.apple, ItemKind.orange, ItemKind.lemon, ItemKind.avocado, ItemKind.watermelonSlice, ItemKind.cherry],
    stack: [ItemKind.orangeSlice, ItemKind.lemonSlice, ItemKind.kiwiSlice],
    big: [ItemKind.watermelon, ItemKind.jamJar, ItemKind.pineapple],
  ),
  _Palette(
    MapTheme.grass,
    small: [ItemKind.carrot, ItemKind.tomato, ItemKind.pepper, ItemKind.onion, ItemKind.broccoli, ItemKind.eggplant, ItemKind.corn],
    stack: [],
    big: [ItemKind.cabbage, ItemKind.pumpkin],
  ),
  _Palette(
    MapTheme.purple,
    small: [ItemKind.cupcake, ItemKind.cocoaMug, ItemKind.milkshake, ItemKind.macaronPink, ItemKind.macaronBlue],
    stack: [ItemKind.donut, ItemKind.donutChoco, ItemKind.waffle, ItemKind.pancakes, ItemKind.cookie, ItemKind.macaronYellow],
    big: [ItemKind.pie, ItemKind.cake],
  ),
  _Palette(
    MapTheme.ocean,
    small: [ItemKind.nigiriSalmon, ItemKind.nigiriTamago, ItemKind.shrimp, ItemKind.wasabi],
    stack: [ItemKind.maki, ItemKind.makiCucumber],
    big: [ItemKind.onigiri, ItemKind.soyDish],
  ),
  _Palette(
    MapTheme.sand,
    small: [ItemKind.carRed, ItemKind.carBlue, ItemKind.carYellow, ItemKind.duck, ItemKind.ball],
    stack: [ItemKind.blockRed, ItemKind.blockBlue, ItemKind.blockGreen, ItemKind.blockYellow],
    big: [ItemKind.teddy],
  ),
  _Palette(
    MapTheme.sky,
    small: [ItemKind.strawberry, ItemKind.greenApple, ItemKind.banana, ItemKind.cherry, ItemKind.lemon],
    stack: [ItemKind.orangeSlice, ItemKind.kiwiSlice, ItemKind.lemonSlice],
    big: [ItemKind.watermelon, ItemKind.pineapple],
  ),
  _Palette(
    MapTheme.mint,
    small: [ItemKind.strawberry, ItemKind.cupcake, ItemKind.cherry, ItemKind.macaronPink, ItemKind.apple],
    stack: [ItemKind.donut, ItemKind.cookie, ItemKind.kiwiSlice, ItemKind.pancakes],
    big: [ItemKind.cake, ItemKind.watermelon],
  ),
];

const _shapes = [Shapes.heart, Shapes.star, Shapes.flower, Shapes.circle, Shapes.diamond, Shapes.ringBand];

/// A new level for every number past the hand-made ones, always the same for
/// the same number.
Level generateLevel(int number) {
  final rng = math.Random(number * 7919 + 17);
  final palette = _palettes[(number + rng.nextInt(2)) % _palettes.length];
  final hard = math.min(1.0, (number - 12) / 60);

  final width = 12.0 + (rng.nextDouble() * 2 * (0.5 + hard)).roundToDouble();
  final height = 17.0 + (rng.nextDouble() * 3 * (0.5 + hard)).roundToDouble();
  final b = LevelBuilder(width, height);

  // Features go into a grid of cells above the starting area.
  const cols = 2;
  final rows = height > 19 ? 3 : 2;
  final top = height - 0.6, bottom = 3.4;
  final cellW = (width - 1) / cols, cellH = (top - bottom) / rows;

  T pick<T>(List<T> list) => list[rng.nextInt(list.length)];
  ItemKind smallKind() => pick(palette.small);
  ItemKind stackKind() => palette.stack.isEmpty ? smallKind() : pick(palette.stack);

  final cells = [
    for (var r = 0; r < rows; r++)
      for (var c = 0; c < cols; c++) (0.5 + cellW * (c + 0.5), bottom + cellH * (r + 0.5)),
  ]..shuffle(rng);

  // One wide centre-piece in about half the levels.
  if (rng.nextBool()) {
    final cy = bottom + (top - bottom) * (0.45 + rng.nextDouble() * 0.2);
    _centrePiece(b, rng, palette, width / 2, cy, math.min(width, top - bottom) * 0.3, stackKind, smallKind);
    cells.removeWhere((c) => (c.$2 - cy).abs() < cellH * 0.7);
  }

  for (final (cx, cy) in cells) {
    final size = math.min(cellW, cellH) * 0.48;
    switch (rng.nextInt(7)) {
      case 0:
        final a = smallKind(), c = smallKind();
        final count = math.max(2, (size / (math.max(a.fit, c.fit) * 2 * 1.12)).floor());
        b.put(a, cx, cy);
        b.rings([a, c], cx, cy, a.r, count, radial: rng.nextBool());
      case 1:
        final k = smallKind();
        b.spiral(k, cx, cy, 0.3, size, turns: math.max(1.5, (size - 0.3) / (k.r * 2.4)), phase: rng.nextDouble() * 6);
      case 2:
        final k = stackKind();
        final n = (size * 2 / (k.r * 2.2)).floor().clamp(2, 7);
        b.grid(k, cx, cy, n, n, layers: 2 + rng.nextInt(2 + (hard * 2).round()));
      case 3:
        final k = stackKind();
        b.pyramid(k, cx, cy, (size * 2 / (k.r * 2.1)).floor().clamp(3, 7));
      case 4:
        b.fill(smallKind(), cx, cy, size * 2.2, size * 2.2, pick(_shapes));
      case 5:
        final k = smallKind();
        final lines = math.max(2, (size * 2 / (k.fit * 2 * 1.5)).floor());
        final across = rng.nextBool();
        for (var i = 0; i < lines; i++) {
          final y = cy - size + (i + 0.5) * size * 2 / lines;
          b.line(k, cx - size, y, cx + size, y, across: across);
        }
      default:
        final k = smallKind(), c = smallKind();
        b.disc(k, cx, cy, size * 0.6);
        b.ring(c, cx, cy, size * 0.6 + c.r * 1.6);
        b.ring(c, cx, cy, size * 0.6 + c.r * 3.8);
    }
  }

  // A row of something along the bottom, either side of the start.
  final row = smallKind();
  b.line(row, 0.8, 2.8, width / 2 - 1.2, 2.8);
  b.line(row, width / 2 + 1.2, 2.8, width - 0.8, 2.8);

  // Big items to grow into, then loose filler.
  final bigCount = 2 + rng.nextInt(3);
  b.scatter(palette.big, bigCount, Rect.fromLTRB(0.8, bottom, width - 0.8, top), rng, spacing: 1.3);
  b.scatter(palette.small, 30 + (hard * 30).round(), Rect.fromLTRB(0.5, 0.5, width - 0.5, top), rng);
  // Keep the start clear.
  b.items.removeWhere((i) => i.below == null && (i.x - width / 2).abs() < 1.0 && i.y < 2.6);
  b.removeOverlaps();

  // Goals: two or three kinds that are on the map in fair numbers.
  final counts = <ItemKind, int>{};
  for (final it in b.items) {
    counts[it.kind] = (counts[it.kind] ?? 0) + 1;
  }
  final candidates = counts.entries.where((e) => e.value >= 6 && e.value <= 180).toList()..shuffle(rng);
  final goalCount = number > 30 ? 3 : 2;
  final goals = [for (final e in candidates.take(goalCount)) GoalSpec(e.key, e.value)];
  if (goals.isEmpty) {
    final most = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    goals.add(GoalSpec(most.key, most.value));
  }

  return b.build(number: number, theme: palette.theme, goals: goals);
}

void _centrePiece(
  LevelBuilder b,
  math.Random rng,
  _Palette palette,
  double cx,
  double cy,
  double size,
  ItemKind Function() stackKind,
  ItemKind Function() smallKind,
) {
  if (palette.big.isNotEmpty && rng.nextBool()) {
    // A big item crowned in rings.
    b.put(palette.big[rng.nextInt(palette.big.length)], cx, cy);
    b.rings([smallKind(), smallKind(), smallKind()], cx, cy, 0.7, 3 + rng.nextInt(2));
  } else {
    // A cluster of towers.
    final k = stackKind();
    final n = 3 + rng.nextInt(2);
    b.grid(k, cx, cy, n, n, layers: 4 + rng.nextInt(6));
    b.ring(smallKind(), cx, cy, n * k.r * 1.2 + 0.5);
    b.ring(smallKind(), cx, cy, n * k.r * 1.2 + 1.0);
  }
}
