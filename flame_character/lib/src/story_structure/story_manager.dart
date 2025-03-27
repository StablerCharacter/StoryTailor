import 'dart:convert';
import 'dart:io';

import 'package:flame_character/src/utils/string_utility.dart';
import 'package:path/path.dart' as p;

import 'chapter.dart';
import 'dialog.dart';

class StoryManager {
  List<Chapter> chapters;
  Directory? storyDirectory;
  int chapterIndex = 0;

  StoryManager(this.chapters);

  Dialog getCurrentDialog() => chapters[chapterIndex].getCurrentDialog();
  Dialog getNextDialog() => chapters[chapterIndex].getNextDialog();

  Future<void> saveChaptersToFile() async {
    for (int i = 0; i < chapters.length; i++) {
      await saveChapterToFile(chapterIndex);
    }
  }

  Future<void> saveChapterToFile(int chapterIndex) async {
    Chapter chapter = chapters[chapterIndex];

    if (chapter.branches == null) {
      return;
    }

    if (chapter.newName != null) {
      await File(
        "${storyDirectory!.path}/${systemFriendlyFileName(chapter.name)}.json",
      ).delete();
      chapter.name = chapter.newName!;
    }

    File chapterFile = File(
      "${storyDirectory!.path}/${systemFriendlyFileName(chapter.name)}.json",
    );
    if (!await chapterFile.exists()) await chapterFile.create();
    chapter.chaptersFile = chapterFile;
    await chapterFile.writeAsString(jsonEncode(chapter.toJson()));
  }

  Future<void> loadChaptersFromDirectory() async {
    if (storyDirectory == null) {
      return;
    }

    chapters.clear();

    List<String>? order;

    await storyDirectory!.list().forEach((entity) {
      if (entity is File) {
        if (p.basename(entity.path) == "StoryManager.json") {
          Map<String, dynamic> manager = jsonDecode(entity.readAsStringSync());
          order =
              (manager["chapters"] as List<dynamic>)
                  .map((e) => e as String)
                  .toList();
          return;
        }

        chapters.add(
          Chapter.fromJson(jsonDecode(entity.readAsStringSync()))
            ..chaptersFile = entity,
        );
      }
    });

    if (order != null) {
      final orderMap = {for (int i = 0; i < order!.length; i++) order![i]: i};

      chapters.sort((a, b) {
        final posA = orderMap[a.name] ?? order!.length;
        final posB = orderMap[b.name] ?? order!.length;

        return posA.compareTo(posB);
      });
    }
  }

  /// Save the information specific to StoryManager
  /// (which at the moment only is the order of chapters)
  Future<void> saveToJson() async {
    if (storyDirectory == null) {
      return;
    }

    final data = {
      // A number that will increase if a breaking change will happen to the format
      "formatVersion": 1,
      "chapters": chapters.map((chapter) => chapter.name).toList(),
    };

    File file = File(p.join(storyDirectory!.path, "StoryManager.json"));
    await file.create();
    await file.writeAsString(jsonEncode(data));
  }
}
