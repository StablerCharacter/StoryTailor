import 'dart:convert';
import 'dart:io';

import '../utils/string_utility.dart';
import 'chapter.dart';
import 'dialog.dart';

class StoryManager {
  List<Chapter> chapters;
  Directory? storyDirectory;
  int chapterIndex = 0;

  StoryManager(this.chapters);

  Dialog getCurrentDialog() => chapters[chapterIndex].getCurrentDialog();
  Dialog getNextDialog() => chapters[chapterIndex].getNextDialog();

  void saveChaptersToFile() async {
    for (int i = 0; i < chapters.length; i++) {
      saveChapterToFile(chapterIndex);
    }
  }

  Future<void> saveChapterToFile(int chapterIndex) async {
    Chapter chapter = chapters[chapterIndex];

    if (chapter.branches == null) {
      return;
    }

    if (chapter.newName != null) {
      await File(
              "${storyDirectory!.path}/${systemFriendlyFileName(chapter.name)}.json")
          .delete();
      chapter.name = chapter.newName!;
    }

    File chapterFile = File(
        "${storyDirectory!.path}/${systemFriendlyFileName(chapter.name)}.json");
    if (!await chapterFile.exists()) await chapterFile.create();
    chapter.chaptersFile = chapterFile;
    await chapterFile.writeAsString(jsonEncode(chapter.toJson()));
  }

  void loadChaptersFromDirectory() async {
    if (storyDirectory == null) {
      return;
    }

    chapters.clear();

    storyDirectory!.list().forEach((entity) async {
      if (entity is File) {
        chapters.add(
          Chapter.fromJson(
            jsonDecode(await entity.readAsString()),
          )..chaptersFile = entity,
        );
      }
    });
  }

  void loadCharacterGroups() {}
}
