part of 'item_art.dart';

// Shared drawing helpers for the item sprites. Everything is drawn in world
// units: the canvas is translated to the sprite centre and scaled by
// pixels-per-unit before a painter runs, with y pointing down the screen.

final double _g = kGroundSquash;
final double _hs = kHeightSquash;

const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);

/// Default rim (outline) width in world units.
const double _rw = 0.012;

// ---------------------------------------------------------------------------
// Colour helpers

Color _lt(Color c, double t) => Color.lerp(c, _white, t)!;

Color _dk(Color c, double t) => Color.from(
  alpha: c.a,
  red: c.r * (1 - t),
  green: c.g * (1 - t),
  blue: c.b * (1 - t),
);

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

Color _al(Color c, double alpha) => c.withValues(alpha: alpha);

// ---------------------------------------------------------------------------
// Paint helpers

Paint _fill(Color c) => Paint()..color = c;

Paint _line(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

List<double>? _stops(List<Color> colors, List<double>? stops) =>
    stops ?? (colors.length == 2 ? null : [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)]);

Paint _lin(Offset a, Offset b, List<Color> colors, [List<double>? stops]) =>
    Paint()..shader = Gradient.linear(a, b, colors, _stops(colors, stops));

Paint _rad(Offset c, double r, List<Color> colors, [List<double>? stops]) =>
    Paint()..shader = Gradient.radial(c, r, colors, _stops(colors, stops));

Rect _ov(Offset c, double rx, double ry) =>
    Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);

/// Soft glossy fill lit from the top-left of [r].
Paint _gloss(
  Rect r,
  Color c, {
  double hi = .5,
  double lo = .3,
  double lx = .32,
  double ly = .26,
  double spread = 1.0,
}) {
  final center = Offset(r.left + r.width * lx, r.top + r.height * ly);
  final rad = math.max(r.width, r.height) * spread;
  return _rad(center, rad, [
    _lt(c, hi),
    _lt(c, hi * .3),
    c,
    _dk(c, lo),
  ], const [0, .2, .55, 1]);
}

/// Fills [path] with a glossy gradient and strokes a darker same-hue rim.
void _body(
  Canvas cv,
  Path path,
  Color c, {
  double hi = .5,
  double lo = .3,
  double rim = .38,
  double lx = .32,
  double ly = .26,
  double spread = 1.0,
  Color? rimColor,
}) {
  cv.drawPath(
    path,
    _gloss(path.getBounds(), c, hi: hi, lo: lo, lx: lx, ly: ly, spread: spread),
  );
  cv.drawPath(path, _line(rimColor ?? _dk(c, rim), _rw));
}

/// Light from the top-left and shade to the bottom-right, over whatever was
/// drawn inside [clip] (used on patterned bodies).
void _shadeOver(Canvas cv, Path clip, {double light = .3, double dark = .35, double lx = .3, double ly = .25}) {
  final r = clip.getBounds();
  final center = Offset(r.left + r.width * lx, r.top + r.height * ly);
  final rad = math.max(r.width, r.height) * 1.05;
  cv.save();
  cv.clipPath(clip);
  cv.drawRect(
    r.inflate(.01),
    _rad(center, rad, [
      _al(_white, light),
      _al(_white, 0),
      _al(_black, 0),
      _al(_black, dark),
    ], const [0, .3, .5, 1]),
  );
  cv.restore();
}

/// Soft white specular highlight.
void _spec(Canvas cv, Offset c, double rx, double ry, {double rot = -.6, double a = .9}) {
  cv.save();
  cv.translate(c.dx, c.dy);
  cv.rotate(rot);
  cv.scale(1, ry / rx);
  cv.drawCircle(
    Offset.zero,
    rx,
    _rad(Offset.zero, rx, [_al(_white, a), _al(_white, a * .75), _al(_white, 0)], const [0, .45, 1]),
  );
  cv.restore();
}

// ---------------------------------------------------------------------------
// Path helpers

