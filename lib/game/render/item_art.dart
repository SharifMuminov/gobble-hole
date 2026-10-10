/// Procedural sprite art for every [ItemKind], drawn with dart:ui only.
///
/// Sprites are drawn for a camera looking down at [kCameraPitchDeg]: a
/// horizontal circle shows as an ellipse squashed by [kGroundSquash] and a
/// vertical extent by [kHeightSquash]. The object's bounding-volume centre is
/// at the box centre; rotating items point to +x.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../constants.dart';
import '../model/item_kind.dart';

part 'art_helpers.dart';

/// Paints [kind] into the square [box]. box.width corresponds to kind.sprite world units.
void paintItem(Canvas canvas, ItemKind kind, Rect box) {
  final k = box.width / kind.sprite;
  canvas.save();
  canvas.translate(box.center.dx, box.center.dy);
  canvas.scale(k, k);
  final a = _Art(canvas, kind);
  switch (kind) {
    case ItemKind.apple:
      _apple(a, leaf: const Color(0xFF43A047));
    case ItemKind.greenApple:
      _apple(a, leaf: const Color(0xFF2E7D32));
    case ItemKind.orange:
      _orange(a);
    case ItemKind.lemon:
      _lemon(a);
    case ItemKind.strawberry:
      _strawberry(a);
    case ItemKind.cherry:
      _cherry(a);
    case ItemKind.banana:
      _banana(a);
    case ItemKind.watermelonSlice:
      _watermelonSlice(a);
    case ItemKind.avocado:
      _avocado(a);
    case ItemKind.orangeSlice:
      _citrusSlice(a, rind: const Color(0xFFF57C00), flesh: const Color(0xFFFFA726), n: 10);
    case ItemKind.lemonSlice:
      _citrusSlice(a, rind: const Color(0xFFFBC02D), flesh: const Color(0xFFFFEE58), n: 9);
    case ItemKind.kiwiSlice:
      _kiwiSlice(a);
    case ItemKind.pineapple:
      _pineapple(a);
    case ItemKind.jamJar:
      _jamJar(a);
    case ItemKind.watermelon:
      _watermelon(a);
    case ItemKind.carrot:
      _carrot(a);
    case ItemKind.tomato:
      _tomato(a);
    case ItemKind.pepper:
      _pepper(a);
    case ItemKind.eggplant:
      _eggplant(a);
    case ItemKind.corn:
      _corn(a);
    case ItemKind.onion:
      _onion(a);
    case ItemKind.broccoli:
      _broccoli(a);
    case ItemKind.cabbage:
      _cabbage(a);
    case ItemKind.pumpkin:
      _pumpkin(a);
    case ItemKind.donut:
      _donut(a, choco: false);
    case ItemKind.donutChoco:
      _donut(a, choco: true);
    case ItemKind.macaronPink:
    case ItemKind.macaronYellow:
    case ItemKind.macaronBlue:
    case ItemKind.macaronGreen:
    case ItemKind.macaronPurple:
      _macaron(a);
    case ItemKind.cookie:
      _cookie(a);
    case ItemKind.waffle:
      _waffle(a);
    case ItemKind.cupcake:
      _cupcake(a);
    case ItemKind.pancakes:
      _pancakes(a);
    case ItemKind.cocoaMug:
      _cocoaMug(a);
    case ItemKind.milkshake:
      _milkshake(a);
    case ItemKind.pie:
      _pie(a);
    case ItemKind.cake:
      _cake(a);
    case ItemKind.maki:
      _maki(a, filling: const Color(0xFFFF7043));
    case ItemKind.makiCucumber:
      _maki(a, filling: const Color(0xFF66BB6A));
    case ItemKind.nigiriSalmon:
      _nigiri(a, tamago: false);
    case ItemKind.nigiriTamago:
      _nigiri(a, tamago: true);
    case ItemKind.shrimp:
      _shrimp(a);
    case ItemKind.wasabi:
      _wasabi(a);
    case ItemKind.onigiri:
      _onigiri(a);
    case ItemKind.soyDish:
      _soyDish(a);
    case ItemKind.carRed:
    case ItemKind.carBlue:
    case ItemKind.carYellow:
      _car(a);
    case ItemKind.duck:
      _duck(a);
    case ItemKind.ball:
      _ball(a);
    case ItemKind.blockRed:
      _block(a, 0);
    case ItemKind.blockBlue:
      _block(a, 1);
    case ItemKind.blockGreen:
      _block(a, 2);
    case ItemKind.blockYellow:
      _block(a, 3);
    case ItemKind.teddy:
      _teddy(a);
  }
  canvas.restore();
}

// ===========================================================================
// Fruit

void _apple(_Art a, {required Color leaf}) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(0, -.125)
    ..cubicTo(-.07, -.2, -.2, -.195, -.214, -.055)
    ..cubicTo(-.226, .08, -.14, .205, -.065, .2)
    ..cubicTo(-.035, .197, .035, .197, .065, .2)
    ..cubicTo(.14, .205, .226, .08, .214, -.055)
    ..cubicTo(.2, -.195, .07, -.2, 0, -.125)
    ..close();
  _body(cv, body, c);
  cv.save();
  cv.clipPath(body);
  cv.drawOval(
    _ov(const Offset(0, -.105), .1, .05),
    _rad(const Offset(0, -.105), .1, [_al(_dk(c, .5), .8), _al(_dk(c, .3), 0)]),
  );
  cv.restore();
  _spec(cv, const Offset(-.105, -.07), .06, .032, rot: -.95);
  _spec(cv, const Offset(.12, .1), .025, .012, rot: -.9, a: .35);
  final stem = Path()
    ..moveTo(0, -.105)
    ..quadraticBezierTo(-.005, -.17, .03, -.235);
  cv.drawPath(stem, _line(const Color(0xFF5D4037), .032));
  cv.drawPath(stem.shift(const Offset(-.006, 0)), _line(const Color(0xFF8D6E63), .01));
  _leaf(cv, const Offset(.02, -.195), const Offset(.175, -.24), .042, leaf, bend: .1);
}

void _orange(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .228;
  final body = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
  _body(cv, body, c, hi: .45, lo: .32);
  _speckle(cv, body, _al(_dk(c, .35), .25), 110, seed: 7, size: .0055);
  _spec(cv, const Offset(-.09, -.095), .07, .042, rot: -.8);
  final top = Offset(0, -r * _hs);
  cv.save();
  cv.translate(top.dx, top.dy);
  cv.scale(1, _g);
  cv.drawPath(_star(Offset.zero, .042, .018, 5), _fill(const Color(0xFF558B2F)));
  cv.restore();
  cv.drawCircle(top + const Offset(0, -.006), .012, _fill(const Color(0xFF6D4C41)));
  _leaf(cv, top + const Offset(.005, -.01), top + const Offset(.13, -.075), .036, const Color(0xFF43A047), bend: .1);
}

void _lemon(_Art a) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(-.215, 0)
    ..quadraticBezierTo(-.2, -.03, -.165, -.06)
    ..cubicTo(-.115, -.15, .115, -.15, .165, -.06)
    ..quadraticBezierTo(.2, -.03, .215, 0)
    ..quadraticBezierTo(.2, .03, .165, .06)
    ..cubicTo(.115, .15, -.115, .15, -.165, .06)
    ..quadraticBezierTo(-.2, .03, -.215, 0)
    ..close();
  final rim = _dk(_mix(c, const Color(0xFFFB8C00), .4), .2);
  cv.drawPath(body, _gloss(body.getBounds(), c, hi: .55, lo: .22));
  _speckle(cv, body, _al(rim, .2), 70, seed: 3, size: .005);
  cv.drawPath(body, _line(rim, _rw));
  _spec(cv, const Offset(-.05, -.07), .09, .025, rot: -.12);
  _spec(cv, const Offset(.1, .06), .03, .01, rot: -.3, a: .3);
}

void _strawberry(_Art a) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(0, -.125)
    ..cubicTo(-.12, -.165, -.195, -.11, -.185, -.02)
    ..cubicTo(-.175, .08, -.07, .2, 0, .215)
    ..cubicTo(.07, .2, .175, .08, .185, -.02)
    ..cubicTo(.195, -.11, .12, -.165, 0, -.125)
    ..close();
  _body(cv, body, c, hi: .45);
  // Seeds.
  cv.save();
  cv.clipPath(body);
  var row = 0;
  for (var y = -.09; y < .19; y += .045) {
    final off = row.isOdd ? .0275 : 0.0;
    for (var x = -.2 + off; x < .2; x += .055) {
      final o = Offset(x, y);
      if (!body.contains(o)) continue;
      cv.drawOval(_ov(o, .014, .019), _fill(_al(_dk(c, .35), .5)));
      cv.drawOval(_ov(o + const Offset(0, -.002), .007, .011), _fill(const Color(0xFFFFF59D)));
    }
    row++;
  }
  cv.restore();
  _spec(cv, const Offset(-.09, -.06), .05, .025, rot: -.9, a: .8);
  // Calyx seen from above.
  final top = const Offset(0, -.115);
  const green = Color(0xFF388E3C);
  cv.save();
  cv.translate(top.dx, top.dy);
  for (var i = 0; i < 6; i++) {
    final ang = -math.pi / 2 + i * math.pi / 3 + .3;
    final tip = Offset(math.cos(ang) * .11, math.sin(ang) * .11 * _g + .01);
    _leaf(cv, Offset.zero, tip, .024, i == 1 || i == 2 ? const Color(0xFF43A047) : green, vein: false);
  }
  cv.restore();
  cv.drawPath(
    Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(top.dx, top.dy - .04, top.dx + .02, top.dy - .07),
    _line(const Color(0xFF2E7D32), .022),
  );
}

void _cherry(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .086;
  const back = Offset(-.075, .07), front = Offset(.06, .105);
  for (final o in [back, front]) {
    final p = Path()..addOval(Rect.fromCircle(center: o, radius: r));
    _body(cv, p, c, hi: .45, lo: .4);
    cv.drawOval(_ov(o + const Offset(0, -.052), .024, .011), _fill(_al(_dk(c, .5), .6)));
    _spec(cv, o + const Offset(-.033, -.03), .03, .016, rot: -.9);
  }
  const stemC = Color(0xFF689F38);
  const top = Offset(-.01, -.135);
  for (final o in [back, front]) {
    final s = Path()
      ..moveTo(o.dx, o.dy - .052)
      ..quadraticBezierTo(o.dx * .5, (o.dy + top.dy) / 2 - .03, top.dx, top.dy);
    cv.drawPath(s, _line(_dk(stemC, .3), .02));
    cv.drawPath(s, _line(stemC, .011));
  }
  _leaf(cv, top, top + const Offset(.12, -.03), .034, const Color(0xFF43A047), bend: -.1);
}

void _banana(_Art a) {
  final cv = a.cv;
  final c = _mix(a.c, const Color(0xFFFDD835), .7);
  const p0 = Offset(-.255, -.05), p1 = Offset(0, .15), p2 = Offset(.27, -.06);
  Offset at(double t) => p0 * ((1 - t) * (1 - t)) + p1 * (2 * (1 - t) * t) + p2 * (t * t);
  Offset tan(double t) => (p1 - p0) * (2 * (1 - t)) + (p2 - p1) * (2 * t);
  Offset nrm(double t) {
    final d = tan(t);
    return Offset(d.dy, -d.dx) / d.distance;
  }

  double w(double t) => .018 + .068 * math.pow(math.sin(math.pi * t), .5);
  final up = <Offset>[], dn = <Offset>[];
  const n = 40;
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    up.add(at(t) + nrm(t) * w(t));
    dn.add(at(t) - nrm(t) * (w(t) * .9));
  }
  final body = _poly([...up, ...dn.reversed]);
  final rim = _dk(_mix(c, const Color(0xFFF57F17), .6), .25);
  cv.drawPath(body, _gloss(body.getBounds(), c, hi: .5, lo: .28, ly: .1));
  // Ridges along the peel.
  final ridge = Path(), shade = Path();
  for (var i = 4; i <= n - 4; i++) {
    final t = i / n;
    final q1 = at(t) + nrm(t) * (w(t) * .3);
    final q2 = at(t) - nrm(t) * (w(t) * .45);
    if (i == 4) {
      ridge.mv(q1);
      shade.mv(q2);
    } else {
      ridge.ln(q1);
      shade.ln(q2);
    }
  }
  cv.drawPath(shade, _line(_al(_dk(c, .3), .5), .014));
  cv.drawPath(ridge, _line(_al(_lt(c, .65), .75), .014));
  cv.drawPath(body, _line(rim, _rw));
  // Stem and tip.
  final s0 = at(0);
  cv.drawLine(s0 + const Offset(.012, .004), s0 + const Offset(-.035, -.022), _line(const Color(0xFF9CCC65), .034));
  cv.drawLine(s0 + const Offset(-.03, -.019), s0 + const Offset(-.036, -.023), _line(const Color(0xFF5D4037), .032));
  cv.drawCircle(at(1) + const Offset(-.004, .002), .015, _fill(const Color(0xFF5D4037)));
  _speckle(cv, body, _al(const Color(0xFF8D6E63), .4), 8, seed: 11, size: .006);
}

