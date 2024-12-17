import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/game_objects/game_object.dart';
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/utils/assets_utility.dart';
import 'package:storytailor/utils/stretch_mode.dart';
import 'package:storytailor/views/project_related/credits_config.dart';

class CreditsStage extends GameObject {
  @override
  get objectTypeId => "creditsScene";

  Project project;

  CreditsStage(this.project, {super.name = "Credits Scene"});

  @override
  Component createComponent() {
    CreditsConfigState.tryLoad(File(
      p.join(
        project.projectDirectory.path,
        "stages",
        "credits.json",
      ),
    ));
    return _CreditsStageComponent(CreditsConfigState.config, project);
  }
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
  double lerpValue = 0;

  _CreditsStageComponent(this.config, this.project);

  @override
  Future<void> onLoad() async {
    if (config.stageBackground.isNotEmpty) {
      background = Sprite(
        await decodeImageFromList(
          await getAssetFromRelativePath(
            project,
            config.stageBackground,
          ).readAsBytes(),
        ),
      );
    }

    if (config.stageBackgroundMusic.isNotEmpty) {
      await FlameAudio.bgm.audioPlayer.release();
      await FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
      await FlameAudio.bgm.audioPlayer.setSourceDeviceFile(
          getAssetFromRelativePath(project, config.stageBackgroundMusic).path);
      FlameAudio.bgm.audioPlayer.resume();
      FlameAudio.bgm.isPlaying = true;
    }

    headingText = TextComponent(
      text: config.sections[0].name,
      textRenderer: TextPaint(
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
    bodyText = TextComponent(
      text: config.sections[0].content,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.black),
      ),
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
  void update(double dt) {
    if (lerpValue == 1.0) return;
    lerpValue += dt / config.animationDuration.inSeconds;
    lerpValue = min(lerpValue, 1.0);
    int alpha =
        lerpDouble(0, 255, config.animationCurve.transform(lerpValue))!.round();
    headingText.textRenderer = (headingText.textRenderer as TextPaint)
        .copyWith((ts) => ts.copyWith(color: ts.color?.withAlpha(alpha)));
    bodyText.textRenderer = (bodyText.textRenderer as TextPaint)
        .copyWith((ts) => ts.copyWith(color: ts.color?.withAlpha(alpha)));
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
