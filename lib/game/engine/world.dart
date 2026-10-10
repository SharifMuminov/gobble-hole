import 'dart:math' as math;
import 'dart:ui';

import '../constants.dart';
import '../levels/level.dart';
import '../model/item.dart';
import '../model/item_kind.dart';
import 'camera.dart';

enum GamePhase { ready, playing, won, lost }

class GoalProgress {
  GoalProgress(this.kind, this.target);

  final ItemKind kind;
  final int target;
  int eaten = 0;

  bool get done => eaten >= target;
  int get left => math.max(0, target - eaten);
}

/// The simulation of one level: the hole, every item, the clock and goals.
class GameWorld {
  GameWorld(this.level, {math.Random? random})
    : items = List.of(level.items),
      goals = [for (final g in level.goals) GoalProgress(g.kind, g.count)],
      timeLeft = level.time,
      holeX = level.holeStart.dx,
      holeY = level.holeStart.dy,
      _rng = random ?? math.Random() {
    _buildGrowth();
    radius = radii[0];
    camX = holeX;
    camY = holeY;
  }

  final Level level;
  final List<Item> items;
  final List<GoalProgress> goals;
  final math.Random _rng;
  final camera = GameCamera();

  GamePhase phase = GamePhase.ready;
  double timeLeft;

  /// Seconds since the level was opened (drives small animations).
  double clock = 0;

  double holeX, holeY;

  /// Current (animated) hole radius; physics uses it too.
  double radius = 0.5;

  /// Hole radius per size step, and the total xp needed to reach it.
  late final List<double> radii;
  late final List<double> thresholds;
  int sizeStep = 0;
  double xp = 0;

  int eatenCount = 0;

  /// Camera look-at point and distance (smoothed).
  double camX = 0, camY = 0, camDist = 0;

  double _acc = 0;
  int _goneSinceCompact = 0;

  // Events for sound, haptics and the HUD.
  void Function(Item item)? onEaten;
  void Function(int step)? onGrow;
  void Function(GoalProgress goal)? onGoalComplete;
  VoidCallback? onWin;
  VoidCallback? onLose;

  int get maxStep => radii.length - 1;

  double get targetRadius => radii[sizeStep];

  /// Progress to the next size, 0..1 (1 at max size).
  double get growthProgress {
    if (sizeStep >= maxStep) return 1;
    final a = thresholds[sizeStep], b = thresholds[sizeStep + 1];
    return ((xp - a) / (b - a)).clamp(0.0, 1.0);
  }

  bool get allGoalsDone => goals.every((g) => g.done);

  void _buildGrowth() {
    const steps = 10;
    final r0 = level.holeRadius;
    var maxFit = 0.0, total = 0.0;
    for (final it in items) {
      maxFit = math.max(maxFit, it.kind.fit);
      total += it.kind.xp;
    }
    final rMax = math.min(3.2, math.max(r0 * 2.6, maxFit * 1.22));
    radii = [for (var s = 0; s <= steps; s++) r0 * math.pow(rMax / r0, s / steps)];

    double eatable(double r) {
      var sum = 0.0;
      for (final it in items) {
        if (it.kind.fit <= r * 0.96) sum += it.kind.xp;
      }
      return sum;
    }

    final t = <double>[0];
    for (var s = 1; s <= steps; s++) {
      final goal = 0.6 * total * math.pow(s / steps, 1.5);
      final reachable = 0.8 * eatable(radii[s - 1]);
      t.add(math.max(t[s - 1] + 0.5, math.min(goal, reachable)));
    }
    thresholds = t;
  }

  // ---------------------------------------------------------------- input

  /// Moves the hole by a finger movement of [delta] screen pixels.
  void drag(Offset delta) {
    if (phase == GamePhase.won || phase == GamePhase.lost) return;
    if (phase == GamePhase.ready) phase = GamePhase.playing;
    final zc = camera.depth(holeX, holeY, 0);
    final k = zc / camera.focal * 1.25;
    holeX += delta.dx * k;
    holeY -= delta.dy * k / kGroundSquash;
    _clampHole();
  }

