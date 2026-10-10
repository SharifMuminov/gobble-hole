import 'dart:math' as math;

/// The camera looks down at the ground at this angle below the horizon.
/// Sprites are drawn for this view, so it is shared by the renderer and art.
const double kCameraPitchDeg = 52;

final double kCameraPitch = kCameraPitchDeg * math.pi / 180;

/// A horizontal circle of radius 1 is seen as an ellipse 1 wide, this tall.
final double kGroundSquash = math.sin(kCameraPitch);

/// A vertical segment of length 1 is seen this long.
final double kHeightSquash = math.cos(kCameraPitch);

/// Fixed simulation step.
const double kStep = 1 / 120;

const double kGravity = 22;
