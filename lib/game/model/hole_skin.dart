import 'dart:ui';

/// How the hole's rim looks. Bought with coins in the shop.
class HoleSkin {
  const HoleSkin({
    required this.id,
    required this.name,
    required this.rim,
    required this.rimShade,
    required this.accent,
    required this.price,
  });

  final String id;
  final String name;

  /// Top of the rim, and its outer edge / inner bevel.
  final Color rim;
  final Color rimShade;

  /// Growth ring on the rim.
  final Color accent;
  final int price;

  static const classic = HoleSkin(
    id: 'classic',
    name: 'Classic',
    rim: Color(0xFFF7F7FA),
    rimShade: Color(0xFFC9CAD6),
    accent: Color(0xFF4CD964),
    price: 0,
  );

  static const all = [
    classic,
    HoleSkin(
      id: 'gold',
      name: 'Gold',
      rim: Color(0xFFFFD54F),
      rimShade: Color(0xFFD49B12),
      accent: Color(0xFFFFFFFF),
      price: 300,
    ),
    HoleSkin(
      id: 'candy',
      name: 'Candy',
      rim: Color(0xFFFF8FC8),
      rimShade: Color(0xFFD9529A),
      accent: Color(0xFFFFFFFF),
      price: 400,
    ),
    HoleSkin(
      id: 'neon',
      name: 'Neon',
      rim: Color(0xFF55F0FF),
      rimShade: Color(0xFF1597C9),
      accent: Color(0xFFFFF176),
      price: 500,
    ),
    HoleSkin(
      id: 'lime',
      name: 'Lime',
      rim: Color(0xFFB4F25C),
      rimShade: Color(0xFF6FB51F),
      accent: Color(0xFFFFFFFF),
      price: 600,
    ),
    HoleSkin(
      id: 'galaxy',
      name: 'Galaxy',
      rim: Color(0xFF9E7BFF),
      rimShade: Color(0xFF5B34C9),
      accent: Color(0xFFFF80AB),
      price: 900,
    ),
  ];

  static HoleSkin byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => classic);
}
