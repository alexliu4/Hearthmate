import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hearthmate/game/components/hearth_object.dart';

class HearthGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final background = _CabinBackgroundLayer();
    await add(background);

    final double u = (min(size.x, size.y) / 95).clamp(3.2, 6.2);
    final double floorTop = (size.y * 0.45 / u).roundToDouble() * u;
    final double tableX = ((size.x - 28 * u) / u).roundToDouble() * u;
    final double tableY = ((floorTop + 10 * u) / u).roundToDouble() * u;

    await add(
      HearthObject(
        position: Vector2(tableX + 8 * u, tableY - 2 * u),
        u: u,
      ),
    );
  }
}

class _CabinBackgroundLayer extends Component with HasGameReference<HearthGame> {
  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final Size size = game.size.toSize();
    final double u = (min(size.width, size.height) / 95).clamp(3.2, 6.2);
    final double floorTop = _snap(size.height * 0.45, u);

    _drawRect(canvas, 0, 0, size.width, size.height, const Color(0xFF4D2F1E), u);
    _drawRect(canvas, 0, floorTop, size.width, size.height - floorTop, const Color(0xFF382215), u);

    _drawWallBoards(canvas, size, floorTop, u);
    _drawCenterBrickChimney(canvas, size, floorTop, u);
    _drawFrames(canvas, size, u);
    final Rect fireplace = _drawFireplace(canvas, size, floorTop, u);
    _drawRugs(canvas, size, floorTop, u);
    _drawTable(canvas, size, floorTop, u);

