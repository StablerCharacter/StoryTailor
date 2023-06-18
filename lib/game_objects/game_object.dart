import 'package:flame/components.dart';

class GameObject {
  String name;
  List<GameObject> children;

  GameObject({
    this.name = "New Object",
    this.children = const [],
  });

  Component createComponent() => Component();
}
