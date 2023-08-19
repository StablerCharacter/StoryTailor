import 'dart:ui';

import 'package:flame/game.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/game_objects/project.dart';
import '../game_preview.dart';

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
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      content: Container(
        margin: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text(appLocal.preview, style: theme.typography.titleLarge),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Column(
                children: [
                  InfoLabel(label: "Game Stage"),
                  ComboBox<String>(
                    value: stage,
                    items: const [
                      ComboBoxItem(
                        value: "mainMenu",
                        child: Text("Main Menu"),
                      ),
                      ComboBoxItem(
                        value: "story",
                        child: Text("Story"),
                      ),
                      ComboBoxItem(
                        value: "credits",
                        child: Text("Credits"),
                      ),
                    ],
                    onChanged: (v) {
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
                      theme.typography.bodyLarge?.copyWith(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    FluentPageRoute(
                      builder: (context) => GameWidget(
                        game: GamePreview(widget.project.story),
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
                                          style: theme.typography.title),
                                      Button(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(appLocal.exitGame)),
                                      Button(
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
