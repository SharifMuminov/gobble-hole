import 'dart:ui';

/// Every object that can lie on the map.
///
/// Sizes are world units (the hole starts with a radius of about 0.5).
/// - [r]: footprint radius (half the longest side for long items).
/// - [h]: height when lying on the ground.
/// - [fit]: the radius the hole must exceed to swallow it (long items fall
///   in lengthwise, so it is smaller than [r]).
/// - [sprite]: world width of the sprite square; the object's 3D centre is
///   drawn at the square's centre.
/// - [rotates]: long items follow their yaw; round ones always face the
///   camera the same way. A rotating item is drawn pointing to +x.
enum ItemKind {
  // Fruit
  apple('Apple', r: 0.22, h: 0.42, sprite: 0.6, color: Color(0xFFE53935)),
  greenApple('Green apple', r: 0.22, h: 0.42, sprite: 0.6, color: Color(0xFF7CB342)),
  orange('Orange', r: 0.24, h: 0.46, sprite: 0.62, color: Color(0xFFFB8C00)),
  lemon('Lemon', r: 0.2, h: 0.3, fit: 0.17, sprite: 0.52, rotates: true, color: Color(0xFFFDD835)),
  strawberry('Strawberry', r: 0.17, h: 0.3, sprite: 0.46, color: Color(0xFFE53935)),
  cherry('Cherry', r: 0.14, h: 0.26, sprite: 0.42, color: Color(0xFFC62828)),
  banana('Banana', r: 0.3, h: 0.16, fit: 0.2, sprite: 0.72, rotates: true, color: Color(0xFFFFE082)),
  watermelonSlice('Watermelon slice', r: 0.26, h: 0.14, fit: 0.2, sprite: 0.64, rotates: true, color: Color(0xFFEF5350)),
  avocado('Avocado', r: 0.22, h: 0.14, fit: 0.2, sprite: 0.56, rotates: true, color: Color(0xFF9CCC65)),
  orangeSlice('Orange slice', r: 0.22, h: 0.07, sprite: 0.52, color: Color(0xFFFFA726)),
  lemonSlice('Lemon slice', r: 0.2, h: 0.06, sprite: 0.48, color: Color(0xFFFFEE58)),
  kiwiSlice('Kiwi slice', r: 0.19, h: 0.06, sprite: 0.46, color: Color(0xFF8BC34A)),
  pineapple('Pineapple', r: 0.3, h: 0.8, sprite: 0.98, color: Color(0xFFFFB300)),
  jamJar('Jam jar', r: 0.32, h: 0.55, sprite: 0.86, color: Color(0xFFD32F2F)),
  watermelon('Watermelon', r: 0.55, h: 0.95, sprite: 1.32, color: Color(0xFF43A047)),

  // Vegetables
  carrot('Carrot', r: 0.34, h: 0.16, fit: 0.2, sprite: 0.78, rotates: true, color: Color(0xFFFF8F00)),
  tomato('Tomato', r: 0.2, h: 0.32, sprite: 0.5, color: Color(0xFFE53935)),
  pepper('Pepper', r: 0.2, h: 0.32, sprite: 0.52, color: Color(0xFFD50000)),
  eggplant('Eggplant', r: 0.3, h: 0.2, fit: 0.22, sprite: 0.72, rotates: true, color: Color(0xFF6A1B9A)),
  corn('Corn', r: 0.32, h: 0.18, fit: 0.2, sprite: 0.76, rotates: true, color: Color(0xFFFFD54F)),
  onion('Onion', r: 0.19, h: 0.32, sprite: 0.5, color: Color(0xFF8E24AA)),
  broccoli('Broccoli', r: 0.24, h: 0.36, sprite: 0.6, color: Color(0xFF388E3C)),
  cabbage('Cabbage', r: 0.38, h: 0.56, sprite: 0.92, color: Color(0xFF9CCC65)),
  pumpkin('Pumpkin', r: 0.48, h: 0.66, sprite: 1.12, color: Color(0xFFF57C00)),

