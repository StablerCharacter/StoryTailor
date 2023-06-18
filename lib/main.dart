import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db/key_value_database.dart';
import 'utils/dialog_util.dart';
import 'utils/string_utility.dart';
import 'views/bug_report.dart';
import 'views/new_project_page.dart';
import 'game_objects/project.dart';
import 'views/settings_page.dart';
import 'project_related_views/project_view.dart';
import 'utils/size_unit_conversion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemTheme.fallbackColor = Colors.blue;
  await SystemTheme.accentColor.load();

  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: "https://tdywftpmrgcepddovnic.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkeXdmdHBtcmdjZXBkZG92bmljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODM1NTc4NjIsImV4cCI6MTk5OTEzMzg2Mn0.o83mfiCZjVTpnN7JM5uCCxj-Ungvg6HisrV2qY9nTj0",
  );

  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp(this.prefs, {super.key});

  Typography? applyFont(Typography typography, Locale locale) {
    if (locale.languageCode == "th") {
      return typography.apply(
          fontFamily: GoogleFonts.ibmPlexSansThai().fontFamily);
    }
    return typography;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AccentColor accentColor = SystemTheme.accentColor.accent.toAccentColor();

    return ChangeNotifierProvider(
      create: (_) => ModelSettings(prefs),
      child: Consumer<ModelSettings>(
        builder: (context, ModelSettings themeNotifier, child) {
          return FluentApp(
            title: 'StoryTailor',
            theme: FluentThemeData.light().copyWith(
              accentColor: accentColor,
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              typography: applyFont(
                Typography.fromBrightness(brightness: Brightness.light),
                themeNotifier.language,
              ),
            ),
            darkTheme: FluentThemeData.dark().copyWith(
              accentColor: accentColor,
              typography: applyFont(
                Typography.fromBrightness(brightness: Brightness.dark),
                themeNotifier.language,
              ),
            ),
            themeMode: themeNotifier.getThemeMode(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: themeNotifier.language,
            home: const MyHomePage(title: 'StoryTailor'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;
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
              HyperlinkButton(
                child: Text(appLocal.renameProject),
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
                          Snackbar(
                              content:
                                  Text(appLocal.projectNameCannotBeEmpty)));
                    } else if (systemFriendlyFileName(name).isEmpty) {
                      showSnackbar(context,
                          Snackbar(content: Text(appLocal.invalidProjectName)));
                    }
                    List<String> pathSections = p.split(dir.path);
                    String oldName = pathSections.removeLast();
                    Directory newDir = dir.renameSync(p.join(
                        pathSections.join(p.separator),
                        systemFriendlyFileName(name)));
                    KeyValueDatabase project =
                        KeyValueDatabase.loadFromFile(File(p.join(newDir.path, "$oldName.json")));
                    project.data["name"] = name;
                    project.saveToFile().then((file) => file.rename(p.join(newDir.path, "$name.json")).then((value) => setState(() {})));
                  });
                },
              ),
              HyperlinkButton(
                child: Text(appLocal.deleteProject),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        title: Text(appLocal.deleteProject),
                        content: Text(appLocal.deletionConfirmation),
                        actions: [
                          HyperlinkButton(
                            child: Text(appLocal.delete),
                            onPressed: () {
                              dir.delete(recursive: true).then((_) {
                                showSnackbar(
                                  context,
                                  Snackbar(
                                    content: Text(appLocal.projectDeleted),
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
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    DateFormat dateFormat =
        DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode);

    return NavigationView(
      appBar: NavigationAppBar(
        leading: Container(
          margin: const EdgeInsets.fromLTRB(10, 15, 2.5, 7.5),
          child: const Image(
            image: AssetImage('assets/icon.png'),
          ),
        ),
        title: Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 30, 0),
            child: Text(
              "StoryTailor",
              style: theme.typography.title,
            )),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.fabric_folder),
            title: Text(appLocal.projects, style: theme.typography.body),
            body: Container(
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(appLocal.projects, style: theme.typography.titleLarge),
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
                                        title:
                                            Text(appLocal.projectDoesntExist),
                                        content: Text(
                                          appLocal
                                              .projectDoesntExistExplaination,
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
              ),
            ),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.documentation),
            title: Text(appLocal.tutorials, style: theme.typography.body),
            body: Container(
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(appLocal.tutorials, style: theme.typography.titleLarge),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Button(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Getting Started",
                                style: theme.typography.bodyLarge,
                              ),
                              const Text(
                                  "Wanna start creating some games? Start here!")
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.bug),
            body: const BugReportPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            body: const SettingsPage(),
          ),
        ],
        selected: selectedTab,
        onChanged: (newValue) => setState(() {
          selectedTab = newValue;
        }),
      ),
    );
  }
}
