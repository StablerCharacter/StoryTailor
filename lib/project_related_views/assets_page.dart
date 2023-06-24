import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import '/game_objects/project.dart';
import '/views/code_page.dart';
import '/components/button_with_icon.dart';
import '/utils/size_unit_conversion.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage(this.project, {super.key});

  final Project project;

  @override
  State<StatefulWidget> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  static const List<String> imageExt = [
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".bmp"
  ];

  FlyoutController newEntityFlyoutControl = FlyoutController();
  late Directory assetsFolder;

  @override
  void initState() {
    assetsFolder = Directory("${widget.project.projectDirectory.path}/assets/");

    super.initState();
  }

  List<TreeViewItem> getDirTree(Directory dir) {
    List<TreeViewItem> dirTree = [];

    dir.listSync().forEach((entity) {
      String basename = p.basename(entity.path);
      if (entity is File) {
        String fileExt = p.extension(entity.path);
        if (imageExt.contains(fileExt)) {
          dirTree.add(
            TreeViewItem(
                content: Text(basename),
                leading: const Icon(FluentIcons.file_image),
                value: entity),
          );
        } else {
          dirTree.add(
            TreeViewItem(
                content: Text(basename),
                leading: const Icon(FluentIcons.page),
                value: entity),
          );
        }
      } else if (entity is Directory) {
        dirTree.add(
          TreeViewItem(
              content: Text(basename),
              leading: const Icon(FluentIcons.fabric_folder),
              lazy: true,
              onExpandToggle: (item, _) async {
                item.children.addAll(getDirTree(entity));
              },
              value: entity),
        );
      }
    });

    return dirTree;
  }

  void showFileRenameDialog(
      BuildContext context, File entity, void Function() onFileRenamed) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    TextEditingController fileName =
        TextEditingController(text: p.basename(entity.path));
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text(appLocal.renameFile),
            content: TextBox(controller: fileName),
            actions: [
              FilledButton(
                child: Text(appLocal.renameFile),
                onPressed: () {
                  Navigator.pop(context);
                  entity
                      .rename(
                    p.join(
                      p.dirname(entity.path),
                      fileName.text,
                    ),
                  )
                      .then(
                    (_) {
                      showSnackbar(context,
                          const Snackbar(content: Text("File renamed.")));
                      onFileRenamed();
                    },
                  );
                },
              ),
              Button(
                child: Text(appLocal.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      content: Container(
        margin: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text(
              appLocal.assets,
              style: theme.typography.titleLarge,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWithIcon(
                    icon: const Icon(FluentIcons.download),
                    child: Text(appLocal.importAssetBtn),
                    onPressed: () {
                      FilePicker.platform
                          .pickFiles(dialogTitle: appLocal.importAssetBtn)
                          .then((value) {
                        if (value != null) {
                          File file = File(value.files.single.path!);
                          String fileName = p.basename(file.path);
                          file
                              .copy("${assetsFolder.path}/$fileName")
                              .then((file) {
                            setState(() {});
                          });
                        }
                      });
                    },
                  ),
                  FlyoutTarget(
                    controller: newEntityFlyoutControl,
                    child: ButtonWithIcon(
                      icon: const Icon(FluentIcons.add),
                      child: Text(appLocal.newBtn),
                      onPressed: () {
                        newEntityFlyoutControl.showFlyout(builder: (context) {
                          return FlyoutContent(
                            child: SizedBox(
                              width: 125,
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Button(
                                    onPressed: () {},
                                    child: const Text("Directory"),
                                  ),
                                  Button(
                                    onPressed: () {},
                                    child: const Text("Text File"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            TreeView(
              selectionMode: TreeViewSelectionMode.single,
              onSelectionChanged: (selected) async {
                if (selected.isEmpty) return;

                FileSystemEntity entity =
                    selected.single.value as FileSystemEntity;
                if (entity is File) {
                  String basename = p.basename(entity.path);

                  if (imageExt.contains(p.extension(entity.path))) {
                    await showBottomSheet(
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Text(
                                basename,
                                style: theme.typography.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              Image.file(
                                entity,
                                height: 300,
                              ),
                              Text(
                                appLocal.fileSize(
                                  SizeUnitConversion.bytesToAppropriateUnits(
                                    entity.lengthSync(),
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              HyperlinkButton(
                                  child: Text(appLocal.renameFile),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showFileRenameDialog(
                                      context,
                                      entity,
                                      () => setState(() {}),
                                    );
                                  }),
                              HyperlinkButton(
                                child: Text(appLocal.delete),
                                onPressed: () {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (context) => ContentDialog(
                                      title: const Text("Delete file"),
                                      content: const Text(
                                          "Do you want to permanently delete the file?"),
                                      actions: [
                                        Button(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                            Navigator.pop(context);
                                          },
                                          child: Text(appLocal.delete),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(appLocal.cancel),
                                        ),
                                      ],
                                    ),
                                  ).then((confirmation) {
                                    if (confirmation ?? false) {
                                      entity
                                          .delete()
                                          .then((_) => setState(() {}));
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    onFileDelete() => setState(() {});

                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => CodeView(
                          entity,
                          onFileDelete: onFileDelete,
                        ),
                      ),
                    );
                  }
                }
              },
              items: [
                TreeViewItem(
                  content:
                      Text(appLocal.assets, style: theme.typography.bodyStrong),
                  expanded: true,
                  leading: const Icon(FluentIcons.fabric_folder),
                  collapsable: false,
                  value: assetsFolder,
                  children: getDirTree(assetsFolder),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
