import 'dart:math' as math;
import 'dart:ui';

import '../engine/world.dart';
import '../model/item.dart';
import 'level.dart';

/// Plays [level] the straightforward way: head for the nearest goal item
/// the hole can swallow, or for anything swallowable to grow. Returns the
/// seconds it took, or null if it got stuck.
///
/// Level clocks are set from this, so every level (hand-made or generated)
/// is equally fair. [level] is consumed: its items are simulated in place.
double? estimateClearTime(Level level, {double speed = 4.5, double limit = 400}) {
  const dt = 1 / 60;
  const viewport = Size(440, 956);
  final w = GameWorld(level, random: math.Random(level.number))
    ..phase = GamePhase.playing
    ..timeLeft = limit + 1;
  Item? target;
  var retarget = 0.0;
  for (var t = 0.0; t < limit; t += dt) {
    if (w.phase == GamePhase.won) return t;
    retarget -= dt;
    if (retarget <= 0 || target == null || target.state != ItemState.resting) {
      target = botTarget(w);
      retarget = 0.3;
      if (target == null && !w.items.any((i) => i.state == ItemState.sinking || i.state == ItemState.airborne)) {
        return null;
      }
    }
    if (target != null) {
      final dx = target.x - w.holeX, dy = target.y - w.holeY;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > 1e-6) {
        final step = math.min(d, speed * dt);
        w.holeX += dx / d * step;
        w.holeY += dy / d * step;
      }
    }
    w.update(dt, viewport);
  }
  return null;
}

/// The item the bot heads for next: the nearest swallowable goal item,
/// else the nearest swallowable anything (to grow).
Item? botTarget(GameWorld w) {
  final open = {for (final g in w.goals) if (!g.done) g.kind};
  final limit = w.targetRadius * 0.96;
  Item? best;
  var bestScore = double.infinity;
  for (final it in w.items) {
    if (it.state != ItemState.resting || it.kind.fit > limit) continue;
    final dx = it.x - w.holeX, dy = it.y - w.holeY;
    final d = math.sqrt(dx * dx + dy * dy);
    final score = open.contains(it.kind) ? d : d + 4;
    if (score < bestScore) {
      bestScore = score;
      best = it;
    }
  }
  return best;
}
