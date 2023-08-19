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
}