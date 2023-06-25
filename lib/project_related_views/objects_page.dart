import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/game_objects/game_object.dart';
import '/game_objects/game_scene.dart';

class ObjectsPage extends StatefulWidget {
  final GameScene scene;

  const ObjectsPage(this.scene, {super.key});

  @override
  State<StatefulWidget> createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  List<GameObject> objects = [GameObject(name: "StoryDialog")];

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appLocal.objects, style: theme.typography.titleLarge),
              const SizedBox(height: 30),
              FilledButton(
                child: Text(appLocal.newObjectBtn),
                onPressed: () {
                  showBottomSheet(context: context, builder: (context) {
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: const Text("Empty Object"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Text"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Button"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Image"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
                },
              ),
              const SizedBox(height: 30),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: objects.length,
                itemBuilder: (context, index) {
                  return Button(
                    onPressed: () {},
                    child: Text(
                      objects[index].name,
                      style: theme.typography.bodyLarge,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