  void _clampHole() {
    final m = radius * 0.5;
    holeX = holeX.clamp(m, level.width - m);
    holeY = holeY.clamp(m, level.height - m);
  }

  /// Booster: +[seconds] on the clock (also revives a lost level).
  void addTime(double seconds) {
    timeLeft += seconds;
    if (phase == GamePhase.lost) phase = GamePhase.playing;
  }

  /// Booster: jump one size up.
  void grow() {
    if (sizeStep >= maxStep) return;
    sizeStep++;
    xp = math.max(xp, thresholds[sizeStep]);
    onGrow?.call(sizeStep);
  }

  // ----------------------------------------------------------- simulation

  void update(double dt, Size viewport) {
    dt = math.min(dt, 0.05);
    clock += dt;
    camera.setViewport(viewport);

    _acc += dt;
    while (_acc >= kStep) {
      _step(kStep);
      _acc -= kStep;
    }

    // Grow smoothly with a little overshoot.
    final target = targetRadius;
    radius += (target - radius) * math.min(1, dt * 7);
    _clampHole();

    if (phase == GamePhase.playing) {
      timeLeft -= dt;
      if (timeLeft <= 0) {
        timeLeft = 0;
        phase = GamePhase.lost;
        onLose?.call();
      }
    }

    if (_goneSinceCompact > 150) {
      items.removeWhere((i) => i.state == ItemState.gone);
      _goneSinceCompact = 0;
    }

    _updateCamera(dt);
  }

  void _updateCamera(double dt) {
    final wantDist = camera.distanceForWidth(4.6 + radius * 4.0);
    if (camDist == 0) {
      camDist = wantDist;
      camX = holeX;
      camY = holeY;
    }
    final k = math.min(1.0, dt * 9);
    camX += (holeX - camX) * k;
    camY += (holeY - camY) * k;
    camDist += (wantDist - camDist) * math.min(1.0, dt * 2.5);
    camera.lookAt(camX, camY, camDist);
  }

  void _step(double dt) {
    final r = radius;
    final fitLimit = r * 0.96;
    for (final it in items) {
      switch (it.state) {
        case ItemState.resting:
          _resting(it, r, fitLimit, dt);
        case ItemState.airborne:
          _airborne(it, r, fitLimit, dt);
        case ItemState.sinking:
          _sinking(it, r, dt);
        case ItemState.gone:
          break;
      }
    }
  }

  void _resting(Item it, double r, double fitLimit, double dt) {
    final below = it.below;
    if (below != null) {
      if (below.state != ItemState.resting) {
        _topple(it);
      } else if (it.kind.fit <= fitLimit && below.kind.fit <= fitLimit) {
        // Over the opening: whatever held it up (in a pyramid, the items
        // around the one it is tied to) is falling in too.
        final dx = it.x - holeX, dy = it.y - holeY;
        final open = r - it.kind.fit * 0.3;
        if (dx * dx + dy * dy < open * open) _topple(it);
      }
      return;
    }

    if (it.vx != 0 || it.vy != 0) {
      it.x += it.vx * dt;
      it.y += it.vy * dt;
      final f = math.max(0.0, 1 - dt * 6);
      it.vx *= f;
      it.vy *= f;
      if (it.vx.abs() + it.vy.abs() < 0.02) it.vx = it.vy = 0;
      _keepInside(it);
    }

    final dx = it.x - holeX, dy = it.y - holeY;
    final reach = r + it.kind.fit * 0.45;
    final d2 = dx * dx + dy * dy;
    if (d2 > reach * reach) {
      if (it.tilt != 0 && it.spin == 0) it.tilt *= 0.9;
      return;
    }
    final d = math.sqrt(d2);
    if (it.kind.fit <= fitLimit) {
      if (d < r - it.kind.fit * 0.3) {
        _startSinking(it);
      } else if (it.supports == 0 && d > 1e-6) {
        // Leaning over the rim: slide in.
        final pull = math.min(d, (1.4 + r) * dt);
        it.x -= dx / d * pull;
        it.y -= dy / d * pull;
      }
    } else if (d < r) {
      // Too big: it rocks on the rim.
      it.tilt = math.sin(clock * 28 + it.x) * 0.06;
    }
  }

