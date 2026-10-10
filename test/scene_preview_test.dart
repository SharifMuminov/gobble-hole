@Tags(['preview'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hole_it_clone/game/engine/world.dart';
import 'package:hole_it_clone/game/levels/levels.dart';
import 'package:hole_it_clone/game/model/hole_skin.dart';
import 'package:hole_it_clone/game/render/sprite_atlas.dart';
import 'package:hole_it_clone/game/render/world_painter.dart';

/// Renders a few in-game frames to PNG for eyeballing the renderer:
/// `flutter test --tags preview --run-skipped --dart-define=OUT=/some/dir`.
void main() {
  const out = String.fromEnvironment('OUT', defaultValue: 'build/preview');
  const size = Size(440, 956);
  const dpr = 2.0;

  Future<void> shot(GameWorld world, String name) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..scale(dpr);
    WorldPainter(world: world, skin: HoleSkin.classic, repaint: ValueNotifier(0)).paint(canvas, size);
    final image = await rec.endRecording().toImage((size.width * dpr).round(), (size.height * dpr).round());
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  }

  testWidgets('scene previews', (tester) async {
    await tester.runAsync(() async {
      await SpriteAtlas.load();
      for (final (n, x, y, steps) in [(1, 5.0, 4.6, 0), (4, 6.5, 8.0, 3), (7, 6.5, 8.6, 2), (8, 6.5, 9.0, 5), (5, 6.5, 6.0, 1), (25, 6.0, 5.0, 4)]) {
        final world = GameWorld(buildLevel(n))..phase = GamePhase.playing;
        for (var s = 0; s < steps; s++) {
          world.grow();
        }
        // Glide to the spot so some items are mid-fall in the shot.
        final sx = world.holeX, sy = world.holeY;
        for (var i = 0; i <= 90; i++) {
          world.holeX = sx + (x - sx) * i / 90;
          world.holeY = sy + (y - sy) * i / 90;
          world.update(1 / 60, size);
        }
        await shot(world, 'level_$n');
      }
    });
  });
}
