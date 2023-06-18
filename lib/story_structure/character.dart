import 'dart:ui';

class Character {
  String name;
  Color textColor;
  List<Map<String, String>> variants = [];

  Character({
    required this.name,
    this.textColor = const Color.fromARGB(255, 0, 0, 0),
  });

  factory Character.fromMap(Map<String, dynamic> characterData) {
    return Character(
      name: characterData["name"],
      textColor: Color(characterData["textColor"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "textColor": textColor.value,
    };
  }
}
