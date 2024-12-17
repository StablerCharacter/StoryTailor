import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:storytailor/views/project_related/credits_config.dart';
import 'package:storytailor/views/project_related/main_menu_config.dart';
import 'package:storytailor/views/project_related/project_settings_page.dart';
import 'package:storytailor/views/project_related/story_config.dart';
import 'package:storytailor/views/settings_page.dart';

import '/game_objects/project.dart';
import 'assets_page.dart';
import 'preview_page.dart';
import 'story_page.dart';

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
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    if (tabIndex == 6) {
      Navigator.pop(context);
    }

    Widget selectedPage = [
      AssetsPage(widget.project),
      StoryPage(widget.project),
      PreviewPage(widget.project),
      MainMenuConfigPage(widget.project),
      const StoryConfigPage(),
      CreditsConfigPage(widget.project),
      Container(), // Close Project
      ProjectSettingsPage(widget.project),
      const SettingsPage(),
    ][tabIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      drawer: NavigationDrawer(
          selectedIndex: tabIndex,
          onDestinationSelected: (newIndex) => setState(
                () {
                  tabIndex = newIndex;
                  Navigator.pop(context);
                },
              ),
          children: [
            NavigationDrawerDestination(
              icon: const Icon(Icons.folder),
              label: Text(appLocal.assets),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.edit_note),
              label: Text(appLocal.story),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.play_arrow),
              label: Text(appLocal.preview),
            ),
            const Divider(),
            NavigationDrawerDestination(
              icon: const Icon(Icons.menu),
              label: Text(appLocal.mainMenuStage),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.note),
              label: Text(appLocal.storyStage),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.list),
              label: Text(appLocal.creditsStage),
            ),
            const Divider(),
            NavigationDrawerDestination(
              icon: const Icon(Icons.close),
              label: Text(appLocal.closeProject),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.app_settings_alt),
              label: Text(appLocal.projectSettings),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.settings),
              label: Text(appLocal.preferences),
            ),
          ]),
      body: selectedPage,
      // pane: NavigationPane(
      //   selected: tabIndex,
      //   onChanged: (newIndex) => setState(() {
      //     tabIndex = newIndex;
      //   }),
      //   header: Container(
      //     margin: const EdgeInsets.only(bottom: 8),
      //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      //     child: Text(widget.project.name, style: theme.textTheme.bodyLarge),
      //   ),
      //   items: [
      //     PaneItem(
      //       icon: const Icon(FluentIcons.fabric_folder),
      //       title: Text(appLocal.assets, style: theme.textTheme.bodyMedium),
      //       body: AssetsPage(widget.project),
      //     ),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.text_document_edit),
      //       title: Text(appLocal.story, style: theme.textTheme.bodyMedium),
      //       body: StoryPage(widget.project),
      //     ),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.play),
      //       title: Text(appLocal.preview, style: theme.textTheme.bodyMedium),
      //       body: PreviewPage(widget.project),
      //     ),
      //     PaneItemSeparator(color: theme.cardColor, thickness: 2),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.context_menu),
      //       title:
      //           Text(appLocal.mainMenuStage, style: theme.textTheme.bodyMedium),
      //       body: MainMenuConfigPage(widget.project),
      //     ),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.storyboard),
      //       title: Text(appLocal.storyStage, style: theme.textTheme.bodyMedium),
      //       body: const StoryConfigPage(),
      //     ),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.circle_stop),
      //       title:
      //           Text(appLocal.creditsStage, style: theme.textTheme.bodyMedium),
      //       body: CreditsConfigPage(widget.project),
      //     ),
      //   ],
      //   footerItems: <PaneItem>[
      //     PaneItem(
      //       icon: const Icon(FluentIcons.content_settings),
      //       title: Text(appLocal.projectSettings,
      //           style: theme.textTheme.bodyMedium),
      //       body: ProjectSettingsPage(widget.project),
      //     ),
      //     PaneItem(
      //       icon: const Icon(FluentIcons.settings),
      //       title:
      //           Text(appLocal.preferences, style: theme.textTheme.bodyMedium),
      //       body: const SettingsPage(),
      //     ),
      //   ],
      // ),
    );
  }
}