extension on Path {
  void mv(Offset o) => moveTo(o.dx, o.dy);
  void ln(Offset o) => lineTo(o.dx, o.dy);
  void qd(Offset c, Offset o) => quadraticBezierTo(c.dx, c.dy, o.dx, o.dy);
  void cb(Offset c1, Offset c2, Offset o) => cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, o.dx, o.dy);
}

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

Path _star(Offset c, double ro, double ri, int n, {double rot = -math.pi / 2}) {
  final pts = <Offset>[];
  for (var i = 0; i < n * 2; i++) {
    final r = i.isEven ? ro : ri;
    final a = rot + i * math.pi / n;
    pts.add(c + Offset(math.cos(a) * r, math.sin(a) * r));
  }
  return _poly(pts);
}

Path _heart(Offset c, double s) {
  return Path()
    ..mv(c + Offset(0, s * .9))
    ..cb(c + Offset(-s * 1.1, s * .1), c + Offset(-s * .9, -s * .95), c + Offset(0, -s * .45))
    ..cb(c + Offset(s * .9, -s * .95), c + Offset(s * 1.1, s * .1), c + Offset(0, s * .9))
    ..close();
}

Path _leafPath(Offset base, Offset tip, double w, {double bend = 0}) {
  final d = tip - base;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final b = n * (bend * d.distance);
  return Path()
    ..mv(base)
    ..cb(base + d * .2 + n * (w * 1.3) + b, base + d * .7 + n * (w * .9) + b, tip)
    ..cb(base + d * .7 - n * (w * .9) + b, base + d * .2 - n * (w * 1.3) + b, base)
    ..close();
}

/// A shaded leaf with a midrib.
void _leaf(Canvas cv, Offset base, Offset tip, double w, Color c, {double bend = 0, bool vein = true}) {
  final path = _leafPath(base, tip, w, bend: bend);
  final d = tip - base;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final mid = base + d * .45 + n * (bend * d.distance * .75);
  cv.drawPath(path, _lin(mid - n * w, mid + n * w, [_lt(c, .3), c, _dk(c, .25)], const [0, .5, 1]));
  if (vein) {
    final v = Path()
      ..mv(base + d * .05)
      ..qd(base + d * .5 + n * (bend * d.distance * .75), base + d * .85 + n * (bend * d.distance * .3));
    cv.drawPath(v, _line(_lt(c, .35), w * .16));
  }
  cv.drawPath(path, _line(_dk(c, .35), _rw * .8));
}

/// A small capsule (sprinkle / seed).
void _capsule(Canvas cv, Offset c, double ang, double len, double w, Color col) {
  final d = Offset(math.cos(ang), math.sin(ang)) * (len / 2);
  cv.drawLine(c - d, c + d, _line(_dk(col, .2), w));
  cv.drawLine(c - d, c + d, _line(col, w * .7));
}

/// Scattered dots (pores, speckles) inside [clip].
void _speckle(Canvas cv, Path clip, Color c, int n, {int seed = 1, double size = .006}) {
  final r = clip.getBounds();
  final rnd = math.Random(seed);
  cv.save();
  cv.clipPath(clip);
  final p = _fill(c);
  for (var i = 0; i < n; i++) {
    final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
    cv.drawCircle(o, size * (.6 + rnd.nextDouble() * .7), p);
  }
  cv.restore();
}

List<Offset> _circ(double r, {int n = 96, double cx = 0, double cy = 0}) => [
  for (var i = 0; i < n; i++)
    Offset(cx + r * math.cos(2 * math.pi * i / n), cy + r * math.sin(2 * math.pi * i / n)),
];

/// Rounded rectangle outline points (plan coordinates).
List<Offset> _rrectPts(double hw, double hh, double rad, {double cx = 0, double cy = 0, int seg = 10}) {
  final pts = <Offset>[];
  final corners = [
    Offset(hw - rad, hh - rad),
    Offset(-hw + rad, hh - rad),
    Offset(-hw + rad, -hh + rad),
    Offset(hw - rad, -hh + rad),
  ];
  for (var c = 0; c < 4; c++) {
    for (var i = 0; i <= seg; i++) {
      final a = (c + i / seg) * math.pi / 2;
      pts.add(Offset(cx, cy) + corners[c] + Offset(math.cos(a), math.sin(a)) * rad);
    }
  }
  return pts;
}

