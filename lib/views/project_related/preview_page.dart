import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/game_objects/project.dart';
import '/game_preview.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage(this.project, {super.key});

  final Project project;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  _PreviewPageState();

  String stage = "story";

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(appLocal.preview, style: theme.textTheme.titleLarge),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Column(
                children: [
                  Text(
                    "Game Stage",
                    style: theme.textTheme.bodyLarge,
                  ),
                  DropdownMenu<String>(
                    controller: TextEditingController(text: stage),
                    enableFilter: false,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: "mainMenu",
                        label: "Main Menu",
                      ),
                      DropdownMenuEntry(
                        value: "story",
                        label: "Story",
                      ),
                      DropdownMenuEntry(
                        value: "credits",
                        label: "Credits",
                      ),
                    ],
                    onSelected: (v) {
                      setState(() {
                        stage = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              child: FilledButton(
                child: Text(
                  appLocal.runPreviewBtn,
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(
                        game: GamePreview(widget.project, stage),
                        overlayBuilderMap: {
                          "devtools":
                              (BuildContext context, GamePreview preview) {
                            return Positioned(
                              top: 50,
                              left: 50,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5,
                                  sigmaY: 5,
                                ),
                                child: Container(
                                  color: Colors.black.withAlpha(100),
                                  padding: const EdgeInsets.all(50),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(appLocal.devtools,
                                          style: theme.textTheme.titleMedium),
                                      OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(appLocal.exitGame)),
                                      OutlinedButton(
                                          child: Text(appLocal.closeOverlay),
                                          onPressed: () =>
                                              preview.closeOverlay("devtools")),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text(
              "No matter which engine you chooses, the preview will be run using Flame Engine.",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
