import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HearthGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await add(_CabinBackgroundLayer());
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
    final double u = (size.shortestSide / 95).clamp(3.2, 6.2);
    final double floorTop = _snap(size.height * 0.70, u);

    _drawRect(canvas, 0, 0, size.width, size.height, const Color(0xFF4D2F1E), u);
    _drawRect(canvas, 0, floorTop, size.width, size.height - floorTop, const Color(0xFF382215), u);

    _drawWallBoards(canvas, size, floorTop, u);
    _drawCenterBrickChimney(canvas, size, floorTop, u);
    _drawFrames(canvas, size, u);
    _drawCoinShelf(canvas, size, floorTop, u);
    final Rect fireplace = _drawFireplace(canvas, size, floorTop, u);
    _drawRugs(canvas, size, floorTop, u);
    _drawTableAndCrystal(canvas, size, floorTop, u);
    _drawMinerSprite(canvas, size, floorTop, u);
    _drawGearOrb(canvas, size, u);
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

  void _drawCoinShelf(Canvas canvas, Size size, double floorTop, double u) {
    final double shelfY = _snap(floorTop - 13 * u, u);
    _drawRect(canvas, 4 * u, shelfY, 15 * u, 3 * u, const Color(0xFF6E4228), u);
    _drawRect(canvas, 5 * u, shelfY + 3 * u, 2 * u, 2 * u, const Color(0xFF3A2418), u);
    _drawRect(canvas, 16 * u, shelfY + 3 * u, 2 * u, 2 * u, const Color(0xFF3A2418), u);

    final Paint coin = Paint()..color = const Color(0xFFF3BC43);
    final Paint coinDark = Paint()..color = const Color(0xFFD19325);
    for (int i = 0; i < 4; i++) {
      final double x = _snap((6 + i) * u, u);
      final double y = _snap((shelfY - (i % 2 + 1) * u), u);
      canvas.drawRect(Rect.fromLTWH(x, y, 2 * u, u), coin);
      canvas.drawRect(Rect.fromLTWH(x, y + u, 2 * u, u), coinDark);
    }
    canvas.drawRect(Rect.fromLTWH(12 * u, shelfY - 2 * u, 2 * u, 2 * u), coin);
    canvas.drawRect(Rect.fromLTWH(13 * u, shelfY - 3 * u, 2 * u, 2 * u), coinDark);
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

  void _drawTableAndCrystal(Canvas canvas, Size size, double floorTop, double u) {
    final double tableX = _snap(size.width - 28 * u, u);
    final double tableY = _snap(floorTop + 10 * u, u);

    _drawRect(canvas, tableX, tableY, 16 * u, 4 * u, const Color(0xFF6F442A), u);
    _drawRect(canvas, tableX + 2 * u, tableY + 4 * u, 2 * u, 2 * u, const Color(0xFF4B2D1D), u);
    _drawRect(canvas, tableX + 12 * u, tableY + 4 * u, 2 * u, 2 * u, const Color(0xFF4B2D1D), u);

    final double crystalX = tableX + 8 * u;
    final double crystalY = tableY - 3 * u + sin(_time * 2.6) * (u * 0.3);
    _drawRect(canvas, crystalX - 3 * u, crystalY, 6 * u, 5 * u, const Color(0xFFFFD46E), u);
    _drawRect(canvas, crystalX - 2 * u, crystalY + u, 4 * u, 3 * u, const Color(0xFF73D5FF), u);
    _drawRect(canvas, crystalX - 2 * u, crystalY + 3 * u, 2 * u, 2 * u, const Color(0xFFFF7F7F), u);
    _drawRect(canvas, crystalX, crystalY + 3 * u, 2 * u, 2 * u, const Color(0xFF8B7BFF), u);
  }

  void _drawMinerSprite(Canvas canvas, Size size, double floorTop, double u) {
    final double bob = sin(_time * 2.0) * u * 0.4;
    final double x = _snap(size.width - 17 * u, u);
    final double y = _snap(floorTop + 6 * u + bob, u);

    _drawRect(canvas, x - 5 * u, y + 8 * u, 13 * u, 5 * u, const Color(0xFF2A2A2A), u);
    _drawRect(canvas, x - 2 * u, y + 9 * u, 9 * u, 4 * u, const Color(0xFF3567A7), u);

    _drawRect(canvas, x + u, y + 3 * u, 6 * u, 6 * u, const Color(0xFFF2BE96), u);
    _drawRect(canvas, x + u, y + 2 * u, 6 * u, 2 * u, const Color(0xFF2B1A17), u);
    _drawRect(canvas, x + 2 * u, y + 5 * u, u, u, const Color(0xFF2A1A14), u);
    _drawRect(canvas, x + 5 * u, y + 5 * u, u, u, const Color(0xFF2A1A14), u);

    _drawRect(canvas, x, y, 9 * u, 3 * u, const Color(0xFFE49428), u);
    _drawRect(canvas, x + u, y + u, 2 * u, 2 * u, const Color(0xFFFFEE9A), u);
    _drawRect(canvas, x + 2 * u, y - u, 7 * u, u, const Color(0xFF4D4D4D), u);

    _drawRect(canvas, x - 2 * u, y + 8 * u, 5 * u, 2 * u, const Color(0xFFE8A12F), u);
    _drawRect(canvas, x + 8 * u, y + 8 * u, 4 * u, 2 * u, const Color(0xFFE8A12F), u);
  }

  void _drawGearOrb(Canvas canvas, Size size, double u) {
    final double r = 4 * u;
    final Offset c = Offset(_snap(size.width - 9 * u, u), _snap(9 * u, u));
    final double pulse = 0.78 + sin(_time * 2.5) * 0.12;

    canvas.drawCircle(c, r * 1.8, Paint()..color = const Color(0xFFFFB144).withValues(alpha: 0.20 * pulse));
    canvas.drawCircle(c, r * 1.2, Paint()..color = const Color(0xFFFFA02E));
    canvas.drawCircle(c, r * 0.62, Paint()..color = const Color(0xFFFFDE9D));

    for (int i = 0; i < 8; i++) {
      final double a = (pi * 2 * i) / 8;
      final Offset p = Offset(c.dx + cos(a) * r * 0.9, c.dy + sin(a) * r * 0.9);
      canvas.drawRect(Rect.fromCenter(center: p, width: u * 0.8, height: u * 0.8), Paint()..color = const Color(0xFF8A5A2C));
    }
  }

  void _drawFireAndSparks(Canvas canvas, Rect fireplace, double u) {
    final double centerX = fireplace.left + fireplace.width / 2;
    final double baseY = fireplace.bottom - 5 * u;
    final double wobble = sin(_time * 12) * 0.8 * u;
    final double flicker = (sin(_time * 9) + sin(_time * 14) * 0.5) * 0.5;

    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX - 2 * u, baseY), width: 3 * u, height: u),
      Paint()..color = const Color(0xFF7B4A2A),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX + 2 * u, baseY), width: 3 * u, height: u),
      Paint()..color = const Color(0xFF7B4A2A),
    );

    _drawRect(canvas, centerX - 6 * u, baseY - 6 * u + wobble, 4 * u, 6 * u, const Color(0xFFFF9F2A), u);
    _drawRect(canvas, centerX - 2 * u, baseY - 8 * u - wobble * 0.6, 4 * u, 8 * u, const Color(0xFFFFB632), u);
    _drawRect(canvas, centerX + 2 * u, baseY - 7 * u + wobble * 0.5, 4 * u, 7 * u, const Color(0xFFFF9225), u);
    _drawRect(canvas, centerX - u, baseY - 6 * u, 2 * u, 4 * u, const Color(0xFFFFF1A0), u);

    final double glowAlpha = (0.17 + flicker * 0.10).clamp(0.10, 0.30);
    canvas.drawCircle(
      Offset(centerX, baseY - 3 * u),
      10 * u,
      Paint()..color = const Color(0xFFFFAA42).withValues(alpha: glowAlpha),
    );

    for (int i = 0; i < 16; i++) {
      final double s = _time * 1.6 + i * 0.47;
      final double x = centerX + sin(s * 1.9) * (6 * u) + (i.isEven ? 18 * u : 30 * u);
      final double y = baseY - (s % 6.5) * 2.3 * u;
      final double a = (0.5 - ((s % 1.0) * 0.35)).clamp(0.10, 0.6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: u * 0.7, height: u * 0.7),
        Paint()..color = const Color(0xFFFFD68B).withValues(alpha: a),
      );
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
