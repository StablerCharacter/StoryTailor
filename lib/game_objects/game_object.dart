import 'package:flame/components.dart';

class GameObject {
  String get objectTypeId => "object";

  String name;
  List<GameObject> children;

  GameObject({
    this.name = "New Object",
    this.children = const [],
  });

  Component createComponent() => Component();

  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "children": children.map((e) => e.toMap()).toList(),
    };
  }
}