void _watermelonSlice(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .26, cy = -.13, h = .14;
  List<Offset> half(double rr) => [
    for (var i = 0; i <= 48; i++) Offset(rr * math.cos(math.pi * i / 48), cy + rr * math.sin(math.pi * i / 48)),
  ];
  const rind = Color(0xFF2E7D32);
  final topPts = a.proj(half(r), h);
  final sil = _sil(topPts, h * _hs);
  cv.drawPath(sil, _sideShade(sil.getBounds(), rind, hi: .2));
  // Darker rind stripes.
  cv.save();
  cv.clipPath(sil);
  for (var i = 1; i < 12; i++) {
    final t = math.pi * i / 12;
    final top = a.p(r * math.cos(t), -(cy + r * math.sin(t)), h);
    cv.drawLine(top, top + Offset(0, h * _hs + .05), _line(_al(const Color(0xFF1B5E20), .7), .022));
  }
  cv.restore();
  cv.drawPath(sil, _line(_dk(rind, .4), _rw));
  a.plan(h, () {
    Path hp(double rr) => Path()
      ..moveTo(rr, cy)
      ..arcTo(Rect.fromCircle(center: const Offset(0, cy), radius: rr), 0, math.pi, false)
      ..close();
    cv.drawPath(hp(r), _fill(const Color(0xFF43A047)));
    cv.drawPath(hp(r - .02), _fill(const Color(0xFFDCEDC8)));
    final flesh = hp(r - .045);
    cv.drawPath(
      flesh,
      _rad(const Offset(-.05, cy + .02), .26, [_lt(c, .25), c, _dk(c, .08)], const [0, .55, 1]),
    );
    // Seeds pointing to the centre.
    for (final s in const [
      [.5, .15], [1.1, .16], [1.7, .155], [2.4, .15], [.85, .09], [1.55, .095], [2.2, .085],
    ]) {
      final ang = s[0], d = s[1];
      final o = Offset(math.cos(ang) * d, cy + math.sin(ang) * d);
      cv.save();
      cv.translate(o.dx, o.dy);
      cv.rotate(ang + math.pi / 2);
      cv.drawOval(_ov(Offset.zero, .012, .021), _fill(const Color(0xFF263238)));
      cv.drawOval(_ov(const Offset(-.003, -.005), .004, .007), _fill(_al(_white, .6)));
      cv.restore();
    }
    cv.drawPath(hp(r), _line(_dk(rind, .3), _rw));
  });
  _spec(cv, a.p(-.1, .04, h), .08, .02, rot: .15, a: .45);
}

void _avocado(_Art a) {
  final cv = a.cv;
  const h = .14;
  List<Offset> pear(double s) => [
    for (var i = 0; i < 80; i++)
      () {
        final t = 2 * math.pi * i / 80;
        return Offset(s * .22 * math.cos(t), s * math.sin(t) * (.108 - .04 * math.cos(t)));
      }(),
  ];
  const skin = Color(0xFF33691E);
  final top = _slab(a, pear(1), 0, h, skin, hi: .25);
  cv.drawPath(top, _fill(const Color(0xFF2E5A1C)));
  a.plan(h, () {
    final flesh = _poly(pear(.9));
    cv.drawPath(
      flesh,
      _rad(const Offset(-.06, 0), .22, const [
        Color(0xFFFFF59D),
        Color(0xFFE6EE9C),
        Color(0xFFC0CA33),
        Color(0xFF8BC34A),
      ], const [0, .3, .7, 1]),
    );
    cv.drawPath(flesh, _line(_al(const Color(0xFF9CCC65), .8), .012));
  });
  final pit = a.p(-.065, 0, h + .012);
  final pitPath = Path()..addOval(_ov(pit, .066, .058));
  cv.drawOval(_ov(pit + const Offset(0, .008), .072, .062), _fill(_al(const Color(0xFF827717), .5)));
  _body(cv, pitPath, const Color(0xFFA0522D), hi: .45, lo: .35);
  _spec(cv, pit + const Offset(-.022, -.02), .025, .014, rot: -.7);
}

void _citrusSlice(_Art a, {required Color rind, required Color flesh, required int n}) {
  final cv = a.cv;
  final r = a.kind.r, h = a.kind.h;
  final pith = _mix(flesh, _white, .82);
  _slab(a, _circ(r), 0, h, rind, hi: .3);
  a.plan(h, () {
    cv.drawCircle(Offset.zero, r, _fill(_lt(rind, .1)));
    cv.drawCircle(Offset.zero, r - .016, _fill(pith));
    final fr = r - .03;
    cv.drawCircle(
      Offset.zero,
      fr,
      _rad(const Offset(-.03, -.03), fr * 1.1, [_lt(flesh, .45), _lt(flesh, .1), flesh, _dk(flesh, .06)], const [0, .35, .7, 1]),
    );
    // Segment membranes.
    for (var i = 0; i < n; i++) {
      final ang = 2 * math.pi * i / n + .2;
      final d = Offset(math.cos(ang), math.sin(ang));
      cv.drawLine(d * .02, d * (fr + .002), _line(pith, .012));
    }
    // Juicy vesicles.
    for (var i = 0; i < n; i++) {
      final ang = 2 * math.pi * (i + .5) / n + .2;
      final d = Offset(math.cos(ang), math.sin(ang));
      cv.save();
      cv.translate(d.dx * fr * .6, d.dy * fr * .6);
      cv.rotate(ang);
      cv.drawOval(_ov(Offset.zero, fr * .26, fr * .055), _fill(_al(_lt(flesh, .7), .55)));
      cv.restore();
    }
    cv.drawCircle(Offset.zero, .022, _fill(pith));
    cv.drawCircle(Offset.zero, r, _line(_dk(rind, .2), _rw * .8));
  });
  _spec(cv, a.p(-r * .45, r * .45, h), r * .3, r * .1, rot: -.35, a: .5);
}

void _kiwiSlice(_Art a) {
  final cv = a.cv;
  final r = a.kind.r, h = a.kind.h;
  const skin = Color(0xFF8D6E63);
  _slab(a, _circ(r), 0, h, skin, hi: .2);
  a.plan(h, () {
    cv.drawCircle(Offset.zero, r, _fill(const Color(0xFF795548)));
    final fr = r - .013;
    cv.drawCircle(
      Offset.zero,
      fr,
      _rad(Offset.zero, fr, const [
        Color(0xFFF9FBE7),
        Color(0xFFDCEDC8),
        Color(0xFF9CCC65),
        Color(0xFF7CB342),
        Color(0xFF558B2F),
      ], const [0, .22, .45, .82, 1]),
    );
    for (var i = 0; i < 30; i++) {
      final ang = 2 * math.pi * i / 30;
      final d = Offset(math.cos(ang), math.sin(ang));
      cv.drawLine(d * .06, d * (fr - .02), _line(_al(_white, .22), .006));
    }
    cv.drawOval(_ov(Offset.zero, .042, .036), _fill(const Color(0xFFFFFDE7)));
    for (var i = 0; i < 18; i++) {
      final ang = 2 * math.pi * i / 18;
      final d = i.isEven ? .066 : .08;
      cv.save();
      cv.translate(math.cos(ang) * d, math.sin(ang) * d);
      cv.rotate(ang + math.pi / 2);
      cv.drawOval(_ov(Offset.zero, .007, .013), _fill(const Color(0xFF1B1B1B)));
      cv.restore();
    }
    cv.drawCircle(Offset.zero, r, _line(_dk(skin, .3), _rw * .8));
  });
  _spec(cv, a.p(-r * .45, r * .45, h), r * .3, r * .1, rot: -.35, a: .45);
}

void _pineapple(_Art a) {
  final cv = a.cv, c = a.c;
  const ctr = Offset(0, .12), rx = .27, ry = .29;
  final body = Path()..addOval(_ov(ctr, rx, ry));
  cv.drawPath(body, _gloss(body.getBounds(), c, hi: .4, lo: .35));
  // Diamond lattice wrapped around the body.
  Offset map(double u, double v) {
    final y = ctr.dy + v * ry;
    final hw = rx * math.sqrt(math.max(0, 1 - v * v));
    return Offset(ctr.dx + hw * math.sin(u * math.pi / 2), y);
  }

  cv.save();
  cv.clipPath(body);
  final lat = _line(_al(const Color(0xFFBF360C), .55), .013);
  for (var k = -8; k <= 8; k++) {
    final p1 = Path(), p2 = Path();
    for (var i = 0; i <= 30; i++) {
      final s = -1 + 2 * i / 30;
      final a1 = map(s, (s + k * .22).clamp(-1, 1).toDouble());
      final a2 = map(s, (-s + k * .22).clamp(-1, 1).toDouble());
      if (i == 0) {
        p1.mv(a1);
        p2.mv(a2);
      } else {
        p1.ln(a1);
        p2.ln(a2);
      }
    }
    cv.drawPath(p1, lat);
    cv.drawPath(p2, lat);
  }
  for (var j = -9; j <= 9; j++) {
    for (var i = -9; i <= 9; i++) {
      if ((i + j).isOdd) continue;
      final u = i * .11, v = j * .11;
      if (u.abs() > .95 || v.abs() > .95) continue;
      final o = map(u, v);
      final sz = .019 * math.cos(u * math.pi / 2).abs() + .006;
      cv.drawCircle(o, sz, _fill(_al(const Color(0xFF8D4A12), .7)));
      cv.drawCircle(o + Offset(-sz * .35, -sz * .35), sz * .4, _fill(_al(_lt(c, .6), .7)));
    }
  }
  cv.restore();
  _shadeOver(cv, body, light: .25, dark: .25);
  cv.drawPath(body, _line(_dk(c, .45), _rw));
  _spec(cv, const Offset(-.11, .02), .05, .1, rot: .35, a: .45);
  // Crown.
  const base = Offset(0, -.14);
  const back = [-62.0, -30.0, 0.0, 30.0, 62.0];
  const front = [-42.0, -14.0, 14.0, 42.0];
  for (var i = 0; i < back.length; i++) {
    final ang = back[i] * math.pi / 180;
    final len = .29 - back[i].abs() / 62 * .08;
    final b = base + Offset(back[i] / 62 * .05, 0);
    _leaf(cv, b, b + Offset(math.sin(ang) * len, -math.cos(ang) * len), .036, const Color(0xFF2E7D32),
        bend: back[i] / 400, vein: false);
  }
  for (var i = 0; i < front.length; i++) {
    final ang = front[i] * math.pi / 180;
    final len = .21 - front[i].abs() / 42 * .05;
    final b = base + Offset(front[i] / 42 * .04, .02);
    _leaf(cv, b, b + Offset(math.sin(ang) * len, -math.cos(ang) * len), .034, const Color(0xFF43A047),
        bend: front[i] / 350);
  }
  _leaf(cv, base + const Offset(0, .025), base + const Offset(0, -.16), .032, const Color(0xFF66BB6A));
}

void _gingham(Canvas cv, Rect area, double cell, Color c) {
  cv.drawRect(area, _fill(_white));
  final p = _fill(_al(c, .5));
  var i = 0;
  for (var x = area.left; x < area.right; x += cell, i++) {
    if (i.isEven) cv.drawRect(Rect.fromLTWH(x, area.top, cell, area.height), p);
  }
  i = 0;
  for (var y = area.top; y < area.bottom; y += cell, i++) {
    if (i.isEven) cv.drawRect(Rect.fromLTWH(area.left, y, area.width, cell), p);
  }
}

void _jamJar(_Art a) {
  final cv = a.cv, c = a.c;
  // Glass body.
  final glass = _cylSil(a, .27, 0, .27, .4);
  cv.drawPath(glass, _sideShade(glass.getBounds(), c, hi: .15, lo: .45));
  cv.save();
  cv.clipPath(glass);
  final gb = glass.getBounds();
  cv.drawRect(Rect.fromLTRB(-.19, gb.top, -.145, gb.bottom), _fill(_al(_white, .35)));
  cv.drawRect(Rect.fromLTRB(-.125, gb.top, -.11, gb.bottom), _fill(_al(_white, .25)));
  cv.drawRect(Rect.fromLTRB(.17, gb.top, .19, gb.bottom), _fill(_al(_white, .18)));
  // Label.
  final lc = a.p(.0, -.27, .17);
  final label = RRect.fromRectAndRadius(_ov(lc + const Offset(0, .02), .13, .07), const Radius.circular(.03));
  cv.drawRRect(label, _fill(const Color(0xFFFFF8E1)));
  cv.drawRRect(label, _line(const Color(0xFFFFB300), .01));
  cv.drawPath(_heart(lc + const Offset(0, .02), .035), _fill(c));
  cv.restore();
  cv.drawPath(glass, _line(_dk(c, .45), _rw));
  // Gingham cloth over the lid.
  const zt = .52, rt = .26, zh = .34, rh = .31;
  final t = a.p(0, 0, zt);
  final hem = a.p(0, 0, zh);
  final skirt = Path()
    ..moveTo(t.dx - rt, t.dy)
    ..arcTo(_ov(t, rt, rt * _g), math.pi, math.pi, false);
  const n = 48;
  for (var i = 0; i <= n; i++) {
    final ang = math.pi * i / n;
    final scallop = .022 * math.pow(math.sin(ang * 7).abs(), .7);
    skirt.lineTo(hem.dx + rh * math.cos(ang), hem.dy + rh * _g * math.sin(ang) + scallop);
  }
  skirt.close();
  cv.save();
  cv.clipPath(skirt);
  _gingham(cv, skirt.getBounds().inflate(.02), .042, const Color(0xFFE53935));
  // Folds.
  for (var i = 1; i < 8; i++) {
    final ang = math.pi * i / 8;
    final x = rh * math.cos(ang);
    cv.drawLine(Offset(x * .85, t.dy + .02), Offset(x, hem.dy + rh * _g * math.sin(ang)),
        _line(_al(_black, .12), .012));
  }
  cv.restore();
  _shadeOver(cv, skirt, light: .15, dark: .35, ly: .1);
  cv.drawPath(skirt, _line(const Color(0xFFB71C1C), _rw));
  // Cloth top.
  final topOv = _ov(t, rt, rt * _g);
  cv.save();
  cv.clipPath(Path()..addOval(topOv));
  a.plan(zt, () => _gingham(cv, Rect.fromCircle(center: Offset.zero, radius: rt + .05), .042, const Color(0xFFE53935)));
  cv.drawOval(topOv, _rad(t + const Offset(-.06, -.04), .3, [_al(_white, .35), _al(_white, 0), _al(_black, .15)], const [0, .5, 1]));
  cv.restore();
  cv.drawOval(topOv, _line(const Color(0xFFC62828), _rw * .8));
  // Golden cord.
  final cord = a.p(0, 0, .44);
  const gold = Color(0xFFFFC107);
  final cordPath = Path()..addArc(_ov(cord, .272, .272 * _g), .05, math.pi - .1);
  cv.drawPath(cordPath, _line(const Color(0xFFB8860B), .034));
  cv.drawPath(cordPath, _line(gold, .022));
  cv.drawPath(cordPath.shift(const Offset(0, -.004)), _line(_al(const Color(0xFFFFF59D), .8), .007));
  // Bow.
  final bow = cord + Offset(0, .272 * _g);
  for (final s in [-1.0, 1.0]) {
    final loop = Path()
      ..mv(bow)
      ..cb(bow + Offset(s * .06, -.06), bow + Offset(s * .1, .0), bow + Offset(s * .015, .012))
      ..close();
    cv.drawPath(loop, _fill(gold));
    cv.drawPath(loop, _line(const Color(0xFFB8860B), .008));
    cv.drawLine(bow, bow + Offset(s * .03, .07), _line(const Color(0xFFB8860B), .02));
    cv.drawLine(bow, bow + Offset(s * .03, .07), _line(gold, .011));
  }
  cv.drawCircle(bow, .014, _fill(const Color(0xFFFFB300)));
}

