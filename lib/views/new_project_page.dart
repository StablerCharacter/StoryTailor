import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storytailor/story_structure/branch.dart';
import 'package:storytailor/story_structure/chapter.dart';
import 'package:storytailor/story_structure/dialog.dart';
import 'package:storytailor/story_structure/story_manager.dart';

import '/game_objects/project.dart';
import '/utils/string_utility.dart';
import '/db/key_value_database.dart';
import './project_related/project_view.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  Project project = Project(projectDirectory: Directory.current);
  late TextEditingController _projectNameControl;
  late Directory directory;

  @override
  void initState() {
    super.initState();
    _projectNameControl = TextEditingController(text: project.name);
    resetProjectsDirectory();
  }

  void resetProjectsDirectory() {
    getApplicationDocumentsDirectory().then((value) {
      directory = value;
      directory = Directory("${directory.path}/StoryTailor/projects/");
    });
  }

  @override
  void dispose() {
    _projectNameControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: Container(
        margin: const EdgeInsets.fromLTRB(30, 15, 30, 0),
        child: PageHeader(
          title: Text(appLocal.newProject),
          leading: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x43434343),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              InfoLabel(
                  label: appLocal.projectName,
                  labelStyle: theme.typography.bodyLarge),
              TextBox(
                controller: _projectNameControl,
                onChanged: (newValue) => project.name = newValue,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Column(
                  children: [
                    Text(appLocal.backendEngine,
                        style: theme.typography.bodyLarge),
                    ComboBox(
                      items: const [
                        ComboBoxItem(
                          value: BackendEngines.haxe,
                          child: Text("HaxeFlixel"),
                        ),
                        ComboBoxItem(
                          value: BackendEngines.flame,
                          child: Text("Flame Engine"),
                        ),
                        ComboBoxItem(
                          value: BackendEngines.sc2dcs,
                          child: Text("StablerCharacter.cs"),
                        ),
                        ComboBoxItem(
                          value: BackendEngines.sc2dts,
                          child: Text("StablerCharacter.ts"),
                        ),
                      ],
                      value: project.backendEngine,
                      onChanged: (newValue) {
                        setState(() {
                          project.backendEngine = newValue!;
                        });
                      },
                    ),
                    Text(appLocal.canChangeLater),
                    const SizedBox(height: 15),
                    // Text(appLocal.projectLocation, style: theme.typography.bodyLarge),
                    // Text(appLocal.projectLocationDescription),
                    // ComboBox(
                    //   items: [
                    //     ComboBoxItem(
                    //       value: ProjectLocation.local,
                    //       child: Text(appLocal.locationLocal),
                    //     ),
                    //     ComboBoxItem(
                    //       value: ProjectLocation.cloud,
                    //       child: Text(appLocal.locationCloud),
                    //     ),
                    //   ],
                    //   value: project.projectLocation,
                    //   onChanged: (location) => setState(() => project.projectLocation = location!),
                    // ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: FilledButton(
                  child: Text(appLocal.create),
                  onPressed: () {
                    String fileName = systemFriendlyFileName(project.name);
                    final Directory projDir =
                        Directory("${directory.path}/$fileName/");
                    if (projDir.existsSync()) {
                      displayInfoBar(context, builder: (context, close) {
                        return InfoBar(
                          title: const Text(
                              "Project with specified name already exists."),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.error,
                        );
                      });
                      return;
                    }
                    projDir.createSync(recursive: true);
                    project.projectDirectory = projDir;
                    Directory("${projDir.path}/assets/").createSync();
                    Directory("${projDir.path}/stages/").createSync();
                    Directory storyDirectory =
                        Directory("${projDir.path}/story/")..createSync();
                    project.story = StoryManager([
                      Chapter("The beginning of the Adventure", {
                        "main": Branch(<Dialog>[Dialog("Hello there.")])
                      }),
                    ])
                      ..storyDirectory = storyDirectory
                      ..saveChaptersToFile();

                    KeyValueDatabase projectDb = KeyValueDatabase(
                        File("${projDir.path}/$fileName.json")..createSync());
                    projectDb.data.addAll({
                      'name': project.name,
                      'backend': project.backendEngine.name,
                    });
                    projectDb.saveToFile();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      FluentPageRoute(
                          builder: (context) => ProjectPage(
                                project: project,
                              )),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
