import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/game_objects/project.dart';

class MainMenuConfig {
  bool enabled = true;
  String buttonAlignment = "left";

  MainMenuConfig({this.enabled = true});

  factory MainMenuConfig.fromMap(Map<String, dynamic> map) {
    return MainMenuConfig();
  }

  Map<String, dynamic> toMap() {
    return {};
  }
}

class MainMenuConfigPage extends StatefulWidget {
  const MainMenuConfigPage(this.project, {super.key});

  final Project project;

  @override
  State<StatefulWidget> createState() => _MainMenuConfigState();
}

class _MainMenuConfigState extends State<MainMenuConfigPage> {
  _MainMenuConfigState();

  MainMenuConfig config = MainMenuConfig();
  late File stageFile;

  @override
  void initState() {
    super.initState();

    stageFile = File(
        p.join(widget.project.projectDirectory.path, "stages", "credits.json"));
    if (stageFile.existsSync()) {
      config = MainMenuConfig.fromMap(jsonDecode(stageFile.readAsStringSync()));
    } else {
      stageFile.create();
      stageFile.writeAsStringSync(jsonEncode(config.toMap()));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                appLocal.mainMenuStage,
                style: theme.textTheme.titleLarge,
              )
            ],
          ),
        ),
      ),
    );
  }
}
