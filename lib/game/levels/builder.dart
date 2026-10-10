import 'dart:math' as math;
import 'dart:ui';

import '../model/item.dart';
import '../model/item_kind.dart';
import 'level.dart';

typedef Shape = bool Function(double u, double v);

/// Lays out items in the patterns the levels are made of: rings, spirals,
/// grids, towers, pyramids and filled shapes.
class LevelBuilder {
  LevelBuilder(this.width, this.height);

  final double width, height;
  final List<Item> items = [];

  int count(ItemKind kind) => items.where((i) => i.kind == kind).length;

  GoalSpec all(ItemKind kind) => GoalSpec(kind, count(kind));

  Item put(ItemKind kind, double x, double y, {double yaw = 0, Item? on}) {
    final z = on == null ? 0.0 : on.z + on.kind.h;
    final item = Item(kind, x, y, z: z, yaw: yaw, below: on);
    items.add(item);
    return item;
  }

  /// A straight stack of [n] items. Returns the top one.
  Item column(ItemKind kind, double x, double y, int n, {double yaw = 0, Item? on}) {
    var top = on;
    for (var i = 0; i < n; i++) {
      top = put(kind, x, y, yaw: yaw, on: top);
    }
    return top!;
  }

  /// A stack of different items, bottom first.
  Item tower(List<(ItemKind, int)> layers, double x, double y, {double yaw = 0}) {
    Item? top;
    for (final (kind, n) in layers) {
      top = column(kind, x, y, n, yaw: yaw, on: top);
    }
    return top!;
  }

  /// Items around a circle, lying along it (or pointing out if [radial]).
  void ring(
    ItemKind kind,
    double cx,
    double cy,
    double radius, {
    double gap = 1.08,
    double phase = 0,
    bool radial = false,
    int layers = 1,
  }) {
    final along = radial ? kind.fit * 2 : kind.r * 2;
    final n = math.max(3, (2 * math.pi * radius / (along * gap)).floor());
    for (var i = 0; i < n; i++) {
      final a = phase + 2 * math.pi * i / n;
      column(
        kind,
        cx + math.cos(a) * radius,
        cy + math.sin(a) * radius,
        layers,
        yaw: radial ? a : a + math.pi / 2,
      );
    }
  }

  /// Concentric rings from [r0] outwards, cycling through [kinds].
  /// Returns the radius after the last ring.
  double rings(
    List<ItemKind> kinds,
    double cx,
    double cy,
    double r0,
    int count, {
    double spacing = 1.12,
    bool radial = false,
  }) {
    var r = r0;
    for (var i = 0; i < count; i++) {
      final kind = kinds[i % kinds.length];
      final depth = radial ? kind.r * 2 : kind.fit * 2;
      r += depth * spacing / 2;
      ring(kind, cx, cy, r, radial: radial, phase: i * 0.37);
      r += depth * spacing / 2;
    }
    return r;
  }

  /// An Archimedean spiral of items from radius [r0] to [r1].
  void spiral(
    ItemKind kind,
    double cx,
    double cy,
    double r0,
    double r1, {
    double turns = 3,
    double gap = 1.1,
    double phase = 0,
    bool radial = false,
  }) {
    final total = turns * 2 * math.pi;
    final step = (radial ? kind.fit * 2 : kind.r * 2) * gap;
    var a = 0.0;
    while (a <= total) {
      final r = r0 + (r1 - r0) * a / total;
      final angle = phase + a;
      put(
        kind,
        cx + math.cos(angle) * r,
        cy + math.sin(angle) * r,
        yaw: radial ? angle : angle + math.pi / 2,
      );
      a += step / math.max(r, 0.3);
    }
  }

