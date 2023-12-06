import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storytailor/db/key_value_database.dart';
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/views/project_related/export_to_zip.dart';
import 'package:storytailor/views/project_related/project_view.dart';
import 'package:storytailor/utils/dialog_util.dart';
import 'package:storytailor/utils/size_unit_conversion.dart';
import 'package:storytailor/utils/string_utility.dart';
import 'package:storytailor/views/new_project_page.dart';
import 'package:path/path.dart' as p;

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  late Directory projectsDir;
  Directory? documentsDir;
  Future<List<Directory>>? projects;

  @override
  void initState() {
    projects = getProjectsList();

    super.initState();
  }

  Future<List<Directory>> getProjectsList() {
    Future<List<Directory>> getDirList(value) async {
      projectsDir = Directory("${value.path}/StoryTailor/projects/");
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }
      return (await projectsDir.list().toList())
          .whereType<Directory>()
          .toList(growable: false);
    }

    if (documentsDir == null) {
      return getApplicationDocumentsDirectory().then((value) {
        documentsDir = value;
        return getDirList(value);
      });
    }

    return getDirList(documentsDir);
  }

  int getSize(Directory dir) {
    int totalSize = 0;
    dir.listSync(recursive: true, followLinks: false).forEach((entity) {
      if (entity is File) {
        totalSize += entity.lengthSync();
      }
    });

    return totalSize;
  }

  void showExtraProjectOptions(BuildContext context, Directory dir) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    showBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FluentIcons.rename),
                title: Text(appLocal.renameProject),
                onPressed: () {
                  askString(
                    context,
                    appLocal.renameProject,
                    null,
                    appLocal.projectName,
                    "",
                    appLocal.renameFile,
                    appLocal.cancel,
                  ).then((name) {
                    if (name == null) {
                      return;
                    } else if (name.isEmpty) {
                      showSnackbar(
                          context,
                          InfoBar(
                              title: Text(appLocal.projectNameCannotBeEmpty)));
                    } else if (systemFriendlyFileName(name).isEmpty) {
                      showSnackbar(context,
                          InfoBar(title: Text(appLocal.invalidProjectName)));
                    }
                    List<String> pathSections = p.split(dir.path);
                    String oldName = pathSections.removeLast();
                    Directory newDir = dir.renameSync(p.join(
                        pathSections.join(p.separator),
                        systemFriendlyFileName(name)));
                    KeyValueDatabase project = KeyValueDatabase.loadFromFile(
                        File(p.join(newDir.path, "$oldName.json")));
                    project.data["name"] = name;
                    project.saveToFile().then((file) => file
                        .rename(p.join(newDir.path, "$name.json"))
                        .then((value) => setState(() {})));
                  });
                },
              ),
              ListTile(
                leading: const Icon(FluentIcons.share),
                title: Text(appLocal.exportProjectToZip),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ExportProjectToZip(
                        dir,
                        "${documentsDir!.path}/StoryTailor/project.zip",
                      );
                    },
                    dismissWithEsc: false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(FluentIcons.delete),
                title: Text(appLocal.deleteProject),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        title: Text(appLocal.deleteProject),
                        content: Text(appLocal.projectDeletionConfirmation),
                        actions: [
                          HyperlinkButton(
                            child: Text(appLocal.delete),
                            onPressed: () {
                              dir.delete(recursive: true).then((_) {
                                showSnackbar(
                                  context,
                                  InfoBar(
                                    title: Text(appLocal.projectDeleted),
                                  ),
                                );
                                setState(() {});
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FilledButton(
                            child: Text(appLocal.cancel),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);
    DateFormat dateFormat =
        DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode);

    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.all(30),
      children: [
        Column(
          children: [
            Text(appLocal.projects, style: theme.typography.titleLarge),
            Visibility(
              visible: kDebugMode,
              child: Text(
                appLocal.developmentVersionWarning,
                style: theme.typography.bodyStrong,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FluentPageRoute(
                          builder: (context) => const NewProjectPage()),
                    );
                  },
                  child: Text(appLocal.newProjectBtn),
                ),
                const SizedBox(width: 25),
                Button(
                  onPressed: () {
                    setState(() {
                      projects = getProjectsList();
                    });
                  },
                  child: Text(appLocal.refresh),
                ),
              ],
            ),
            const SizedBox(height: 15),
            FutureBuilder(
              future: projects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        Directory dir = snapshot.data![index];

                        if (!dir.existsSync()) {
                          return Container();
                        }

                        FileStat fileStat = dir.statSync();

                        return Button(
                          onLongPress: () {
                            showExtraProjectOptions(context, dir);
                          },
                          onPressed: () {
                            if (!dir.existsSync()) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: Text(appLocal.projectDoesntExist),
                                  content: Text(
                                    appLocal.projectDoesntExistExplaination,
                                    softWrap: true,
                                  ),
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                  severity: InfoBarSeverity.warning,
                                );
                              });
                              setState(() {
                                projects = getProjectsList();
                              });
                              return;
                            }

                            Navigator.push(
                              context,
                              FluentPageRoute(
                                builder: (context) => ProjectPage(
                                  project: Project.fromDir(dir),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Text(
                                  p.basename(dir.path),
                                  style: theme.typography.bodyLarge,
                                ),
                                Text(
                                  "${appLocal.lastModified(dateFormat.format(fileStat.changed))} | ${appLocal.fileSize(SizeUnitConversion.bytesToAppropriateUnits(getSize(dir)))}",
                                  style: theme.typography.caption,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const ProgressRing();
                }
              },
            ),
          ],
        )
      ],
    );
  }
}
