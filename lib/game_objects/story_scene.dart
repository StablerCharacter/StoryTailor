import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:storytailor/game_objects/game_object.dart';
import 'package:storytailor/game_objects/story_dialog.dart';
import 'package:storytailor/story_structure/story_manager.dart';

class StoryScene extends GameObject {
  @override
  get objectTypeId => "storyScene";

  StoryManager story;
  StoryDialog? storyDialog;

  StoryScene(
      this.story, {
        super.name = "New Story Scene",
      });

  @override
  void initialize() {
    storyDialog = StoryDialog(story);
    children.add(storyDialog!);
  }

  @override
  Route createComponent() =>
      Route(() => Component(children: children.map((e) => e.createComponent())));

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": objectTypeId,
      "name": name,
      "children": children.map((e) => e.toMap()).toList(),
    };
  }
}
