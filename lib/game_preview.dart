import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:storytailor/game_objects/credits_stage.dart';
import 'package:storytailor/game_objects/project.dart';

import 'game_objects/story_dialog.dart';

class GamePreview extends FlameGame
    with HasKeyboardHandlerComponents, LongPressDetector {
  late final RouterComponent router;
  static const String devtools = "devtools";
  String stage;
  Project project;

  GamePreview(this.project, this.stage);

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
    add(
      router = RouterComponent(
        initialRoute: stage,
        routes: {
          "mainMenu": Route(Component.new),
          "story": Route(() => StoryDialog(project.story).createComponent()),
          "credits": Route(
            () => CreditsStage(project).createComponent(),
            maintainState: false,
          ),
        },
      ),
    );
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    overlays.isActive(devtools)
        ? overlays.remove(devtools)
        : overlays.add(devtools);
  }

  void closeOverlay(String overlayName) => overlays.remove(overlayName);
}
