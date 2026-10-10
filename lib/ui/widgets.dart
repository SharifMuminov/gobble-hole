import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../game/audio/sfx.dart';
import '../game/model/item_kind.dart';
import '../game/render/item_art.dart';

/// Chunky casual-game text: white fill with a dark outline.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.outline = AppColors.ink,
    this.stroke,
    this.align = TextAlign.center,
  });

  final String text;
  final double size;
  final Color color;
  final Color outline;
  final double? stroke;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1.05,
      letterSpacing: 0.5,
    );
    return Stack(
      children: [
        Text(
          text,
          textAlign: align,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke ?? size * 0.2
              ..strokeJoin = StrokeJoin.round
              ..color = outline,
            shadows: [Shadow(color: outline, offset: Offset(0, size * 0.08))],
          ),
        ),
        Text(text, textAlign: align, style: style.copyWith(color: color)),
      ],
    );
  }
}

/// A rounded button with a darker base that squashes when pressed.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = AppColors.green,
    this.shade = AppColors.greenDark,
    this.radius = 22,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.depth = 6,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color shade;
  final double radius;
  final EdgeInsets padding;
  final double depth;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  var _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = enabled ? widget.color : AppColors.grey;
    final shade = enabled ? widget.shade : AppColors.greyDark;
    final press = _down ? widget.depth - 1 : 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: enabled
          ? (_) {
              setState(() => _down = false);
              Sfx.click();
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: Padding(
        padding: EdgeInsets.only(top: press),
        child: Container(
          decoration: BoxDecoration(
            color: shade,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          padding: EdgeInsets.only(bottom: widget.depth - press),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(color, Colors.white, 0.18)!, color],
              ),
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              child: Center(widthFactor: 1, heightFactor: 1, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// A white rounded card for dialogs.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 24)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.ink, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

/// A gold coin drawn in code.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFFF1A8), AppColors.coin, Color(0xFFE09A00)],
          stops: [0, 0.55, 1],
        ),
        border: Border.all(color: const Color(0xFFB87400), width: size * 0.08),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.42,
        height: size * 0.42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xAAB87400), width: size * 0.07),
        ),
      ),
    );
  }
}

/// Dark pill with an icon and a value, for the top bars.
class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.icon, required this.label, this.trailing});

  final Widget icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 4, right: 12),
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          OutlinedText(label, size: 18, stroke: 4),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}

class CoinPill extends StatelessWidget {
  const CoinPill({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) =>
      StatPill(icon: const CoinIcon(size: 30), label: '$coins');
}

/// An item sprite as a widget (vector, crisp at any size).
class ItemIcon extends StatelessWidget {
  const ItemIcon(this.kind, {super.key, this.size = 40});

  final ItemKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: Size.square(size), painter: _ItemIconPainter(kind)),
    );
  }
}

class _ItemIconPainter extends CustomPainter {
  _ItemIconPainter(this.kind);

  final ItemKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    // Small items fill the square; big ones are scaled to fit too.
    final r = Offset.zero & size;
    paintItem(canvas, kind, r.inflate(size.width * 0.12));
  }

  @override
  bool shouldRepaint(_ItemIconPainter old) => old.kind != kind;
}

/// A heart drawn with a path.
class HeartIcon extends StatelessWidget {
  const HeartIcon({super.key, this.size = 30, this.color = AppColors.danger});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _HeartPainter(color));
}

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.9)
      ..cubicTo(w * 0.05, h * 0.62, w * 0.0, h * 0.3, w * 0.22, h * 0.15)
      ..cubicTo(w * 0.36, h * 0.06, w * 0.48, h * 0.16, w * 0.5, h * 0.28)
      ..cubicTo(w * 0.52, h * 0.16, w * 0.64, h * 0.06, w * 0.78, h * 0.15)
      ..cubicTo(w * 1.0, h * 0.3, w * 0.95, h * 0.62, w * 0.5, h * 0.9)
      ..close();
    canvas.drawPath(path.shift(Offset(0, h * 0.04)), Paint()..color = const Color(0x55000000));
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.3)!, color],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..color = Color.lerp(color, Colors.black, 0.35)!,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.18, h * 0.12),
      Paint()..color = const Color(0x99FFFFFF),
    );
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.color != color;
}

/// Five-point star for level ratings.
class StarIcon extends StatelessWidget {
  const StarIcon({super.key, this.size = 40, this.filled = true});

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _StarPainter(filled));
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.filled);

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2, inner = outer * 0.48;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(r * math.cos(a), r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: filled
              ? const [Color(0xFFFFF176), Color(0xFFFFB300)]
              : const [Color(0xFFDAD6E8), Color(0xFFB9B3CF)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.width * 0.07
        ..color = filled ? const Color(0xFFC77700) : const Color(0xFF8A85A3),
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.filled != filled;
}
