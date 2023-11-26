import 'dart:math';

import 'package:flame/components.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/story_structure/chapter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Stretch {
  noStretch("No Stretch"),
  letterbox("Letterbox"),
  pillarbox("Pillarbox"),
  scaleToCover("Scale to cover"),
  stretchToFit("Stretch to fit");

  final String displayName;

  const Stretch(this.displayName);

  factory Stretch.fromDisplayName(String displayName) {
    for (Stretch stretchMode in Stretch.values) {
      if (stretchMode.displayName == displayName) return stretchMode;
    }
    throw KeyNotFoundException(
        "a stretch mode with display name $displayName is not found.");
  }
}

class StretchModeImpl {
  static Vector2 calculate(
      Stretch stretchMode, Vector2 screenSize, Vector2 imageSize) {
    switch (stretchMode) {
      case Stretch.noStretch:
        return imageSize;
      case Stretch.letterbox:
        return StretchModeImpl.letterBox(screenSize, imageSize);
      case Stretch.pillarbox:
        return StretchModeImpl.pillarBox(screenSize, imageSize);
      case Stretch.scaleToCover:
        return StretchModeImpl.scaleToCover(screenSize, imageSize);
      case Stretch.stretchToFit:
        return screenSize;
    }
  }

  static Vector2 letterBox(Vector2 screenSize, Vector2 imageSize) {
    double diff = screenSize.x - imageSize.x;
    Vector2 newSize = Vector2.copy(imageSize)..add(Vector2.all(diff.abs()));
    return newSize;
  }

  static Vector2 pillarBox(Vector2 screenSize, Vector2 imageSize) {
    double diff = screenSize.y - imageSize.y;
    Vector2 newSize = Vector2.copy(imageSize)..add(Vector2.all(diff.abs()));
    return newSize;
  }

  static Vector2 scaleToCover(Vector2 screenSize, Vector2 imageSize) {
    double diffX = screenSize.x - imageSize.x;
    double diffY = screenSize.y - imageSize.y;
    double maxDiff = max(diffX, diffY);
    Vector2 newSize = Vector2.copy(imageSize)..add(Vector2.all(maxDiff));
    return newSize;
  }
}

class StretchModeComboBox extends StatelessWidget {
  final Stretch value;
  final void Function(Stretch?)? onChange;

  const StretchModeComboBox({super.key, this.value = Stretch.scaleToCover, this.onChange,});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ComboBox(items: [
      ComboBoxItem(value: Stretch.noStretch, child: Text(appLocal.noStretch)),
      ComboBoxItem(value: Stretch.letterbox, child: Text(appLocal.letterbox)),
      ComboBoxItem(value: Stretch.pillarbox, child: Text(appLocal.pillarbox)),
      ComboBoxItem(value: Stretch.scaleToCover, child: Text(appLocal.scaleToCover)),
      ComboBoxItem(value: Stretch.stretchToFit, child: Text(appLocal.stretchToFit)),
    ], value: value, onChanged: onChange,);
  }

}
