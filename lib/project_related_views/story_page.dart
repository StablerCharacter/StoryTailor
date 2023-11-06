import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '/game_objects/project.dart';
import '../story_structure/branch.dart';
import '../story_structure/chapter.dart';
import '../story_structure/dialog.dart';
import '../story_structure/story_manager.dart';
import '../utils/string_utility.dart';

class StoryPage extends StatefulWidget {
  const StoryPage(this.project, {super.key});

  final Project project;

  @override
  State<StatefulWidget> createState() => _StoryPageState();
}

enum StoryObjects { storyManager, chapter, branch, dialog }

class _StoryPageState extends State<StoryPage> {
  String selectedBranch = "";
  int selectedChapterIndex = 0;
  int selectedDialogIndex = -1;
  StoryObjects currentlyViewingObject = StoryObjects.storyManager;
  StoryManager get story => widget.project.story;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    story.storyDirectory ??=
        Directory("${widget.project.projectDirectory.path}/story/");
    story.saveChaptersToFile();

    super.deactivate();
  }

  String getViewingName(AppLocalizations appLocal) {
    switch (currentlyViewingObject) {
      case StoryObjects.storyManager:
        return appLocal.chapters;
      case StoryObjects.chapter:
        return appLocal.branches;
      case StoryObjects.branch:
        return appLocal.dialogs;
      case StoryObjects.dialog:
        return appLocal.dialog;
    }
  }

  String getViewingPath() {
    String chapterName = "";

    if (story.chapters.isNotEmpty) {
      chapterName = story.chapters[selectedChapterIndex].name;
    }

    switch (currentlyViewingObject) {
      case StoryObjects.storyManager:
        return "";
      case StoryObjects.chapter:
        return "Branches inside $chapterName";
      case StoryObjects.branch:
        return "Dialogs inside branch $selectedBranch ($chapterName)";
      case StoryObjects.dialog:
        return "A dialog inside $selectedBranch ($chapterName)";
    }
  }

  Widget getCurrentObjectList(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    switch (currentlyViewingObject) {
      case StoryObjects.storyManager:
        if (story.chapters.isEmpty) {
          return const Text("No chapters...");
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: story.chapters.length,
          itemBuilder: (context, index) {
            return Slidable(
              endActionPane: ActionPane(
                extentRatio: 1 / 5,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.typography.body!.color,
                    onPressed: (context) {
                      story.chapters[index].chaptersFile!.deleteSync();
                      story.chapters.removeAt(index);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(5),
                    icon: FluentIcons.delete,
                  ),
                ],
              ),
              child: ListTile(
                title: Text(story.chapters[index].name),
                onPressed: () {
                  setState(() {
                    selectedChapterIndex = index;
                    story.chapters[index].loadFromFile();
                    currentlyViewingObject = StoryObjects.chapter;
                  });
                },
              ),
            );
          },
        );
      case StoryObjects.chapter:
        Chapter current = story.chapters[selectedChapterIndex];
        if (current.branches == null) current.loadFromFile();
        List<String> branchNames = current.branches!.keys.toList();
        return Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              InfoLabel(
                label: appLocal.chapterName,
                labelStyle: theme.typography.bodyStrong,
              ),
              TextBox(
                controller: TextEditingController(text: current.newName ?? current.name),
                onChanged: (newValue) => current.newName = newValue,
              ),
              const SizedBox(height: 15),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: branchNames.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    endActionPane: branchNames[index] == "main"
                        ? null
                        : ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 1 / 5,
                            children: [
                              SlidableAction(
                                backgroundColor: theme.cardColor,
                                foregroundColor: theme.typography.body!.color,
                                onPressed: (context) {
                                  current.branches?.remove(branchNames[index]);
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(5),
                                icon: FluentIcons.delete,
                              ),
                            ],
                          ),
                    child: ListTile(
                      title: Text(branchNames[index]),
                      onPressed: () {
                        setState(() {
                          selectedBranch = branchNames[index];
                          currentlyViewingObject = StoryObjects.branch;
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      case StoryObjects.branch:
        Branch current =
            story.chapters[selectedChapterIndex].branches![selectedBranch]!;
        return Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: current.dialogs.length,
            itemBuilder: (context, index) {
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 1 / 5,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: theme.cardColor,
                      foregroundColor: theme.typography.body!.color,
                      borderRadius: BorderRadius.circular(5),
                      onPressed: (context) {
                        setState(() {
                          current.dialogs.removeAt(index);
                        });
                      },
                      icon: FluentIcons.delete,
                    ),
                  ],
                ),
                child: ListTile(
                  onPressed: () {
                    setState(() {
                      selectedDialogIndex = index;
                      currentlyViewingObject = StoryObjects.dialog;
                    });
                  },
                  title: Text(limitDisplayStringLength(
                      current.dialogs[index].text, 30)),
                ),
              );
            },
          ),
        );
      case StoryObjects.dialog:
        Dialog current = story.chapters[selectedChapterIndex]
            .branches![selectedBranch]!.dialogs[selectedDialogIndex];
        return Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              children: [
                InfoLabel(
                  label: appLocal.dialogContent,
                  labelStyle: theme.typography.bodyStrong,
                ),
                TextBox(
                  controller: TextEditingController(text: current.text),
                  placeholder: appLocal.dialogContentPlaceholder,
                  onChanged: (newValue) => current.text = newValue,
                  maxLines: null,
                )
              ],
            ));
    }
  }

  void goUp() {
    switch (currentlyViewingObject) {
      case StoryObjects.storyManager:
        throw UnimplementedError(
            "This isn't supposed to be called. Can't go above root level.");
      case StoryObjects.chapter:
        currentlyViewingObject = StoryObjects.storyManager;
        story.saveChapterToFile(selectedChapterIndex).then(
            (value) => story.chapters[selectedChapterIndex].branches = null);
        break;
      case StoryObjects.branch:
        currentlyViewingObject = StoryObjects.chapter;
        break;
      case StoryObjects.dialog:
        currentlyViewingObject = StoryObjects.branch;
        break;
    }
  }

  void addNew(BuildContext context) async {
    String name = "";
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        switch (currentlyViewingObject) {
          case StoryObjects.storyManager:
            return ContentDialog(
              title: Text(appLocal.newChapter),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InfoLabel(label: appLocal.chapterName),
                  TextBox(
                    placeholder: appLocal.chapterNamePlaceholder,
                    onChanged: (newValue) => name = newValue,
                  ),
                ],
              ),
              actions: [
                FilledButton(
                    child: Text(appLocal.create),
                    onPressed: () {
                      setState(() {
                        story.chapters.add(
                          Chapter(name, {
                            "main": Branch(<Dialog>[]),
                          }),
                        );
                        Navigator.pop(context);
                      });
                    }),
                HyperlinkButton(
                    child: Text(appLocal.cancel),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          case StoryObjects.chapter:
            return ContentDialog(
              title: Text(appLocal.newBranch),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InfoLabel(label: appLocal.branchName),
                  TextBox(
                    placeholder: appLocal.branchNamePlaceholder,
                    onChanged: (newValue) => name = newValue,
                  ),
                ],
              ),
              actions: [
                FilledButton(
                    child: Text(appLocal.create),
                    onPressed: () {
                      setState(() {
                        story.chapters[selectedChapterIndex].branches!
                            .addEntries({
                          name: Branch(<Dialog>[]),
                        }.entries);
                        Navigator.pop(context);
                      });
                    }),
                HyperlinkButton(
                    child: Text(appLocal.cancel),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          case StoryObjects.branch:
            return ContentDialog(
              title: Text(appLocal.newDialog),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InfoLabel(label: appLocal.dialogContent),
                  TextBox(
                    placeholder: appLocal.dialogContentPlaceholder,
                    onChanged: (newValue) => name = newValue,
                  ),
                ],
              ),
              actions: [
                FilledButton(
                    child: Text(appLocal.create),
                    onPressed: () {
                      setState(() {
                        story.chapters[selectedChapterIndex]
                            .branches![selectedBranch]!.dialogs
                            .add(Dialog(name));
                        Navigator.pop(context);
                      });
                    }),
                HyperlinkButton(
                    child: Text(appLocal.cancel),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          case StoryObjects.dialog:
            return const ContentDialog();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Column(
            children: [
              Text(appLocal.story, style: theme.typography.titleLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      currentlyViewingObject == StoryObjects.storyManager
                          ? Container()
                          : IconButton(
                              icon: const Icon(
                                FluentIcons.up,
                                size: 22,
                              ),
                              onPressed: () => setState(() {
                                goUp();
                              }),
                            ),
                      currentlyViewingObject == StoryObjects.dialog
                          ? Container()
                          : IconButton(
                              icon: const Icon(
                                FluentIcons.add,
                                size: 22,
                              ),
                              onPressed: () => addNew(context),
                            ),
                    ],
                  ),
                  Text(getViewingName(appLocal),
                      style: theme.typography.subtitle),
                ],
              ),
              Text(
                getViewingPath(),
                textAlign: TextAlign.center,
              ),
              getCurrentObjectList(context),
            ],
          ),
        ),
      ),
    );
  }
}
