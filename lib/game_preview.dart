import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game_objects/story_dialog.dart';
import 'story_structure/story_manager.dart';

class GamePreview extends FlameGame
    with HasKeyboardHandlerComponents, LongPressDetector {
  static const String devtools = "devtools";
  StoryManager story;

  GamePreview(this.story);

  @override
  Future<void> onLoad() async {
    add(
      KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.f10: (_) {
            overlays.isActive(devtools)
                ? overlays.remove(devtools)
                : overlays.add(devtools);
            return true;
          },
          LogicalKeyboardKey.escape: (_) {
            if (buildContext == null) {
              return true;
            }
            Navigator.pop(buildContext!);
            return true;
          },
        },
      ),
    );
    add(StoryDialog(story).createComponent());
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    overlays.isActive(devtools)
        ? overlays.remove(devtools)
        : overlays.add(devtools);
  }

  void closeOverlay(String overlayName) => overlays.remove(overlayName);
}
