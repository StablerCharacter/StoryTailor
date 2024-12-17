import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/game_objects/project.dart';

class ProjectSettingsPage extends StatefulWidget {
  const ProjectSettingsPage(this.project, {super.key});

  final Project project;

  @override
  State<ProjectSettingsPage> createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettingsPage> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocal.projectSettings,
                style: theme.textTheme.titleLarge,
              ),
              Text(appLocal.projectName, style: theme.textTheme.bodyLarge),
              Text(widget.project.name),
              Text(appLocal.toRename, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
