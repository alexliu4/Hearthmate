import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:hearthmate/game/hearth_game.dart';

class HearthObject extends Component with HasGameReference<HearthGame> {
  HearthObject({required this.position, required this.u});

  final Vector2 position;
  final double u;
  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final double bob = sin(_time * 2.5) * (u * 0.4);
    final double pu = u * 0.5;

    canvas.save();
    canvas.translate(position.x, position.y + bob);

    // Simple procedural crystal for now
    final Path crystalPath = Path()
      ..moveTo(0, -4 * pu)
      ..lineTo(3 * pu, 0)
      ..lineTo(0, 4 * pu)
      ..lineTo(-3 * pu, 0)
      ..close();

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 8 * pu - bob), width: 6 * pu, height: 2 * pu),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Crystal layers
    canvas.drawPath(crystalPath, Paint()..color = const Color(0xFF73D5FF));
    canvas.drawPath(
      Path()
        ..moveTo(0, -4 * pu)
        ..lineTo(1.5 * pu, 0)
        ..lineTo(0, 4 * pu)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );

    // Glow
    canvas.drawCircle(
      Offset.zero,
      5 * pu,
      Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * pu)
        ..color = const Color(0xFF73D5FF).withValues(alpha: 0.3),
    );

    canvas.restore();
  }
}
