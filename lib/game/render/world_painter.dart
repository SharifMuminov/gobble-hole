import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../engine/world.dart';
import '../levels/level.dart';
import '../model/hole_skin.dart';
import '../model/item.dart';
import 'sprite_atlas.dart';

/// Draws the ground, the hole and every item of a [GameWorld].
///
/// Order: ground → shadows → hole → items behind the hole → items falling
/// into it (clipped to the opening) → items in front of it.
class WorldPainter extends CustomPainter {
  WorldPainter({required this.world, required this.skin, required super.repaint});

  final GameWorld world;
  final HoleSkin skin;

  static final _checkers = <MapTheme, ui.Image>{};

  // Reused per-frame buffers.
  static var _cap = 0;
  static var _depth = Float64List(0);
  static var _xform = Float32List(0);
  static var _rects = Float32List(0);
  static var _sXform = Float32List(0);
  static var _sRects = Float32List(0);
  static var _sColors = Int32List(0);
  static var _shXform = Float32List(0);
  static var _shRects = Float32List(0);
  static final _sortedItems = <Item>[];
  static final _sinking = <Item>[];
  static final _order = <int>[];
  static final _p = [0.0, 0.0];

  static void _ensure(int n) {
    if (n <= _cap) return;
    _cap = n + 256;
    _depth = Float64List(_cap);
    _xform = Float32List(_cap * 4);
    _rects = Float32List(_cap * 4);
    _sXform = Float32List(_cap * 4);
    _sRects = Float32List(_cap * 4);
    _sColors = Int32List(_cap);
    _shXform = Float32List(_cap * 4);
    _shRects = Float32List(_cap * 4);
  }

