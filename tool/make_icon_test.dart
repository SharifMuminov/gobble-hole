// Draws the app icon in code and writes the layers as 1024 px PNGs.
//
//   flutter test tool/make_icon_test.dart --dart-define=OUT=build/icon
//   python3 tool/install_icons.py build/icon
//
// Layers: icon_full.png (iOS, legacy Android), icon_fg.png and icon_bg.png
// (Android adaptive icon).
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hole_it_clone/game/model/item_kind.dart';
import 'package:hole_it_clone/game/render/item_art.dart';

const _size = 1024.0;

void main() {
  const out = String.fromEnvironment('OUT', defaultValue: 'build/icon');

  testWidgets('make icon', (tester) async {
    await tester.runAsync(() async {
      Directory(out).createSync(recursive: true);
      await _write('$out/icon_full.png', (c) {
        _background(c);
        _foreground(c, 1);
      });
      await _write('$out/icon_bg.png', _background);
      // Adaptive icons crop to the middle ~66%: keep the art inside it.
      await _write('$out/icon_fg.png', (c) => _foreground(c, 0.64));
    });
  });
}

Future<void> _write(String path, void Function(Canvas) paint) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec)..scale(_size);
  paint(canvas);
  final image = await rec.endRecording().toImage(_size.toInt(), _size.toInt());
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(png!.buffer.asUint8List());
}

/// Pink-to-violet sky with soft rays from behind the hole.
void _background(Canvas c) {
  const rect = Rect.fromLTWH(0, 0, 1, 1);
  c.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8FC4), Color(0xFFFF5C9E), Color(0xFF8D5BFF)],
        stops: [0, 0.45, 1],
      ).createShader(rect),
  );
  const center = Offset(0.5, 0.62);
  final ray = Paint()..color = const Color(0x1FFFFFFF);
  for (var i = 0; i < 12; i++) {
    final a = i * math.pi / 6;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + math.cos(a - 0.13) * 1.2, center.dy + math.sin(a - 0.13) * 1.2)
      ..lineTo(center.dx + math.cos(a + 0.13) * 1.2, center.dy + math.sin(a + 0.13) * 1.2)
      ..close();
    c.drawPath(path, ray);
  }
  c.drawCircle(
    center,
    0.55,
    Paint()
      ..shader = ui.Gradient.radial(center, 0.55, const [Color(0x55FFFFFF), Color(0x00FFFFFF)]),
  );
}

/// The hole with food tumbling into it. [scale] shrinks it about the centre.
void _foreground(Canvas c, double scale) {
  c.save();
  c.translate(0.5, 0.5);
  c.scale(scale);
  c.translate(-0.5, -0.5);

  const hc = Offset(0.5, 0.66);
  const rx = 0.36, ry = 0.2;
  final opening = Rect.fromCenter(center: hc, width: rx * 2, height: ry * 2);

  // Shadow, rim, inner wall, mouth.
  c.drawOval(opening.inflate(0.06).shift(const Offset(0, 0.025)), Paint()..color = const Color(0x44300040));
  c.drawOval(
    Rect.fromCenter(center: hc, width: rx * 2.3, height: ry * 2.36),
    Paint()..color = const Color(0xFFC9CAD6),
  );
  c.drawOval(
    Rect.fromCenter(center: hc.translate(0, -0.006), width: rx * 2.24, height: ry * 2.24),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFFFFFFF), Color(0xFFE9E9F2)],
      ).createShader(opening.inflate(0.05)),
  );
  c.drawOval(opening.inflate(0.006), Paint()..color = const Color(0xFFB9BACB));
  c.drawOval(opening, Paint()..color = const Color(0xFF3B3B4A));
  c.save();
  c.clipPath(Path()..addOval(opening));
  c.drawOval(opening.shift(const Offset(0, ry * 0.42)), Paint()..color = const Color(0xFF050508));
  c.restore();

  // A donut half-way in: clipped by the near rim, free above the middle.
  final clip = Path.combine(
    PathOperation.union,
    Path()..addOval(opening),
    Path()..addRect(Rect.fromLTRB(hc.dx - rx, -1, hc.dx + rx, hc.dy)),
  );
  c.save();
  c.clipPath(clip);
  _item(c, ItemKind.donut, const Offset(0.5, 0.75), 0.4, -0.3);
  c.restore();

  // Items flying in.
  _item(c, ItemKind.apple, const Offset(0.75, 0.35), 0.27, 0.45);
  _item(c, ItemKind.strawberry, const Offset(0.25, 0.4), 0.22, -0.5);
  _item(c, ItemKind.orange, const Offset(0.5, 0.2), 0.2, 0.25);
  _sparkle(c, const Offset(0.16, 0.6), 0.035);
  _sparkle(c, const Offset(0.86, 0.56), 0.03);
  _sparkle(c, const Offset(0.62, 0.1), 0.025);
  c.restore();
}

void _item(Canvas c, ItemKind kind, Offset at, double size, double angle) {
  c.save();
  c.translate(at.dx, at.dy);
  c.rotate(angle);
  // paintItem draws the sprite square; give it room so the item is [size].
  final box = size * kind.sprite / (kind.r * 2);
  paintItem(c, kind, Rect.fromCenter(center: Offset.zero, width: box, height: box));
  c.restore();
}

void _sparkle(Canvas c, Offset at, double r) {
  final p = Path()
    ..moveTo(at.dx, at.dy - r)
    ..quadraticBezierTo(at.dx, at.dy, at.dx + r, at.dy)
    ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + r)
    ..quadraticBezierTo(at.dx, at.dy, at.dx - r, at.dy)
    ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy - r)
    ..close();
  c.drawPath(p, Paint()..color = const Color(0xFFFFFFFF));
}
