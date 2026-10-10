import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/theme.dart';
import '../game/audio/sfx.dart';
import '../game/constants.dart';
import '../game/model/hole_skin.dart';
import 'widgets.dart';

void showSkinsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    builder: (context) => const _SkinsSheet(),
  );
}

class _SkinsSheet extends StatelessWidget {
  const _SkinsSheet();

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: AppColors.ink, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const OutlinedText('HOLE SKINS', size: 28, color: AppColors.pink),
                const Spacer(),
                CoinPill(coins: profile.coins),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final skin in HoleSkin.all)
                  _SkinTile(
                    skin: skin,
                    owned: profile.owned.contains(skin.id),
                    equipped: profile.skinId == skin.id,
                    affordable: profile.coins >= skin.price,
                    onTap: () {
                      final wasOwned = profile.owned.contains(skin.id);
                      if (profile.useSkin(skin) && !wasOwned) Sfx.coin();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.owned,
    required this.equipped,
    required this.affordable,
    required this.onTap,
  });

  final HoleSkin skin;
  final bool owned, equipped, affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: owned || affordable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: equipped ? const Color(0xFFDDF8E3) : AppColors.panelSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: equipped ? AppColors.greenDark : const Color(0xFFDCD5EE), width: 3),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(child: CustomPaint(size: Size.infinite, painter: _HolePreview(skin))),
            Text(skin.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            SizedBox(
              height: 24,
              child: equipped
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 24)
                  : owned
                  ? const Text('USE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.blue, fontSize: 16))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CoinIcon(size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${skin.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: affordable ? AppColors.ink : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The hole as seen in game, drawn flat for the shop.
class _HolePreview extends CustomPainter {
  _HolePreview(this.skin);

  final HoleSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.36;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(1, kGroundSquash);
    canvas.drawCircle(Offset.zero, r * 1.13, Paint()..color = skin.rimShade);
    canvas.drawCircle(
      Offset.zero,
      r * 1.1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(skin.rim, Colors.white, 0.5)!, skin.rim],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 1.055),
      -1.5708,
      4.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..strokeCap = StrokeCap.round
        ..color = skin.accent,
    );
    canvas.drawCircle(Offset.zero, r * 1.01, Paint()..color = skin.rimShade);
    canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFF3B3B4A));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)));
    canvas.drawCircle(Offset(0, r * 0.3), r * 1.02, Paint()..color = Colors.black);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HolePreview old) => old.skin != skin;
}
