import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

import '../game_preview.dart';
import '../story_structure/story_manager.dart';
import 'game_object.dart';

class StoryDialog extends GameObject {
  @override
  get objectTypeId => "storyDialog";

  StoryManager story;
  double height;
  int offsetY;

  StoryDialog(this.story, {
    super.name = "New Story Dialog",
    super.children = const [],
    this.height = 200,
    this.offsetY = -100,
  });

  @override
  RectangleComponent createComponent() => _StoryDialogComponent(story, height: height, offsetY: offsetY);

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "children": children.map((e) => e.toMap()).toList(),
      "height": height,
      "offsetY": offsetY,
    };
  }
}

class _StoryDialogComponent extends RectangleComponent
    with HasGameReference<GamePreview>, TapCallbacks {
  final TextPaint textPaint = TextPaint(
    style: TextStyle(
      color: BasicPalette.black.color,
    ),
  );
  late final TextComponent storyText;
  @override
  double height;
  StoryManager story;
  int offsetY;

  _StoryDialogComponent(this.story, {this.height = 200, this.offsetY = -100})
      : super(position: Vector2(0, 100));

  @override
  FutureOr<void> onLoad() {
    size = Vector2(game.size.x, height);
    position = Vector2(0, game.size.y - height + offsetY);
    story.chapters[story.chapterIndex].loadFromFile();
    storyText = TextComponent(
      text: story.getCurrentDialog().text,
      textRenderer: textPaint,
      position: Vector2(50, 50),
    );
    add(storyText);
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    storyText.text = story.getNextDialog().text;
  }
}
