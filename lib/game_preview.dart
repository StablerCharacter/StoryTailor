import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_character/flame_character.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:path/path.dart' as p;
import 'package:storytailor/game_preview/project_asset_manager.dart';
import 'package:storytailor/project.dart';
import 'package:storytailor/views/project_related/credits_config.dart';

class GamePreview extends BasicGame
    with HasKeyboardHandlerComponents, LongPressDetector {
  @override
  late final RouterComponent router;
  static const String devtools = "devtools";
  String stage;
  Project project;

  GamePreview(this.project, this.stage);

  @override
  Future<void> onLoad() async {
    FlameAudio.bgm.initialize();
    GameConfig.assetManager = ProjectAssetManager(project);
    CreditsConfigState.tryLoad(
      File(p.join(project.projectDirectory.path, "stages", "credits.json")),
    );

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
            () => CreditsStage(CreditsConfigState.config).createComponent(),
            maintainState: false,
          ),
        },
      ),
    );
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop();
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    overlays.isActive(devtools)
        ? overlays.remove(devtools)
        : overlays.add(devtools);
  }

  void closeOverlay(String overlayName) => overlays.remove(overlayName);
}