  /// A rectangular block of [cols] x [rows] columns, [layers] high.
  void grid(
    ItemKind kind,
    double cx,
    double cy,
    int cols,
    int rows, {
    double gap = 1.06,
    int layers = 1,
    double yaw = 0,
  }) {
    final dx = (kind.rotates ? kind.r * 2 : kind.r * 2) * gap;
    final dy = (kind.rotates ? kind.fit * 2 : kind.r * 2) * gap;
    for (var j = 0; j < rows; j++) {
      for (var i = 0; i < cols; i++) {
        column(
          kind,
          cx + (i - (cols - 1) / 2) * dx,
          cy + (j - (rows - 1) / 2) * dy,
          layers,
          yaw: yaw,
        );
      }
    }
  }

  /// Fills a shape with a hexagonal pattern of columns. [shape] receives
  /// u, v in [-1, 1] across a box of [w] x [h] centred at cx, cy.
  void fill(
    ItemKind kind,
    double cx,
    double cy,
    double w,
    double h,
    Shape shape, {
    double gap = 1.06,
    int layers = 1,
    double yaw = 0,
  }) {
    final d = kind.r * 2 * gap;
    final rowH = d * 0.866;
    var row = 0;
    for (var y = cy - h / 2; y <= cy + h / 2; y += rowH, row++) {
      final offset = row.isOdd ? d / 2 : 0.0;
      for (var x = cx - w / 2 + offset; x <= cx + w / 2; x += d) {
        if (shape((x - cx) / (w / 2), (y - cy) / (h / 2))) {
          column(kind, x, y, layers, yaw: yaw);
        }
      }
    }
  }

  void disc(ItemKind kind, double cx, double cy, double radius, {double gap = 1.06, int layers = 1}) =>
      fill(kind, cx, cy, radius * 2, radius * 2, Shapes.circle, gap: gap, layers: layers);

  /// A square pyramid: each layer one item narrower, resting on the layer
  /// below.
  void pyramid(ItemKind kind, double cx, double cy, int base, {double gap = 1.04}) {
    final d = kind.r * 2 * gap;
    var below = <(double, double, Item)>[];
    for (var layer = 0; layer < base; layer++) {
      final n = base - layer;
      final next = <(double, double, Item)>[];
      for (var j = 0; j < n; j++) {
        for (var i = 0; i < n; i++) {
          final x = cx + (i - (n - 1) / 2) * d;
          final y = cy + (j - (n - 1) / 2) * d;
          Item? on;
          if (below.isNotEmpty) {
            var best = double.infinity;
            for (final (bx, by, b) in below) {
              final dist = (bx - x) * (bx - x) + (by - y) * (by - y);
              if (dist < best) {
                best = dist;
                on = b;
              }
            }
          }
          next.add((x, y, put(kind, x, y, on: on)));
        }
      }
      below = next;
    }
  }

  /// Items in a straight line, pointing along it.
  void line(
    ItemKind kind,
    double x0,
    double y0,
    double x1,
    double y1, {
    double gap = 1.1,
    int layers = 1,
    bool across = false,
  }) {
    final len = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
    final along = (across ? kind.fit : kind.r) * 2 * gap;
    final n = math.max(1, (len / along).floor() + 1);
    final yaw = math.atan2(y1 - y0, x1 - x0) + (across ? math.pi / 2 : 0);
    for (var i = 0; i < n; i++) {
      final t = n == 1 ? 0.5 : i / (n - 1);
      column(kind, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, layers, yaw: yaw);
    }
  }

  /// Drops up to [n] items at random free spots inside [area].
  void scatter(List<ItemKind> kinds, int n, Rect area, math.Random rng, {double spacing = 1.15}) {
    var placed = 0;
    for (var tries = 0; placed < n && tries < n * 40; tries++) {
      final kind = kinds[rng.nextInt(kinds.length)];
      final x = area.left + rng.nextDouble() * area.width;
      final y = area.top + rng.nextDouble() * area.height;
      if (!isFree(x, y, kind.r * spacing)) continue;
      put(kind, x, y, yaw: rng.nextDouble() * math.pi * 2);
      placed++;
    }
  }

