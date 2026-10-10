import 'dart:math' as math;

import '../constants.dart';
import 'item_kind.dart';

enum ItemState {
  /// Lying on the ground or on top of another item.
  resting,

  /// Falling or tumbling through the air above the ground.
  airborne,

  /// Inside the hole, on its way down.
  sinking,

  /// Swallowed.
  gone,
}

/// One object on the map. Mutable: the world simulates it in place.
class Item {
  Item(this.kind, this.x, this.y, {this.z = 0, this.yaw = 0, this.below})
    : screenAngle = kind.rotates ? _screenAngle(yaw) : 0 {
    below?.supports++;
  }

  final ItemKind kind;

  /// Position of the bottom centre.
  double x, y, z;
  double vx = 0, vy = 0, vz = 0;

  /// Direction a long item points to, in world radians.
  final double yaw;

  /// [yaw] as seen on screen (constant: the camera never turns).
  final double screenAngle;

  /// Extra screen rotation while tumbling, and its speed.
  double tilt = 0;
  double spin = 0;

  ItemState state = ItemState.resting;

  /// The item this one is stacked on, if any.
  Item? below;

  /// How many items rest on this one.
  int supports = 0;

  /// Offset from the hole centre while [ItemState.sinking].
  double rx = 0, ry = 0;

  bool get isActive => state != ItemState.gone;

  /// A world direction (cos a, sin a, 0) on screen, where y grows downwards
  /// and depth squashes the vertical part.
  static double _screenAngle(double yaw) =>
      math.atan2(-math.sin(yaw) * kGroundSquash, math.cos(yaw));
}