    _drawMinerSprite(canvas, size, floorTop, u);
    _drawFireAndSparks(canvas, fireplace, u);
  }

  void _drawWallBoards(Canvas canvas, Size size, double floorTop, double u) {
    final Paint plank = Paint()..color = const Color(0xFF633C27);
    final Paint seam = Paint()..color = const Color(0xFF4C2E1D);
    final double boardW = _snap(size.width * 0.13, u);
    double x = 0;
    while (x < size.width) {
      canvas.drawRect(Rect.fromLTWH(_snap(x, u), 0, boardW, floorTop), plank);
      canvas.drawRect(Rect.fromLTWH(_snap(x + boardW - u, u), 0, u, floorTop), seam);
      x += boardW;
    }
  }

  void _drawCenterBrickChimney(Canvas canvas, Size size, double floorTop, double u) {
    final double chimneyW = _snap(size.width * 0.35, u);
    final double chimneyX = _snap((size.width - chimneyW) / 2, u);
    final Paint brick = Paint()..color = const Color(0xFF6A4A34);
    final Paint mortar = Paint()..color = const Color(0xFF4E3527);

    canvas.drawRect(Rect.fromLTWH(chimneyX, 0, chimneyW, floorTop - (8 * u)), brick);
    for (double y = 3 * u; y < floorTop - (8 * u); y += 4 * u) {
      canvas.drawRect(Rect.fromLTWH(chimneyX, _snap(y, u), chimneyW, u), mortar);
      final double offset = (((y / (4 * u)).floor() % 2) == 0) ? 0 : (2 * u);
      for (double x = chimneyX + offset; x < chimneyX + chimneyW; x += 6 * u) {
        canvas.drawRect(Rect.fromLTWH(_snap(x, u), _snap(y, u), u, 4 * u), mortar);
      }
    }
  }

  void _drawFrames(Canvas canvas, Size size, double u) {
    final Paint frame = Paint()..color = const Color(0xFF3B2317);
    final Paint mat = Paint()..color = const Color(0xFF8C6B4B);
    final Paint art = Paint()..color = const Color(0xFF647B5F);

    final Rect left = Rect.fromLTWH(_snap(7 * u, u), _snap(26 * u, u), _snap(12 * u, u), _snap(11 * u, u));
    final Rect right = Rect.fromLTWH(
      _snap(size.width - 21 * u, u),
      _snap(24 * u, u),
      _snap(14 * u, u),
      _snap(12 * u, u),
    );

    canvas.drawRect(left, frame);
    canvas.drawRect(left.deflate(1.2 * u), mat);
    canvas.drawRect(left.deflate(2.4 * u), art);

    canvas.drawRect(right, frame);
    canvas.drawRect(right.deflate(1.2 * u), mat);
    final Rect artArea = right.deflate(2.4 * u);
    canvas.drawRect(artArea, Paint()..color = const Color(0xFF5E7B68));
    _drawRect(canvas, artArea.left + u, artArea.top + 2 * u, 3 * u, 3 * u, const Color(0xFF3D9DD8), u);
    _drawRect(canvas, artArea.left + 5 * u, artArea.top + 4 * u, 6 * u, 2 * u, const Color(0xFF9B5F37), u);
  }


  Rect _drawFireplace(Canvas canvas, Size size, double floorTop, double u) {
    final double w = _snap(size.width * 0.42, u);
    final double h = _snap(size.height * 0.23, u);
    final double x = _snap((size.width - w) / 2, u);
    final double y = _snap(floorTop - h - 2 * u, u);

    _drawRect(canvas, x, y, w, h, const Color(0xFF98724D), u);
    _drawRect(canvas, x + u, y + u, w - 2 * u, h - 2 * u, const Color(0xFFA17A52), u);
    _drawRect(canvas, x - u, y - 2 * u, w + 2 * u, 2 * u, const Color(0xFF7F5535), u);
    _drawRect(canvas, x + 4 * u, y + 4 * u, w - 8 * u, h - 5 * u, const Color(0xFF2A1A13), u);
    return Rect.fromLTWH(x, y, w, h);
  }

  void _drawRugs(Canvas canvas, Size size, double floorTop, double u) {
    final Paint rug = Paint()..color = const Color(0xFF933B33);
    final Paint edge = Paint()..color = const Color(0xFFBC5A4D);
    final RRect left = RRect.fromRectAndRadius(
      Rect.fromLTWH(_snap(2 * u, u), _snap(floorTop + 6 * u, u), _snap(24 * u, u), _snap(11 * u, u)),
      Radius.circular(6 * u),
    );
    final RRect right = RRect.fromRectAndRadius(
      Rect.fromLTWH(_snap(size.width - 30 * u, u), _snap(floorTop + 6 * u, u), _snap(26 * u, u), _snap(12 * u, u)),
      Radius.circular(6 * u),
    );
    canvas.drawRRect(left, rug);
    canvas.drawRRect(right, rug);
    canvas.drawRRect(left.deflate(u), edge..color = const Color(0xFF8A312B));
    canvas.drawRRect(right.deflate(u), edge..color = const Color(0xFF8A312B));
  }

  void _drawTable(Canvas canvas, Size size, double floorTop, double u) {
    final double tableX = _snap(size.width - 28 * u, u);
    final double tableY = _snap(floorTop + 10 * u, u);

    _drawRect(canvas, tableX, tableY, 16 * u, 4 * u, const Color(0xFF6F442A), u);
    _drawRect(canvas, tableX + 2 * u, tableY + 4 * u, 2 * u, 2 * u, const Color(0xFF4B2D1D), u);
    _drawRect(canvas, tableX + 12 * u, tableY + 4 * u, 2 * u, 2 * u, const Color(0xFF4B2D1D), u);
  }

  void _drawMinerSprite(Canvas canvas, Size size, double floorTop, double u) {
    final double breathe = sin(_time * 1.5) * 0.15;
    final double x = _snap(size.width - 18 * u, u);
    final double y = _snap(floorTop + 4 * u, u);

    final double pu = u * 0.5; // Smaller "pixel" unit for more detail

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x + 4*u, y + 10*u), width: 12*u, height: 3*u),
      Paint()..color = Colors.black.withValues(alpha: 0.2)
    );

    canvas.save();
    canvas.translate(x, y);
    // Breath effect: slight vertical stretch
    canvas.translate(0, -breathe * u);
    canvas.scale(1.0, 1.0 + breathe * 0.05);

    // Miner Body (Overalls)
    _drawRect(canvas, 0, 8*pu, 16*pu, 12*pu, const Color(0xFF3567A7), pu); // Main pants
    _drawRect(canvas, 2*pu, 6*pu, 12*pu, 4*pu, const Color(0xFF3567A7), pu); // Bib
    _drawRect(canvas, 1*pu, 5*pu, 2*pu, 4*pu, const Color(0xFF2A4D80), pu); // Strap L
    _drawRect(canvas, 13*pu, 5*pu, 2*pu, 4*pu, const Color(0xFF2A4D80), pu); // Strap R

    // Shirt (Yellow)
    _drawRect(canvas, 3*pu, 7*pu, 10*pu, 3*pu, const Color(0xFFF3BC43), pu);
    _drawRect(canvas, -2*pu, 9*pu, 4*pu, 4*pu, const Color(0xFFF3BC43), pu); // Left shoulder
    _drawRect(canvas, 14*pu, 9*pu, 4*pu, 4*pu, const Color(0xFFF3BC43), pu); // Right shoulder

    // Head
    _drawRect(canvas, 2*pu, -2*pu, 12*pu, 10*pu, const Color(0xFFF2BE96), pu); // Face
    _drawRect(canvas, 1*pu, 1*pu, 2*pu, 5*pu, const Color(0xFF2B1A17), pu); // Sideburn L
    _drawRect(canvas, 13*pu, 1*pu, 2*pu, 5*pu, const Color(0xFF2B1A17), pu); // Sideburn R

    // Eyes
    _drawRect(canvas, 5*pu, 4*pu, 2*pu, 2*pu, const Color(0xFF2A1A14), pu);
    _drawRect(canvas, 10*pu, 4*pu, 2*pu, 2*pu, const Color(0xFF2A1A14), pu);

    // Helmet
    _drawRect(canvas, 1*pu, -5*pu, 14*pu, 4*pu, const Color(0xFFE49428), pu); // Base
    _drawRect(canvas, 3*pu, -8*pu, 10*pu, 3*pu, const Color(0xFFE49428), pu); // Top
    _drawRect(canvas, 0, -3*pu, 16*pu, 2*pu, const Color(0xFFBC7A21), pu); // Brim

    // Headlamp
    final double lampFlicker = (sin(_time * 15) + 1.0) * 0.5;
    _drawRect(canvas, 6*pu, -7*pu, 4*pu, 3*pu, const Color(0xFF4D4D4D), pu);
    _drawRect(canvas, 7*pu, -6*pu, 2*pu, 2*pu, const Color(0xFFFFEE9A), pu);

    // Lamp Glow
    canvas.drawCircle(
      Offset(8*pu, -5*pu),
      (3 + lampFlicker) * pu,
      Paint()..color = const Color(0xFFFFF6D1).withValues(alpha: 0.3 + lampFlicker * 0.2)
    );

    // Hands
    _drawRect(canvas, -2*pu, 13*pu, 4*pu, 3*pu, const Color(0xFFF2BE96), pu);
    _drawRect(canvas, 14*pu, 13*pu, 4*pu, 3*pu, const Color(0xFFF2BE96), pu);

    // Pickaxe (resting)
    _drawRect(canvas, -6*pu, 12*pu, 6*pu, 2*pu, const Color(0xFF7A7A7A), pu); // Left blade
    _drawRect(canvas, -1*pu, 8*pu, 2*pu, 12*pu, const Color(0xFF6E4228), pu); // Handle

    canvas.restore();
  }

  void _drawFireAndSparks(Canvas canvas, Rect fireplace, double u) {
    final double centerX = fireplace.left + fireplace.width / 2;
    final double baseY = fireplace.bottom - 5 * u;

    // Logs
    _drawRect(canvas, centerX - 4 * u, baseY - u, 3 * u, 1.5 * u, const Color(0xFF5D3A26), u);
    _drawRect(canvas, centerX + u, baseY - u, 3 * u, 1.5 * u, const Color(0xFF5D3A26), u);
    _drawRect(canvas, centerX - 1.5 * u, baseY - 2 * u, 3 * u, 1.5 * u, const Color(0xFF7B4A2A), u);

    final double t = _time * 4.0;

    // Multi-layered flames for fluid look
    for (int i = 0; i < 3; i++) {
      final double layerT = t + i * 1.5;
      final double wobble = sin(layerT) * 0.5 * u;
      final double heightScale = 1.0 + sin(layerT * 0.7) * 0.2;

      final Color flameColor = i == 0
          ? const Color(0xFFFF4D00)
          : (i == 1 ? const Color(0xFFFF9F2A) : const Color(0xFFFFD68B));
      final double flameW = (6 - i * 1.5) * u;
      final double flameH = (8 - i * 2) * u * heightScale;

      canvas.drawPath(
        Path()
          ..moveTo(centerX - flameW / 2 + wobble, baseY - 1.5 * u)
          ..quadraticBezierTo(centerX + wobble * 2, baseY - 1.5 * u - flameH, centerX + flameW / 2 + wobble, baseY - 1.5 * u)
          ..close(),
        Paint()..color = flameColor.withValues(alpha: 0.8),
      );
    }

    // Dynamic Glow
    final double flicker = (sin(_time * 10) + sin(_time * 17)) * 0.05;
    canvas.drawCircle(
      Offset(centerX, baseY - 3 * u),
      (12 + flicker * 20) * u,
      Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * u)
            ..color = const Color(0xFFFF7700).withValues(alpha: 0.2 + flicker),
    );

    // Sparks
    for (int i = 0; i < 12; i++) {
      final double seed = i * 13.5;
      final double life = (_time * 1.2 + seed) % 4.0;
      final double progress = life / 4.0;

      final double x = centerX + sin(life * 2.0 + seed) * 8 * u;
      final double y = baseY - 2 * u - (progress * 25 * u);
      final double size = (1.0 - progress) * u * 0.6;
      final double alpha = (1.0 - progress).clamp(0.0, 1.0);

      if (progress < 0.8) {
        _drawRect(canvas, x, y, size, size, const Color(0xFFFFD68B).withValues(alpha: alpha), u);
      }
    }
  }

  void _drawRect(Canvas canvas, double x, double y, double w, double h, Color color, double u) {
    canvas.drawRect(
      Rect.fromLTWH(_snap(x, u), _snap(y, u), _snap(w, u), _snap(h, u)),
      Paint()..color = color,
    );
  }

  double _snap(double value, double u) {
    return (value / u).roundToDouble() * u;
  }
}
