import 'dart:io';

import '/db/key_value_database.dart';
import 'game_object.dart';

class GameScene extends GameObject {
  @override
  get objectTypeId => "gameScene";

  GameScene({
    super.name = "New Scene",
    super.children = const [],
  });

  factory GameScene.fromFile(File file) {
    KeyValueDatabase kvdb = KeyValueDatabase.loadFromFile(file);
    GameScene scene = GameScene(name: kvdb.data["name"]);
    return scene;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "children": children.map((e) => e.toMap()).toList(),
    };
  }

  void saveScene(Directory projectDirectory) {
    KeyValueDatabase kvdb = KeyValueDatabase(File("${projectDirectory.path}/scenes/$name.json"));
    kvdb.data = toMap();
    kvdb.saveToFile();
  }
}
