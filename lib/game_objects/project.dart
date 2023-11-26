import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:storytailor/story_structure/chapter.dart';

import '/story_structure/story_manager.dart';
import '../db/key_value_database.dart';
import 'game_object.dart';

enum BackendEngines {
  /// Uses HaxeFlixel (Haxe)
  haxe,

  /// Uses Flame Engine (Dart)
  flame,

  /// Uses the StablerCharacter.cs 2D Framework
  sc2dcs,

  /// Uses the StablerCharacter.ts 2D Framework
  sc2dts;

  factory BackendEngines.fromValue(String value) {
    for (BackendEngines backendEngine in BackendEngines.values) {
      if (backendEngine.name == value) return backendEngine;
    }
    throw KeyNotFoundException(
        "a backend engine with name $value is not found.");
  }
}

enum ProjectLocation {
  /// The project is stored locally.
  local,

  /// The project is stored on the StoryTailor cloud.
  cloud
}

class Project extends GameObject {
  @override
  get objectTypeId => "project";

  late KeyValueDatabase projectDb;

  ProjectLocation projectLocation = ProjectLocation.local;
  BackendEngines backendEngine;
  Directory projectDirectory;
  int currentSceneIndex = 0;
  StoryManager story = StoryManager([]);

  Project({
    super.name = "New Project",
    this.backendEngine = BackendEngines.flame,
    required this.projectDirectory,
  });

  factory Project.fromDir(Directory projectDirectory) {
    KeyValueDatabase db = KeyValueDatabase.loadFromFile(File(p.join(
      projectDirectory.path,
      "${p.basename(projectDirectory.path)}.json",
    )));
    Project project = Project(
      name: db.data["name"],
      backendEngine: BackendEngines.fromValue(db.data["backend"]),
      projectDirectory: projectDirectory,
    );

    return project;
  }
}
