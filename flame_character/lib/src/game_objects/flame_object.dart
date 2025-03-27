import 'package:flame/components.dart';
import 'package:flame_character/src/game_objects/game_object.dart';

class FlameObject extends GameObject {
  @override
  get objectTypeId => "flameObject";

  Component component;

  FlameObject(this.component, {super.name = "New Flame Object"});

  @override
  Component createComponent() => component;
}
