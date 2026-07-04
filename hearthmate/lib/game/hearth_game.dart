import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'components/hearth_object.dart';

class HearthGame extends FlameGame {
  late Sprite woodSprite;
  late Sprite brickSprite;
  late Sprite fireplaceSprite;

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A);

  Future<SpriteSheet> loadSpriteSheet(String path, int width, int height) async {
    final image = await images.load(path);
    return SpriteSheet(
      image: image,
      srcSize: Vector2(width.toDouble(), height.toDouble()),
    );
  }

  @override
  Future<void> onLoad() async {
    // Load static sprites
    woodSprite = await loadSprite('wood_tile.png');
    brickSprite = await loadSprite('brick_tile.png');
    fireplaceSprite = await loadSprite('fireplace_frame.png');

    final gameSize = size;
    final floorTop = gameSize.y * 0.45;

    // Background Bricks - Tiled manually
    for (double x = 0; x < gameSize.x; x += 64) {
      for (double y = 0; y < floorTop; y += 64) {
        add(SpriteComponent(
          sprite: brickSprite,
          position: Vector2(x, y),
          size: Vector2(64, 64),
          paint: Paint()..filterQuality = FilterQuality.none..isAntiAlias = false,
        ));
      }
    }

    // Floor Wood - Tiled manually
    for (double x = 0; x < gameSize.x; x += 64) {
      for (double y = floorTop; y < gameSize.y; y += 64) {
        add(SpriteComponent(
          sprite: woodSprite,
          position: Vector2(x, y),
          size: Vector2(64, 64),
          paint: Paint()..filterQuality = FilterQuality.none..isAntiAlias = false,
        ));
      }
    }

    // Fireplace Frame
    add(SpriteComponent(
      sprite: fireplaceSprite,
      position: Vector2(gameSize.x / 2, floorTop),
      size: Vector2(256, 256),
      anchor: Anchor.bottomCenter,
      paint: Paint()..filterQuality = FilterQuality.none..isAntiAlias = false,
    ));

    // Fire
    add(FireObject(
      position: Vector2(gameSize.x / 2, floorTop - 20),
      size: Vector2(80, 80),
    ));

    // Miner
    add(HearthObject(
      position: Vector2(gameSize.x * 0.75, floorTop + 60),
      size: Vector2(100, 100),
    ));

    // Add simple crystal
    add(CrystalObject(
      position: Vector2(gameSize.x * 0.25, floorTop + 30),
      size: Vector2(40, 40),
    ));
  }
}
