import 'dart:convert';
import 'dart:io';

import 'package:flame_character/flame_character.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/components/audio_asset_field.dart';
import 'package:storytailor/components/button_with_icon.dart';
import 'package:storytailor/components/color_field.dart';
import 'package:storytailor/components/image_asset_field.dart';
import 'package:storytailor/components/stretch_mode_combobox.dart';
import 'package:storytailor/l10n/app_localizations.dart';
import 'package:storytailor/project.dart';
import 'package:storytailor/utils/assets_utility.dart';
import 'package:storytailor/utils/list_utility.dart';

class CreditsConfigPage extends StatefulWidget {
  const CreditsConfigPage(this.project, {super.key});

  final Project project;

  @override
  State<CreditsConfigPage> createState() => CreditsConfigState();
}

class CreditsConfigState extends State<CreditsConfigPage> {
  CreditsConfigState();

  static CreditsConfig config = CreditsConfig();
  List<TextEditingController> sectionNameControls = [];
  List<TextEditingController> creditsControls = [];
  late File stageFile;

  @override
  void initState() {
    stageFile = File(
      p.join(
        widget.project.projectDirectory.path,
        "stages",
        "credits.json",
      ),
    );
    tryLoad(stageFile);

    for (CreditsSection section in config.sections) {
      sectionNameControls.add(TextEditingController(text: section.name));
      creditsControls.add(TextEditingController(text: section.content));
    }

    super.initState();
  }

  static void tryLoad(File stageFile) {
    if (stageFile.existsSync()) {
      try {
        config =
            CreditsConfig.fromMap(jsonDecode(stageFile.readAsStringSync()));
      } catch (err) {
        stageFile.writeAsStringSync(jsonEncode(config.toMap()));
      }
    } else {
      stageFile.create();
      stageFile.writeAsStringSync(jsonEncode(config.toMap()));
    }
  }

  @override
  void deactivate() {
    for (int i = 0; i < config.sections.length; i++) {
      config.sections[i].name = sectionNameControls[i].text;
      config.sections[i].content = creditsControls[i].text;
    }

    stageFile.writeAsStringSync(jsonEncode(config.toMap()));

    super.deactivate();
  }

  @override
  void dispose() {
    for (TextEditingController creditsControl in creditsControls) {
      creditsControl.dispose();
    }

    for (TextEditingController sectionNameControl in sectionNameControls) {
      sectionNameControl.dispose();
    }

    super.dispose();
  }

