import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'game_object.dart';

enum ImageType {
  normal,
  spritesheet
}

class SpriteMetadata {
  String pathToImage;
  ImageType imageType = ImageType.normal;
  bool animation = false;
  double animStepTime = 0.5;

  SpriteMetadata(this.pathToImage);
}

class SpriteObject extends GameObject {
  SpriteMetadata metadata;

  SpriteObject({ super.name = "New Sprite", super.children = const [], required this.metadata });

  @override
  Component createComponent() => _SpriteComponent(metadata);
}

class _SpriteComponent extends Component {
  Sprite? sprite;
  SpriteMetadata metadata;
  bool isCached = false;

  _SpriteComponent(this.metadata);

  @override
  FutureOr<void> onLoad() async {
    if (!isCached) {
      sprite = Sprite(await Flame.images.load(metadata.pathToImage));
    } else {
      sprite = Sprite(Flame.images.fromCache(metadata.pathToImage));
    }
  }

  @override
  void render(Canvas canvas) {
    sprite?.render(canvas);
  }
}
