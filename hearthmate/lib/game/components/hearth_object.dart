import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../hearth_game.dart';

class HearthObject extends SpriteAnimationComponent with HasGameRef<HearthGame> {
  HearthObject({
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.loadSpriteSheet(
      'miner.png',
      32,
      32,
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.5,
      to: 4,
    );

    // Fix: Set filter quality on the component's paint
    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
  }
}

class FireObject extends SpriteAnimationComponent with HasGameRef<HearthGame> {
  FireObject({
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.loadSpriteSheet(
      'fire.png',
      32,
      32,
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.15,
      to: 4,
    );

    // Fix: Set filter quality on the component's paint
    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
  }
}

class CrystalObject extends SpriteComponent with HasGameRef<HearthGame> {
  CrystalObject({
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('crystal.png');
    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
  }
}
