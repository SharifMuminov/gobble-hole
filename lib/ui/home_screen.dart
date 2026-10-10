import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app/app.dart';
import '../app/profile.dart';
import '../app/theme.dart';
import '../game/engine/world.dart';
import '../game/levels/levels.dart';
import '../game/render/world_painter.dart';
import 'game_screen.dart';
import 'overlays.dart';
import 'skins_sheet.dart';
import 'widgets.dart';

/// Title screen. The next level plays itself in the background while the
/// hole wanders around it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _frame = ValueNotifier<int>(0);
  GameWorld? _world;
  int _worldLevel = -1;
  Size _size = Size.zero;
  Duration _last = Duration.zero;
  double _t = 0;
  Timer? _clock;
  bool _noLives = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    // Debug aid (`--dart-define=START_LEVEL=5`): jump straight into a level.
    const start = int.fromEnvironment('START_LEVEL');
    if (start > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).push(GameScreen.route(start));
      });
    }
    // Keeps the life timer in the top bar fresh.
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock?.cancel();
    _frame.dispose();
    super.dispose();
  }

  GameWorld _demoFor(int level) {
    if (_world == null || _worldLevel != level) {
      _world = GameWorld(layoutLevel(level));
      prefetchLevel(level);
      _worldLevel = level;
      _t = 0;
    }
    return _world!;
  }

  void _tick(Duration elapsed) {
    final world = _world;
    if (world == null || _size.isEmpty) return;
    final dt = _last == Duration.zero ? 0.0 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _t += dt;
    final w = world.level.width, h = world.level.height;
    world.holeX = w / 2 + math.sin(_t * 0.35) * w * 0.32;
    world.holeY = world.level.holeStart.dy + (1 - math.cos(_t * 0.22)) * h * 0.3;
    world.update(dt, _size);
    _frame.value++;
  }

  void _play(PlayerProfile profile) {
    if (profile.lives <= 0) {
      setState(() => _noLives = true);
      return;
    }
    _ticker.stop();
    Navigator.of(context).push(GameScreen.route(profile.level)).then((_) {
      if (!mounted) return;
      _last = Duration.zero;
      _ticker.start();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);
    final world = _demoFor(profile.level);
    final theme = world.level.theme;
    final lives = profile.lives;
    final wait = profile.nextLifeIn;

    return Scaffold(
      backgroundColor: theme.outside,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                _size = c.biggest;
                return CustomPaint(
                  size: Size.infinite,
                  painter: WorldPainter(world: world, skin: profile.skin, repaint: _frame),
                );
              },
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xAA000000)],
                    stops: [0, 0.3, 0.6, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      StatPill(
                        icon: const HeartIcon(size: 30),
                        label: '$lives',
                        trailing: wait == null
                            ? const OutlinedText('FULL', size: 13, stroke: 3, color: AppColors.green)
                            : OutlinedText(
                                '${wait.inMinutes}:${(wait.inSeconds % 60).toString().padLeft(2, '0')}',
                                size: 14,
                                stroke: 3,
                              ),
                      ),
                      const Spacer(),
                      CoinPill(coins: profile.coins),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _Title(),
                const SizedBox(height: 6),
                OutlinedText(theme.name.toUpperCase(), size: 18, stroke: 4, color: theme.border),
                const Spacer(),
                ChunkyButton(
                  onTap: () => _play(profile),
                  radius: 30,
                  depth: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                  child: Column(
                    children: [
                      const OutlinedText('PLAY', size: 40, outline: AppColors.greenDark),
                      OutlinedText('LEVEL ${profile.level}', size: 18, stroke: 4, outline: AppColors.greenDark),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SmallButton(
                      icon: Icons.palette_rounded,
                      label: 'SKINS',
                      color: AppColors.pink,
                      shade: AppColors.pinkDark,
                      onTap: () => showSkinsSheet(context),
                    ),
                    const SizedBox(width: 18),
                    _SmallButton(
                      icon: Icons.settings_rounded,
                      label: 'SETTINGS',
                      color: AppColors.blue,
                      shade: AppColors.blueDark,
                      onTap: () => _showSettings(context, profile),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
          if (_noLives)
            OverlayFrame(
              child: ListenableBuilder(
                listenable: profile,
                builder: (context, _) => NoLivesPanel(
                  profile: profile,
                  onRefilled: () => setState(() => _noLives = false),
                  onClose: () => setState(() => _noLives = false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, PlayerProfile profile) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (context) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: ListenableBuilder(
            listenable: profile,
            builder: (context, _) => Panel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OutlinedText('SETTINGS', size: 32, color: AppColors.blue),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  ChunkyButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const OutlinedText('OK', size: 26, outline: AppColors.greenDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Transform.rotate(
        angle: -0.05,
        child: const Column(
          children: [
            OutlinedText('GOBBLE', size: 64, color: Color(0xFFFFE04A), stroke: 13),
            OutlinedText('HOLE!', size: 70, color: Color(0xFFFF6FA3), stroke: 14),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.shade,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color shade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: color,
      shade: shade,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 6),
          OutlinedText(label, size: 18, stroke: 4, outline: shade),
        ],
      ),
    );
  }
}
