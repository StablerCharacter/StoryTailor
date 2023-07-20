import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/game_objects/project.dart';
import 'assets_page.dart';
import 'preview_page.dart';
import 'story_page.dart';
import 'project_settings_page.dart';
import '../views/settings_page.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key, required this.project});

  final Project project;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();

    widget.project.story.storyDirectory =
        Directory("${widget.project.projectDirectory.path}/story/")
          ..createSync();
    widget.project.story.loadChaptersFromDirectory();
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return NavigationView(
      appBar: NavigationAppBar(title: Text(widget.project.name)),
      pane: NavigationPane(
        selected: tabIndex,
        onChanged: (newIndex) => setState(() {
          tabIndex = newIndex;
        }),
        header: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(widget.project.name, style: theme.typography.bodyStrong),
        ),
        items: [
          PaneItem(
              icon: const Icon(FluentIcons.fabric_folder),
              title: Text(appLocal.assets, style: theme.typography.body),
              body: AssetsPage(widget.project)),
          PaneItem(
              icon: const Icon(FluentIcons.text_document_edit),
              title: Text(appLocal.story, style: theme.typography.body),
              body: StoryPage(widget.project)),
          PaneItem(
              icon: const Icon(FluentIcons.play),
              title: Text(appLocal.preview, style: theme.typography.body),
              body: PreviewPage(widget.project)),
        ],
        footerItems: <PaneItem>[
          PaneItem(
            icon: const Icon(FluentIcons.content_settings),
            title: Text(appLocal.projectSettings, style: theme.typography.body),
            body: ProjectSettingsPage(widget.project),
          ),
          PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(appLocal.preferences, style: theme.typography.body),
              body: const SettingsPage()),
        ],
      ),
    );
  }
}
