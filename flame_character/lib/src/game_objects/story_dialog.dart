import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart' show TextStyle;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../story_structure/story_manager.dart';
import 'game_object.dart';

class StoryDialog extends GameObject {
  @override
  get objectTypeId => "storyDialog";

  StoryManager story;
  double height;
  int offsetY;

  StoryDialog(
    this.story, {
    super.name = "New Story Dialog",
    super.children = const [],
    this.height = 200,
    this.offsetY = -100,
  });

  @override
  RectangleComponent createComponent() =>
      _StoryDialogComponent(story, height: height, offsetY: offsetY);

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
    with TapCallbacks, KeyboardHandler, HasGameRef {
  final TextPaint textPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );
  late final TextBoxComponent storyText;
  StoryManager story;
  int offsetY;
  Vector2 screenSize = Vector2.zero();

  _StoryDialogComponent(this.story, {double height = 200, this.offsetY = -100})
    : super(position: Vector2(0, 100)) {
    this.height = height;
  }

  void updateSizeAndPos() {
    size = Vector2(screenSize.x, height);
    position = Vector2(0, screenSize.y - height + offsetY);
    if (isLoaded) {
      storyText.size = Vector2(screenSize.x - 100, size.y - 100);
      storyText.boxConfig = storyText.boxConfig.copyWith(
        maxWidth: screenSize.x - 100,
      );
      storyText.redraw();
    }
  }

  @override
  FutureOr<void> onLoad() {
    String text = "The story has no dialogs.";
    if (story.chapters.isNotEmpty) {
      story.chapters[story.chapterIndex].loadFromFile();
      try {
        text = story.getCurrentDialog().text;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    storyText = TextBoxComponent(
      text: text,
      textRenderer: textPaint,
      position: Vector2(50, 50),
      size: game.size - Vector2(100, 50),
      boxConfig: TextBoxConfig(),
    );
    add(storyText);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    screenSize = newSize;
    updateSizeAndPos();
  }

  void nextDialog() {
    storyText.text = story.getNextDialog().text;
  }

  @override
  void onTapUp(TapUpEvent event) {
    nextDialog();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.enter)) {
      nextDialog();
    }
    return true;
  }
}