List<Offset> _hull(List<Offset> pts) {
  final p = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

// ---------------------------------------------------------------------------
// Projection

/// Painting context of one sprite.
class _Art {
  _Art(this.cv, this.kind);

  final Canvas cv;
  final ItemKind kind;

  Color get c => kind.color;

  double get hc => kind.h / 2;

  /// Screen position of world point (x right, y away from the camera, z up),
  /// relative to the bounding-volume centre at ground level.
  Offset p(double x, double y, double z) => Offset(x, -(y * _g + (z - hc) * _hs));

  /// Screen y of height [z] straight above the centre.
  double sy(double z, [double y = 0]) => -(y * _g + (z - hc) * _hs);

  /// Runs [draw] in plan coordinates of the horizontal plane at height [z]:
  /// x right, y toward the camera (down the screen).
  void plan(double z, void Function() draw, {double x = 0, double y = 0}) {
    final o = p(x, y, z);
    cv.save();
    cv.translate(o.dx, o.dy);
    cv.scale(1, _g);
    draw();
    cv.restore();
  }

  /// Projects plan points (x right, y toward camera) at height [z].
  List<Offset> proj(List<Offset> plan, double z) => [for (final q in plan) p(q.dx, -q.dy, z)];

  /// Horizontal ellipse (circle of radius [r] at height [z]).
  Rect disk(double r, double z, {double x = 0, double y = 0}) => _ov(p(x, y, z), r, r * _g);
}

/// Silhouette of polygon [top] swept straight down by [drop].
Path _sil(List<Offset> top, double drop) {
  final n = top.length;
  var iMin = 0, iMax = 0;
  for (var i = 0; i < n; i++) {
    if (top[i].dx < top[iMin].dx) iMin = i;
    if (top[i].dx > top[iMax].dx) iMax = i;
  }
  List<Offset> chain(int step) {
    final out = <Offset>[];
    var i = iMin;
    while (true) {
      out.add(top[i]);
      if (i == iMax) break;
      i = (i + step + n) % n;
    }
    return out;
  }

  final c1 = chain(1), c2 = chain(-1);
  double meanY(List<Offset> l) => l.fold(0.0, (s, o) => s + o.dy) / l.length;
  final upper = meanY(c1) < meanY(c2) ? c1 : c2;
  final lower = identical(upper, c1) ? c2 : c1;
  final path = Path()..mv(upper.first);
  for (final o in upper.skip(1)) {
    path.ln(o);
  }
  for (final o in lower.reversed) {
    path.lineTo(o.dx, o.dy + drop);
  }
  return path..close();
}

/// Horizontal shading for the curved side of a solid.
Paint _sideShade(Rect b, Color c, {double hi = .22, double lo = .4}) => _lin(
  Offset(b.left, 0),
  Offset(b.right, 0),
  [_dk(c, lo * .3), _lt(c, hi), c, _dk(c, lo * .55), _dk(c, lo)],
  const [0, .2, .5, .8, 1],
);

/// Extrudes plan shape [plan] from [z0] to [z1]: draws the side and returns
/// the (projected) top face path, optionally filling it with [top].
Path _slab(
  _Art a,
  List<Offset> plan,
  double z0,
  double z1,
  Color side, {
  Paint? top,
  double rim = .4,
  double hi = .22,
  double lo = .4,
  Color? rimColor,
}) {
  final topPts = a.proj(plan, z1);
  final sil = _sil(topPts, (z1 - z0) * _hs);
  a.cv.drawPath(sil, _sideShade(sil.getBounds(), side, hi: hi, lo: lo));
  final tp = _poly(topPts);
  if (top != null) a.cv.drawPath(tp, top);
  if (rim > 0) a.cv.drawPath(sil, _line(rimColor ?? _dk(side, rim), _rw));
  return tp;
}

/// Silhouette of a frustum / cylinder between two horizontal circles.
Path _cylSil(_Art a, double r0, double z0, double r1, double z1, {double x = 0, double y = 0}) {
  final b = a.p(x, y, z0), t = a.p(x, y, z1);
  return Path()
    ..moveTo(t.dx - r1, t.dy)
    ..arcTo(_ov(t, r1, r1 * _g), math.pi, math.pi, false)
    ..lineTo(b.dx + r0, b.dy)
    ..arcTo(_ov(b, r0, r0 * _g), 0, math.pi, false)
    ..close();
}

// ---------------------------------------------------------------------------
// Spheroids

class _V3 {
  const _V3(this.x, this.y, this.z);

  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  _V3 get unit => this * (1 / math.sqrt(dot(this)));
}

/// A spheroid in view space (x right, y up, z toward the viewer), used to draw
/// stripes and ribs that wrap correctly around round bodies.
class _Globe {
  /// Upright spheroid (pole = world up) centred on screen point [c].
  _Globe.upright(this.c, this.ra, this.rb)
    : pole = _V3(0, _hs, _g),
      e1 = const _V3(1, 0, 0),
      e2 = _V3(0, _g, -_hs),
      rx = ra,
      ry = math.sqrt(ra * ra * _g * _g + rb * rb * _hs * _hs);

  /// Sphere of radius [r] with an arbitrary pole direction.
  factory _Globe.tilted(Offset c, double r, _V3 pole) {
    final p = pole.unit;
    final e1 = (const _V3(1, 0, 0) - p * p.x).unit;
    return _Globe._(c, r, r, p, e1, p.cross(e1), r, r);
  }

  _Globe._(this.c, this.ra, this.rb, this.pole, this.e1, this.e2, this.rx, this.ry);

  final Offset c;
  final double ra, rb;
  final _V3 pole, e1, e2;
  final double rx, ry;

  Path get outline => Path()..addOval(_ov(c, rx, ry));

  _V3 _pos(double th, double ph) =>
      (e1 * math.cos(ph) + e2 * math.sin(ph)) * (ra * math.sin(th)) + pole * (rb * math.cos(th));

  bool visible(double th, double ph) =>
      ((e1 * math.cos(ph) + e2 * math.sin(ph)) * (math.sin(th) / ra) + pole * (math.cos(th) / rb)).z > 0;

  Offset raw(double th, double ph) {
    final v = _pos(th, ph);
    return Offset(c.dx + v.x, c.dy - v.y);
  }

  /// Screen point; hidden points are pushed onto the outline.
  Offset at(double th, double ph) {
    final q = raw(th, ph);
    if (visible(th, ph)) return q;
    final d = q - c;
    final k = math.sqrt((d.dx / rx) * (d.dx / rx) + (d.dy / ry) * (d.dy / ry));
    if (k < 1e-6) return q;
    return c + d / k;
  }

  /// Region between meridians [left] and [right] (functions of t in 0..1,
  /// pole to pole).
  Path band(double Function(double t) left, double Function(double t) right,
      {int n = 60, double t0 = 0, double t1 = 1}) {
    final l = <Offset>[], r = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final t = t0 + (t1 - t0) * i / n;
      l.add(at(t * math.pi, left(t)));
      r.add(at(t * math.pi, right(t)));
    }
    return _poly([...l, ...r.reversed]);
  }

  /// Visible part of the curve (theta, phi)(t) as a polyline.
  Path curve(double Function(double t) th, double Function(double t) ph, {int n = 48}) {
    final path = Path();
    var pen = false;
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final a = th(t), b = ph(t);
      if (!visible(a, b)) {
        pen = false;
        continue;
      }
      final q = raw(a, b);
      if (pen) {
        path.ln(q);
      } else {
        path.mv(q);
        pen = true;
      }
    }
    return path;
  }
}