void _watermelon(_Art a) {
  final cv = a.cv, c = a.c;
  final g = _Globe.upright(a.p(0, 0, .475), .52, .47);
  final out = g.outline;
  final base = _lt(c, .28);
  cv.drawPath(out, _fill(base));
  cv.save();
  cv.clipPath(out);
  final stripe = _fill(_dk(c, .38));
  for (var i = 0; i < 10; i++) {
    final ph = 2 * math.pi * i / 10;
    cv.drawPath(
      g.band(
        (t) => ph - .13 - .05 * math.sin(t * 34 + i),
        (t) => ph + .13 + .05 * math.sin(t * 31 + i * 2),
        n: 90,
      ),
      stripe,
    );
  }
  cv.restore();
  _shadeOver(cv, out, light: .35, dark: .45, lx: .32, ly: .22);
  cv.drawPath(out, _line(_dk(c, .55), _rw * 1.2));
  _spec(cv, g.c + const Offset(-.2, -.22), .15, .08, rot: -.6, a: .55);
  _spec(cv, g.c + const Offset(-.25, -.15), .05, .03, rot: -.6, a: .7);
  final pole = g.raw(0, 0);
  cv.drawOval(_ov(pole, .035, .025), _fill(const Color(0xFF9E9D24)));
  cv.drawOval(_ov(pole, .02, .014), _fill(const Color(0xFF827717)));
}

// ===========================================================================
// Vegetables

void _carrot(_Art a) {
  final cv = a.cv, c = a.c;
  // Leaves first: the body covers their base.
  const b = Offset(-.15, 0);
  _leaf(cv, b, const Offset(-.36, -.13), .045, const Color(0xFF1B5E20), bend: .1);
  _leaf(cv, b, const Offset(-.36, .12), .045, const Color(0xFF2E7D32), bend: -.1);
  _leaf(cv, b, const Offset(-.385, -.06), .05, const Color(0xFF388E3C), bend: .05);
  _leaf(cv, b, const Offset(-.385, .05), .05, const Color(0xFF43A047), bend: -.05);
  _leaf(cv, b + const Offset(.01, 0), const Offset(-.31, -.005), .045, const Color(0xFF66BB6A));
  final body = Path()
    ..moveTo(-.15, -.086)
    ..cubicTo(.0, -.092, .22, -.04, .335, 0)
    ..cubicTo(.22, .05, .0, .095, -.15, .086)
    ..cubicTo(-.197, .083, -.197, -.083, -.15, -.086)
    ..close();
  cv.drawPath(body, _gloss(body.getBounds(), c, hi: .45, lo: .32, ly: .15));
  cv.save();
  cv.clipPath(body);
  for (final x in [-.1, -.03, .04, .11, .18, .245]) {
    final half = .085 * (1 - (x + .15) / .5);
    cv.drawPath(
      Path()
        ..moveTo(x - .005, -half * .25)
        ..quadraticBezierTo(x + .014, half * .3, x - .002, half * .85),
      _line(_al(_dk(c, .38), .6), .01),
    );
  }
  cv.restore();
  cv.drawPath(body, _line(_dk(c, .42), _rw));
  _spec(cv, const Offset(-.02, -.045), .13, .018, rot: .06, a: .6);
  cv.drawOval(_ov(const Offset(-.172, 0), .016, .06), _fill(_al(const Color(0xFF558B2F), .9)));
}

void _tomato(_Art a) {
  final cv = a.cv;
  final c = _mix(a.c, const Color(0xFFFF5722), .2);
  final body = Path()
    ..moveTo(0, -.15)
    ..cubicTo(-.1, -.175, -.205, -.13, -.205, -.015)
    ..cubicTo(-.205, .11, -.11, .17, 0, .17)
    ..cubicTo(.11, .17, .205, .11, .205, -.015)
    ..cubicTo(.205, -.13, .1, -.175, 0, -.15)
    ..close();
  _body(cv, body, c, hi: .5, lo: .32);
  cv.save();
  cv.clipPath(body);
  for (final s in [-1.0, 1.0]) {
    cv.drawPath(
      Path()
        ..moveTo(s * .03, -.12)
        ..quadraticBezierTo(s * .16, -.02, s * .08, .16),
      _line(_al(_dk(c, .35), .3), .014),
    );
  }
  cv.restore();
  _spec(cv, const Offset(-.1, -.06), .06, .035, rot: -.8);
  _spec(cv, const Offset(.06, -.1), .02, .012, rot: -.2, a: .6);
  // Calyx.
  const top = Offset(0, -.118);
  for (var i = 0; i < 6; i++) {
    final ang = -math.pi / 2 + i * math.pi / 3 + .25;
    final tip = top + Offset(math.cos(ang) * .1, math.sin(ang) * .1 * _g);
    _leaf(cv, top, tip, .02, const Color(0xFF2E7D32), bend: .15, vein: false);
  }
  cv.drawLine(top, top + const Offset(.005, -.045), _line(const Color(0xFF33691E), .024));
  cv.drawLine(top + const Offset(-.003, -.005), top + const Offset(.001, -.04), _line(const Color(0xFF689F38), .008));
}

void _pepper(_Art a) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(-.11, -.14)
    ..cubicTo(-.2, -.13, -.21, -.04, -.195, .05)
    ..cubicTo(-.185, .15, -.145, .21, -.09, .21)
    ..quadraticBezierTo(-.05, .21, -.03, .19)
    ..quadraticBezierTo(0, .215, .03, .19)
    ..quadraticBezierTo(.05, .21, .09, .21)
    ..cubicTo(.145, .21, .185, .15, .195, .05)
    ..cubicTo(.21, -.04, .2, -.13, .11, -.14)
    ..cubicTo(.07, -.15, .04, -.125, 0, -.135)
    ..cubicTo(-.04, -.125, -.07, -.15, -.11, -.14)
    ..close();
  _body(cv, body, c, hi: .45, lo: .4);
  cv.save();
  cv.clipPath(body);
  for (final s in [-1.0, 1.0]) {
    final crease = Path()
      ..moveTo(s * .045, -.12)
      ..quadraticBezierTo(s * .075, .05, s * .03, .2);
    cv.drawPath(crease, _line(_al(_dk(c, .5), .55), .016));
    cv.drawPath(crease.shift(Offset(s * .025, 0)), _line(_al(_lt(c, .4), .25), .02));
  }
  cv.restore();
  _spec(cv, const Offset(-.13, .0), .085, .018, rot: 1.45, a: .75);
  _spec(cv, const Offset(-.01, -.07), .03, .015, rot: -.4, a: .7);
  _spec(cv, const Offset(.12, .02), .05, .01, rot: 1.5, a: .35);
  // Stem cap and stem.
  const top = Offset(0, -.115);
  cv.drawOval(_ov(top, .07, .035), _fill(_al(_dk(c, .55), .7)));
  cv.save();
  cv.translate(top.dx, top.dy);
  cv.scale(1, _g);
  cv.drawPath(_star(Offset.zero, .06, .03, 5, rot: -1.2), _fill(const Color(0xFF388E3C)));
  cv.restore();
  final stem = Path()
    ..moveTo(top.dx, top.dy)
    ..quadraticBezierTo(top.dx - .005, top.dy - .08, top.dx + .055, top.dy - .1);
  cv.drawPath(stem, _line(const Color(0xFF2E7D32), .04));
  cv.drawPath(stem.shift(const Offset(-.006, -.003)), _line(const Color(0xFF7CB342), .014));
  cv.drawCircle(top + const Offset(.055, -.1), .02, _fill(const Color(0xFF9CCC65)));
}

void _eggplant(_Art a) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(-.18, 0)
    ..cubicTo(-.18, -.05, -.13, -.065, -.07, -.07)
    ..cubicTo(.0, -.075, .05, -.105, .15, -.105)
    ..cubicTo(.23, -.105, .275, -.06, .275, 0)
    ..cubicTo(.275, .065, .225, .105, .15, .105)
    ..cubicTo(.05, .105, .0, .075, -.07, .07)
    ..cubicTo(-.13, .065, -.18, .05, -.18, 0)
    ..close();
  _body(cv, body, c, hi: .4, lo: .45, ly: .15);
  _spec(cv, const Offset(.1, -.06), .1, .018, rot: .08, a: .75);
  _spec(cv, const Offset(-.08, -.04), .05, .012, rot: -.08, a: .5);
  // Calyx and stem.
  const green = Color(0xFF558B2F);
  final calyx = Path()
    ..moveTo(-.2, -.06)
    ..quadraticBezierTo(-.13, -.07, -.05, -.05)
    ..quadraticBezierTo(-.11, -.03, -.08, -.005)
    ..quadraticBezierTo(-.06, .03, -.03, .04)
    ..quadraticBezierTo(-.1, .06, -.14, .045)
    ..quadraticBezierTo(-.1, .075, -.07, .085)
    ..quadraticBezierTo(-.17, .09, -.2, .06)
    ..close();
  cv.drawPath(calyx, _gloss(calyx.getBounds(), green, hi: .4, lo: .3));
  cv.drawPath(calyx, _line(_dk(green, .4), _rw * .8));
  final stem = Path()
    ..moveTo(-.19, 0)
    ..quadraticBezierTo(-.25, -.005, -.3, -.03);
  cv.drawPath(stem, _line(_dk(green, .3), .045));
  cv.drawPath(stem.shift(const Offset(0, -.008)), _line(const Color(0xFF7CB342), .014));
  cv.drawOval(_ov(const Offset(-.302, -.031), .015, .022), _fill(const Color(0xFFAED581)));
}

void _corn(_Art a) {
  final cv = a.cv;
  final c = _mix(a.c, const Color(0xFFFFC107), .35);
  const husk = Color(0xFF8BC34A);
  _leaf(cv, const Offset(-.1, -.02), const Offset(-.37, -.08), .06, _dk(husk, .12), bend: .05, vein: false);
  final cob = Path()
    ..moveTo(-.15, -.085)
    ..lineTo(.2, -.08)
    ..cubicTo(.28, -.077, .325, -.03, .325, 0)
    ..cubicTo(.325, .03, .28, .077, .2, .08)
    ..lineTo(-.15, .085)
    ..close();
  cv.drawPath(cob, _fill(_dk(c, .5)));
  cv.save();
  cv.clipPath(cob);
  double halfW(double x) => x < .2 ? .083 : .083 * math.sqrt(math.max(0, 1 - math.pow((x - .2) / .125, 2)));
  var col = 0;
  for (var x = -.16; x < .33; x += .044, col++) {
    final hw = halfW(x + .022);
    if (hw < .015) continue;
    for (var j = -4; j <= 4; j++) {
      final th = (j + (col.isOdd ? .5 : 0)) * math.pi / 7;
      if (th.abs() > math.pi / 2 + .2) continue;
      final y0 = hw * math.sin((th - math.pi / 14).clamp(-math.pi / 2, math.pi / 2));
      final y1 = hw * math.sin((th + math.pi / 14).clamp(-math.pi / 2, math.pi / 2));
      if (y1 - y0 < .006) continue;
      final k = RRect.fromLTRBR(x + .004, y0 + .003, x + .04, y1 - .003, const Radius.circular(.012));
      final lit = (1 - (th + .5).abs() / 2.0).clamp(0.0, 1.0);
      final kc = Color.lerp(_dk(c, .2), _lt(c, .35), lit)!;
      cv.drawRRect(k, _lin(k.outerRect.topLeft, k.outerRect.bottomRight, [_lt(kc, .25), kc]));
      if ((y1 - y0) > .022) {
        cv.drawCircle(Offset(x + .016, y0 + (y1 - y0) * .35), .006, _fill(_al(_white, .6)));
      }
    }
  }
  cv.restore();
  cv.drawPath(cob, _line(_dk(c, .45), _rw));
  _leaf(cv, const Offset(-.08, .0), const Offset(-.385, .005), .06, husk, bend: .03);
  _leaf(cv, const Offset(-.07, .03), const Offset(-.33, .115), .055, _lt(husk, .15), bend: -.08);
}

