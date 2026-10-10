import 'dart:ui';

import '../model/item.dart';
import '../model/item_kind.dart';

/// Colours of one map.
class MapTheme {
  const MapTheme({
    required this.name,
    required this.ground,
    required this.groundAlt,
    required this.outside,
    required this.border,
  });

  final String name;
  final Color ground;
  final Color groundAlt;
  final Color outside;
  final Color border;

  static const pink = MapTheme(
    name: 'Fruit Party',
    ground: Color(0xFFF8A5C8),
    groundAlt: Color(0xFFF49AC0),
    outside: Color(0xFFD9779F),
    border: Color(0xFFFFD3E6),
  );

  static const grass = MapTheme(
    name: 'Veggie Farm',
    ground: Color(0xFF8BD650),
    groundAlt: Color(0xFF80CC47),
    outside: Color(0xFF5FA832),
    border: Color(0xFFC5EE9E),
  );

  static const purple = MapTheme(
    name: 'Sweet Land',
    ground: Color(0xFF9B6BEA),
    groundAlt: Color(0xFF915FE3),
    outside: Color(0xFF6D3FC0),
    border: Color(0xFFCDB4FA),
  );

  static const ocean = MapTheme(
    name: 'Sushi Bar',
    ground: Color(0xFF3A9EF0),
    groundAlt: Color(0xFF3193E6),
    outside: Color(0xFF1E6FC0),
    border: Color(0xFFA8D5FB),
  );

  static const sky = MapTheme(
    name: 'Butterfly Garden',
    ground: Color(0xFF9EDCF7),
    groundAlt: Color(0xFF93D3F0),
    outside: Color(0xFF63B4DD),
    border: Color(0xFFDDF3FD),
  );

  static const sand = MapTheme(
    name: 'Toy Town',
    ground: Color(0xFFFFD98A),
    groundAlt: Color(0xFFFFD17A),
    outside: Color(0xFFE8A94C),
    border: Color(0xFFFFF0C9),
  );

  static const mint = MapTheme(
    name: 'Mint Picnic',
    ground: Color(0xFF7FE0C4),
    groundAlt: Color(0xFF73D6B9),
    outside: Color(0xFF45B394),
    border: Color(0xFFCBF5E8),
  );

  static const all = [pink, grass, purple, ocean, sky, sand, mint];
}

/// "Swallow [count] of [kind]".
class GoalSpec {
  const GoalSpec(this.kind, this.count);

  final ItemKind kind;
  final int count;
}

/// A ready-to-play level. Items are fresh objects each time it is built.
class Level {
  Level({
    required this.number,
    required this.theme,
    required this.width,
    required this.height,
    required this.items,
    required this.goals,
    required this.time,
    required this.holeStart,
    this.holeRadius = 0.5,
  });

  final int number;
  final MapTheme theme;

  /// Arena size: x in [0, width], y in [0, height].
  final double width, height;
  final List<Item> items;
  final List<GoalSpec> goals;

  /// Seconds on the clock.
  final double time;
  final Offset holeStart;
  final double holeRadius;

  Level withTime(double seconds) => Level(
    number: number,
    theme: theme,
    width: width,
    height: height,
    items: items,
    goals: goals,
    time: seconds,
    holeStart: holeStart,
    holeRadius: holeRadius,
  );
}
