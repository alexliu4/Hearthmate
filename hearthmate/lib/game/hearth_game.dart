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
    _drawFloorPlanks(canvas, size, floorTop, u);

    _drawWallBoards(canvas, size, floorTop, u);
    _drawCenterBrickChimney(canvas, size, floorTop, u);
    _drawFrames(canvas, size, u);
    final Rect fireplace = _drawFireplace(canvas, size, floorTop, u);
    _drawRugs(canvas, size, floorTop, u);
    _drawShelvesAndTables(canvas, size, floorTop, u);

    _drawMinerSprite(canvas, size, floorTop, u);
    _drawFireAndSparks(canvas, fireplace, u);
    _drawDynamicLighting(canvas, size, floorTop, fireplace, u);
  }

  void _drawFloorPlanks(Canvas canvas, Size size, double floorTop, double u) {
    final double plankH = _snap(u * 3, u);
    final Random rand = Random(123);

    double y = floorTop;
    while (y < size.height) {
      final double currentY = _snap(y, u);
      // Plank base with subtle variation
      final Color plankColor = Color.lerp(const Color(0xFF321B0F), const Color(0xFF42281A), rand.nextDouble() * 0.3)!;
      _drawRect(canvas, 0, currentY, size.width, plankH, plankColor, u);

      // Plank top highlight (makes them look slightly raised)
      _drawRect(canvas, 0, currentY, size.width, u * 0.5, const Color(0xFF4E3527).withValues(alpha: 0.5), u);

      // Plank seam (darker)
      _drawRect(canvas, 0, currentY + plankH - u, size.width, u, const Color(0xFF1A1008), u);

      // Horizontal Wood grain lines
      for (int i = 0; i < 12; i++) {
        final double grainW = size.width * (0.1 + rand.nextDouble() * 0.3);
        final double grainX = rand.nextDouble() * (size.width - grainW);
        final double grainY = currentY + (rand.nextDouble() * (plankH - u));
        _drawRect(canvas, grainX, grainY, grainW, u * 0.5, const Color(0xFF1A1008).withValues(alpha: 0.2), u);
      }

      y += plankH;
    }
  }

  void _drawWallBoards(Canvas canvas, Size size, double floorTop, double u) {
    final double boardW = _snap(size.width * 0.12, u);
    final Random rand = Random(42);

    double x = 0;
    while (x < size.width) {
      final double currentX = _snap(x, u);
      // Main plank color
      _drawRect(canvas, currentX, 0, boardW, floorTop, const Color(0xFF5A3622), u);

      // Plank depth
      _drawRect(canvas, currentX, 0, u * 0.5, floorTop, const Color(0xFF6E432B), u); // Left highlight
      _drawRect(canvas, currentX + boardW - u, 0, u, floorTop, const Color(0xFF3D2518), u); // Right seam

      // Vertical Grain
      for (int i = 0; i < 6; i++) {
        final double gx = currentX + (rand.nextDouble() * (boardW - u));
        final double gh = floorTop * (0.2 + rand.nextDouble() * 0.5);
        final double gy = rand.nextDouble() * (floorTop - gh);
        _drawRect(canvas, gx, gy, u * 0.5, gh, const Color(0xFF3D2518).withValues(alpha: 0.15), u);
      }

      // Knots with rings
      if (rand.nextDouble() > 0.7) {
        final double kx = currentX + (rand.nextDouble() * (boardW - 3*u)).clamp(u, boardW - 4*u);
        final double ky = rand.nextDouble() * (floorTop - 3*u);
        _drawRect(canvas, kx, ky, 2*u, 2*u, const Color(0xFF2D1A10), u);
        _drawRect(canvas, kx-u, ky-u, 4*u, u*0.5, const Color(0xFF2D1A10).withValues(alpha: 0.1), u); // Ring
      }

      x += boardW;
    }
  }

  void _drawCenterBrickChimney(Canvas canvas, Size size, double floorTop, double u) {
    final double baseW = _snap(size.width * 0.38, u);
    final double topW = _snap(size.width * 0.28, u);
    final double chimneyX = _snap((size.width - baseW) / 2, u);
    final double chimneyH = floorTop - (10 * u);

    final Paint brickPaint = Paint()..color = const Color(0xFF6A4A34);
    final Paint mortarPaint = Paint()..color = const Color(0xFF4E3527);
    final Random rand = Random(99);

    // Tapered Chimney
    final Path chimneyPath = Path()
      ..moveTo(_snap(size.width / 2 - topW / 2, u), 0)
      ..lineTo(_snap(size.width / 2 + topW / 2, u), 0)
      ..lineTo(_snap(size.width / 2 + baseW / 2, u), chimneyH)
      ..lineTo(_snap(size.width / 2 - baseW / 2, u), chimneyH)
      ..close();
    canvas.drawPath(chimneyPath, brickPaint);

    // Bricks on chimney
    for (double y = 2 * u; y < chimneyH - 2 * u; y += 4 * u) {
      final double progress = y / chimneyH;
      final double currentW = topW + (baseW - topW) * progress;
      final double currentX = (size.width - currentW) / 2;

      // Horizontal mortar
      _drawRect(canvas, currentX, y, currentW, u, const Color(0xFF4E3527), u);

      // Vertical mortar (staggered)
      final double offset = (((y / (4 * u)).floor() % 2) == 0) ? 0 : (3 * u);
      for (double x = currentX + offset; x < currentX + currentW - u; x += 6 * u) {
        _drawRect(canvas, x, y, u, 4 * u, const Color(0xFF4E3527), u);
      }

      // Random brick variations
      if (rand.nextDouble() > 0.7) {
        final double bx = currentX + rand.nextDouble() * (currentW - 4 * u);
        _drawRect(canvas, bx, y + u, 3 * u, 2 * u, const Color(0xFF7A5A44), u);
      }
    }
  }

  void _drawFrames(Canvas canvas, Size size, double u) {
    final Paint framePaint = Paint()..color = const Color(0xFF3B2317);
    final Paint matPaint = Paint()..color = const Color(0xFF8C6B4B);

    // Left Frame (Landscape)
    final Rect left = Rect.fromLTWH(_snap(7 * u, u), _snap(16 * u, u), _snap(14 * u, u), _snap(12 * u, u));
    canvas.drawRect(left, framePaint);
    canvas.drawRect(left.deflate(u), matPaint);
    final Rect leftArt = left.deflate(2 * u);
    _drawRect(canvas, leftArt.left, leftArt.top, leftArt.width, leftArt.height, const Color(0xFF5E7B68), u);
    _drawRect(canvas, leftArt.left + 2*u, leftArt.top + 3*u, 4*u, 3*u, const Color(0xFF4A6347), u); // Tree silhouette

    // Right Frame (Map)
    final Rect right = Rect.fromLTWH(
      _snap(size.width - 24 * u, u),
      _snap(14 * u, u),
      _snap(18 * u, u),
      _snap(14 * u, u),
    );
    canvas.drawRect(right, framePaint);
    canvas.drawRect(right.deflate(u), matPaint);
    final Rect mapArea = right.deflate(2 * u);
    _drawRect(canvas, mapArea.left, mapArea.top, mapArea.width, mapArea.height, const Color(0xFFC4A484), u); // Parchment

    // Map details
    _drawRect(canvas, mapArea.left + 2*u, mapArea.top + 3*u, 3*u, 3*u, const Color(0xFF3D9DD8), u); // Blue crystal/water
    _drawRect(canvas, mapArea.left + 6*u, mapArea.top + 5*u, 8*u, 2*u, const Color(0xFF9B5F37), u); // Path
    _drawRect(canvas, mapArea.left + 12*u, mapArea.top + 2*u, 2*u, 2*u, const Color(0xFFD35400), u); // 'X' mark
  }


  Rect _drawFireplace(Canvas canvas, Size size, double floorTop, double u) {
    final double w = _snap(size.width * 0.48, u);
    final double h = _snap(size.height * 0.25, u);
    final double x = _snap((size.width - w) / 2, u);
    final double y = _snap(floorTop - h, u);

    // Main fireplace body (darker mortar)
    _drawRect(canvas, x, y, w, h, const Color(0xFF4E3527), u);

    // Stone pattern (Detailed stones)
    final Random rand = Random(77);
    for (int i = 0; i < 25; i++) {
      final double sx = x + rand.nextDouble() * (w - 6 * u);
      final double sy = y + rand.nextDouble() * (h - 5 * u);
      final double sw = (3 + rand.nextInt(4)) * u;
      final double sh = (2 + rand.nextInt(3)) * u;
      final Color stoneColor = Color.lerp(const Color(0xFF98724D), const Color(0xFF8A623D), rand.nextDouble())!;

      _drawRect(canvas, sx, sy, sw, sh, stoneColor, u);
      _drawRect(canvas, sx, sy, sw, u * 0.5, const Color(0xFFA67D55).withValues(alpha: 0.5), u); // Top highlight
      _drawRect(canvas, sx, sy, u * 0.5, sh, const Color(0xFFA67D55).withValues(alpha: 0.3), u); // Left highlight
    }

    // Mantel (Stronger wood presence)
    _drawRect(canvas, x - 2 * u, y - 3 * u, w + 4 * u, 4 * u, const Color(0xFF3E2723), u);
    _drawRect(canvas, x - 2 * u, y - 3 * u, w + 4 * u, u, const Color(0xFF5D4037), u); // Top edge

    // Firebox opening
    _drawRect(canvas, x + 5 * u, y + 5 * u, w - 10 * u, h - 5 * u, const Color(0xFF1A1008), u);

    // Arched/Gothic Opening frame
    _drawRect(canvas, x + 4 * u, y + 4 * u, w - 8 * u, u, const Color(0xFF2D1A10), u);
    _drawRect(canvas, x + 4 * u, y + 4 * u, u, h - 4 * u, const Color(0xFF2D1A10), u);
    _drawRect(canvas, x + w - 5 * u, y + 4 * u, u, h - 4 * u, const Color(0xFF2D1A10), u);

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

  void _drawShelvesAndTables(Canvas canvas, Size size, double floorTop, double u) {
    // Coin Shelf (Left)
    final double shelfX = _snap(4 * u, u);
    final double shelfY = _snap(floorTop + 8 * u, u);
    _drawRect(canvas, shelfX, shelfY, 10 * u, 2 * u, const Color(0xFF6F442A), u); // Shelf
    _drawRect(canvas, shelfX + u, shelfY - 4 * u, 3 * u, 4 * u, const Color(0xFFF1C40F), u); // Gold stack 1
    _drawRect(canvas, shelfX + 5 * u, shelfY - 2 * u, 2 * u, 2 * u, const Color(0xFFF39C12), u); // Gold stack 2

    // Round Table (Right)
    final double tableX = _snap(size.width - 28 * u, u);
    final double tableY = _snap(floorTop + 10 * u, u);

    // Circular top (approximated with rects for pixel look)
    _drawRect(canvas, tableX + 2*u, tableY, 12 * u, 3 * u, const Color(0xFF6F442A), u);
    _drawRect(canvas, tableX + 4*u, tableY - u, 8 * u, u, const Color(0xFF6F442A), u);

    // Table legs
    _drawRect(canvas, tableX + 4 * u, tableY + 3 * u, 2 * u, 3 * u, const Color(0xFF4B2D1D), u);
    _drawRect(canvas, tableX + 10 * u, tableY + 3 * u, 2 * u, 3 * u, const Color(0xFF4B2D1D), u);
  }

  void _drawMinerSprite(Canvas canvas, Size size, double floorTop, double u) {
    final double breathe = sin(_time * 1.2) * 0.12;
    final double x = _snap(size.width - 18 * u, u);
    final double y = _snap(floorTop + 4 * u, u);
    final double pu = u * 0.5;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x + 4*u, y + 10*u), width: 12*u, height: 3*u),
      Paint()..color = Colors.black.withValues(alpha: 0.3)
    );

    canvas.save();
    canvas.translate(x, y);

    // Breathe effect
    canvas.translate(0, -breathe * u);
    canvas.scale(1.0, 1.0 + breathe * 0.04);

    // Miner Body (Detailed Overalls)
    _drawRect(canvas, 0, 8*pu, 16*pu, 12*pu, const Color(0xFF2A5298), pu); // Dark Blue
    _drawRect(canvas, 2*pu, 6*pu, 12*pu, 4*pu, const Color(0xFF2A5298), pu); // Bib

    // Shirt (Yellow with shadow)
    _drawRect(canvas, 3*pu, 7*pu, 10*pu, 3*pu, const Color(0xFFF9A825), pu);
    _drawRect(canvas, -2*pu, 9*pu, 4*pu, 4*pu, const Color(0xFFF57F17), pu); // Arm shadow L
    _drawRect(canvas, 14*pu, 9*pu, 4*pu, 4*pu, const Color(0xFFF9A825), pu); // Arm R

    // Head with subtle Look-at-Fire tilt
    final double lookTilt = sin(_time * 0.5) * 0.05;
    canvas.save();
    canvas.translate(8*pu, 4*pu);
    canvas.rotate(lookTilt);
    canvas.translate(-8*pu, -4*pu);

    _drawRect(canvas, 2*pu, -2*pu, 12*pu, 10*pu, const Color(0xFFF5CBA7), pu); // Face

    // Eyes with blinking
    final bool isBlinking = (_time % 4.0) > 3.8;
    if (!isBlinking) {
      _drawRect(canvas, 5*pu, 4*pu, 2*pu, 2*pu, const Color(0xFF212121), pu);
      _drawRect(canvas, 10*pu, 4*pu, 2*pu, 2*pu, const Color(0xFF212121), pu);
    } else {
      _drawRect(canvas, 5*pu, 5*pu, 2*pu, pu, const Color(0xFF212121), pu);
      _drawRect(canvas, 10*pu, 5*pu, 2*pu, pu, const Color(0xFF212121), pu);
    }

    // Helmet
    _drawRect(canvas, 1*pu, -5*pu, 14*pu, 4*pu, const Color(0xFFF9A825), pu);
    _drawRect(canvas, 0, -3*pu, 16*pu, 2*pu, const Color(0xFFE65100), pu); // Brim

    // Headlamp
    final double lampFlicker = (sin(_time * 20) + 1.0) * 0.5;
    _drawRect(canvas, 6*pu, -7*pu, 4*pu, 3*pu, const Color(0xFF37474F), pu);
    _drawRect(canvas, 7*pu, -6*pu, 2*pu, 2*pu, const Color(0xFFFFF176), pu);
    canvas.drawCircle(Offset(8*pu, -5*pu), (3 + lampFlicker) * pu, Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.3 + lampFlicker * 0.2));

    canvas.restore(); // End Head Tilt

    // Hands & Pickaxe
    _drawRect(canvas, -3*pu, 13*pu, 5*pu, 4*pu, const Color(0xFFF5CBA7), pu);
    _drawRect(canvas, 14*pu, 13*pu, 5*pu, 4*pu, const Color(0xFFF5CBA7), pu);
    _drawRect(canvas, -7*pu, 12*pu, 7*pu, 2*pu, const Color(0xFF9E9E9E), pu); // Pickaxe head
    _drawRect(canvas, -2*pu, 8*pu, 2*pu, 14*pu, const Color(0xFF5D4037), pu); // Handle

    canvas.restore();
  }

  void _drawDynamicLighting(Canvas canvas, Size size, double floorTop, Rect fireplace, double u) {
    final double centerX = fireplace.left + fireplace.width / 2;
    final double flicker = sin(_time * 10) * 0.04 + sin(_time * 17) * 0.02;
    final double intensity = 0.35 + flicker;

    // 1. Ambient Darkening (Vignette & Corners)
    final Paint ambientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.2),
          Colors.black.withValues(alpha: 0.5),
        ],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ambientPaint);

    // 2. Fire glow on floor (Directional)
    final Paint floorGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF7700).withValues(alpha: intensity),
          const Color(0xFFFF7700).withValues(alpha: intensity * 0.5),
          const Color(0xFFFF7700).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, floorTop + 2 * u), radius: 35 * u));

    canvas.drawRect(Rect.fromLTWH(0, floorTop, size.width, size.height - floorTop), floorGlow);

    // 3. Fire glow on walls
    final Paint wallGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF7700).withValues(alpha: intensity * 0.7),
          const Color(0xFFFF7700).withValues(alpha: intensity * 0.3),
          const Color(0xFFFF7700).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, floorTop - 5 * u), radius: 45 * u));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, floorTop), wallGlow);

    // 4. Directional Shadows for objects
    _drawDirectionalShadow(canvas, Offset(centerX, floorTop), Offset(_snap(size.width - 18 * u, u) + 4 * u, floorTop + 10 * u), 10 * u, 4 * u, u); // Miner
    _drawDirectionalShadow(canvas, Offset(centerX, floorTop), Offset(_snap(size.width - 28 * u, u) + 8 * u, floorTop + 13 * u), 14 * u, 5 * u, u); // Table

    // 5. Corner Shadows (Ambient Occlusion)
    final Paint cornerPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawRect(Rect.fromLTWH(0, 0, 4 * u, size.height), cornerPaint); // Left corner
    canvas.drawRect(Rect.fromLTWH(size.width - 4 * u, 0, 4 * u, size.height), cornerPaint); // Right corner
  }

  void _drawDirectionalShadow(Canvas canvas, Offset lightSource, Offset objectPos, double width, double height, double u) {
    final double dx = objectPos.dx - lightSource.dx;
    final double distance = dx.abs();
    final double shadowStretch = (distance / (20 * u)).clamp(1.0, 2.5);
    final double shadowOffset = dx * 0.15;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(objectPos.dx + shadowOffset, objectPos.dy),
        width: width * shadowStretch,
        height: height
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.25)
    );
  }

  void _drawFireAndSparks(Canvas canvas, Rect fireplace, double u) {
    final double centerX = fireplace.left + fireplace.width / 2;
    final double baseY = fireplace.bottom - 4 * u;

    // Charred Logs with Glowing Embers
    final Paint logPaint = Paint()..color = const Color(0xFF211510);
    _drawRect(canvas, centerX - 5 * u, baseY - u, 4 * u, 2 * u, const Color(0xFF2D1A10), u);
    _drawRect(canvas, centerX + u, baseY - u, 4 * u, 2 * u, const Color(0xFF2D1A10), u);
    _drawRect(canvas, centerX - 2 * u, baseY - 2.5 * u, 4 * u, 2 * u, const Color(0xFF3E2723), u);

    // Glowing cracks in logs
    final double emberFlicker = (sin(_time * 8) + 1) * 0.5;
    _drawRect(canvas, centerX - 4 * u, baseY - 0.5 * u, 2 * u, 0.5 * u, const Color(0xFFFF3D00).withValues(alpha: 0.5 + 0.5 * emberFlicker), u);
    _drawRect(canvas, centerX + 2 * u, baseY - 0.5 * u, 2 * u, 0.5 * u, const Color(0xFFFF3D00).withValues(alpha: 0.5 + 0.5 * emberFlicker), u);

    final double t = _time * 5.0;

    // Multi-layered Fluid Flames (Increased size)
    for (int i = 0; i < 4; i++) {
      final double layerT = t + i * 1.2;
      final double wobble = sin(layerT) * 0.8 * u;
      final double heightScale = 1.1 + sin(layerT * 0.8) * 0.3;

      final Color flameColor = [
        const Color(0xFFE65100), // Deep orange
        const Color(0xFFFF9100), // Bright orange
        const Color(0xFFFFC400), // Yellow
        const Color(0xFFFFF8E1), // White-hot center
      ][i];

      final double flameW = (8 - i * 2) * u;
      final double flameH = (12 - i * 2.5) * u * heightScale;

      canvas.drawPath(
        Path()
          ..moveTo(centerX - flameW / 2 + wobble, baseY - 2 * u)
          ..quadraticBezierTo(centerX + wobble * 1.5, baseY - 2 * u - flameH, centerX + flameW / 2 + wobble, baseY - 2 * u)
          ..close(),
        Paint()..color = flameColor.withValues(alpha: 0.85 - i * 0.1),
      );
    }

    // Dynamic Atmospheric Glow (Heat Haze)
    final double flicker = (sin(_time * 12) + sin(_time * 19)) * 0.06;
    canvas.drawCircle(
      Offset(centerX, baseY - 5 * u),
      (15 + flicker * 25) * u,
      Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * u)
            ..color = const Color(0xFFFF6D00).withValues(alpha: 0.25 + flicker),
    );

    // High-Velocity Sparks
    for (int i = 0; i < 15; i++) {
      final double seed = i * 27.5;
      final double life = (_time * 1.5 + seed) % 3.0;
      final double progress = life / 3.0;

      final double x = centerX + sin(life * 3.0 + seed) * 10 * u;
      final double y = baseY - 2 * u - (progress * 35 * u);
      final double sz = (1.2 - progress) * u * 0.7;
      final double alpha = (1.0 - progress).clamp(0.0, 1.0);

      if (progress < 0.9) {
        _drawRect(canvas, x, y, sz, sz, const Color(0xFFFFD54F).withValues(alpha: alpha), u);
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