void _onion(_Art a) {
  final cv = a.cv, c = a.c;
  final body = Path()
    ..moveTo(0, -.21)
    ..cubicTo(.02, -.16, .07, -.125, .13, -.09)
    ..cubicTo(.2, -.045, .21, .07, .16, .14)
    ..cubicTo(.12, .19, .06, .21, 0, .21)
    ..cubicTo(-.06, .21, -.12, .19, -.16, .14)
    ..cubicTo(-.21, .07, -.2, -.045, -.13, -.09)
    ..cubicTo(-.07, -.125, -.02, -.16, 0, -.21)
    ..close();
  _body(cv, body, c, hi: .45, lo: .4);
  cv.save();
  cv.clipPath(body);
  for (var k = -3; k <= 3; k++) {
    if (k == 0) continue;
    final line = Path()
      ..moveTo(0, -.2)
      ..quadraticBezierTo(k * .075, -.02, k * .025, .21);
    cv.drawPath(line, _line(_al(_lt(c, .55), .45), .008));
  }
  cv.restore();
  _spec(cv, const Offset(-.1, -.03), .06, .035, rot: -1.0, a: .75);
  final tail = Path()
    ..moveTo(0, -.2)
    ..quadraticBezierTo(.005, -.245, .035, -.255);
  cv.drawPath(tail, _line(const Color(0xFF8D6E63), .025));
  cv.drawPath(tail, _line(const Color(0xFFD7CCC8), .01));
}

void _broccoli(_Art a) {
  final cv = a.cv;
  const stemC = Color(0xFFAED581);
  final stem = Path()
    ..moveTo(-.06, .0)
    ..lineTo(.06, .0)
    ..quadraticBezierTo(.06, .14, .085, .2)
    ..lineTo(-.085, .2)
    ..quadraticBezierTo(-.06, .14, -.06, .0)
    ..close();
  cv.drawPath(stem, _sideShade(stem.getBounds(), stemC));
  cv.drawPath(stem, _line(_dk(stemC, .4), _rw));
  cv.drawOval(_ov(const Offset(0, .2), .085, .03), _fill(const Color(0xFFDCEDC8)));
  cv.drawOval(_ov(const Offset(0, .2), .085, .03), _line(_dk(stemC, .35), _rw * .8));
  const c = Color(0xFF388E3C);
  const florets = [
    [-.12, -.11, .09], [.0, -.14, .1], [.12, -.11, .09],
    [-.17, -.02, .085], [-.06, -.05, .1], [.07, -.05, .1], [.18, -.02, .08],
    [-.1, .05, .09], [.04, .055, .095],
  ];
  var seed = 1;
  for (final f in florets) {
    final o = Offset(f[0], f[1]);
    final r = f[2];
    final p = Path()..addOval(Rect.fromCircle(center: o, radius: r));
    _body(cv, p, c, hi: .35, lo: .35, rim: .45);
    final rnd = math.Random(seed++);
    for (var i = 0; i < 7; i++) {
      final ang = rnd.nextDouble() * 2 * math.pi;
      final d = rnd.nextDouble() * r * .6;
      final q = o + Offset(math.cos(ang) * d, math.sin(ang) * d);
      cv.drawCircle(q, r * .22, _fill(_al(_lt(c, .35), .35)));
      cv.drawCircle(q + Offset(r * .06, r * .06), r * .2, _line(_al(_dk(c, .4), .35), .006));
    }
  }
  _spec(cv, const Offset(-.03, -.17), .04, .02, rot: -.4, a: .35);
}

void _cabbage(_Art a) {
  final cv = a.cv, c = a.c;
  Path wavy(Offset o, double rr, int lobes, double amp, double phase, {double sy = 1}) {
    final pts = <Offset>[];
    for (var i = 0; i < 96; i++) {
      final t = 2 * math.pi * i / 96;
      final rad = rr * (1 + amp * math.sin(t * lobes + phase));
      pts.add(o + Offset(math.cos(t) * rad, math.sin(t) * rad * sy));
    }
    return _poly(pts);
  }

  final leafC = _dk(_mix(c, const Color(0xFF7CB342), .6), .05);
  void leaf(Path shape, Offset root, Color col) {
    final b = shape.getBounds();
    cv.drawPath(shape, _gloss(b, col, hi: .3, lo: .4, ly: .2));
    cv.save();
    cv.clipPath(shape);
    final vein = _line(_al(const Color(0xFFE6F2C8), .8), .016);
    final thin = _line(_al(const Color(0xFFE6F2C8), .5), .008);
    final top = Offset(b.center.dx, b.top);
    cv.drawLine(root, top + const Offset(0, .02), vein);
    for (var v = -3; v <= 3; v++) {
      if (v == 0) continue;
      final m = Offset.lerp(root, top, .3 + v.abs() * .08)!;
      cv.drawPath(
        Path()
          ..mv(m)
          ..qd(m + Offset(v * .03, -.05), m + Offset(v * .07, -.12 + v.abs() * .015)),
        thin,
      );
    }
    cv.restore();
    cv.drawPath(shape, _line(_dk(col, .4), _rw));
  }

  // Back leaves peeking out behind the head.
  leaf(wavy(const Offset(-.21, -.1), .17, 6, .05, 0), const Offset(-.12, .0), _dk(leafC, .12));
  leaf(wavy(const Offset(.21, -.1), .17, 6, .05, 1), const Offset(.12, .0), _dk(leafC, .12));
  // Head.
  const hc = Offset(0, -.05);
  final head = Path()..addOval(Rect.fromCircle(center: hc, radius: .29));
  final headC = _lt(c, .12);
  cv.drawPath(head, _gloss(head.getBounds(), headC, hi: .45, lo: .35));
  cv.save();
  cv.clipPath(head);
  for (var i = 0; i < 4; i++) {
    final rr = .09 + i * .07;
    final arc = Path()..addArc(_ov(hc + Offset(.03 - .02 * i, -.1 + .03 * i), rr, rr * .85), -2.9 + i * .25, 2.1);
    cv.drawPath(arc, _line(_al(_dk(c, .25), .5), .012));
    cv.drawPath(arc.shift(const Offset(-.006, -.008)), _line(_al(_white, .35), .008));
  }
  cv.restore();
  cv.drawPath(head, _line(_dk(c, .4), _rw));
  _spec(cv, hc + const Offset(-.12, -.15), .07, .035, rot: -.7, a: .55);
  // Front leaves wrapping the head.
  leaf(wavy(const Offset(-.17, .13), .2, 7, .045, 2, sy: .95), const Offset(-.15, .31), leafC);
  leaf(wavy(const Offset(.17, .13), .2, 7, .045, .5, sy: .95), const Offset(.15, .31), leafC);
  leaf(wavy(const Offset(0, .2), .18, 8, .045, 0, sy: .9), const Offset(0, .36), _lt(leafC, .08));
}

void _pumpkin(_Art a) {
  final cv = a.cv, c = a.c;
  final g = _Globe.upright(a.p(0, 0, .29), .47, .29);
  final out = g.outline;
  cv.drawPath(out, _gloss(out.getBounds(), c, hi: .4, lo: .35));
  cv.save();
  cv.clipPath(out);
  const ribs = 10;
  for (var i = 0; i < ribs; i++) {
    final ph = 2 * math.pi * (i + .5) / ribs;
    cv.drawPath(
      g.curve((t) => .35 + t * 2.0, (t) => ph, n: 40),
      _line(_al(_lt(c, .5), .35), .07),
    );
  }
  for (var i = 0; i < ribs; i++) {
    final ph = 2 * math.pi * i / ribs;
    cv.drawPath(g.curve((t) => .12 + t * (math.pi - .12), (t) => ph, n: 60), _line(_al(_dk(c, .4), .75), .018));
  }
  cv.restore();
  _shadeOver(cv, out, light: .15, dark: .35);
  cv.drawPath(out, _line(_dk(c, .45), _rw * 1.2));
  _spec(cv, g.c + const Offset(-.2, -.17), .1, .05, rot: -.5, a: .55);
  final pole = g.raw(0, 0);
  cv.drawOval(_ov(pole, .1, .05), _rad(pole, .1, [_al(_dk(c, .6), .8), _al(_dk(c, .5), 0)]));
  // Stem.
  const stemC = Color(0xFF6D7B2F);
  final stem = Path()
    ..mv(pole + const Offset(0, .01))
    ..qd(pole + const Offset(-.005, -.09), pole + const Offset(.05, -.14));
  cv.drawPath(stem, _line(_dk(stemC, .35), .07));
  cv.drawPath(stem, _line(stemC, .05));
  cv.drawPath(stem.shift(const Offset(-.01, 0)), _line(_al(_lt(stemC, .4), .7), .012));
  cv.drawOval(_ov(pole + const Offset(.052, -.142), .028, .02), _fill(const Color(0xFFC0CA33)));
}

// ===========================================================================
// Sweets

/// Frosting on the top of a round tier (top ellipse plus drips).
void _frosting(_Art a, double z, double r, Color c, math.Random rnd, {int drips = 9, double maxLen = .09, double band = .015}) {
  final cv = a.cv;
  final ctr = a.p(0, 0, z);
  final ry = r * _g;
  final lens = List.generate(drips, (_) => maxLen * (.35 + .65 * rnd.nextDouble()));
  final path = Path()..moveTo(ctr.dx - r, ctr.dy);
  path.arcTo(_ov(ctr, r, ry), math.pi, math.pi, false);
  const n = 120;
  for (var i = 0; i <= n; i++) {
    final t = i / n * math.pi;
    var d = band;
    for (var j = 0; j < drips; j++) {
      final tc = (j + .5) / drips * math.pi;
      final u = ((t - tc) / (math.pi / drips * .42)).abs();
      if (u < 1) {
        final prof = u < .45 ? 1.0 : math.sqrt(1 - math.pow((u - .45) / .55, 2));
        d = math.max(d, band + lens[j] * prof);
      }
    }
    path.lineTo(ctr.dx + r * math.cos(t), ctr.dy + ry * math.sin(t) + d);
  }
  path.close();
  cv.drawPath(path, _sideShade(path.getBounds(), c, hi: .3, lo: .25));
  cv.drawPath(path, _line(_dk(c, .25), _rw * .8));
  final top = _ov(ctr, r, ry);
  cv.drawOval(top, _rad(ctr + Offset(-r * .35, -ry * .4), r * 1.2, [_lt(c, .5), c, _dk(c, .06)], const [0, .55, 1]));
}

void _sprinkles(Canvas cv, math.Random rnd, int n, Offset Function() pos, {double len = .03, double w = .012}) {
  const colors = [
    Color(0xFFFFFFFF), Color(0xFFFFEB3B), Color(0xFF4FC3F7), Color(0xFF81C784), Color(0xFFE53935), Color(0xFFBA68C8),
  ];
  for (var i = 0; i < n; i++) {
    _capsule(cv, pos(), rnd.nextDouble() * math.pi, len, w, colors[rnd.nextInt(colors.length)]);
  }
}

void _donut(_Art a, {required bool choco}) {
  final cv = a.cv;
  const dough = Color(0xFFE3A857);
  const r = .25, rh = .07, h = .12;
  final icing = choco ? a.c : a.c;
  final top = a.p(0, 0, .085), bot = a.p(0, 0, .03);
  final outer = Path()
    ..moveTo(top.dx - r, top.dy)
    ..arcTo(_ov(top, r, r * _g), math.pi, math.pi, false)
    ..lineTo(bot.dx + r - .008, bot.dy)
    ..arcTo(_ov(bot, r - .008, (r - .008) * _g), 0, math.pi, false)
    ..close();
  final holeTop = Path()..addOval(a.disk(rh, h));
  final holeBot = Path()..addOval(a.disk(rh, 0));
  final see = Path.combine(PathOperation.intersect, holeTop, holeBot);
  final body = Path.combine(PathOperation.difference, outer, see);
  cv.drawPath(body, _sideShade(outer.getBounds(), dough, hi: .25, lo: .35));
  cv.drawPath(Path.combine(PathOperation.difference, holeTop, holeBot), _fill(_dk(dough, .3)));
  cv.drawPath(body, _line(_dk(dough, .4), _rw));
  // Icing ring.
  final rnd = math.Random(choco ? 5 : 4);
  a.plan(h, () {
    Path ring() {
      final pts = <Offset>[];
      for (var i = 0; i < 120; i++) {
        final t = 2 * math.pi * i / 120;
        final rr = .208 + .012 * math.sin(t * 9) + .006 * math.sin(t * 4 + 1);
        pts.add(Offset(math.cos(t) * rr, math.sin(t) * rr));
      }
      final inner = <Offset>[];
      for (var i = 0; i < 60; i++) {
        final t = 2 * math.pi * i / 60;
        final rr = rh + .018 + .005 * math.sin(t * 6);
        inner.add(Offset(math.cos(t) * rr, math.sin(t) * rr));
      }
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addPolygon(pts, true)
        ..addPolygon(inner, true);
    }

    final ice = ring();
    cv.drawPath(
      ice,
      _rad(Offset.zero, .22, [_dk(icing, .2), _dk(icing, .05), _lt(icing, .3), icing, _dk(icing, .12)],
          const [0, .45, .62, .82, 1]),
    );
    cv.save();
    cv.clipPath(ice);
    cv.drawCircle(const Offset(-.07, -.07), .17, _fill(_al(_white, .12)));
    if (choco) {
      final z = Path()..moveTo(-.24, -.2);
      var up = false;
      for (var x = -.2; x <= .26; x += .045) {
        z.lineTo(x, up ? -.2 : .2);
        up = !up;
      }
      cv.drawPath(z, _line(_lt(const Color(0xFFFFF3E0), .3), .016));
    } else {
      _sprinkles(cv, rnd, 26, () {
        final ang = rnd.nextDouble() * 2 * math.pi;
        final d = .11 + rnd.nextDouble() * .08;
        return Offset(math.cos(ang) * d, math.sin(ang) * d);
      }, len: .032, w: .013);
    }
    cv.restore();
    cv.drawPath(ice, _line(_dk(icing, .3), _rw * .8));
  });
  // Drips over the front edge.
  for (final ang in [.6, 1.45, 2.3]) {
    final o = a.p(math.cos(ang) * .2, -math.sin(ang) * .2, h);
    final len = .03 + .02 * math.sin(ang * 5).abs();
    final drip = RRect.fromLTRBR(o.dx - .018, o.dy - .01, o.dx + .018, o.dy + len, const Radius.circular(.018));
    cv.drawRRect(drip, _lin(Offset(o.dx - .018, 0), Offset(o.dx + .018, 0), [_lt(icing, .2), _dk(icing, .1)]));
  }
  _spec(cv, a.p(-.12, .08, h), .05, .015, rot: -.5, a: .55);
}

