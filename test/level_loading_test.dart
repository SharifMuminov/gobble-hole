import 'package:flutter_test/flutter_test.dart';
import 'package:hole_it_clone/game/levels/levels.dart';

void main() {
  test('loadLevel runs the bot off the main isolate and caches the clock', () async {
    prefetchLevel(6);
    final a = await loadLevel(5).timeout(const Duration(seconds: 20));
    final b = await loadLevel(6).timeout(const Duration(seconds: 20));
    expect(a.time, buildLevel(5).time);
    expect(b.time, greaterThan(0));
  });
}
