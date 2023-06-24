import 'package:flame/components.dart';

class GameObject {
  String name;
  List<GameObject> children;

  GameObject({
    this.name = "New Object",
    this.children = const [],
  });

  Component createComponent() => Component();

  Map<String, dynamic> toMap() {
    return {
      "type": "object",
      "name": name,
      "children": children.map((e) => e.toMap()),
    };
  }
}
