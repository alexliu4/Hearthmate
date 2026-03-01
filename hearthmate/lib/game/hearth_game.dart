import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/miner_sprite.dart';

class HearthGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await add(_BackgroundLayer());
    await add(MinerSprite());
  }
}

class _BackgroundLayer extends Component with HasGameReference<HearthGame> {
  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final Size size = game.size.toSize();
    final Rect area = Offset.zero & size;

    final Paint sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD180), Color(0xFFFF8A65)],
      ).createShader(area);
    canvas.drawRect(area, sky);

    final Paint sunPaint = Paint()..color = const Color(0xFFFFF59D);
    final double sunYOffset = sin(_time * 0.7) * 5;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22 + sunYOffset),
      34,
      sunPaint,
    );

    final Paint hillPaint = Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.95);
    final Path hill = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.24, size.height * 0.62, size.width * 0.53, size.height * 0.81)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.95, size.width, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, hillPaint);
  }
}