  bool isFree(double x, double y, double r) {
    if (x < r || y < r || x > width - r || y > height - r) return false;
    for (final it in items) {
      final min = r + it.kind.r * 0.9;
      final dx = it.x - x, dy = it.y - y;
      if (dx * dx + dy * dy < min * min) return false;
    }
    return true;
  }

  /// Drops items that overlap something placed before them (keeps the
  /// first), and anything outside the arena.
  void removeOverlaps({double tolerance = 0.82}) {
    final kept = <Item>{};
    final cell = 0.6;
    final grid = <int, List<Item>>{};
    int key(int cx, int cy) => cx * 10007 + cy;
    for (final it in items) {
      final r = it.kind.r;
      if (it.x < r * 0.5 || it.y < r * 0.5 || it.x > width - r * 0.5 || it.y > height - r * 0.5) {
        it.below?.supports--;
        continue;
      }
      if (it.below != null) {
        if (kept.contains(it.below)) {
          kept.add(it);
        } else {
          it.below?.supports--;
        }
        continue;
      }
      final gx = (it.x / cell).floor(), gy = (it.y / cell).floor();
      var ok = true;
      for (var i = gx - 2; i <= gx + 2 && ok; i++) {
        for (var j = gy - 2; j <= gy + 2 && ok; j++) {
          for (final o in grid[key(i, j)] ?? const <Item>[]) {
            final min = (r + o.kind.r) * tolerance;
            final dx = o.x - it.x, dy = o.y - it.y;
            if (dx * dx + dy * dy < min * min) {
              ok = false;
              break;
            }
          }
        }
      }
      if (!ok) continue;
      kept.add(it);
      grid.putIfAbsent(key(gx, gy), () => []).add(it);
    }
    items
      ..clear()
      ..addAll(kept);
  }

  Level build({
    required int number,
    required MapTheme theme,
    required List<GoalSpec> goals,
    double time = 0,
    Offset? holeStart,
    double holeRadius = 0.5,
  }) {
    return Level(
      number: number,
      theme: theme,
      width: width,
      height: height,
      items: items,
      goals: goals,
      time: time,
      holeStart: holeStart ?? Offset(width / 2, 1.6),
      holeRadius: holeRadius,
    );
  }
}

/// Shape masks for [LevelBuilder.fill], over u, v in [-1, 1].
abstract final class Shapes {
  static bool circle(double u, double v) => u * u + v * v <= 1;

  static bool square(double u, double v) => u.abs() <= 1 && v.abs() <= 1;

  static bool diamond(double u, double v) => u.abs() + v.abs() <= 1;

  static bool ringBand(double u, double v) {
    final d = u * u + v * v;
    return d <= 1 && d >= 0.36;
  }

  static bool heart(double u, double v) {
    final x = u * 1.25, y = v * 1.25 + 0.2;
    final a = x * x + y * y - 1;
    return a * a * a - x * x * y * y * y <= 0;
  }

  static bool star(double u, double v) {
    final r = math.sqrt(u * u + v * v);
    final a = math.atan2(v, u) - math.pi / 2;
    final edge = 0.55 + 0.45 * math.pow(math.cos(2.5 * a).abs(), 3);
    return r <= edge;
  }

  static bool flower(double u, double v) {
    final r = math.sqrt(u * u + v * v);
    final a = math.atan2(v, u);
    return r <= 0.62 + 0.38 * math.cos(5 * a).abs();
  }

  /// Two wings each side of a thin body, the upper ones bigger.
  static bool butterfly(double u, double v) {
    bool ellipse(double cx, double cy, double rx, double ry) {
      final dx = (u - cx) / rx, dy = (v - cy) / ry;
      return dx * dx + dy * dy <= 1;
    }

    if (u.abs() < 0.08) return false;
    return ellipse(-0.5, 0.35, 0.48, 0.55) ||
        ellipse(0.5, 0.35, 0.48, 0.55) ||
        ellipse(-0.42, -0.5, 0.38, 0.42) ||
        ellipse(0.42, -0.5, 0.38, 0.42);
  }
}
