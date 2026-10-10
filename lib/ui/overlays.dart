import 'package:flutter/material.dart';

import '../app/profile.dart';
import '../app/theme.dart';
import '../game/engine/world.dart';
import 'widgets.dart';

/// Dims the game and pops a panel in.
class OverlayFrame extends StatelessWidget {
  const OverlayFrame({super.key, required this.child, this.dim = 0x99});

  final Widget child;
  final int dim;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Color(dim << 24),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.elasticOut,
            builder: (context, s, child) => Transform.scale(scale: s, child: child),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PausePanel extends StatelessWidget {
  const PausePanel({
    super.key,
    required this.profile,
    required this.onResume,
    required this.onQuit,
    required this.quitCostsLife,
  });

  final PlayerProfile profile;
  final VoidCallback onResume;
  final VoidCallback onQuit;
  final bool quitCostsLife;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) => Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OutlinedText('PAUSED', size: 34, color: AppColors.orange),
            const SizedBox(height: 18),
            SettingToggle(
              icon: profile.sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              label: 'Sound',
              value: profile.sound,
              onChanged: profile.setSound,
            ),
            SettingToggle(
              icon: Icons.vibration_rounded,
              label: 'Vibration',
              value: profile.haptics,
              onChanged: profile.setHaptics,
            ),
            const SizedBox(height: 18),
            ChunkyButton(
              onTap: onResume,
              child: const OutlinedText('RESUME', size: 26, outline: AppColors.greenDark),
            ),
            const SizedBox(height: 12),
            ChunkyButton(
              onTap: onQuit,
              color: AppColors.pink,
              shade: AppColors.pinkDark,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OutlinedText('QUIT', size: 20, outline: AppColors.pinkDark),
                  if (quitCostsLife) ...[
                    const SizedBox(width: 8),
                    const OutlinedText('-1', size: 18, outline: AppColors.pinkDark),
                    const HeartIcon(size: 22),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingToggle extends StatelessWidget {
  const SettingToggle({super.key, required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ink, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.green),
        ],
      ),
    );
  }
}

class WinPanel extends StatelessWidget {
  const WinPanel({
    super.key,
    required this.level,
    required this.stars,
    required this.coins,
    required this.onNext,
    required this.onHome,
  });

  final int level;
  final int stars;
  final int coins;
  final VoidCallback onNext;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedText('LEVEL $level', size: 22, color: AppColors.blue),
          const SizedBox(height: 4),
          const OutlinedText('COMPLETE!', size: 40, color: AppColors.green),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == 1 ? 14 : 0, left: 4, right: 4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500 + i * 250),
                    curve: Interval(0.4 + i * 0.1, 1, curve: Curves.elasticOut),
                    builder: (context, s, child) => Transform.scale(scale: s, child: child),
                    child: StarIcon(size: i == 1 ? 72 : 58, filled: i < stars),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(color: AppColors.panelSoft, borderRadius: BorderRadius.circular(18)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 34),
                const SizedBox(width: 8),
                OutlinedText('+$coins', size: 30, color: AppColors.coin),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ChunkyButton(
            onTap: onNext,
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            child: const OutlinedText('NEXT', size: 30, outline: AppColors.greenDark),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onHome,
            child: const Text(
              'Home',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.greyDark),
            ),
          ),
        ],
      ),
    );
  }
}

class LosePanel extends StatelessWidget {
  const LosePanel({
    super.key,
    required this.goals,
    required this.coins,
    required this.continuePrice,
    required this.continueSeconds,
    required this.onContinue,
    required this.onRetry,
    required this.onHome,
  });

  final List<GoalProgress> goals;
  final int coins;
  final int continuePrice;
  final int continueSeconds;
  final VoidCallback onContinue;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final left = goals.where((g) => !g.done).toList();
    return Panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OutlinedText("TIME'S UP!", size: 38, color: AppColors.danger),
          const SizedBox(height: 12),
          const Text(
            'Still to swallow:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.greyDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              for (final g in left)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ItemIcon(g.kind, size: 48),
                    OutlinedText('${g.left}', size: 20, stroke: 4),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          ChunkyButton(
            onTap: coins >= continuePrice ? onContinue : null,
            color: AppColors.orange,
            shade: AppColors.orangeDark,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 6),
                OutlinedText('+${continueSeconds}s', size: 26, outline: AppColors.orangeDark),
                const SizedBox(width: 12),
                const CoinIcon(size: 24),
                const SizedBox(width: 4),
                OutlinedText('$continuePrice', size: 20, outline: AppColors.orangeDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ChunkyButton(
            onTap: onRetry,
            color: AppColors.blue,
            shade: AppColors.blueDark,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedText('TRY AGAIN', size: 22, outline: AppColors.blueDark),
                SizedBox(width: 8),
                OutlinedText('-1', size: 18, outline: AppColors.blueDark),
                HeartIcon(size: 22),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onHome,
            child: const Text(
              'Home',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.greyDark),
            ),
          ),
        ],
      ),
    );
  }
}

class NoLivesPanel extends StatelessWidget {
  const NoLivesPanel({super.key, required this.profile, required this.onRefilled, required this.onClose});

  final PlayerProfile profile;
  final VoidCallback onRefilled;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final wait = profile.nextLifeIn;
    final waitText = wait == null
        ? ''
        : '${wait.inMinutes}:${(wait.inSeconds % 60).toString().padLeft(2, '0')}';
    return Panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OutlinedText('OUT OF LIVES', size: 32, color: AppColors.danger),
          const SizedBox(height: 14),
          const HeartIcon(size: 84, color: AppColors.grey),
          const SizedBox(height: 10),
          Text(
            'Next life in $waitText',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.greyDark),
          ),
          const SizedBox(height: 18),
          ChunkyButton(
            onTap: profile.coins >= PlayerProfile.refillPrice
                ? () {
                    if (profile.refillLives()) onRefilled();
                  }
                : null,
            color: AppColors.pink,
            shade: AppColors.pinkDark,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedText('REFILL', size: 24, outline: AppColors.pinkDark),
                SizedBox(width: 10),
                CoinIcon(size: 24),
                SizedBox(width: 4),
                OutlinedText('${PlayerProfile.refillPrice}', size: 20, outline: AppColors.pinkDark),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onClose,
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.greyDark),
            ),
          ),
        ],
      ),
    );
  }
}
