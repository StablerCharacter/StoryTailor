import 'dart:ui';

import 'game_object.dart';

class Background extends GameObject {
  @override
  get objectTypeId => "background";

  bool isSprite;
  /// The fill of the background
  /// Which will be painted *under* the background.
  Color fill;

  Background({super.name = "New Background", this.isSprite = false, this.fill = const Color.fromARGB(255, 0, 0, 0)});
}