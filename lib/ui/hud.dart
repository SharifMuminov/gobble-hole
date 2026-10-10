import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../game/engine/world.dart';
import 'widgets.dart';

/// Clock pill at the top; red and pulsing for the last ten seconds.
class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    final text = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return TweenAnimationBuilder<double>(
      key: ValueKey(urgent ? seconds : -1),
      tween: Tween(begin: urgent ? 1.18 : 1, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        height: 44,
        padding: const EdgeInsets.only(left: 8, right: 16),
        decoration: BoxDecoration(
          color: urgent ? AppColors.danger : const Color(0xCC2B2340),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 4),
            OutlinedText(text, size: 22, stroke: 4),
          ],
        ),
      ),
    );
  }
}

/// One mission: the item, how many are left, and a tick when done.
class GoalChip extends StatefulWidget {
  const GoalChip({super.key, required this.goal, required this.left});

  final GoalProgress goal;

  /// Passed separately so the chip notices when it changes.
  final int left;

  @override
  State<GoalChip> createState() => _GoalChipState();
}

class _GoalChipState extends State<GoalChip> with SingleTickerProviderStateMixin {
  late final _bump = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void didUpdateWidget(GoalChip old) {
    super.didUpdateWidget(old);
    if (old.left != widget.left) _bump.forward(from: 0);
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.goal.done;
    return AnimatedBuilder(
      animation: _bump,
      builder: (context, child) {
        final t = _bump.value;
        final s = 1 + 0.22 * (t < 0.4 ? t / 0.4 : (1 - t) / 0.6);
        return Transform.scale(scale: s, child: child);
      },
      child: Container(
        width: 74,
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFDDF8E3) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: done ? AppColors.greenDark : AppColors.ink, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(top: 4, child: ItemIcon(widget.goal.kind, size: 46)),
            Positioned(
              bottom: 2,
              child: done
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 28)
                  : OutlinedText('${widget.left}', size: 22, stroke: 5),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round icon button for the top bar.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, this.color = AppColors.blue, this.shade = AppColors.blueDark});

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color shade;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: color,
      shade: shade,
      radius: 16,
      depth: 5,
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

/// A booster button: icon, label and coin price.
class BoosterButton extends StatelessWidget {
  const BoosterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.price,
    required this.onTap,
    required this.color,
    required this.shade,
  });

  final IconData icon;
  final String label;
  final int price;
  final VoidCallback? onTap;
  final Color color;
  final Color shade;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: color,
      shade: shade,
      radius: 20,
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedText(label, size: 17, stroke: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 16),
                  const SizedBox(width: 3),
                  OutlinedText('$price', size: 14, stroke: 3),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
