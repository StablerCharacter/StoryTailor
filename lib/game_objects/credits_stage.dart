import 'dart:io';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:storytailor/game_objects/game_object.dart';
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/utils/stretch_mode.dart';
import 'package:storytailor/views/project_related/credits_config.dart';

class CreditsStage extends GameObject {
  @override
  get objectTypeId => "creditsScene";

  Project project;

  CreditsStage(this.project, {super.name = "Credits Scene"});

  @override
  Component createComponent() =>
      _CreditsStageComponent(CreditsConfigState.config, project);
}

class _CreditsStageComponent extends Component {
  CreditsConfig config;
  Sprite? background;
  Project project;
  Vector2 screenSize = Vector2.zero();
  Vector2 backgroundSize = Vector2.zero();
  late TextComponent headingText;
  late TextComponent bodyText;
  bool isOnLoadCalled = false;

  _CreditsStageComponent(this.config, this.project);

  @override
  Future<void> onLoad() async {
    if (config.stageBackground.isNotEmpty) {
      background = Sprite(
        await decodeImageFromList(
          await File(
                  "${project.projectDirectory.path}/assets/${config.stageBackground}")
              .readAsBytes(),
        ),
      );
    }
    headingText = TextComponent(
      text: config.sections[0].name,
      textRenderer: TextPaint(
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    bodyText = TextComponent(
      text: config.sections[0].content,
    );
    recalculateObjectPosition();
    isOnLoadCalled = true;

    add(headingText);
    add(bodyText);
  }

  void recalculateObjectPosition() {
    headingText.position = Vector2(
      screenSize.x / 2 - headingText.size.x / 2,
      screenSize.y / 2 - headingText.size.y / 2 - bodyText.size.y / 2 - 20,
    );
    bodyText.position = Vector2(
      screenSize.x / 2 - bodyText.size.x / 2,
      headingText.y + 20,
    );
    if (background != null) {
      backgroundSize = StretchModeImpl.calculate(
        config.backgroundStretch,
        screenSize,
        background!.originalSize,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    background?.render(canvas, size: backgroundSize);
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);

    screenSize = newSize;
    if (isOnLoadCalled) {
      recalculateObjectPosition();
    }
  }
}
