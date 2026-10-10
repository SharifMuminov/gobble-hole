import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../constants.dart';

/// A perspective camera that looks down at the ground (z = 0) at
/// [kCameraPitch], always facing +y. World x goes right, y goes away from
/// the camera, z goes up.
class GameCamera {
  final double _cos = math.cos(kCameraPitch);
  final double _sin = math.sin(kCameraPitch);

  Size size = Size.zero;

  /// Focal length in pixels.
  double focal = 1;

  /// Where the look-at point lands on screen.
  double centerX = 0, centerY = 0;

  /// Look-at point on the ground, and distance to it.
  double targetX = 0, targetY = 0, distance = 10;

  double camX = 0, camY = 0, camZ = 0;

  /// Fraction of the screen height where the look-at point is drawn.
  static const double anchor = 0.56;

  void setViewport(Size s) {
    size = s;
    focal = s.height * 1.3;
    centerX = s.width / 2;
    centerY = s.height * anchor;
  }

  /// Distance at which [width] world units fill the screen width at the
  /// look-at point.
  double distanceForWidth(double width) =>
      size.width <= 0 ? 10 : width * focal / size.width;

  void lookAt(double x, double y, double dist) {
    targetX = x;
    targetY = y;
    distance = dist;
    camX = x;
    camY = y - dist * _cos;
    camZ = dist * _sin;
  }

  /// Depth of a world point along the view direction.
  double depth(double x, double y, double z) =>
      (y - camY) * _cos - (z - camZ) * _sin;

  /// Projects a world point. Returns depth (<= 0 means behind the camera);
  /// the screen position goes to [out].
  double project(double x, double y, double z, List<double> out) {
    final ry = y - camY;
    final rz = z - camZ;
    final zc = ry * _cos - rz * _sin;
    if (zc <= 0.01) return zc;
    final yc = ry * _sin + rz * _cos;
    out[0] = centerX + focal * (x - camX) / zc;
    out[1] = centerY - focal * yc / zc;
    return zc;
  }

  Offset projectOffset(double x, double y, double z) {
    final p = [0.0, 0.0];
    project(x, y, z, p);
    return Offset(p[0], p[1]);
  }

  /// The ground point under a screen position (null above the horizon).
  Offset? unproject(Offset screen) {
    final a = (screen.dx - centerX) / focal;
    final b = -(screen.dy - centerY) / focal;
    // Ray direction: right * a + up * b + forward.
    final dx = a;
    final dy = b * _sin + _cos;
    final dz = b * _cos - _sin;
    if (dz >= -1e-4) return null;
    final t = -camZ / dz;
    return Offset(camX + dx * t, camY + dy * t);
  }

  /// Canvas transform that maps the ground plane (world x, y) to the screen.
  Float64List groundMatrix() {
    final f = focal;
    final w0 = -camY * _cos + camZ * _sin;
    final m = Float64List(16);
    // Column-major: m[col * 4 + row].
    m[0] = f;
    m[4] = centerX * _cos;
    m[12] = centerX * w0 - f * camX;
    m[5] = centerY * _cos - f * _sin;
    m[13] = centerY * w0 + f * (camY * _sin + camZ * _cos);
    m[10] = 1;
    m[7] = _cos;
    m[15] = w0;
    return m;
  }

  /// World-space bounds of the ground visible on screen.
  Rect visibleGround({double margin = 1}) {
    final pts = [
      unproject(Offset(0, 0)),
      unproject(Offset(size.width, 0)),
      unproject(Offset(0, size.height)),
      unproject(Offset(size.width, size.height)),
    ].whereType<Offset>().toList();
    if (pts.isEmpty) return Rect.zero;
    var l = pts.first.dx, r = l, t = pts.first.dy, b = t;
    for (final p in pts) {
      l = math.min(l, p.dx);
      r = math.max(r, p.dx);
      t = math.min(t, p.dy);
      b = math.max(b, p.dy);
    }
    return Rect.fromLTRB(l - margin, t - margin, r + margin, b + margin);
  }
}
