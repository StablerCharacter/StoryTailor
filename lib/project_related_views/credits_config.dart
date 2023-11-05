import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/components/button_with_icon.dart';
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/utils/list_utility.dart';

class CreditsSection {
  String name;
  String content;

  CreditsSection(this.name, this.content);

  factory CreditsSection.fromMap(Map<String, String> map) {
    return CreditsSection(map["name"]!, map["content"]!);
  }

  Map<String, String> toMap() {
    return {
      "name": name,
      "content": content,
    };
  }
}

class CreditsConfig {
  bool enabled = true;
  List<CreditsSection> sections = [
    CreditsSection("Made with", "Game made with StoryTailor.")
  ];

  CreditsConfig({this.enabled = true});

  factory CreditsConfig.fromMap(Map<String, dynamic> map) {
    CreditsConfig config = CreditsConfig(enabled: map["enabled"]!);

    config.sections = (map["sections"]! as List<dynamic>)
        .map(
          (e) => CreditsSection.fromMap(
            (e as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as String),
            ),
          ),
        )
        .toList();

    return config;
  }

  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "sections": sections.map((e) => e.toMap()).toList(growable: false),
    };
  }
}

class CreditsConfigPage extends StatefulWidget {
  const CreditsConfigPage(this.project, {super.key});

  final Project project;

  @override
  State<CreditsConfigPage> createState() => _CreditsConfigState();
}

class _CreditsConfigState extends State<CreditsConfigPage> {
  _CreditsConfigState();

  CreditsConfig config = CreditsConfig();
  List<TextEditingController> sectionNameControls = [];
  List<TextEditingController> creditsControls = [];
  late File stageFile;

  @override
  void initState() {
    stageFile = File(
        p.join(widget.project.projectDirectory.path, "stages", "credits.json"));
    if (stageFile.existsSync()) {
      config = CreditsConfig.fromMap(jsonDecode(stageFile.readAsStringSync()));
    } else {
      stageFile.create();
      stageFile.writeAsStringSync(jsonEncode(config.toMap()));
    }

    for (CreditsSection section in config.sections) {
      sectionNameControls.add(TextEditingController(text: section.name));
      creditsControls.add(TextEditingController(text: section.content));
    }

    super.initState();
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
              const SizedBox(height: 15),
              ButtonWithIcon(
                  icon: const Icon(FluentIcons.add),
                  child: Text(appLocal.newCreditSection),
                  onPressed: () {
                    int sectionNumber = config.sections.length + 1;
                    config.sections.add(CreditsSection(
                        "Section Name $sectionNumber", "Content"));
                    sectionNameControls.add(TextEditingController(
                        text: "Section Name $sectionNumber"));
                    creditsControls.add(TextEditingController(text: "Content"));
                    setState(() {});
                  }),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ButtonWithIcon(
                                  icon: const Icon(FluentIcons.delete),
                                  onPressed: () {
                                    config.sections.removeAt(index);
                                    sectionNameControls.removeAt(index);
                                    creditsControls.removeAt(index);
                                    setState(() {});
                                  },
                                  child: Text(appLocal.delete),
                                ),
                              ),
                              const Gap(5),
                              Expanded(
                                child: ButtonWithIcon(
                                  icon: const Icon(FluentIcons.up),
                                  onPressed: () {
                                    int newIndex = index - 1;
                                    if (newIndex < 0) {
                                      return;
                                    }
                                    cloneAndMoveCreditsSection(index, newIndex);
                                    setState(() {});
                                  },
                                  child: const Text("Move Up"),
                                ),
                              ),
                              const Gap(5),
                              Expanded(
                                child: ButtonWithIcon(
                                  icon: const Icon(FluentIcons.down),
                                  onPressed: () {
                                    int newIndex = index + 1;
                                    if (newIndex >= config.sections.length) {
                                      return;
                                    }
                                    cloneAndMoveCreditsSection(index, newIndex);
                                    setState(() {});
                                  },
                                  child: const Text("Move Down"),
                                ),
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
