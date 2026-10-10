import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../app/app.dart';
import '../app/profile.dart';
import '../app/theme.dart';
import '../game/audio/sfx.dart';
import '../game/engine/world.dart';
import '../game/levels/bot.dart';
import '../game/levels/level.dart';
import '../game/levels/levels.dart';
import '../game/model/item.dart';
import '../game/render/world_painter.dart';
import 'confetti.dart';
import 'hud.dart';
import 'overlays.dart';
import 'widgets.dart';

enum _Overlay { none, paused, won, lost, noLives }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelNumber});

  final int levelNumber;

  /// Opens a level, or the out-of-lives panel when there are none.
  static Route<void> route(int level) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) => GameScreen(levelNumber: level),
    transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
  );

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _timePrice = 50;
  static const _timeBoost = 10.0;
  static const _growPrice = 80;
  static const _continuePrice = 100;
  static const _continueSeconds = 15;

  /// Debug aid (`--dart-define=AUTOPLAY=true`): the bot drives the hole.
  static const _autoplay = bool.fromEnvironment('AUTOPLAY');
  Item? _autoTarget;
  double _autoRetarget = 0;

  /// Null while the level is loading.
  GameWorld? _loaded;
  late final Ticker _ticker;
  final _frame = ValueNotifier<int>(0);
  final _hud = ValueNotifier<int>(0);
  Size _size = Size.zero;
  Duration _last = Duration.zero;
  int _shownSeconds = -1;
  GamePhase? _shownPhase;
  _Overlay _overlay = _Overlay.none;
  int _stars = 0;
  int _reward = 0;
  DateTime _lastHaptic = DateTime(0);
  Timer? _winDelay;

  late final PlayerProfile _profile = ProfileScope.read(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_tick);
    loadLevel(widget.levelNumber).then((level) {
      if (!mounted) return;
      setState(() => _loaded = _createWorld(level));
      _ticker.start();
      prefetchLevel(widget.levelNumber + 1);
    });
  }

  GameWorld get _world => _loaded!;

  GameWorld _createWorld(Level level) {
    final world = GameWorld(level);
    world.onEaten = _onEaten;
    world.onGrow = (_) {
      Sfx.grow();
      _haptic(HapticFeedback.mediumImpact, force: true);
      _hud.value++;
    };
    world.onGoalComplete = (_) {
      Sfx.goal();
      _hud.value++;
    };
    world.onWin = _onWin;
    world.onLose = _onLose;
    return world;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _winDelay?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _hud.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_loaded == null) return;
    if (state != AppLifecycleState.resumed && _overlay == _Overlay.none && _world.phase == GamePhase.playing) {
      setState(() => _overlay = _Overlay.paused);
    }
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 0.0 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_size.isEmpty) return;
    if (_autoplay && _overlay == _Overlay.none) _drive(dt);
    if (_overlay != _Overlay.paused) _world.update(dt, _size);
    _frame.value++;

    if (_world.phase != _shownPhase) {
      _shownPhase = _world.phase;
      setState(() {});
    }

    final secs = _world.timeLeft.ceil();
    if (secs != _shownSeconds) {
      if (_world.phase == GamePhase.playing && secs <= 10 && secs > 0 && _shownSeconds > secs) Sfx.tick();
      _shownSeconds = secs;
      _hud.value++;
    }
  }

  void _drive(double dt) {
    final w = _world;
    if (w.phase == GamePhase.won || w.phase == GamePhase.lost) return;
    _autoRetarget -= dt;
    if (_autoRetarget <= 0 || _autoTarget?.state != ItemState.resting) {
      _autoTarget = botTarget(w);
      _autoRetarget = 0.3;
    }
    final t = _autoTarget;
    if (t == null) return;
    final dx = t.x - w.holeX, dy = t.y - w.holeY;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d < 1e-6) return;
    final step = math.min(d, 4.5 * dt);
    w.phase = GamePhase.playing;
    w.holeX += dx / d * step;
    w.holeY += dy / d * step;
  }

  void _haptic(Future<void> Function() fn, {bool force = false}) {
    if (!_profile.haptics) return;
    final now = DateTime.now();
    if (!force && now.difference(_lastHaptic).inMilliseconds < 70) return;
    _lastHaptic = now;
    fn();
  }

  void _onEaten(Item item) {
    Sfx.plop();
    final isGoal = _world.goals.any((g) => g.kind == item.kind);
    if (isGoal) {
      _haptic(HapticFeedback.selectionClick);
      _hud.value++;
    }
  }

  void _onWin() {
    final ratio = _world.timeLeft / _world.level.time;
    _stars = ratio >= 0.4 ? 3 : (ratio >= 0.2 ? 2 : 1);
    _reward = 20 + _stars * 10 + math.min(40, _world.timeLeft.round());
    _profile.completeLevel(widget.levelNumber, _stars);
    _profile.addCoins(_reward);
    _haptic(HapticFeedback.heavyImpact, force: true);
    _winDelay = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Sfx.win();
      setState(() => _overlay = _Overlay.won);
    });
    _hud.value++;
  }

  void _onLose() {
    Sfx.lose();
    _haptic(HapticFeedback.heavyImpact, force: true);
    setState(() => _overlay = _Overlay.lost);
  }

  // ------------------------------------------------------------- actions

  void _restart() {
    if (_profile.lives <= 0) {
      setState(() => _overlay = _Overlay.noLives);
      return;
    }
    Navigator.of(context).pushReplacement(GameScreen.route(widget.levelNumber));
  }

  void _giveUpAndRetry() {
    _profile.loseLife();
    _restart();
  }

  void _giveUpAndLeave() {
    _profile.loseLife();
    Navigator.of(context).pop();
  }

  void _quitFromPause() {
    if (_world.phase == GamePhase.playing) _profile.loseLife();
    Navigator.of(context).pop();
  }

  void _next() => Navigator.of(context).pushReplacement(GameScreen.route(widget.levelNumber + 1));

  void _continue() {
    if (!_profile.spend(_continuePrice)) return;
    Sfx.coin();
    _world.addTime(_continueSeconds.toDouble());
    setState(() => _overlay = _Overlay.none);
  }

  bool get _canBoost =>
      _overlay == _Overlay.none && (_world.phase == GamePhase.playing || _world.phase == GamePhase.ready);

  void _boostTime() {
    if (!_canBoost || !_profile.spend(_timePrice)) return;
    Sfx.coin();
    _world.addTime(_timeBoost);
    _hud.value++;
  }

  void _boostGrow() {
    if (!_canBoost || _world.sizeStep >= _world.maxStep || !_profile.spend(_growPrice)) return;
    Sfx.coin();
    _world.grow();
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    if (_loaded == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF2B2340),
        body: Center(child: OutlinedText('LEVEL ${widget.levelNumber}', size: 44)),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _overlay == _Overlay.none) setState(() => _overlay = _Overlay.paused);
      },
      child: Scaffold(
        backgroundColor: _world.level.theme.outside,
        body: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _size = constraints.biggest;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: _overlay == _Overlay.none ? (d) => _world.drag(d.delta) : null,
                    child: CustomPaint(
                      size: Size.infinite,
                      isComplex: true,
                      willChange: true,
                      painter: WorldPainter(world: _world, skin: _profile.skin, repaint: _frame),
                    ),
                  );
                },
              ),
            ),
            SafeArea(child: ValueListenableBuilder<int>(valueListenable: _hud, builder: (context, _, _) => _buildHud())),
            if (_world.phase == GamePhase.ready && _overlay == _Overlay.none) const _DragHint(),
            ..._buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.pause_rounded,
                onTap: () {
                  if (_overlay == _Overlay.none) setState(() => _overlay = _Overlay.paused);
                },
              ),
              Expanded(child: Center(child: TimerPill(seconds: _world.timeLeft.ceil()))),
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    const OutlinedText('LEVEL', size: 12, stroke: 3),
                    OutlinedText('${widget.levelNumber}', size: 26, stroke: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [for (final g in _world.goals) GoalChip(goal: g, left: g.left)],
        ),
        const Spacer(),
        if (_world.phase == GamePhase.playing || _world.phase == GamePhase.ready)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ListenableBuilder(
              listenable: _profile,
              builder: (context, _) => Row(
                children: [
                  BoosterButton(
                    icon: Icons.more_time_rounded,
                    label: '+${_timeBoost.round()}s',
                    price: _timePrice,
                    color: AppColors.blue,
                    shade: AppColors.blueDark,
                    onTap: _profile.coins >= _timePrice ? _boostTime : null,
                  ),
                  const Spacer(),
                  CoinPill(coins: _profile.coins),
                  const Spacer(),
                  BoosterButton(
                    icon: Icons.open_in_full_rounded,
                    label: 'GROW',
                    price: _growPrice,
                    color: AppColors.pink,
                    shade: AppColors.pinkDark,
                    onTap: _profile.coins >= _growPrice && _world.sizeStep < _world.maxStep ? _boostGrow : null,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildOverlay() {
    switch (_overlay) {
      case _Overlay.none:
        return const [];
      case _Overlay.paused:
        return [
          OverlayFrame(
            child: PausePanel(
              profile: _profile,
              quitCostsLife: _world.phase == GamePhase.playing,
              onResume: () {
                _last = Duration.zero;
                setState(() => _overlay = _Overlay.none);
              },
              onQuit: _quitFromPause,
            ),
          ),
        ];
      case _Overlay.won:
        return [
          OverlayFrame(
            dim: 0x77,
            child: WinPanel(
              level: widget.levelNumber,
              stars: _stars,
              coins: _reward,
              onNext: _next,
              onHome: () => Navigator.of(context).pop(),
            ),
          ),
          const Positioned.fill(child: Confetti()),
        ];
      case _Overlay.lost:
        return [
          OverlayFrame(
            child: ListenableBuilder(
              listenable: _profile,
              builder: (context, _) => LosePanel(
                goals: _world.goals,
                coins: _profile.coins,
                continuePrice: _continuePrice,
                continueSeconds: _continueSeconds,
                onContinue: _continue,
                onRetry: _giveUpAndRetry,
                onHome: _giveUpAndLeave,
              ),
            ),
          ),
        ];
      case _Overlay.noLives:
        return [
          OverlayFrame(
            child: ListenableBuilder(
              listenable: _profile,
              builder: (context, _) => NoLivesPanel(
                profile: _profile,
                onRefilled: _restart,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ];
    }
  }
}

/// "Drag to move" with a finger swinging left and right.
class _DragHint extends StatefulWidget {
  const _DragHint();

  @override
  State<_DragHint> createState() => _DragHintState();
}

class _DragHintState extends State<_DragHint> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 150,
      child: IgnorePointer(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) => Transform.translate(
                offset: Offset(math.sin(_c.value * 2 * math.pi) * 60, 0),
                child: child,
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                size: 72,
                color: Colors.white,
                shadows: [Shadow(color: Color(0x88000000), blurRadius: 8, offset: Offset(0, 3))],
              ),
            ),
            const SizedBox(height: 8),
            const OutlinedText('DRAG TO MOVE', size: 26),
          ],
        ),
      ),
    );
  }
}
