import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import '../constants.dart';
import '../model/item_kind.dart';
import 'item_art.dart';

/// Every item sprite (plus a soft ground shadow) painted once into a single
/// image, so the whole map is drawn with a few drawRawAtlas calls.
class SpriteAtlas {
  SpriteAtlas._(this.image, this.rects, this.shadow);

  final ui.Image image;

  /// Source rect of each [ItemKind], by index.
  final List<Rect> rects;
  final Rect shadow;

  static SpriteAtlas? _instance;

  static SpriteAtlas get instance => _instance!;

  static bool get isLoaded => _instance != null;

  /// Pixels per world unit in the atlas.
  static const double density = 220;

  static const double _width = 2048;
  static const double _pad = 3;

  static Future<SpriteAtlas> load() async {
    if (_instance != null) return _instance!;

    // Shelf-pack the tiles, biggest first.
    final kinds = List.of(ItemKind.values)
      ..sort((a, b) => b.sprite.compareTo(a.sprite));
    final rects = List<Rect>.filled(ItemKind.values.length, Rect.zero);
    var x = _pad, y = _pad, shelf = 0.0;
    Rect place(double size) {
      if (x + size + _pad > _width) {
        x = _pad;
        y += shelf + _pad;
        shelf = 0;
      }
      final r = Rect.fromLTWH(x, y, size, size);
      x += size + _pad;
      shelf = math.max(shelf, size);
      return r;
    }

    for (final kind in kinds) {
      final size = (kind.sprite * density).clamp(64, 360).roundToDouble();
      rects[kind.index] = place(size);
    }
    final shadow = place(96);
    final height = y + shelf + _pad;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (final kind in ItemKind.values) {
      final r = rects[kind.index];
      canvas.save();
      canvas.clipRect(r);
      paintItem(canvas, kind, r);
      canvas.restore();
    }
    _paintShadow(canvas, shadow);

    final image = await recorder.endRecording().toImage(_width.toInt(), height.ceil());
    return _instance = SpriteAtlas._(image, rects, shadow);
  }

  static void _paintShadow(Canvas canvas, Rect r) {
    final c = r.center;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1, kGroundSquash);
    canvas.drawCircle(
      Offset.zero,
      r.width / 2,
      Paint()
        ..shader = ui.Gradient.radial(Offset.zero, r.width / 2, const [
          Color(0x55000000),
          Color(0x33000000),
          Color(0x00000000),
        ], const [0, 0.55, 1]),
    );
    canvas.restore();
  }
}
