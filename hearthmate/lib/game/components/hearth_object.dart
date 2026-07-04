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

    // Drawing a pixelated sphere with rects
    final double step = pu;
    for (double x = -radius; x < radius; x += step) {
      for (double y = -radius; y < radius; y += step) {
        if (x * x + y * y <= radius * radius) {
          final double angle = (atan2(y, x) + pi) / (2 * pi);
          final int colorIndex = (angle * rainbow.length).floor() % rainbow.length;
          canvas.drawRect(
            Rect.fromLTWH(x, y, step, step),
            Paint()..color = rainbow[colorIndex]..isAntiAlias = false,
          );
        }
      }
    }

    // Highlight (Rect based)
    canvas.drawRect(
      Rect.fromLTWH(-radius * 0.5, -radius * 0.5, 2 * pu, 2 * pu),
      Paint()..color = Colors.white.withValues(alpha: 0.6)..isAntiAlias = false,
    );

    // Shadow on ground (Rect based)
    canvas.drawRect(
      Rect.fromLTWH(-4 * pu, 9 * pu - bob, 8 * pu, 2 * pu),
      Paint()..color = Colors.black.withValues(alpha: 0.2)..isAntiAlias = false,
    );

    // Magical Glow (Rect based)
    final double glowRadius = radius * 2;
    for (double x = -glowRadius; x < glowRadius; x += step * 2) {
      for (double y = -glowRadius; y < glowRadius; y += step * 2) {
        if (x * x + y * y <= glowRadius * glowRadius) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, step * 2, step * 2),
            Paint()..color = Colors.white.withValues(alpha: 0.05 + (sin(_time * 3) + 1) * 0.05)..isAntiAlias = false,
          );
        }
      }
    }

    // Sparks/Particles
    for (int i = 0; i < 4; i++) {
      final double angle = _time * 2 + (i * pi / 2);
      final double dist = radius * 1.5 + sin(_time * 4 + i) * pu;
      final double px = (cos(angle) * dist / step).round() * step;
      final double py = (sin(angle) * dist / step).round() * step;
      canvas.drawRect(
        Rect.fromLTWH(px, py, step, step),
        Paint()..color = Colors.white.withValues(alpha: 0.7)..isAntiAlias = false,
      );
    }

    canvas.restore();
  }
}