  void _topple(Item it) {
    it.below!.supports--;
    it.below = null;
    it.state = ItemState.airborne;
    final kick = 0.25 + it.z * 0.35;
    it.vx = (_rng.nextDouble() - 0.5) * kick;
    it.vy = (_rng.nextDouble() - 0.5) * kick;
    it.vz = 0;
    it.spin = (_rng.nextDouble() - 0.5) * 3;
  }

  void _airborne(Item it, double r, double fitLimit, double dt) {
    it.vz -= kGravity * dt;
    it.x += it.vx * dt;
    it.y += it.vy * dt;
    it.z += it.vz * dt;
    it.tilt += it.spin * dt;
    _keepInside(it);
    if (it.z > 0) return;

    it.z = 0;
    final dx = it.x - holeX, dy = it.y - holeY;
    final d = math.sqrt(dx * dx + dy * dy);
    if (it.kind.fit <= fitLimit && d < r - it.kind.fit * 0.1) {
      _startSinking(it);
      return;
    }
    it.state = ItemState.resting;
    it.vz = 0;
    it.vx *= 0.4;
    it.vy *= 0.4;
    it.spin = 0;
  }

  void _startSinking(Item it) {
    it.state = ItemState.sinking;
    it.rx = it.x - holeX;
    it.ry = it.y - holeY;
    it.vz = math.min(it.vz, 0);
    it.spin = (_rng.nextDouble() - 0.5) * 7;
  }

  void _sinking(Item it, double r, double dt) {
    it.vz -= kGravity * dt;
    it.z += it.vz * dt;
    it.vx -= it.rx * 7 * dt;
    it.vy -= it.ry * 7 * dt;
    final f = math.max(0.0, 1 - dt * 5);
    it.vx *= f;
    it.vy *= f;
    it.rx += it.vx * dt;
    it.ry += it.vy * dt;
    final lim = math.max(0.02, r - it.kind.fit * 0.8);
    final d2 = it.rx * it.rx + it.ry * it.ry;
    if (d2 > lim * lim) {
      final s = lim / math.sqrt(d2);
      it.rx *= s;
      it.ry *= s;
    }
    it.x = holeX + it.rx;
    it.y = holeY + it.ry;
    it.tilt += it.spin * dt;
    if (it.z < -(r * 1.5 + it.kind.h + 0.4)) _eat(it);
  }

  void _keepInside(Item it) {
    final m = it.kind.r * 0.6;
    if (it.x < m) {
      it.x = m;
      it.vx = it.vx.abs() * 0.3;
    } else if (it.x > level.width - m) {
      it.x = level.width - m;
      it.vx = -it.vx.abs() * 0.3;
    }
    if (it.y < m) {
      it.y = m;
      it.vy = it.vy.abs() * 0.3;
    } else if (it.y > level.height - m) {
      it.y = level.height - m;
      it.vy = -it.vy.abs() * 0.3;
    }
  }

  void _eat(Item it) {
    it.state = ItemState.gone;
    _goneSinceCompact++;
    eatenCount++;
    xp += it.kind.xp;
    onEaten?.call(it);

    if (phase != GamePhase.won) {
      for (final g in goals) {
        if (g.kind == it.kind && !g.done) {
          g.eaten++;
          if (g.done) onGoalComplete?.call(g);
        }
      }
    }

    while (sizeStep < maxStep && xp >= thresholds[sizeStep + 1]) {
      sizeStep++;
      onGrow?.call(sizeStep);
    }

    if (phase == GamePhase.playing && allGoalsDone) {
      phase = GamePhase.won;
      onWin?.call();
    }
  }
}
