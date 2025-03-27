import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_character/flame_character.dart';

class StoryScene extends GameObject {
  @override
  get objectTypeId => "storyScene";

  StoryManager story;
  StoryDialog? storyDialog;

  StoryScene(this.story, {super.name = "New Story Scene"});

  @override
  void initialize() {
    storyDialog = StoryDialog(story);
    children.add(storyDialog!);
  }

  @override
  Route createComponent() => Route(
    () => Component(children: children.map((e) => e.createComponent())),
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "children": children.map((e) => e.toMap()).toList(),
    };
  }
}
