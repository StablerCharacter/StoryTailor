import 'package:flame/components.dart';

enum VAlign {
  top,
  center,
  bottom;
}

enum HAlign {
  left,
  center,
  right;
}

class Alignment {
  VAlign vAlign = VAlign.top;
  HAlign hAlign = HAlign.left;
  int offsetX = 0;
  int offsetY = 0;

  Vector2 calculate(Vector2 screenSize, Vector2 objectSize) {
    Vector2 screenCenter = Vector2.copy(screenSize)..divide(Vector2.all(2));
    double x;
    double y;
    switch (vAlign) {
      case VAlign.top:
        y = 0;
        break;
      case VAlign.center:
        y = screenCenter.y - (objectSize.y / 2);
        break;
      case VAlign.bottom:
        y = screenSize.y - objectSize.y;
        break;
    }
    switch (hAlign) {
      case HAlign.left:
        x = 0;
        break;
      case HAlign.center:
        x = screenCenter.x - (objectSize.x / 2);
        break;
      case HAlign.right:
        x = screenSize.x - objectSize.x;
        break;
    }
    return Vector2(x + offsetX, y + offsetY);
  }
}