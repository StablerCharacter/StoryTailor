import 'dart:ui' show Image;

import 'package:flame_audio/flame_audio.dart';
import 'package:flame_character/flame_character.dart';
import 'package:flutter/painting.dart';
import 'package:storytailor/project.dart';
import 'package:storytailor/utils/assets_utility.dart';

class ProjectAssetManager extends AssetManager {
  Project project;

  ProjectAssetManager(this.project);

  @override
  Future<Image> loadImage(String fileName) async {
    return await decodeImageFromList(
      await getAssetFromRelativePath(
        project,
        fileName,
      ).readAsBytes(),
    );
  }

  @override
  Future<void> playBgm(String fileName, {double volume = 1.0}) async {
    await FlameAudio.bgm.audioPlayer.release();
    await FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await FlameAudio.bgm.audioPlayer.setVolume(volume);
    await FlameAudio.bgm.audioPlayer.setSourceDeviceFile(
      getAssetFromRelativePath(project, fileName).path,
    );
    FlameAudio.bgm.audioPlayer.resume();
    FlameAudio.bgm.isPlaying = true;
  }
}
