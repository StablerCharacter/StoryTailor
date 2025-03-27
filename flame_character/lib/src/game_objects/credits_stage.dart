import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flame/components.dart';
import 'package:flame_character/flame_character.dart';
import 'package:flutter/painting.dart';

class CreditsStage extends GameObject {
  @override
  get objectTypeId => "creditsScene";

  CreditsConfig config;

  CreditsStage(this.config, {super.name = "Credits Scene"});

  @override
  Component createComponent() {
    return _CreditsStageComponent(config);
  }
}

class _CreditsStageComponent extends Component
    with HasGameReference<BasicGame> {
  CreditsConfig config;
  Sprite? background;
  Vector2 screenSize = Vector2.zero();
  Vector2 backgroundSize = Vector2.zero();
  late TextComponent headingText;
  late TextComponent bodyText;
  double lerpValue = 0;
  double textDisplayedTime = 0;
  int creditSectionIndex = 0;
  int animationDuration = 1;
  bool fadeOut = false;

  _CreditsStageComponent(this.config);

  @override
  Future<void> onLoad() async {
    if (config.stageBackground.isNotEmpty) {
      background = Sprite(
        await GameConfig.assetManager.loadImage(config.stageBackground),
      );
    }

    if (config.stageBackgroundMusic.isNotEmpty) {
      await GameConfig.assetManager.playBgm(config.stageBackgroundMusic);
    }

    animationDuration = config.animationDuration.inSeconds;
    headingText = TextComponent(
      text: config.sections[0].name,
      textRenderer: TextPaint(
        style: TextStyle(fontWeight: FontWeight.bold, color: config.textColor),
      ),
    );
    bodyText = TextComponent(
      text: config.sections[0].content,
      textRenderer: TextPaint(style: TextStyle(color: config.textColor)),
    );
    recalculateObjectPosition();

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

  void nextCreditSection() {
    if (creditSectionIndex + 1 == config.sections.length) {
      game.router.pushNamed("mainMenu");
      return;
    }
    textDisplayedTime = 0;
    lerpValue = 0;
    creditSectionIndex++;
    var section = config.sections[creditSectionIndex];
    headingText.text = section.name;
    bodyText.text = section.content;
    recalculateObjectPosition();
  }

  @override
  void update(double dt) {
    if (!fadeOut) {
      textDisplayedTime += dt;

      if (Duration(seconds: textDisplayedTime.toInt()) >=
          config.sections[creditSectionIndex].displayDuration) {
        fadeOut = true;
        lerpValue = 0;
      }
    }

    if (lerpValue == 1.0) {
      if (fadeOut) {
        fadeOut = false;
        nextCreditSection();
        lerpValue = 0;
      }

      return;
    }
    lerpValue += dt / animationDuration;
    lerpValue = min(lerpValue, 1.0);
    int alpha = 0;

    if (fadeOut) {
      alpha =
          lerpDouble(255, 0, config.fadeOutCurve.transform(lerpValue))!.round();
    } else {
      alpha =
          lerpDouble(0, 255, config.fadeInCurve.transform(lerpValue))!.round();
    }

    headingText.textRenderer = (headingText.textRenderer as TextPaint).copyWith(
      (ts) => ts.copyWith(color: ts.color?.withAlpha(alpha)),
    );
    bodyText.textRenderer = (bodyText.textRenderer as TextPaint).copyWith(
      (ts) => ts.copyWith(color: ts.color?.withAlpha(alpha)),
    );
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);

    screenSize = newSize;
    if (isLoaded) {
      recalculateObjectPosition();
    }
  }
}
