import 'dart:ui';

import 'package:flame_character/flame_character.dart';

class Character {
  String name;
  Color textColor;
  List<Map<String, SpriteMetadata>> variants = [];

  Character({
    required this.name,
    this.textColor = const Color.fromARGB(255, 0, 0, 0),
  });

  factory Character.fromMap(Map<String, dynamic> characterData) {
    Character char = Character(
      name: characterData["name"],
      textColor: Color(characterData["textColor"]),
    );

    char.variants =
        (characterData["variants"] as List<Map<String, Map<String, dynamic>>>)
            .map(
              (e) => e.map(
                (key, value) => MapEntry(key, SpriteMetadata.fromMap(value)),
              ),
            )
            .toList();

    return char;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "textColor": textColor.toARGB32(),
      "variants": variants.map(
        (e) => e.map((key, value) => MapEntry(key, value.toMap())),
      ),
    };
  }
}
