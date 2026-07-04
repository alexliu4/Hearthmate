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
    final double bob = sin(_time * 2.0) * (u * 0.6);
    final double pu = u * 0.4;

    canvas.save();
    canvas.translate(position.x, position.y + bob);

    // Rainbow Sphere (Gem)
    final double radius = 5 * pu;
    final Rect gemRect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Draw slices of colors for rainbow effect
    final List<Color> rainbow = [
      const Color(0xFFFF5252),
      const Color(0xFFFFD740),
      const Color(0xFF69F0AE),
      const Color(0xFF40C4FF),
      const Color(0xFF7C4DFF),
    ];

    for (int i = 0; i < rainbow.length; i++) {
      final double startAngle = (i / rainbow.length) * 2 * pi;
      final double sweepAngle = (1 / rainbow.length) * 2 * pi;
      canvas.drawArc(
        gemRect,
        startAngle,
        sweepAngle,
        true,
        Paint()..color = rainbow[i]
      );
    }

    // Highlight
    canvas.drawCircle(
      Offset(-radius * 0.4, -radius * 0.4),
      radius * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.6)
    );

    // Shadow on ground
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 10 * pu - bob), width: 8 * pu, height: 3 * pu),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    // Magical Glow
    canvas.drawCircle(
      Offset.zero,
      radius * 2.5,
      Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * pu)
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.2 + (sin(_time * 3) + 1) * 0.1),
    );

    // Sparks/Particles
    for (int i = 0; i < 4; i++) {
      final double angle = _time * 2 + (i * pi / 2);
      final double dist = radius * 1.5 + sin(_time * 4 + i) * pu;
      final double px = cos(angle) * dist;
      final double py = sin(angle) * dist;
      canvas.drawRect(
        Rect.fromLTWH(px, py, pu, pu),
        Paint()..color = Colors.white.withValues(alpha: 0.7)
      );
    }

    canvas.restore();
  }
}
