import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '/utils/string_utility.dart';
import 'character.dart';

class CharacterGroup {
  String groupName;
  List<Character> characters;

  CharacterGroup(this.groupName, this.characters);

  void saveGroup(Directory characterGroupDir) {
    File groupFile = File(p.join(characterGroupDir.path, "${systemFriendlyFileName(groupName)}.json"));
    groupFile.createSync();
    groupFile.writeAsString(jsonEncode({
      "name": groupName,
      "characters": characters.map((e) => e.toMap())
    }));
  }
}