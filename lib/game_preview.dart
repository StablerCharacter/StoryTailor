import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game_objects/story_dialog.dart';
import 'story_structure/story_manager.dart';

class GamePreview extends FlameGame
    with KeyboardEvents, LongPressDetector {
  static const String devtools = "devtools";
  StoryManager story;

  GamePreview(this.story);

  @override
  Future<void> onLoad() async {
    add(StoryDialog(story).createComponent());
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.f10) &&
        event is RawKeyDownEvent) {
      overlays.isActive(devtools)
          ? overlays.remove(devtools)
          : overlays.add(devtools);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    overlays.isActive(devtools)
        ? overlays.remove(devtools)
        : overlays.add(devtools);
  }

  void closeOverlay(String overlayName) => overlays.remove(overlayName);
}
