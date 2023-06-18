import 'dart:io';

import '/db/key_value_database.dart';
import 'game_object.dart';

class GameScene extends GameObject {
  GameScene({
    super.name = "New Scene",
    super.children = const [],
  });

  factory GameScene.fromFile(File file) {
    KeyValueDatabase kvdb = KeyValueDatabase.loadFromFile(file);
    GameScene scene = GameScene(name: kvdb.data["name"]);
    return scene;
  }

  KeyValueDatabase toKVDB(File file) {
    KeyValueDatabase kvdb = KeyValueDatabase(file);
    kvdb.data.addAll({
      "name": name
    });
    return kvdb;
  }

  void saveScene(Directory projectDirectory) {
    toKVDB(File("${projectDirectory.path}/scenes/$name.json")).saveToFile();
  }
}
