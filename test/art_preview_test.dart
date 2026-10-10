@Tags(['preview'])
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hole_it_clone/game/constants.dart';
import 'package:hole_it_clone/game/model/item_kind.dart';
import 'package:hole_it_clone/game/render/item_art.dart';

/// Renders the item art into PNG contact sheets for visual review:
/// `flutter test test/art_preview_test.dart --tags preview --run-skipped --dart-define=OUT=build/preview`.
const _outDir = String.fromEnvironment('OUT', defaultValue: 'build/preview');

Future<void> _save(ui.Picture pic, int w, int h, String name) async {
  final img = await pic.toImage(w, h);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory(_outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('$_outDir/$name').writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Draws [kind] standing on the ground at world (x, y) with its base at
/// height [z], seen from a camera whose ground origin is [origin].
void _place(Canvas canvas, ItemKind kind, Offset origin, double k, double x, double y, double z,
    {double angle = 0, bool shadow = false}) {
  final ground = origin + Offset(x * k, -(y * kGroundSquash + z * kHeightSquash) * k);
  if (shadow) {
    canvas.drawOval(
      Rect.fromCenter(center: ground, width: kind.r * 2.2 * k, height: kind.r * 2.2 * kGroundSquash * k),
      Paint()
        ..shader = ui.Gradient.radial(ground, kind.r * 1.1 * k, const [Color(0x44000000), Color(0x00000000)]),
    );
  }
  final c = ground - Offset(0, kind.h / 2 * kHeightSquash * k);
  final size = kind.sprite * k;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle);
  paintItem(canvas, kind, Rect.fromCenter(center: Offset.zero, width: size, height: size));
  canvas.restore();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('contact sheet of every item', () async {
    const cols = 8;
    const cell = 160.0;
    const kinds = ItemKind.values;
    final rows = (kinds.length / cols).ceil();
    final w = (cols * cell).toInt(), h = (rows * cell).toInt();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), Paint()..color = const Color(0xFFF9D9E6));
    for (var i = 0; i < kinds.length; i++) {
      final cellRect = Rect.fromLTWH((i % cols) * cell, (i ~/ cols) * cell, cell, cell);
      final box = cellRect.deflate(8);
      canvas.drawRect(
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x22000000),
      );
      canvas.save();
      canvas.clipRect(box);
      paintItem(canvas, kinds[i], box);
      canvas.restore();
    }
    await _save(rec.endRecording(), w, h, 'art_preview.png');
  });

  test('stacked compositions', () async {
    const w = 1400, h = 1150;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1400, 1150), Paint()..color = const Color(0xFFF7C6DA));

    // Column of 15 orange slices.
    const k = 200.0;
    for (var i = 0; i < 15; i++) {
      _place(canvas, ItemKind.orangeSlice, const Offset(80, 470), k, 0, 0, i * ItemKind.orangeSlice.h, shadow: i == 0);
    }
    // 12 donuts.
    for (var i = 0; i < 12; i++) {
      _place(canvas, ItemKind.donut, const Offset(210, 470), k, 0, 0, i * ItemKind.donut.h, shadow: i == 0);
    }
    // Chocolate donuts, cookies, waffles, pancakes.
    for (var i = 0; i < 8; i++) {
      _place(canvas, ItemKind.donutChoco, const Offset(340, 470), k, 0, 0, i * ItemKind.donutChoco.h, shadow: i == 0);
    }
    for (var i = 0; i < 14; i++) {
      _place(canvas, ItemKind.cookie, const Offset(450, 470), k, 0, 0, i * ItemKind.cookie.h, shadow: i == 0);
    }
    for (var i = 0; i < 12; i++) {
      _place(canvas, ItemKind.waffle, const Offset(570, 470), k, 0, 0, i * ItemKind.waffle.h, shadow: i == 0);
    }
    for (var i = 0; i < 4; i++) {
      _place(canvas, ItemKind.pancakes, const Offset(700, 470), k, 0, 0, i * ItemKind.pancakes.h, shadow: i == 0);
    }
    // Rainbow macaron columns.
    const macs = [
      ItemKind.macaronPink,
      ItemKind.macaronYellow,
      ItemKind.macaronBlue,
      ItemKind.macaronGreen,
      ItemKind.macaronPurple,
    ];
    for (var m = 0; m < macs.length; m++) {
      for (var i = 0; i < 8; i++) {
        _place(canvas, macs[m], Offset(800 + m * 72.0, 470), k, 0, 0, i * macs[m].h, shadow: i == 0);
      }
    }
    // Lemon and kiwi slices.
    for (var i = 0; i < 14; i++) {
      _place(canvas, ItemKind.lemonSlice, const Offset(1200, 470), k, 0, 0, i * ItemKind.lemonSlice.h, shadow: i == 0);
      _place(canvas, ItemKind.kiwiSlice, const Offset(1310, 470), k, 0, 0, i * ItemKind.kiwiSlice.h, shadow: i == 0);
    }

    // Maki pyramid (3x3, 2x2, 1).
    final pyramid = <(double, double, double)>[];
    for (var layer = 0; layer < 3; layer++) {
      final n = 3 - layer;
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          final s = ItemKind.maki.r * 2;
          pyramid.add(((i - (n - 1) / 2) * s, (j - (n - 1) / 2) * s, layer * ItemKind.maki.h));
        }
      }
    }
    pyramid.sort((p, q) {
      final dp = -p.$2 * kHeightSquash + p.$3 * kGroundSquash;
      final dq = -q.$2 * kHeightSquash + q.$3 * kGroundSquash;
      return dp.compareTo(dq);
    });
    for (final (x, y, z) in pyramid) {
      _place(canvas, ItemKind.maki, const Offset(150, 720), 220, x, y, z, shadow: z == 0);
    }
    // Block tower.
    const blocks = [ItemKind.blockRed, ItemKind.blockBlue, ItemKind.blockGreen, ItemKind.blockYellow];
    for (var i = 0; i < 6; i++) {
      _place(canvas, blocks[i % 4], const Offset(360, 720), 160, 0, 0, i * .3, shadow: i == 0);
    }
    // Rotated carrots and other long items.
    const longs = [
      ItemKind.carrot,
      ItemKind.banana,
      ItemKind.corn,
      ItemKind.eggplant,
      ItemKind.carRed,
      ItemKind.nigiriSalmon,
      ItemKind.shrimp,
    ];
    for (var row = 0; row < longs.length; row++) {
      for (var i = 0; i < 8; i++) {
        _place(canvas, longs[row], Offset(470 + i * 66.0, 560 + row * 44.0), 90, 0, 0, 0,
            angle: i * math.pi / 4, shadow: true);
      }
    }
    // Every item at in-game scale on the ground.
    const kinds = ItemKind.values;
    for (var i = 0; i < kinds.length; i++) {
      final col = i % 14, row = i ~/ 14;
      _place(canvas, kinds[i], Offset(50.0 + col * 95.0, 905.0 + row * 66.0), 60, 0, 0, 0, shadow: true);
    }
    await _save(rec.endRecording(), w, h, 'art_stack_preview.png');
  });

  test('zoomed detail sheet', () async {
    // Large renders of a few kinds, handy when tuning the art. Set
    // ART_ZOOM=<first index> to pick which eight kinds are shown.
    final first = int.tryParse(Platform.environment['ART_ZOOM'] ?? '') ?? 0;
    final kinds = ItemKind.values.skip(first).take(8).toList();
    const cell = 320.0, cols = 4;
    final rows = (kinds.length / cols).ceil();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(Rect.fromLTWH(0, 0, cols * cell, rows * cell), Paint()..color = const Color(0xFFF9D9E6));
    for (var i = 0; i < kinds.length; i++) {
      final box = Rect.fromLTWH((i % cols) * cell, (i ~/ cols) * cell, cell, cell).deflate(10);
      canvas.drawRect(
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x22000000),
      );
      paintItem(canvas, kinds[i], box);
    }
    await _save(rec.endRecording(), (cols * cell).toInt(), (rows * cell).toInt(), 'art_zoom.png');
  });
}