  // Sweets
  donut('Donut', r: 0.25, h: 0.12, sprite: 0.6, color: Color(0xFFF06292)),
  donutChoco('Chocolate donut', r: 0.25, h: 0.12, sprite: 0.6, color: Color(0xFF6D4C41)),
  macaronPink('Pink macaron', r: 0.17, h: 0.13, sprite: 0.42, color: Color(0xFFF48FB1)),
  macaronYellow('Yellow macaron', r: 0.17, h: 0.13, sprite: 0.42, color: Color(0xFFFFEE58)),
  macaronBlue('Blue macaron', r: 0.17, h: 0.13, sprite: 0.42, color: Color(0xFF4FC3F7)),
  macaronGreen('Green macaron', r: 0.17, h: 0.13, sprite: 0.42, color: Color(0xFF9CCC65)),
  macaronPurple('Purple macaron', r: 0.17, h: 0.13, sprite: 0.42, color: Color(0xFFBA68C8)),
  cookie('Cookie', r: 0.19, h: 0.05, sprite: 0.46, color: Color(0xFFBF8040)),
  waffle('Waffle', r: 0.25, h: 0.06, sprite: 0.58, color: Color(0xFFFFB74D)),
  cupcake('Cupcake', r: 0.2, h: 0.4, sprite: 0.56, color: Color(0xFFF8BBD0)),
  pancakes('Pancakes', r: 0.26, h: 0.24, sprite: 0.62, color: Color(0xFFE0A050)),
  cocoaMug('Cocoa mug', r: 0.2, h: 0.3, sprite: 0.56, color: Color(0xFFE64A19)),
  milkshake('Milkshake', r: 0.2, h: 0.55, sprite: 0.72, color: Color(0xFFF8BBD0)),
  pie('Pie', r: 0.5, h: 0.18, sprite: 1.16, color: Color(0xFFFFB74D)),
  cake('Cake', r: 0.6, h: 1.1, sprite: 1.46, color: Color(0xFFF48FB1)),

  // Sushi
  maki('Maki', r: 0.16, h: 0.16, sprite: 0.42, color: Color(0xFF263238)),
  makiCucumber('Cucumber maki', r: 0.16, h: 0.16, sprite: 0.42, color: Color(0xFF66BB6A)),
  nigiriSalmon('Salmon nigiri', r: 0.24, h: 0.14, fit: 0.17, sprite: 0.6, rotates: true, color: Color(0xFFFF7043)),
  nigiriTamago('Tamago nigiri', r: 0.24, h: 0.14, fit: 0.17, sprite: 0.6, rotates: true, color: Color(0xFFFFCA28)),
  shrimp('Shrimp', r: 0.3, h: 0.14, fit: 0.2, sprite: 0.72, rotates: true, color: Color(0xFFFF8A65)),
  wasabi('Wasabi', r: 0.2, h: 0.26, sprite: 0.52, color: Color(0xFF7CB342)),
  onigiri('Onigiri', r: 0.3, h: 0.3, sprite: 0.72, color: Color(0xFFF5F5F5)),
  soyDish('Soy dish', r: 0.42, h: 0.08, sprite: 0.98, color: Color(0xFF4E342E)),

  // Toys
  carRed('Red car', r: 0.32, h: 0.26, fit: 0.26, sprite: 0.78, rotates: true, color: Color(0xFFE53935)),
  carBlue('Blue car', r: 0.32, h: 0.26, fit: 0.26, sprite: 0.78, rotates: true, color: Color(0xFF1E88E5)),
  carYellow('Yellow car', r: 0.32, h: 0.26, fit: 0.26, sprite: 0.78, rotates: true, color: Color(0xFFFDD835)),
  duck('Duck', r: 0.2, h: 0.32, sprite: 0.52, color: Color(0xFFFFEB3B)),
  ball('Ball', r: 0.22, h: 0.44, sprite: 0.56, color: Color(0xFF29B6F6)),
  blockRed('Red block', r: 0.17, h: 0.3, sprite: 0.5, color: Color(0xFFE53935)),
  blockBlue('Blue block', r: 0.17, h: 0.3, sprite: 0.5, color: Color(0xFF1E88E5)),
  blockGreen('Green block', r: 0.17, h: 0.3, sprite: 0.5, color: Color(0xFF43A047)),
  blockYellow('Yellow block', r: 0.17, h: 0.3, sprite: 0.5, color: Color(0xFFFDD835)),
  teddy('Teddy bear', r: 0.3, h: 0.5, sprite: 0.82, color: Color(0xFF8D6E63));

  const ItemKind(
    this.label, {
    required this.r,
    required this.h,
    double? fit,
    required this.sprite,
    this.rotates = false,
    required this.color,
  }) : fit = fit ?? r;

  final String label;
  final double r;
  final double h;
  final double fit;
  final double sprite;
  final bool rotates;
  final Color color;

  /// Growth the hole gets for swallowing one.
  double get xp => fit * fit * 100;
}