  final _atlasPaint = Paint()..filterQuality = FilterQuality.medium;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = world.camera;
    if (cam.size != size) {
      cam.setViewport(size);
      cam.lookAt(world.camX, world.camY, world.camDist == 0 ? cam.distanceForWidth(8) : world.camDist);
    }
    final theme = world.level.theme;
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.outside);

    final matrix = cam.groundMatrix();
    final visible = cam.visibleGround(margin: 2);

    canvas.save();
    canvas.transform(matrix);
    canvas.clipRect(visible);
    _paintGround(canvas, theme);
    canvas.restore();

    _paintItems(canvas, size, matrix, visible);
  }

  void _paintGround(Canvas canvas, MapTheme theme) {
    final level = world.level;
    final arena = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, level.width, level.height),
      const Radius.circular(0.9),
    );
    canvas.drawRRect(
      arena.inflate(0.42),
      Paint()..color = Color.lerp(theme.outside, const Color(0xFF000000), 0.12)!,
    );
    canvas.drawRRect(arena.inflate(0.32), Paint()..color = theme.border);
    canvas.drawRRect(
      arena,
      Paint()
        ..shader = ImageShader(
          _checker(theme),
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.diagonal3Values(1.3 / 32, 1.3 / 32, 1).storage,
          filterQuality: FilterQuality.medium,
        ),
    );
  }

  static ui.Image _checker(MapTheme theme) {
    return _checkers.putIfAbsent(theme, () {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      final a = Paint()..color = theme.ground;
      final b = Paint()..color = theme.groundAlt;
      c.drawRect(const Rect.fromLTWH(0, 0, 64, 64), a);
      c.drawRect(const Rect.fromLTWH(32, 0, 32, 32), b);
      c.drawRect(const Rect.fromLTWH(0, 32, 32, 32), b);
      return rec.endRecording().toImageSync(64, 64);
    });
  }

  void _paintHole(Canvas canvas, double hx, double hy, double r) {
    final c = Offset(hx, hy);
    // Soft shade around the rim.
    canvas.drawCircle(
      c,
      r * 1.38,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 1.38, const [
          Color(0x40000000),
          Color(0x22000000),
          Color(0x00000000),
        ], [0.72, 0.84, 1]),
    );
    // Rim with a lit far side.
    canvas.drawCircle(c, r * 1.13, Paint()..color = skin.rimShade);
    canvas.drawCircle(
      c,
      r * 1.1,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(hx, hy + r),
          Offset(hx, hy - r),
          [Color.lerp(skin.rim, const Color(0xFFFFFFFF), 0.5)!, skin.rim],
        ),
    );
    // Growth ring.
    final progress = world.growthProgress;
    if (world.sizeStep < world.maxStep && progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 1.055),
        math.pi / 2,
        -2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.05
          ..strokeCap = StrokeCap.round
          ..color = skin.accent,
      );
    }
    canvas.drawCircle(c, r * 1.01, Paint()..color = skin.rimShade);
    // The far inner wall shows as a lighter crescent.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(hx, hy + r),
          Offset(hx, hy),
          const [Color(0xFF3B3B4A), Color(0xFF15151C)],
        ),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(
      Offset(hx, hy - r * 0.3),
      r * 1.02,
      Paint()
        ..shader = ui.Gradient.radial(Offset(hx, hy - r * 0.3), r * 1.02, const [
          Color(0xFF000000),
          Color(0xFF07070B),
        ]),
    );
    canvas.restore();
  }

  void _paintItems(Canvas canvas, Size size, Float64List matrix, Rect visible) {
    final atlas = SpriteAtlas.instance;
    final cam = world.camera;
    final items = world.items;
    _ensure(items.length);

    final cosP = math.cos(kCameraPitch), sinP = math.sin(kCameraPitch);
    final camX = cam.camX, camY = cam.camY, camZ = cam.camZ;
    final f = cam.focal, cx = cam.centerX, cy = cam.centerY;
    final w = size.width, h = size.height;
    final hx = world.holeX, hy = world.holeY, hr = world.radius;
    final rects = atlas.rects;

    // Shadows of items on the ground, and the sorted list of the rest.
    var shadows = 0;
    _sortedItems.clear();
    _sinking.clear();
    final sh = atlas.shadow;
    final shTile = sh.width;
    for (final it in items) {
      final st = it.state;
      if (st == ItemState.gone) continue;
      if (it.x < visible.left || it.x > visible.right || it.y < visible.top || it.y > visible.bottom) {
        continue;
      }
      if (st == ItemState.sinking) {
        _sinking.add(it);
        continue;
      }
      _sortedItems.add(it);
      if (it.below != null) continue;
      final k = it.kind;
      final gx = it.x + k.r * 0.12, gy = it.y - k.r * 0.12;
      final ry = gy - camY, rz = -camZ;
      final zc = ry * cosP - rz * sinP;
      if (zc <= 0.05) continue;
      final s = f / zc;
      final sx = cx + (gx - camX) * s;
      final sy = cy - (ry * sinP + rz * cosP) * s;
      final scale = k.r * 2.5 * s / shTile;
      final o = shadows * 4;
      _shXform[o] = scale;
      _shXform[o + 1] = 0;
      _shXform[o + 2] = sx - scale * shTile / 2;
      _shXform[o + 3] = sy - scale * shTile / 2;
      _shRects[o] = sh.left;
      _shRects[o + 1] = sh.top;
      _shRects[o + 2] = sh.right;
      _shRects[o + 3] = sh.bottom;
      shadows++;
    }
    if (shadows > 0) {
      canvas.drawRawAtlas(
        atlas.image,
        Float32List.sublistView(_shXform, 0, shadows * 4),
        Float32List.sublistView(_shRects, 0, shadows * 4),
        null,
        null,
        null,
        _atlasPaint,
      );
    }

    canvas.save();
    canvas.transform(matrix);
    _paintHole(canvas, hx, hy, hr);
    canvas.restore();

    // Project and sort standing items, far to near.
    var n = 0;
    final list = _sortedItems;
    _order.clear();
    for (var i = 0; i < list.length; i++) {
      final it = list[i];
      _depth[i] = (it.y - camY) * cosP - (it.z + it.kind.h / 2 - camZ) * sinP;
      _order.add(i);
    }
    _order.sort((a, b) => _depth[b].compareTo(_depth[a]));

    final holeDepth = (hy - camY) * cosP + camZ * sinP;
    var split = -1;
    for (final i in _order) {
      final it = list[i];
      final k = it.kind;
      final ry = it.y - camY, rz = it.z + k.h / 2 - camZ;
      final zc = _depth[i];
      if (zc <= 0.05) continue;
      final s = f / zc;
      final sx = cx + (it.x - camX) * s;
      final sy = cy - (ry * sinP + rz * cosP) * s;
      final half = k.sprite * s * 0.6;
      if (sx < -half || sx > w + half || sy < -half || sy > h + half) continue;
      if (split < 0 && zc < holeDepth) split = n;
      _write(_xform, _rects, n, rects[k.index], k.sprite * s, sx, sy, it.screenAngle + it.tilt);
      n++;
    }
    if (split < 0) split = n;

    if (split > 0) _draw(canvas, atlas.image, _xform, _rects, null, 0, split);

    // Falling items, clipped to the opening (and free above its centre
    // line, where they still stick out of the hole).
    if (_sinking.isNotEmpty) {
      var m = 0;
      // Deeper and farther first.
      double depth(Item it) => (it.y - camY) * cosP - (it.z + it.kind.h / 2 - camZ) * sinP;
      _sinking.sort((a, b) => depth(b).compareTo(depth(a)));
      for (final it in _sinking) {
        final k = it.kind;
        final ry = it.y - camY, rz = it.z + k.h / 2 - camZ;
        final zc = ry * cosP - rz * sinP;
        if (zc <= 0.05) continue;
        final s = f / zc;
        final sx = cx + (it.x - camX) * s;
        final sy = cy - (ry * sinP + rz * cosP) * s;
        _write(_sXform, _sRects, m, rects[k.index], k.sprite * s, sx, sy, it.screenAngle + it.tilt);
        final top = it.z + k.h;
        final dark = top >= 0 ? 0.0 : (-top / (hr * 1.2 + 0.3)).clamp(0.0, 0.8);
        final v = (255 * (1 - dark)).round();
        _sColors[m] = 0xFF000000 | (v << 16) | (v << 8) | v;
        m++;
      }
      if (m > 0) {
        canvas.save();
        canvas.clipPath(_holeClip(hx, hy, hr));
        _draw(canvas, atlas.image, _sXform, _sRects, _sColors, 0, m);
        canvas.restore();
      }
    }

    if (n > split) _draw(canvas, atlas.image, _xform, _rects, null, split, n);
  }

  Path _holeClip(double hx, double hy, double r) {
    final cam = world.camera;
    final opening = Path();
    const segments = 40;
    for (var i = 0; i <= segments; i++) {
      final a = 2 * math.pi * i / segments;
      cam.project(hx + math.cos(a) * r * 1.01, hy + math.sin(a) * r * 1.01, 0, _p);
      if (i == 0) {
        opening.moveTo(_p[0], _p[1]);
      } else {
        opening.lineTo(_p[0], _p[1]);
      }
    }
    opening.close();
    cam.project(hx - r * 1.01, hy, 0, _p);
    final left = _p[0], mid = _p[1];
    cam.project(hx + r * 1.01, hy, 0, _p);
    final above = Path()..addRect(Rect.fromLTRB(left, -10000, _p[0], mid));
    return Path.combine(PathOperation.union, opening, above);
  }

  static void _write(
    Float32List xf,
    Float32List rc,
    int i,
    Rect src,
    double worldPx,
    double sx,
    double sy,
    double angle,
  ) {
    final scale = worldPx / src.width;
    final scos = math.cos(angle) * scale;
    final ssin = math.sin(angle) * scale;
    final ax = src.width / 2, ay = src.height / 2;
    final o = i * 4;
    xf[o] = scos;
    xf[o + 1] = ssin;
    xf[o + 2] = sx - scos * ax + ssin * ay;
    xf[o + 3] = sy - ssin * ax - scos * ay;
    rc[o] = src.left;
    rc[o + 1] = src.top;
    rc[o + 2] = src.right;
    rc[o + 3] = src.bottom;
  }

  void _draw(Canvas canvas, ui.Image image, Float32List xf, Float32List rc, Int32List? colors, int from, int to) {
    canvas.drawRawAtlas(
      image,
      Float32List.sublistView(xf, from * 4, to * 4),
      Float32List.sublistView(rc, from * 4, to * 4),
      colors == null ? null : Int32List.sublistView(colors, from, to),
      colors == null ? null : BlendMode.modulate,
      null,
      _atlasPaint,
    );
  }

  @override
  bool shouldRepaint(WorldPainter oldDelegate) =>
      oldDelegate.world != world || oldDelegate.skin != skin;
}