void _macaron(_Art a) {
  final cv = a.cv, c = a.c;
  final cream = _mix(_lt(c, .82), const Color(0xFFFFFBF0), .5);
  // Bottom shell.
  final bottom = _cylSil(a, .158, 0, .166, .034);
  cv.drawPath(bottom, _sideShade(bottom.getBounds(), c, hi: .25, lo: .35));
  cv.drawPath(bottom, _line(_dk(c, .38), _rw));
  // Cream filling, slightly bulging.
  final fill = _cylSil(a, .162, .03, .162, .082);
  cv.drawPath(fill, _sideShade(fill.getBounds(), cream, hi: .35, lo: .25));
  cv.drawPath(fill, _line(_dk(cream, .3), _rw * .7));
  // Top shell: a squat dome.
  final t0 = a.p(0, 0, .08), t1 = a.p(0, 0, .1);
  final dome = Path()
    ..moveTo(t1.dx - .168, t1.dy)
    ..arcTo(_ov(t1, .168, .168 * _g + .006), math.pi, math.pi, false)
    ..lineTo(t0.dx + .168, t0.dy)
    ..arcTo(_ov(t0, .168, .168 * _g), 0, math.pi, false)
    ..close();
  _body(cv, dome, c, hi: .45, lo: .3, ly: .2);
  // Ruffled foot of the top shell.
  for (var i = 1; i < 26; i++) {
    final ang = math.pi * i / 26;
    final o = a.p(.166 * math.cos(ang), -.166 * math.sin(ang), .084);
    cv.drawCircle(o, .006, _fill(_al(_dk(c, .2), .35)));
  }
  _spec(cv, t1 + const Offset(-.065, -.055), .055, .02, rot: -.35, a: .7);
}

void _cookie(_Art a) {
  final cv = a.cv;
  const top = Color(0xFFD9A066);
  final side = a.c;
  final pts = <Offset>[];
  for (var i = 0; i < 90; i++) {
    final t = 2 * math.pi * i / 90;
    final rr = .185 * (1 + .025 * math.sin(t * 5) + .015 * math.sin(t * 11 + 1));
    pts.add(Offset(math.cos(t) * rr, math.sin(t) * rr));
  }
  final tp = _slab(a, pts, 0, .04, side, hi: .2);
  final tb = tp.getBounds();
  cv.drawPath(tp, _rad(tb.center + Offset(-tb.width * .15, -tb.height * .2), tb.width * .6, [_lt(top, .35), top, _dk(top, .08)], const [0, .55, 1]));
  _speckle(cv, tp, _al(_dk(top, .25), .35), 40, seed: 9, size: .006);
  const chipC = Color(0xFF4E342E);
  final rnd = math.Random(21);
  for (final q in const [
    [-.08, -.06], [.05, -.08], [.11, .02], [-.12, .04], [.0, .02], [-.04, .1], [.08, .1], [.14, -.07], [-.14, -.06],
  ]) {
    final o = a.p(q[0], -q[1], .045);
    final blob = <Offset>[];
    final s = .022 + rnd.nextDouble() * .01;
    for (var i = 0; i < 7; i++) {
      final t = 2 * math.pi * i / 7 + rnd.nextDouble() * .4;
      final rr = s * (.75 + rnd.nextDouble() * .4);
      blob.add(o + Offset(math.cos(t) * rr, math.sin(t) * rr * .8));
    }
    final chip = _poly(blob);
    cv.drawPath(chip, _gloss(chip.getBounds(), chipC, hi: .25, lo: .2));
    cv.drawCircle(o + Offset(-s * .3, -s * .3), s * .25, _fill(_al(_white, .35)));
  }
  cv.drawPath(tp, _line(_dk(side, .3), _rw * .8));
}

void _waffle(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .25, h = .06;
  _slab(a, _circ(r), 0, h, _dk(c, .12), hi: .25);
  a.plan(h, () {
    cv.drawCircle(Offset.zero, r, _fill(_dk(c, .05)));
    cv.drawCircle(Offset.zero, r - .022, _rad(const Offset(-.06, -.06), .28, [_lt(c, .3), c, _dk(c, .1)]));
    cv.save();
    cv.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r - .03)));
    const step = .066, pocket = .046;
    for (var i = -4; i <= 4; i++) {
      for (var j = -4; j <= 4; j++) {
        final o = Offset(i * step, j * step);
        final rr = RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: pocket, height: pocket), const Radius.circular(.008));
        cv.drawRRect(rr, _fill(_dk(c, .3)));
        cv.drawRRect(
          rr.shift(const Offset(.006, .006)).deflate(.004),
          _fill(_dk(c, .14)),
        );
      }
    }
    cv.restore();
    cv.drawCircle(Offset.zero, r, _line(_dk(c, .35), _rw * .8));
  });
  _spec(cv, a.p(-.1, .1, h), .08, .02, rot: -.5, a: .45);
}

void _cupcake(_Art a) {
  final cv = a.cv, c = a.c;
  const wrap = Color(0xFF4FC3F7);
  // Pleated wrapper.
  const zt = .19, rt = .175, rb = .13;
  final t = a.p(0, 0, zt), b = a.p(0, 0, 0);
  final cup = Path()
    ..moveTo(t.dx - rt, t.dy)
    ..lineTo(b.dx - rb, b.dy)
    ..arcTo(_ov(b, rb, rb * _g), math.pi, -math.pi, false)
    ..lineTo(t.dx + rt, t.dy)
    ..arcTo(_ov(t, rt, rt * _g), 0, math.pi, false)
    ..close();
  cv.drawPath(cup, _sideShade(cup.getBounds(), wrap, hi: .35, lo: .35));
  cv.save();
  cv.clipPath(cup);
  for (var i = -7; i <= 7; i++) {
    final s = math.sin(i * math.pi / 15);
    cv.drawLine(Offset(s * rt, t.dy), Offset(s * rb, b.dy + rb * _g), _line(_al(_dk(wrap, .35), .5), .01));
    cv.drawLine(Offset(s * rt + .012, t.dy), Offset(s * rb + .009, b.dy + rb * _g), _line(_al(_white, .35), .008));
  }
  cv.restore();
  cv.drawPath(cup, _line(_dk(wrap, .4), _rw));
  // Piped swirl of frosting: puffs along a rising spiral, back to front.
  final puffs = <(double, Offset, double)>[];
  const turns = 2.4;
  for (var i = 0; i <= 44; i++) {
    final u = i / 44;
    final th = -math.pi / 2 + 2 * math.pi * turns * u;
    final rr = u < .4 ? .14 : .14 * (1 - (u - .4) / .6) + .015;
    final z = zt + .02 + .17 * u;
    final x = rr * math.cos(th), y = rr * math.sin(th);
    final depth = -y * _hs + z * _g;
    puffs.add((depth, a.p(x, y, z), .07 * (1 - u * .55)));
  }
  puffs.sort((p, q) => p.$1.compareTo(q.$1));
  for (final (_, o, r) in puffs) {
    final p = Path()..addOval(_ov(o, r, r * .88));
    cv.drawPath(p, _gloss(p.getBounds(), c, hi: .45, lo: .25));
    cv.drawPath(p, _line(_al(_dk(c, .3), .6), _rw * .7));
  }
  final rnd = math.Random(8);
  _sprinkles(cv, rnd, 14, () {
    final ang = rnd.nextDouble() * 2 * math.pi;
    final d = .03 + rnd.nextDouble() * .13;
    return a.p(math.cos(ang) * d, math.sin(ang) * d, .3 - d * .6);
  }, len: .024, w: .011);
  // Cherry.
  final ch = a.p(.0, 0, .4);
  final cherry = Path()..addOval(Rect.fromCircle(center: ch, radius: .045));
  _body(cv, cherry, const Color(0xFFD32F2F), hi: .5, lo: .4);
  _spec(cv, ch + const Offset(-.016, -.016), .016, .01, rot: -.8);
  cv.drawPath(
    Path()
      ..mv(ch + const Offset(0, -.04))
      ..qd(ch + const Offset(.005, -.08), ch + const Offset(.04, -.1)),
    _line(const Color(0xFF6D4C41), .012),
  );
}

void _pancakes(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .25, th = .06;
  const offs = [-.006, .008, -.004];
  for (var i = 0; i < 3; i++) {
    final z0 = i * .064, z1 = z0 + th;
    final x = offs[i];
    final s = _cylSil(a, r - .01, z0, r, z1, x: x);
    cv.drawPath(s, _sideShade(s.getBounds(), _dk(c, .1), hi: .25, lo: .4));
    final mid = a.p(x, 0, z0 + th * .55);
    cv.drawPath(Path()..addArc(_ov(mid, r - .005, (r - .005) * _g), .15, math.pi - .3), _line(_al(_lt(c, .45), .7), .014));
    cv.drawPath(s, _line(_dk(c, .45), _rw));
    final tp = a.disk(r, z1, x: x);
    cv.drawOval(tp, _rad(tp.center + const Offset(-.05, -.04), .3, [_lt(c, .35), _lt(c, .1), c], const [0, .5, 1]));
    cv.drawOval(tp, _line(_dk(c, .25), _rw * .7));
  }
  // Syrup.
  const zTop = .188;
  const syrup = Color(0xFFB85C10);
  final rnd = math.Random(4);
  final pts = <Offset>[];
  for (var i = 0; i < 80; i++) {
    final t = 2 * math.pi * i / 80;
    final rr = .2 + .015 * math.sin(t * 5 + 1);
    pts.add(a.p(math.cos(t) * rr, -math.sin(t) * rr, zTop));
  }
  final pool = _poly(pts);
  for (final ang in [.5, 1.3, 2.2, 2.7]) {
    final o = a.p(math.cos(ang) * .235, -math.sin(ang) * .235, zTop);
    final len = .04 + rnd.nextDouble() * .05;
    final drip = RRect.fromLTRBR(o.dx - .02, o.dy - .02, o.dx + .02, o.dy + len, const Radius.circular(.02));
    cv.drawRRect(drip, _lin(Offset(o.dx - .02, 0), Offset(o.dx + .02, 0), [_lt(syrup, .2), _dk(syrup, .15)]));
  }
  cv.drawPath(pool, _gloss(pool.getBounds(), syrup, hi: .35, lo: .2));
  cv.drawPath(pool, _line(_dk(syrup, .3), _rw * .7));
  _spec(cv, a.p(-.08, .06, zTop), .07, .02, rot: -.4, a: .6);
  // Raspberries.
  for (final q in const [[-.05, .02], [.05, .0], [-.005, .07]]) {
    final o = a.p(q[0], q[1], zTop + .04);
    final berry = Path()..addOval(Rect.fromCircle(center: o, radius: .042));
    _body(cv, berry, const Color(0xFFD81B60), hi: .4, lo: .35);
    for (var i = 0; i < 6; i++) {
      final ang = i * math.pi / 3;
      cv.drawCircle(o + Offset(math.cos(ang), math.sin(ang)) * .022, .011, _line(_al(_dk(const Color(0xFFD81B60), .35), .5), .005));
    }
    _spec(cv, o + const Offset(-.015, -.015), .014, .009, a: .8);
  }
}

