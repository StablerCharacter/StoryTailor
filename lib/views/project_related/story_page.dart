import 'dart:io';

import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '/game_objects/project.dart';
import '/story_structure/branch.dart';
import '/story_structure/chapter.dart';
import '/story_structure/dialog.dart';
import '/story_structure/story_manager.dart';
import '/utils/string_utility.dart';

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
  Future<void>? loadingChapters;

  @override
  void initState() {
    super.initState();

    loadingChapters = story.loadChaptersFromDirectory();
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
    ThemeData theme = Theme.of(context);
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
                    foregroundColor: theme.textTheme.bodyMedium!.color,
                    onPressed: (context) {
                      story.chapters[index].chaptersFile!.deleteSync();
                      story.chapters.removeAt(index);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(5),
                    icon: Icons.delete,
                  ),
                ],
              ),
              child: ListTile(
                title: Text(story.chapters[index].name),
                onTap: () {
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
              Text(
                appLocal.chapterName,
                style: theme.textTheme.bodyLarge,
              ),
              TextField(
                controller: TextEditingController(
                    text: current.newName ?? current.name),
                decoration: InputDecoration(border: OutlineInputBorder()),
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
                                foregroundColor:
                                    theme.textTheme.bodyMedium!.color,
                                onPressed: (context) {
                                  current.branches?.remove(branchNames[index]);
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(5),
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                    child: ListTile(
                      title: Text(branchNames[index]),
                      onTap: () {
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
                      foregroundColor: theme.textTheme.bodyMedium!.color,
                      borderRadius: BorderRadius.circular(5),
                      onPressed: (context) {
                        setState(() {
                          current.dialogs.removeAt(index);
                        });
                      },
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
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
                Text(
                  appLocal.dialogContent,
                  style: theme.textTheme.bodyLarge,
                ),
                TextField(
                  controller: TextEditingController(text: current.text),
                  decoration: InputDecoration(
                    hintText: appLocal.dialogContentPlaceholder,
                    border: OutlineInputBorder(),
                  ),
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
            return AlertDialog(
              title: Text(appLocal.newChapter),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appLocal.chapterName),
                  TextField(
                    decoration: InputDecoration(
                        hintText: appLocal.chapterNamePlaceholder),
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
                        story.saveChapterToFile(story.chapters.length - 1);
                        Navigator.pop(context);
                      });
                    }),
                TextButton(
                    child: Text(appLocal.cancel),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          case StoryObjects.chapter:
            return AlertDialog(
              title: Text(appLocal.newBranch),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appLocal.branchName),
                  TextField(
                    decoration: InputDecoration(
                        hintText: appLocal.branchNamePlaceholder),
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
                TextButton(
                    child: Text(appLocal.cancel),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          case StoryObjects.branch:
            return AlertDialog(
              title: Text(appLocal.newDialog),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appLocal.dialogContent),
                  TextField(
                    decoration: InputDecoration(
                        hintText: appLocal.dialogContentPlaceholder),
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
                TextButton(
                  child: Text(appLocal.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          case StoryObjects.dialog:
            return const AlertDialog();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: currentlyViewingObject == StoryObjects.dialog
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add), onPressed: () => addNew(context)),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Column(
            children: [
              Text(appLocal.story, style: theme.textTheme.titleLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  currentlyViewingObject == StoryObjects.storyManager
                      ? Container()
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_upward,
                            size: 22,
                          ),
                          onPressed: () => setState(() {
                            goUp();
                          }),
                        ),
                  Text(
                    getViewingName(appLocal),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                getViewingPath(),
                textAlign: TextAlign.center,
              ),
              FutureBuilder(
                  future: loadingChapters,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return getCurrentObjectList(context);
                    }

                    return const CircularProgressIndicator();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
