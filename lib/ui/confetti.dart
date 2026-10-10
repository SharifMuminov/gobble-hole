import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A one-shot burst of confetti falling from the top of the screen.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
    ..forward();
  final _pieces = List.generate(140, (i) => _Piece(math.Random(i * 31 + 7)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_pieces, _c),
      ),
    );
  }
}

class _Piece {
  _Piece(math.Random r)
    : x = r.nextDouble(),
      delay = r.nextDouble() * 0.35,
      speed = 0.55 + r.nextDouble() * 0.6,
      drift = (r.nextDouble() - 0.5) * 0.3,
      spin = (r.nextDouble() - 0.5) * 18,
      size = 7 + r.nextDouble() * 7,
      color = _colors[r.nextInt(_colors.length)];

  final double x, delay, speed, drift, spin, size;
  final Color color;

  static const _colors = [
    Color(0xFFFF5C8A),
    Color(0xFFFFC928),
    Color(0xFF4CD964),
    Color(0xFF3DA5F5),
    Color(0xFFB57BFF),
    Color(0xFFFF8A3D),
  ];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.anim) : super(repaint: anim);

  final List<_Piece> pieces;
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 3.2;
    final paint = Paint();
    for (final p in pieces) {
      final life = t - p.delay;
      if (life <= 0) continue;
      final y = -0.05 + life * p.speed * 0.55;
      if (y > 1.1) continue;
      final x = p.x + p.drift * life + math.sin(life * 3 + p.x * 9) * 0.03;
      final fade = (1.6 - life * 0.45).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(life * p.spin);
      canvas.scale(1, math.cos(life * p.spin * 0.7).abs() * 0.8 + 0.2);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