void _cocoaMug(_Art a) {
  final cv = a.cv, c = a.c;
  const r = .16, h = .28;
  // Handle.
  final h0 = a.p(.15, 0, .22), h1 = a.p(.15, 0, .07);
  final handle = Path()
    ..mv(h0)
    ..cb(h0 + const Offset(.13, -.02), h1 + const Offset(.13, .02), h1);
  cv.drawPath(handle, _line(_dk(c, .35), .055));
  cv.drawPath(handle, _line(c, .04));
  cv.drawPath(handle.shift(const Offset(-.004, -.006)), _line(_al(_lt(c, .5), .7), .01));
  // Body.
  final body = _cylSil(a, r, 0, r, h);
  cv.drawPath(body, _sideShade(body.getBounds(), c, hi: .3, lo: .4));
  cv.drawPath(_heart(a.p(-.02, -r, .13) + const Offset(0, .02), .045), _fill(_al(_white, .9)));
  cv.drawPath(body, _line(_dk(c, .4), _rw));
  _spec(cv, a.p(-.1, -r, .15), .015, .06, rot: 0, a: .45);
  // Rim and cocoa.
  final rim = a.disk(r, h);
  cv.drawOval(rim, _fill(_lt(c, .25)));
  final inner = a.disk(r - .022, h);
  cv.drawOval(inner, _fill(_dk(c, .45)));
  cv.save();
  cv.clipPath(Path()..addOval(inner));
  final cocoa = a.disk(r - .022, h - .04);
  cv.drawOval(cocoa, _rad(cocoa.center, .14, const [Color(0xFF8D6E63), Color(0xFF6D4C41), Color(0xFF4E342E)], const [0, .6, 1]));
  for (final q in const [[-.05, .03, .2], [.04, .045, -.3], [.0, -.04, .5], [.07, -.02, .1]]) {
    final o = a.p(q[0], q[1], h - .02);
    cv.save();
    cv.translate(o.dx, o.dy);
    cv.rotate(q[2]);
    final side = RRect.fromLTRBR(-.026, -.016, .026, .03, const Radius.circular(.01));
    cv.drawRRect(side, _fill(const Color(0xFFE6D3B3)));
    final top = RRect.fromLTRBR(-.026, -.022, .026, .014, const Radius.circular(.01));
    cv.drawRRect(top, _fill(const Color(0xFFFFF8E1)));
    cv.drawRRect(side, _line(const Color(0xFFBCAAA4), .005));
    cv.restore();
  }
  cv.restore();
  cv.drawOval(rim, _line(_dk(c, .3), _rw * .8));
}

void _milkshake(_Art a) {
  final cv = a.cv, c = a.c;
  const glass = Color(0xFFE3F2FD);
  // Foot and stem.
  final foot = _cylSil(a, .125, 0, .125, .028);
  cv.drawPath(foot, _sideShade(foot.getBounds(), glass, hi: .4, lo: .3));
  cv.drawOval(a.disk(.125, .028), _fill(_lt(glass, .5)));
  cv.drawPath(foot, _line(const Color(0xFF90A4AE), _rw * .8));
  final s0 = a.p(0, 0, .028), s1 = a.p(0, 0, .14);
  final stem = Rect.fromLTRB(-.026, s1.dy, .026, s0.dy);
  cv.drawRect(stem, _sideShade(stem, glass, hi: .4, lo: .3));
  // Cup.
  final cup = _cylSil(a, .09, .13, .19, .38);
  cv.drawPath(cup, _sideShade(cup.getBounds(), c, hi: .3, lo: .3));
  cv.save();
  cv.clipPath(cup);
  final cb = cup.getBounds();
  cv.drawRect(Rect.fromLTRB(-.15, cb.top, -.11, cb.bottom), _fill(_al(_white, .45)));
  cv.drawRect(Rect.fromLTRB(.11, cb.top, .13, cb.bottom), _fill(_al(_white, .3)));
  cv.restore();
  cv.drawPath(cup, _line(_dk(c, .3), _rw));
  cv.drawOval(a.disk(.19, .38), _line(_al(_white, .9), .018));
  // Straw (behind the cream top).
  final st0 = a.p(.03, .02, .42), st1 = a.p(.16, .02, .7);
  cv.drawLine(st0, st1, _line(const Color(0xFFC62828), .04));
  cv.drawLine(st0, st1, _line(_white, .031));
  final d = st1 - st0;
  for (var i = 0; i < 6; i++) {
    final p0 = st0 + d * (i / 6), p1 = st0 + d * ((i + .5) / 6);
    cv.drawLine(p0, p1, _line(const Color(0xFFE53935), .031));
  }
  // Whipped cream.
  const cream = Color(0xFFFFFDF5);
  for (final tier in const [[.38, .185, .065], [.44, .135, .06], [.49, .085, .055]]) {
    final o = a.p(0, 0, tier[0]);
    final p = Path()..addOval(_ov(o, tier[1], tier[1] * _g * .8 + tier[2] * _hs * .6));
    _body(cv, p, cream, hi: .5, lo: .14, rim: .2);
  }
  final peak = Path()
    ..mv(a.p(-.045, 0, .52))
    ..qd(a.p(-.01, 0, .585), a.p(.025, 0, .59))
    ..qd(a.p(.01, 0, .55), a.p(.05, 0, .52))
    ..close();
  _body(cv, peak, cream, hi: .5, lo: .14, rim: .2);
  final ch = a.p(-.005, 0, .59);
  final cherry = Path()..addOval(Rect.fromCircle(center: ch, radius: .046));
  _body(cv, cherry, const Color(0xFFD32F2F), hi: .5, lo: .4);
  _spec(cv, ch + const Offset(-.016, -.016), .016, .01, rot: -.8);
  cv.drawPath(
    Path()
      ..mv(ch + const Offset(0, -.042))
      ..qd(ch + const Offset(.0, -.08), ch + const Offset(.04, -.095)),
    _line(const Color(0xFF6D4C41), .012),
  );
}

void _pie(_Art a) {
  final cv = a.cv;
  const crust = Color(0xFFF2A94A);
  const r = .5, zs = .13;
  _slab(a, _circ(r), 0, zs, _dk(crust, .08), hi: .2);
  // Filling.
  const fillC = Color(0xFFC62828);
  a.plan(zs, () {
    cv.drawCircle(Offset.zero, r, _fill(_dk(crust, .1)));
    cv.drawCircle(Offset.zero, .44, _rad(const Offset(-.1, -.1), .5, [_lt(fillC, .2), fillC, _dk(fillC, .25)]));
  });
  // Lattice (woven).
  a.plan(zs + .02, () {
    cv.save();
    cv.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: .44)));
    const w = .075;
    const pos = [-.3, -.15, .0, .15, .3];
    Paint strip(bool vertical) => _lin(
      vertical ? const Offset(-w / 2, 0) : const Offset(0, -w / 2),
      vertical ? const Offset(w / 2, 0) : const Offset(0, w / 2),
      [_lt(crust, .35), crust, _dk(crust, .15)],
    );
    void vStrip(double x, double y0, double y1) {
      cv.save();
      cv.translate(x, 0);
      final rr = Rect.fromLTRB(-w / 2, y0, w / 2, y1);
      cv.drawRect(rr.shift(const Offset(.008, 0)), _fill(_al(_black, .25)));
      cv.drawRect(rr, strip(true));
      cv.drawLine(Offset(-w / 2, y0), Offset(-w / 2, y1), _line(_dk(crust, .3), .006));
      cv.drawLine(Offset(w / 2, y0), Offset(w / 2, y1), _line(_dk(crust, .3), .006));
      cv.restore();
    }

    void hStrip(double y) {
      cv.save();
      cv.translate(0, y);
      final rr = const Rect.fromLTRB(-.5, -w / 2, .5, w / 2);
      cv.drawRect(rr.shift(const Offset(0, .012)), _fill(_al(_black, .25)));
      cv.drawRect(rr, strip(false));
      cv.drawLine(const Offset(-.5, -w / 2), const Offset(.5, -w / 2), _line(_dk(crust, .3), .006));
      cv.drawLine(const Offset(-.5, w / 2), const Offset(.5, w / 2), _line(_dk(crust, .3), .006));
      cv.restore();
    }

    for (final x in pos) {
      vStrip(x, -.5, .5);
    }
    for (final y in pos) {
      hStrip(y);
    }
    for (var i = 0; i < pos.length; i++) {
      for (var j = 0; j < pos.length; j++) {
        if ((i + j).isEven) continue;
        vStrip(pos[i], pos[j] - w * .75, pos[j] + w * .75);
      }
    }
    cv.restore();
  });
  // Crimped rim.
  const n = 26;
  final bumps = <Offset>[
    for (var i = 0; i < n; i++) Offset(math.cos(2 * math.pi * i / n) * .46, math.sin(2 * math.pi * i / n) * .46),
  ]..sort((p, q) => p.dy.compareTo(q.dy));
  for (final b in bumps) {
    final o = a.p(b.dx, -b.dy, zs + .03);
    final p = Path()..addOval(_ov(o, .06, .045));
    _body(cv, p, crust, hi: .45, lo: .25, rim: .3, ly: .15);
  }
  // Blueberries.
  const blue = Color(0xFF3949AB);
  _leaf(cv, a.p(.02, .02, zs + .06), a.p(.14, .07, zs + .06), .035, const Color(0xFF66BB6A));
  for (final q in const [[-.06, .05], [.05, .06], [.0, .0], [-.07, -.04], [.07, -.03], [.0, -.08]]) {
    final o = a.p(q[0], q[1], zs + .07);
    final berry = Path()..addOval(Rect.fromCircle(center: o, radius: .05));
    _body(cv, berry, blue, hi: .45, lo: .35);
    cv.drawPath(_star(o + const Offset(0, -.018), .014, .006, 5), _fill(_dk(blue, .45)));
    _spec(cv, o + const Offset(-.02, -.018), .016, .01, rot: -.7, a: .8);
  }
}

void _cake(_Art a) {
  final cv = a.cv, c = a.c;
  const cream = Color(0xFFFFF7FA);
  final rnd = math.Random(12);
  const tiers = [
    // z0, z1, radius, isPink
    [0.0, .34, .47, 1.0],
    [.34, .64, .35, 0.0],
    [.64, .9, .235, 1.0],
  ];
  for (final t in tiers) {
    final z0 = t[0], z1 = t[1], r = t[2];
    final pink = t[3] > .5;
    final body = pink ? c : cream;
    final icing = pink ? cream : c;
    final s = _cylSil(a, r, z0, r, z1);
    cv.drawPath(s, _sideShade(s.getBounds(), body, hi: .3, lo: .3));
    // Sprinkles on the side.
    final sb = s.getBounds();
    cv.save();
    cv.clipPath(s);
    _sprinkles(cv, rnd, (r * 60).round(), () {
      final x = (rnd.nextDouble() * 2 - 1) * r * .9;
      return Offset(x, sb.bottom - rnd.nextDouble() * (sb.height * .55));
    }, len: .028, w: .011);
    cv.restore();
    cv.drawPath(s, _line(_dk(body, .3), _rw));
    _frosting(a, z1, r + .008, icing, rnd, drips: (r * 22).round(), maxLen: .07 + r * .1);
    // Sprinkles on top.
    final top = a.disk(r * .8, z1);
    _sprinkles(cv, rnd, (r * 40).round(), () {
      final ang = rnd.nextDouble() * 2 * math.pi;
      final d = math.sqrt(rnd.nextDouble());
      return top.center + Offset(math.cos(ang) * d * top.width / 2, math.sin(ang) * d * top.height / 2);
    }, len: .026, w: .011);
  }
  // Candles.
  const colors = [Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFFFDD835)];
  const spots = [[.0, .08], [-.11, -.02], [.11, -.03]];
  for (var i = 0; i < 3; i++) {
    final x = spots[i][0], y = spots[i][1];
    final b = a.p(x, y, .9), t = a.p(x, y, 1.1);
    final rect = Rect.fromLTRB(b.dx - .028, t.dy, b.dx + .028, b.dy);
    cv.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(.01)), _sideShade(rect, colors[i], hi: .35, lo: .35));
    cv.save();
    cv.clipRect(rect);
    for (var k = 0; k < 4; k++) {
      final yy = t.dy + k * .03;
      cv.drawLine(Offset(rect.left, yy + .02), Offset(rect.right, yy), _line(_al(_white, .8), .008));
    }
    cv.restore();
    cv.drawOval(_ov(t, .028, .013), _fill(_lt(colors[i], .3)));
    cv.drawLine(t, t + const Offset(0, -.02), _line(const Color(0xFF424242), .006));
    final f = t + const Offset(0, -.05);
    cv.drawCircle(f, .05, _rad(f, .05, [_al(const Color(0xFFFFEB3B), .45), _al(const Color(0xFFFFEB3B), 0)]));
    final flame = Path()
      ..mv(f + const Offset(0, -.042))
      ..qd(f + const Offset(.026, .0), f + const Offset(0, .022))
      ..qd(f + const Offset(-.026, .0), f + const Offset(0, -.042))
      ..close();
    cv.drawPath(flame, _lin(f + const Offset(0, -.04), f + const Offset(0, .02), const [Color(0xFFFFF59D), Color(0xFFFFB300), Color(0xFFFF6F00)]));
  }
}

// ===========================================================================
// Sushi

void _rice(Canvas cv, Path clip, int n, int seed, {double outline = .45}) {
  final b = clip.getBounds();
  final rnd = math.Random(seed);
  cv.save();
  cv.clipPath(clip);
  for (var i = 0; i < n; i++) {
    final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
    cv.save();
    cv.translate(o.dx, o.dy);
    cv.rotate(rnd.nextDouble() * math.pi);
    final g = _ov(Offset.zero, .016, .008);
    cv.drawOval(g, _fill(_white));
    cv.drawOval(g, _line(_al(const Color(0xFF9E9E9E), outline), .003));
    cv.restore();
  }
  cv.restore();
}

