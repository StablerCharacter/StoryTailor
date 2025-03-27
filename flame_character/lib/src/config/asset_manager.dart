import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

class AssetManager {
  Future<Image> loadImage(String fileName) {
    return Flame.images.load(fileName);
  }

  Future<void> playBgm(String fileName, {double volume = 1.0}) {
    return FlameAudio.bgm.play(fileName, volume: volume);
  }
}
