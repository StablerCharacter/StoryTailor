import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:storytailor/story_structure/chapter.dart';

import 'game_object.dart';

enum ImageType {
  normal,
  spritesheet;

  factory ImageType.fromValue(String value) {
    for (ImageType imageType in ImageType.values) {
      if (imageType.name == value) return imageType;
    }

    throw KeyNotFoundException("an image type of name $value is not defined.");
  }
}

class SpriteMetadata {
  String pathToImage;
  ImageType imageType = ImageType.normal;
  bool animation = false;
  double animStepTime = 0.5;

  SpriteMetadata(
    this.pathToImage, {
    this.imageType = ImageType.normal,
    this.animation = false,
    this.animStepTime = 0.5,
  });

  SpriteMetadata.fromMap(Map<String, dynamic> data)
      : pathToImage = data["pathToImage"],
        imageType = ImageType.fromValue(data["imageType"]),
        animation = data["animation"],
        animStepTime = data["animStepTime"];

  Map<String, dynamic> toMap() {
    return {
      "pathToImage": pathToImage,
      "imageType": imageType.name,
      "animation": animation,
      "animStepTime": animStepTime,
    };
  }
}

class SpriteObject extends GameObject {
  @override
  get objectTypeId => "sprite";

  SpriteMetadata metadata;

  SpriteObject(
      {super.name = "New Sprite",
      super.children = const [],
      required this.metadata});

  @override
  Component createComponent() => _SpriteComponent(metadata);

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "metadata": metadata.toMap(),
      "children": children.map((e) => e.toMap()).toList(),
    };
  }
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