void _maki(_Art a, {required Color filling}) {
  final cv = a.cv;
  const nori = Color(0xFF263238);
  const r = .15, h = .16;
  final side = _cylSil(a, r, 0, r, h);
  cv.drawPath(side, _sideShade(side.getBounds(), const Color(0xFF37474F), hi: .25, lo: .45));
  cv.drawPath(side, _line(_dk(nori, .4), _rw));
  a.plan(h, () {
    cv.drawCircle(Offset.zero, r, _fill(const Color(0xFF37474F)));
    final rice = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r - .016));
    cv.drawPath(rice, _rad(const Offset(-.04, -.04), .16, const [Color(0xFFFFFFFF), Color(0xFFF2F2F2), Color(0xFFDADADA)]));
    _rice(cv, rice, 40, 2);
    final fill = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: .06));
    cv.drawPath(fill, _gloss(fill.getBounds(), filling, hi: .35, lo: .25));
    if (filling.g > filling.r) {
      cv.drawCircle(Offset.zero, .03, _fill(_lt(filling, .55)));
      for (var i = 0; i < 5; i++) {
        final ang = 2 * math.pi * i / 5;
        cv.drawCircle(Offset(math.cos(ang), math.sin(ang)) * .018, .005, _fill(_dk(filling, .3)));
      }
      cv.drawCircle(Offset.zero, .06, _line(const Color(0xFF2E7D32), .012));
    } else {
      for (var i = -1; i <= 1; i++) {
        cv.drawLine(Offset(-.05, i * .025 - .01), Offset(.05, i * .025 + .015), _line(_al(_white, .55), .007));
      }
      cv.drawCircle(Offset.zero, .06, _line(_dk(filling, .3), .006));
    }
  });
  _spec(cv, a.p(-.1, -.15, .1), .012, .035, rot: 0, a: .25);
}

void _nigiri(_Art a, {required bool tamago}) {
  final cv = a.cv;
  const riceC = Color(0xFFF5F5F5);
  // Rice bed.
  const zr = .1;
  final ricePts = _rrectPts(.19, .085, .075);
  final riceTop = _slab(a, ricePts, 0, zr, riceC, hi: .3, lo: .22, rimColor: const Color(0xFFBDBDBD));
  final riceSil = _sil(a.proj(ricePts, zr), zr * _hs);
  _rice(cv, Path.combine(PathOperation.union, riceSil, riceTop), 46, 3, outline: .35);
  // Topping.
  final topC = tamago ? const Color(0xFFFFCA28) : a.c;
  final topPts = _rrectPts(.235, .092, .06);
  final tp = _slab(a, topPts, .088, .14, _dk(topC, .1), hi: .25, lo: .3);
  cv.drawPath(tp, _gloss(tp.getBounds(), topC, hi: .35, lo: .15));
  cv.save();
  cv.clipPath(tp);
  if (tamago) {
    final tb = tp.getBounds();
    for (var i = 1; i < 3; i++) {
      final y = tb.top + tb.height * i / 3;
      cv.drawLine(Offset(tb.left, y), Offset(tb.right, y), _line(_al(_lt(topC, .6), .5), .008));
    }
  } else {
    a.plan(.14, () {
      for (var i = -4; i <= 4; i++) {
        final x = i * .065;
        final s = Path()
          ..moveTo(x - .06, .12)
          ..quadraticBezierTo(x + .01, 0, x + .06, -.12);
        cv.drawPath(s, _line(_al(const Color(0xFFFFE0D0), .85), .016));
      }
    });
  }
  cv.restore();
  if (tamago) {
    // Nori belt.
    final belt = Path()
      ..mv(a.p(-.04, .092, .145))
      ..ln(a.p(.04, .092, .145))
      ..ln(a.p(.04, -.092, .145))
      ..ln(a.p(.04, -.088, 0))
      ..ln(a.p(-.04, -.088, 0))
      ..ln(a.p(-.04, -.092, .145))
      ..close();
    cv.drawPath(belt, _lin(a.p(-.04, 0, 0), a.p(.04, 0, 0), const [Color(0xFF37474F), Color(0xFF263238), Color(0xFF1B252B)]));
    cv.drawLine(a.p(-.04, -.092, .145), a.p(.04, -.092, .145), _line(_al(_white, .25), .006));
  }
  cv.drawPath(tp, _line(_dk(topC, .3), _rw * .8));
  _spec(cv, a.p(-.08, .04, .14), .08, .015, rot: 0, a: .6);
}

void _shrimp(_Art a) {
  final cv = a.cv, c = a.c;
  const p0 = Offset(-.17, .02), p1 = Offset(.05, -.08), p2 = Offset(.28, .02);
  Offset at(double t) => p0 * ((1 - t) * (1 - t)) + p1 * (2 * (1 - t) * t) + p2 * (t * t);
  Offset tan(double t) => (p1 - p0) * (2 * (1 - t)) + (p2 - p1) * (2 * t);
  Offset nrm(double t) {
    final d = tan(t);
    return Offset(d.dy, -d.dx) / d.distance;
  }

  double w(double t) => t > .88 ? .08 * math.sqrt(math.max(0, 1 - math.pow((t - .88) / .12, 2))) : .034 + .046 * math.pow(t / .88, .6);
  // Tail fan.
  const tail = Color(0xFFE64A19);
  final tb = at(0);
  _leaf(cv, tb, tb + const Offset(-.12, -.07), .035, tail, vein: false);
  _leaf(cv, tb, tb + const Offset(-.12, .06), .035, tail, vein: false);
  _leaf(cv, tb, tb + const Offset(-.13, -.005), .03, _lt(tail, .15), vein: false);
  final up = <Offset>[], dn = <Offset>[];
  const n = 48;
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    up.add(at(t) + nrm(t) * w(t));
    dn.add(at(t) - nrm(t) * w(t));
  }
  final body = _poly([...up, ...dn.reversed]);
  cv.drawPath(body, _gloss(body.getBounds(), const Color(0xFFFFE0D6), hi: .4, lo: .15));
  cv.save();
  cv.clipPath(body);
  for (var i = 0; i < 6; i++) {
    final t0 = .04 + i * .145, t1 = t0 + .085;
    final band = <Offset>[];
    for (var j = 0; j <= 8; j++) {
      final t = t0 + (t1 - t0) * j / 8;
      band.add(at(t) + nrm(t) * (w(t) + .02) + tan(t) / tan(t).distance * (.012));
    }
    for (var j = 8; j >= 0; j--) {
      final t = t0 + (t1 - t0) * j / 8;
      band.add(at(t) - nrm(t) * (w(t) + .02) - tan(t) / tan(t).distance * .012);
    }
    final bp = _poly(band);
    cv.drawPath(bp, _gloss(bp.getBounds(), c, hi: .3, lo: .2));
  }
  cv.restore();
  _shadeOver(cv, body, light: .2, dark: .2, ly: .1);
  cv.drawPath(body, _line(_dk(c, .4), _rw));
  _spec(cv, at(.55) + nrm(.55) * .035, .09, .012, rot: -.05, a: .65);
}

void _wasabi(_Art a) {
  final cv = a.cv, c = a.c;
  final base = _lt(c, .2);
  const lumps = [
    // x, y, r — back to front
    [-.06, -.1, .085], [.07, -.095, .08],
    [-.13, -.02, .08], [.0, -.04, .095], [.13, -.01, .08],
    [-.09, .06, .09], [.07, .065, .09],
  ];
  var sil = Path();
  for (final l in lumps) {
    sil = Path.combine(PathOperation.union, sil, Path()..addOval(Rect.fromCircle(center: Offset(l[0], l[1]), radius: l[2])));
  }
  cv.drawPath(sil, _gloss(sil.getBounds(), base, hi: .3, lo: .3));
  cv.save();
  cv.clipPath(sil);
  for (final l in lumps) {
    final o = Offset(l[0], l[1]);
    final r = l[2];
    cv.drawPath(
      Path()..addArc(Rect.fromCircle(center: o, radius: r * .95), .6, 1.9),
      _line(_al(_dk(c, .3), .3), .012),
    );
    cv.drawCircle(o + Offset(-r * .3, -r * .35), r * .55, _rad(o + Offset(-r * .3, -r * .35), r * .55, [_al(_white, .4), _al(_white, 0)]));
  }
  cv.restore();
  _speckle(cv, sil, _al(_dk(c, .3), .3), 80, seed: 4, size: .0045);
  _speckle(cv, sil, _al(_lt(c, .7), .45), 40, seed: 5, size: .004);
  cv.drawPath(sil, _line(_dk(c, .4), _rw));
}

void _onigiri(_Art a) {
  final cv = a.cv;
  const rice = Color(0xFFFAFAFA);
  Path tri(Offset o, double s) {
    const top = Offset(0, -.24), l = Offset(-.29, .19), r = Offset(.29, .19);
    Offset q(Offset p) => o + p * s;
    return Path()
      ..mv(q(Offset.lerp(top, l, .2)!))
      ..qd(q(top), q(Offset.lerp(top, r, .2)!))
      ..ln(q(Offset.lerp(top, r, .85)!))
      ..qd(q(r), q(Offset.lerp(r, l, .15)!))
      ..ln(q(Offset.lerp(r, l, .85)!))
      ..qd(q(l), q(Offset.lerp(l, top, .15)!))
      ..close();
  }

  const shift = Offset(0, -.075);
  final front = tri(const Offset(0, .045), 1);
  final back = tri(const Offset(0, .045) + shift, .96);
  final sil = Path.combine(PathOperation.union, back, front);
  // The thickness band between the back and front faces.
  final bands = <Path>[];
  for (var i = 1; i < 6; i++) {
    bands.add(tri(const Offset(0, .045) + shift * (i / 6), 1 - .04 * i / 6));
  }
  cv.drawPath(sil, _fill(const Color(0xFFE0E0E0)));
  for (final b in bands) {
    cv.drawPath(b, _fill(const Color(0xFFE8E8E8)));
  }
  cv.drawPath(back, _fill(const Color(0xFFEEEEEE)));
  cv.drawPath(front, _gloss(front.getBounds(), rice, hi: .5, lo: .14));
  _rice(cv, front, 45, 5, outline: .22);
  _rice(cv, back, 20, 6, outline: .22);
  cv.drawPath(sil, _line(const Color(0xFFBDBDBD), _rw));
  // Nori.
  final fb = front.getBounds();
  final nori = RRect.fromLTRBAndCorners(-.1, fb.bottom - .16, .1, fb.bottom + .004,
      topLeft: const Radius.circular(.02), topRight: const Radius.circular(.02), bottomLeft: const Radius.circular(.015), bottomRight: const Radius.circular(.015));
  cv.save();
  cv.clipPath(sil);
  cv.drawRRect(nori, _lin(Offset(nori.left, 0), Offset(nori.right, 0), const [Color(0xFF37474F), Color(0xFF263238), Color(0xFF1A2327)]));
  cv.drawLine(Offset(nori.left + .03, nori.top + .02), Offset(nori.left + .03, nori.bottom - .02), _line(_al(_white, .15), .01));
  cv.restore();
  _spec(cv, Offset(-.08, fb.top + .1), .05, .025, rot: -.9, a: .5);
}

void _soyDish(_Art a) {
  final cv = a.cv;
  const dish = Color(0xFFF5F5F5);
  const r = .4, h = .08;
  _slab(a, _circ(r), 0, h, const Color(0xFFE8E8EE), hi: .3, lo: .3, rimColor: const Color(0xFFB0BEC5));
  final rim = a.disk(r, h);
  cv.drawOval(rim, _fill(dish));
  cv.drawOval(a.disk(r - .015, h), _line(_al(const Color(0xFF64B5F6), .7), .01));
  final well = a.disk(r - .06, h);
  cv.drawOval(well, _rad(well.center + const Offset(0, -.05), .4, const [Color(0xFFCFD8DC), Color(0xFFE0E0E0)]));
  cv.save();
  cv.clipPath(Path()..addOval(well));
  final soy = a.disk(r - .065, h - .03);
  cv.drawOval(soy, _rad(soy.center + const Offset(-.08, -.05), .35, const [Color(0xFF6D4C41), Color(0xFF3E2723), Color(0xFF2B1B17)], const [0, .5, 1]));
  cv.restore();
  cv.drawOval(well, _line(_al(const Color(0xFF90A4AE), .6), .008));
  _spec(cv, a.p(-.12, .06, h - .03), .1, .02, rot: -.35, a: .5);
  cv.drawOval(rim, _line(const Color(0xFFB0BEC5), _rw));
  // Chopsticks resting across.
  const wood = Color(0xFFD7B98E);
  for (final dy in const [-.035, .035]) {
    final s0 = a.p(-.44, -.12 + dy, h + .02), s1 = a.p(.44, .18 + dy, h + .02);
    cv.drawLine(s0 + const Offset(0, .02), s1 + const Offset(0, .02), _line(_al(_black, .15), .03));
    final stick = Path()
      ..mv(s0 + const Offset(0, -.013))
      ..ln(s1 + const Offset(0, -.008))
      ..ln(s1 + const Offset(0, .008))
      ..ln(s0 + const Offset(0, .013))
      ..close();
    cv.drawPath(stick, _lin(s0 + const Offset(0, -.013), s0 + const Offset(0, .013), [_lt(wood, .35), wood, _dk(wood, .2)]));
    cv.drawPath(stick, _line(_dk(wood, .35), _rw * .7));
  }
}

// ===========================================================================
// Toys

