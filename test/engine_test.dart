import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hole_it_clone/game/engine/world.dart';
import 'package:hole_it_clone/game/levels/bot.dart';
import 'package:hole_it_clone/game/levels/builder.dart';
import 'package:hole_it_clone/game/levels/level.dart';
import 'package:hole_it_clone/game/levels/levels.dart';
import 'package:hole_it_clone/game/model/item.dart';
import 'package:hole_it_clone/game/model/item_kind.dart';

const _viewport = Size(440, 956);

void _run(GameWorld w, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    w.update(1 / 60, _viewport);
  }
}

GameWorld _world(void Function(LevelBuilder b) build, {List<GoalSpec>? goals}) {
  final b = LevelBuilder(10, 10);
  build(b);
  final level = b.build(
    number: 1,
    theme: MapTheme.pink,
    goals: goals ?? [b.all(b.items.first.kind)],
    time: 60,
    holeStart: const Offset(5, 1),
  );
  return GameWorld(level, random: math.Random(1))..phase = GamePhase.playing;
}

void main() {
  test('the hole swallows a small item under it', () {
    final w = _world((b) => b.put(ItemKind.apple, 5, 3));
    w.holeY = 3;
    _run(w, 1);
    expect(w.items.where((i) => i.state != ItemState.gone), isEmpty);
    expect(w.goals.single.done, isTrue);
    expect(w.phase, GamePhase.won);
  });

  test('an item too big for the hole stays on the ground', () {
    final w = _world((b) => b.put(ItemKind.watermelon, 5, 3));
    w.holeY = 3;
    _run(w, 1);
    expect(w.items.single.state, ItemState.resting);
  });

  test('a tower falls in when its base is swallowed', () {
    final w = _world((b) => b.column(ItemKind.orangeSlice, 5, 3, 10));
    w.holeY = 3;
    _run(w, 3);
    expect(w.eatenCount, 10);
  });

  test('a tower topples when its base is eaten from the side, leaving items on the ground', () {
    final w = _world((b) => b.column(ItemKind.donut, 5, 3, 8));
    // Swallow the base, then move away before the rest lands.
    w.holeY = 3;
    for (var i = 0; i < 6; i++) {
      w.update(1 / 60, _viewport);
    }
    w.holeX = 1.0;
    w.holeY = 1.0;
    _run(w, 2);
    final left = w.items.where((i) => i.state == ItemState.resting).toList();
    expect(left, isNotEmpty);
    expect(left.every((i) => i.z == 0 && i.below == null), isTrue);
  });

  test('growth thresholds rise and radii grow', () {
    for (var n = 1; n <= 30; n++) {
      final w = GameWorld(buildLevel(n));
      for (var s = 1; s < w.thresholds.length; s++) {
        expect(w.thresholds[s], greaterThan(w.thresholds[s - 1]), reason: 'level $n step $s');
        expect(w.radii[s], greaterThan(w.radii[s - 1]));
      }
    }
  });

  test('every level builds, has goals that exist, and items inside the arena', () {
    for (var n = 1; n <= 80; n++) {
      final level = buildLevel(n);
      expect(level.goals, isNotEmpty, reason: 'level $n');
      for (final g in level.goals) {
        final count = level.items.where((i) => i.kind == g.kind).length;
        expect(g.count, count, reason: 'level $n goal ${g.kind}');
        expect(count, greaterThan(0));
      }
      for (final it in level.items) {
        expect(it.x, inInclusiveRange(0, level.width), reason: 'level $n');
        expect(it.y, inInclusiveRange(0, level.height), reason: 'level $n');
        if (it.below != null) expect(level.items.contains(it.below), isTrue);
      }
      expect(level.items.length, lessThan(3500), reason: 'level $n');
    }
  });

  test('a bot can clear every level, with at least twice its time on the clock', () {
    final report = StringBuffer();
    var failures = 0;
    for (var n = 1; n <= 60; n++) {
      final level = buildLevel(n);
      final used = estimateClearTime(buildLevel(n));
      final ok = used != null && level.time >= used * 2;
      if (!ok) failures++;
      report.writeln(
        'L$n items=${level.items.length} '
        'goals=${level.goals.map((g) => '${g.kind.name}:${g.count}').join(',')} '
        'time=${level.time.round()} bot=${used?.toStringAsFixed(1) ?? 'STUCK'}${ok ? '' : '  <-- FAIL'}',
      );
    }
    // ignore: avoid_print
    print(report);
    expect(failures, 0);
  });
}