  void cloneAndMoveCreditsSection(int oldIndex, int newIndex) {
    var clonedConfigSections = cloneList(config.sections);
    var clonedSectionNameControls = cloneList(sectionNameControls);
    var clonedCreditsControls = cloneList(creditsControls);
    clonedConfigSections.insert(
      newIndex,
      clonedConfigSections.removeAt(oldIndex),
    );
    clonedSectionNameControls.insert(
      newIndex,
      clonedSectionNameControls.removeAt(oldIndex),
    );
    clonedCreditsControls.insert(
      newIndex,
      clonedCreditsControls.removeAt(oldIndex),
    );
    config.sections = clonedConfigSections;
    sectionNameControls = clonedSectionNameControls;
    creditsControls = clonedCreditsControls;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                appLocal.creditsStage,
                style: theme.typography.title,
              ),
              const Gap(15),
              Expander(
                header: Text(appLocal.stageEnvironment),
                content: Wrap(
                  spacing: 20,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appLocal.stageBackground,
                          style: theme.typography.bodyStrong,
                        ),
                        ImageAssetField(
                          widget.project,
                          initialValue: config.stageBackground.isNotEmpty
                              ? getAssetFromRelativePath(
                                  widget.project, config.stageBackground)
                              : null,
                          onAssetSelected: (file) {
                            if (file == null) {
                              config.stageBackground = "";
                              return;
                            }

                            config.stageBackground = getRelativePathFromAsset(
                              widget.project,
                              file.path,
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appLocal.stretchMode,
                          style: theme.typography.bodyStrong,
                        ),
                        StretchModeComboBox(
                          value: config.backgroundStretch,
                          onChange: (newValue) => setState(() {
                            config.backgroundStretch =
                                newValue ?? Stretch.scaleToCover;
                          }),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appLocal.stageBackgroundMusic,
                          style: theme.typography.bodyStrong,
                        ),
                        AudioAssetField(
                          widget.project,
                          initialValue: config.stageBackgroundMusic.isNotEmpty
                              ? getAssetFromRelativePath(
                                  widget.project, config.stageBackgroundMusic)
                              : null,
                          onAssetSelected: (file) {
                            if (file == null) {
                              config.stageBackgroundMusic = "";
                              return;
                            }

                            config.stageBackgroundMusic =
                                getRelativePathFromAsset(
                              widget.project,
                              file.path,
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appLocal.textColor,
                          style: theme.typography.bodyStrong,
                        ),
                        ColorField(
                          initialValue: config.textColor,
                          onColorSelected: (color) {
                            if (color == null) return;

                            config.textColor = color;
                          },
                        )
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Fade Duration (ms)",
                          style: theme.typography.bodyStrong,
                        ),
                        SizedBox(
                          width: 125,
                          child: NumberBox(
                            value: config.animationDuration.inMilliseconds,
                            onChanged: (newDuration) {
                              setState(() {
                                if (newDuration == null) return;

                                config.animationDuration =
                                    Duration(milliseconds: newDuration);
                              });
                            },
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(15),
              ButtonWithIcon(
                icon: const Icon(FluentIcons.add),
                child: Text(appLocal.newCreditSection),
                onPressed: () {
                  int sectionNumber = config.sections.length + 1;
                  config.sections.add(
                      CreditsSection("Section Name $sectionNumber", "Content"));
                  sectionNameControls.add(TextEditingController(
                      text: "Section Name $sectionNumber"));
                  creditsControls.add(TextEditingController(text: "Content"));
                  setState(() {});
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: config.sections.length,
                itemBuilder: (context, index) {
                  return Container(
                    key: UniqueKey(),
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Expander(
                      header: TextBox(
                        controller: sectionNameControls[index],
                        placeholder: appLocal.creditSectionNamePlaceholder,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextBox(
                            maxLines: null,
                            controller: creditsControls[index],
                            placeholder:
                                appLocal.creditSectionContentPlaceholder,
                          ),
                          const Gap(10),
                          CommandBar(
                            mainAxisAlignment: MainAxisAlignment.center,
                            compactBreakpointWidth: 600,
                            overflowBehavior: CommandBarOverflowBehavior.wrap,
                            primaryItems: [
                              CommandBarButton(
                                onPressed: () {
                                  config.sections.removeAt(index);
                                  sectionNameControls.removeAt(index);
                                  creditsControls.removeAt(index);
                                  setState(() {});
                                },
                                icon: const Icon(FluentIcons.delete),
                                label: Text(appLocal.delete),
                              ),
                              CommandBarButton(
                                icon: const Icon(FluentIcons.up),
                                onPressed: () {
                                  int newIndex = index - 1;
                                  if (newIndex < 0) {
                                    return;
                                  }
                                  cloneAndMoveCreditsSection(index, newIndex);
                                  setState(() {});
                                },
                                label: Text(appLocal.moveUp),
                              ),
                              CommandBarButton(
                                icon: const Icon(FluentIcons.down),
                                onPressed: () {
                                  int newIndex = index + 1;
                                  if (newIndex >= config.sections.length) {
                                    return;
                                  }
                                  cloneAndMoveCreditsSection(index, newIndex);
                                  setState(() {});
                                },
                                label: Text(appLocal.moveDown),
                              ),
                            ],
                          ),
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
    );
  }
}