void _car(_Art a) {
  final cv = a.cv, c = a.c;
  void wheel(double x, double y) {
    final o = a.p(x, y, .07);
    cv.drawOval(_ov(o, .07, .058), _fill(const Color(0xFF212121)));
    cv.drawOval(_ov(o + const Offset(-.004, .002), .052, .043), _fill(const Color(0xFF37474F)));
    cv.drawOval(_ov(o + const Offset(-.004, .002), .031, .026), _fill(const Color(0xFFECEFF1)));
    cv.drawOval(_ov(o + const Offset(-.004, .002), .012, .01), _fill(const Color(0xFF90A4AE)));
  }

  wheel(-.18, .13);
  wheel(.18, .13);
  // Lower body.
  const zb = .19;
  final bodyPts = _rrectPts(.3, .15, .075);
  final top = _slab(a, bodyPts, .045, zb, c, hi: .3, lo: .45);
  cv.drawPath(top, _gloss(top.getBounds(), _lt(c, .06), hi: .4, lo: .06));
  cv.drawPath(top, _line(_al(_lt(c, .6), .7), .008));
  // Racing stripes on hood and trunk.
  for (final y in const [-.03, .03]) {
    cv.drawLine(a.p(.15, y, zb), a.p(.285, y, zb), _line(_al(_white, .85), .02));
    cv.drawLine(a.p(-.29, y, zb), a.p(-.21, y, zb), _line(_al(_white, .85), .02));
  }
  // Side trim line.
  final trim = Path()
    ..mv(a.p(-.24, -.15, .12))
    ..ln(a.p(.24, -.15, .12));
  cv.drawPath(trim, _line(_al(_dk(c, .35), .6), .01));
  wheel(-.18, -.15);
  wheel(.18, -.15);
  // Lights.
  for (final y in const [-.09, .09]) {
    final hl = _ov(a.p(.275, y, zb), .022, .02);
    cv.drawOval(hl, _fill(const Color(0xFFFFF9C4)));
    cv.drawOval(hl, _line(_dk(c, .35), .006));
    cv.drawOval(_ov(a.p(-.285, y, zb), .02, .016), _fill(const Color(0xFFFF5252)));
  }
  // Cabin: glass hull with the roof on top.
  const z0 = zb, z1 = .3;
  final lowPts = a.proj(_rrectPts(.14, .13, .05, cx: -.04), z0);
  final roofPlan = _rrectPts(.088, .1, .04, cx: -.07);
  final roofPts = a.proj(roofPlan, z1);
  final cabin = _poly(_hull([...lowPts, ...roofPts]));
  final cb = cabin.getBounds();
  cv.drawPath(
    cabin,
    _lin(Offset(0, cb.top), Offset(0, cb.bottom), const [Color(0xFFE1F5FE), Color(0xFF81D4FA), Color(0xFF0288D1)],
        const [0, .45, 1]),
  );
  final pillar = _line(_dk(c, .08), .018);
  for (final y in const [-1.0, 1.0]) {
    cv.drawLine(a.p(.018, y * .1, z1), a.p(.1, y * .13, z0), pillar);
    cv.drawLine(a.p(-.158, y * .1, z1), a.p(-.18, y * .13, z0), pillar);
  }
  cv.drawLine(a.p(-.065, -.1, z1), a.p(-.045, -.13, z0), pillar);
  cv.drawPath(cabin, _line(_dk(c, .4), _rw));
  final roof = _poly(roofPts);
  cv.drawPath(roof, _gloss(roof.getBounds(), _lt(c, .05), hi: .5, lo: .1));
  cv.drawPath(roof, _line(_dk(c, .35), _rw * .8));
  // Glass glints.
  cv.drawLine(a.p(.06, .05, z1 - .02), a.p(.09, -.03, z0 + .02), _line(_al(_white, .75), .014));
  cv.drawLine(a.p(-.02, -.128, z1 - .02), a.p(.005, -.132, z0 + .02), _line(_al(_white, .6), .01));
  _spec(cv, a.p(-.1, .03, z1), .05, .014, rot: 0, a: .65);
}

void _duck(_Art a) {
  final cv = a.cv, c = a.c;
  final rim = _dk(_mix(c, const Color(0xFFFF9800), .5), .25);
  final body = Path()
    ..moveTo(-.18, .03)
    ..cubicTo(-.22, .2, .14, .23, .2, .09)
    ..quadraticBezierTo(.235, .0, .245, -.075)
    ..quadraticBezierTo(.18, -.03, .12, -.03)
    ..cubicTo(.05, -.035, -.15, -.07, -.18, .03)
    ..close();
  _body(cv, body, c, hi: .55, lo: .25, rimColor: rim);
  final wing = Path()
    ..moveTo(-.02, .04)
    ..cubicTo(.03, -.01, .14, .0, .16, .04)
    ..quadraticBezierTo(.12, .12, .02, .1)
    ..quadraticBezierTo(-.03, .08, -.02, .04)
    ..close();
  cv.drawPath(wing, _gloss(wing.getBounds(), _dk(_mix(c, const Color(0xFFFFB300), .4), .02), hi: .2, lo: .15));
  cv.drawPath(wing, _line(_al(rim, .7), _rw * .8));
  const hc = Offset(-.07, -.1);
  final head = Path()..addOval(Rect.fromCircle(center: hc, radius: .115));
  _body(cv, head, c, hi: .55, lo: .22, rimColor: rim);
  _spec(cv, hc + const Offset(-.03, -.05), .04, .022, rot: -.6, a: .8);
  _spec(cv, const Offset(-.06, .07), .05, .02, rot: -.3, a: .5);
  // Beak.
  const orange = Color(0xFFFF9800);
  final beak = Path()
    ..moveTo(-.145, -.115)
    ..quadraticBezierTo(-.24, -.13, -.255, -.08)
    ..quadraticBezierTo(-.2, -.045, -.135, -.06)
    ..close();
  cv.drawPath(beak, _gloss(beak.getBounds(), orange, hi: .4, lo: .2));
  cv.drawLine(const Offset(-.25, -.083), const Offset(-.15, -.085), _line(_dk(orange, .35), .008));
  cv.drawPath(beak, _line(_dk(orange, .35), _rw * .8));
  cv.drawOval(_ov(const Offset(-.07, -.05), .028, .016), _fill(_al(const Color(0xFFFF8A80), .45)));
  // Eye.
  cv.drawCircle(const Offset(-.09, -.135), .022, _fill(const Color(0xFF212121)));
  cv.drawCircle(const Offset(-.097, -.142), .008, _fill(_white));
}

void _ball(_Art a) {
  final cv = a.cv;
  const r = .215;
  final g = _Globe.tilted(Offset.zero, r, const _V3(-.3, .62, .72));
  final out = g.outline;
  final colors = [
    const Color(0xFFE53935), _white, const Color(0xFFFDD835), _white, a.c, _white,
  ];
  const phase = .33;
  cv.save();
  cv.clipPath(out);
  cv.drawPath(out, _fill(_white));
  for (var i = 0; i < 6; i++) {
    final ph0 = 2 * math.pi * i / 6 + phase, ph1 = 2 * math.pi * (i + 1) / 6 + phase;
    cv.drawPath(g.band((t) => ph0, (t) => ph1, n: 60), _fill(colors[i]));
  }
  // Pole cap.
  final cap = <Offset>[for (var i = 0; i < 36; i++) g.at(.22, 2 * math.pi * i / 36)];
  cv.drawPath(_poly(cap), _fill(_white));
  cv.drawPath(_poly(cap), _line(_al(const Color(0xFFB0BEC5), .8), .006));
  cv.restore();
  _shadeOver(cv, out, light: .3, dark: .35);
  cv.drawPath(out, _line(const Color(0xFF546E7A), _rw));
  _spec(cv, const Offset(-.09, -.1), .06, .035, rot: -.8);
}

void _block(_Art a, int emblem) {
  final cv = a.cv, c = a.c;
  const s = .15, h = .3;
  const wood = Color(0xFFF2D49B);
  final yb = a.p(0, s, h).dy, yf = a.p(0, -s, h).dy, y0 = a.p(0, -s, 0).dy;
  final topR = Rect.fromLTRB(-s, yb, s, yf), frontR = Rect.fromLTRB(-s, yf, s, y0);
  final whole = RRect.fromLTRBR(-s, yb, s, y0, const Radius.circular(.028));
  cv.save();
  cv.clipRRect(whole);
  cv.drawRect(topR, _lin(topR.topLeft, topR.bottomRight, [_lt(wood, .55), _lt(wood, .3)]));
  cv.drawRect(frontR, _lin(frontR.topCenter, frontR.bottomCenter, [wood, _dk(wood, .14)]));
  cv.drawRect(frontR, _lin(frontR.centerLeft, frontR.centerRight, [_al(_black, 0), _al(_black, 0), _al(_black, .12)], const [0, .7, 1]));
  cv.restore();
  // Coloured inset panels.
  const ins = .028;
  final tp = RRect.fromLTRBR(-s + ins, yb + ins * _g, s - ins, yf - ins * _g, const Radius.circular(.016));
  final fp = RRect.fromLTRBR(-s + ins, yf + ins * _hs, s - ins, y0 - ins * _hs, const Radius.circular(.016));
  cv.drawRRect(tp, _lin(tp.outerRect.topLeft, tp.outerRect.bottomRight, [_lt(c, .3), _lt(c, .05)]));
  cv.drawRRect(fp, _lin(fp.outerRect.topCenter, fp.outerRect.bottomCenter, [c, _dk(c, .12)]));
  for (final p in [tp, fp]) {
    cv.drawRRect(p, _line(_dk(c, .3), .008));
  }
  // Inner shadow at the top of each panel.
  cv.drawLine(Offset(fp.left + .01, fp.top + .006), Offset(fp.right - .01, fp.top + .006), _line(_al(_dk(c, .5), .35), .008));
  // Emblems.
  Path emblemAt(Offset pc, double k) => switch (emblem) {
    0 => _star(pc, .058 * k, .025 * k, 5),
    1 => Path()..addOval(_ov(pc, .045 * k, .045 * k)),
    2 => _poly([pc + Offset(0, -.05 * k), pc + Offset(.055 * k, .04 * k), pc + Offset(-.055 * k, .04 * k)]),
    _ => _heart(pc + Offset(0, .005 * k), .05 * k),
  };
  final fe = emblemAt(fp.center, .95);
  cv.drawPath(fe.shift(const Offset(.004, .005)), _fill(_al(_dk(c, .5), .5)));
  cv.drawPath(fe, _fill(_lt(c, .85)));
  cv.save();
  cv.translate(tp.center.dx, tp.center.dy);
  cv.scale(1, _g);
  final te = emblemAt(Offset.zero, .85);
  cv.drawPath(te, _fill(_lt(c, .85)));
  cv.drawPath(te, _line(_al(_dk(c, .3), .6), .006));
  cv.restore();
  // Edge highlight between the faces and the outline.
  cv.drawLine(Offset(-s + .015, yf), Offset(s - .015, yf), _line(_al(_white, .8), .01));
  cv.drawRRect(whole, _line(_dk(wood, .5), _rw));
}

void _teddy(_Art a) {
  final cv = a.cv, c = a.c;
  final light = _lt(_mix(c, const Color(0xFFFFCC80), .4), .25);
  final rim = _dk(c, .4);
  void blob(Rect r, Color col, {double rot = 0}) {
    cv.save();
    cv.translate(r.center.dx, r.center.dy);
    cv.rotate(rot);
    final p = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: r.width, height: r.height));
    _body(cv, p, col, hi: .35, lo: .3, rimColor: rim);
    cv.restore();
  }

  // Arms behind the body edges.
  blob(_ov(const Offset(-.19, .1), .06, .1), c, rot: .5);
  blob(_ov(const Offset(.19, .1), .06, .1), c, rot: -.5);
  blob(_ov(const Offset(0, .14), .175, .18), c);
  cv.drawOval(_ov(const Offset(0, .16), .1, .11), _fill(_al(light, .9)));
  // Legs.
  for (final s in [-1.0, 1.0]) {
    blob(_ov(Offset(s * .12, .27), .085, .07), c);
    cv.drawOval(_ov(Offset(s * .125, .275), .048, .042), _fill(light));
  }
  // Head.
  for (final s in [-1.0, 1.0]) {
    blob(_ov(Offset(s * .135, -.26), .065, .065), c);
    cv.drawCircle(Offset(s * .135, -.255), .035, _fill(light));
  }
  blob(_ov(const Offset(0, -.13), .175, .155), c);
  cv.drawOval(_ov(const Offset(0, -.075), .078, .058), _gloss(_ov(const Offset(0, -.075), .078, .058), light, hi: .4, lo: .1));
  cv.drawOval(_ov(const Offset(0, -.095), .032, .022), _fill(const Color(0xFF3E2723)));
  cv.drawOval(_ov(const Offset(-.01, -.1), .01, .006), _fill(_al(_white, .7)));
  cv.drawPath(
    Path()
      ..moveTo(-.025, -.055)
      ..quadraticBezierTo(0, -.04, .025, -.055),
    _line(const Color(0xFF3E2723), .008),
  );
  cv.drawLine(const Offset(0, -.073), const Offset(0, -.052), _line(const Color(0xFF3E2723), .008));
  for (final s in [-1.0, 1.0]) {
    cv.drawCircle(Offset(s * .065, -.15), .022, _fill(const Color(0xFF212121)));
    cv.drawCircle(Offset(s * .065 - .007, -.157), .008, _fill(_white));
  }
  // Bow tie.
  const red = Color(0xFFE53935);
  for (final s in [-1.0, 1.0]) {
    final w = Path()
      ..moveTo(0, .02)
      ..lineTo(s * .075, -.015)
      ..quadraticBezierTo(s * .09, .02, s * .075, .055)
      ..close();
    cv.drawPath(w, _gloss(w.getBounds(), red, hi: .35, lo: .25));
    cv.drawPath(w, _line(_dk(red, .35), _rw * .8));
  }
  cv.drawCircle(const Offset(0, .02), .02, _fill(_dk(red, .1)));
  _spec(cv, const Offset(-.08, -.2), .04, .02, rot: -.5, a: .35);
}
