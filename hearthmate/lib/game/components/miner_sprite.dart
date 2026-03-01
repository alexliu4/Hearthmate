import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:hearthmate/game/hearth_game.dart';

class MinerSprite extends Component with HasGameReference<HearthGame> {
  final Paint _bodyPaint = Paint()..color = const Color(0xFFFFB74D);
  final Paint _helmetPaint = Paint()..color = const Color(0xFFFFCA28);
  final Paint _eyePaint = Paint()..color = Colors.black;
  final Paint _shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.2);

  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final Size scene = game.size.toSize();
    final double floorY = scene.height * 0.83;
    final double t = (sin(_time * 1.3) + 1) / 2;
    final double x = 50 + (scene.width - 100) * t;
    final double y = floorY - 24 - sin(_time * 6) * 3;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, floorY + 8), width: 42, height: 12),
      _shadowPaint,
    );

    canvas.drawCircle(Offset(x, y), 20, _bodyPaint);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y - 14), width: 28, height: 12),
      _helmetPaint,
    );
    canvas.drawCircle(Offset(x - 6, y - 2), 2, _eyePaint);
    canvas.drawCircle(Offset(x + 6, y - 2), 2, _eyePaint);
  }
}

