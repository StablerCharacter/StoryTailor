import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_character/flame_character.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/components/audio_player_widget.dart';
import 'package:storytailor/l10n/app_localizations.dart';
import 'package:storytailor/project.dart';
import 'package:storytailor/utils/assets_utility.dart';
import 'package:storytailor/views/advanced_audio_file_config.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '/components/button_with_icon.dart';
import '/utils/size_unit_conversion.dart';
import '/views/code_page.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage(this.project, {super.key});

  static const Set<String> imageExt = {
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".bmp",
  };

  static final Set<String> audioExt =
      windowsAudioFormat.union(androidAudioFormat).union(linuxAudioFormat);

  /// Audio containers supported by Windows according to
  /// https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation
  ///
  /// 3GPP is not added to this list because it can be both audio and video.
  static const Set<String> windowsAudioFormat = {
    ".asf",
    ".wma",
    ".aac",
    ".adts",
    ".mp3",
    ".m4a",
    ".mov",
    ".wav",
  };

  /// Audio containers supported by Android according to
  /// https://developer.android.com/guide/topics/media/platform/supported-formats
  ///
  /// 3GPP & Matroska is not added to this list because it can be both audio and video.
  static const Set<String> androidAudioFormat = {
    ".m4a",
    ".ogg",
    ".wav",
    ".mp3",
    ".flac",
    ".aac"
  };

  /// Some of the audio containers supported by Linux according to
  /// https://gstreamer.freedesktop.org/documentation/plugin-development/advanced/media-types.html?gi-language=c#table-of-audio-types
  /// https://www.iana.org/assignments/media-types/media-types.xhtml#audio
  static const Set<String> linuxAudioFormat = {
    ".aac",
    ".m4a",
    ".mp3",
    ".oga",
    ".ogg",
    ".spx",
    ".opus",
    ".flac",
    ".wma",
    ".wav"
  };

  final Project project;

  /// Get directory structure as a TreeViewItem.
  ///
  /// The result will only include the file format in the `formatFilter` set.
  /// If the set is empty, The result won't be filtered.
  /// However, This method will **never** return metadata files. (`*.meta`)
  ///
  /// Example:
  /// ```dart
  /// AssetsPage.getDirTree(dir, [".png", ".jpg"]);
  /// ```
  static List<TreeViewItem> getDirTree(Directory dir,
      {Set<String> formatFilter = const {}}) {
    List<TreeViewItem> dirTree = [];

    dir.listSync().forEach((entity) {
      String basename = p.basename(entity.path);
      if (entity is File) {
        String fileExt = p.extension(entity.path);

        if (formatFilter.isNotEmpty && !formatFilter.contains(fileExt)) {
          return;
        }

        if (fileExt == ".meta") {
          return;
        }

        if (AssetsPage.imageExt.contains(fileExt)) {
          dirTree.add(
            TreeViewItem(
              content: Text(basename),
              leading: const Icon(LineIcons.imageFile),
              value: entity,
            ),
          );
        } else if (AssetsPage.audioExt.contains(fileExt)) {
          dirTree.add(
            TreeViewItem(
              content: Text(basename),
              leading: const Icon(LineIcons.audioFile),
              value: entity,
            ),
          );
        } else {
          dirTree.add(
            TreeViewItem(
              content: Text(basename),
              leading: const Icon(FluentIcons.page),
              value: entity,
            ),
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
            value: entity,
          ),
        );
      }
    });

    return dirTree;
  }

  @override
  State<StatefulWidget> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  FlyoutController newEntityFlyoutControl = FlyoutController();
  late Directory assetsFolder;

  @override
  void initState() {
    assetsFolder = Directory("${widget.project.projectDirectory.path}/assets/");

    super.initState();
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextBox(controller: fileName),
              ],
            ),
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
                      displayInfoBar(
                        context,
                        builder: (context, close) =>
                            const InfoBar(title: Text("File renamed.")),
                      );
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

    return ScaffoldPage.scrollable(
      children: [
        DropRegion(
          formats: Formats.standardFormats,
          onDropOver: (DropOverEvent event) {
            if (event.session.allowedOperations.contains(DropOperation.copy)) {
              return DropOperation.copy;
            } else {
              return DropOperation.none;
            }
          },
          onPerformDrop: (PerformDropEvent event) async {
            for (final item in event.session.items) {
              item.dataReader!.getFile(null, (file) async {
                if (file.fileName == null) {
                  return;
                }
                File targetFile = File("${assetsFolder.path}${file.fileName!}")
                  ..createSync();
                IOSink sink = targetFile.openWrite();
                await sink.addStream(file.getStream());
                await sink.flush();
                sink.close();
                setState(() {});
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Text(
                  appLocal.assets,
                  style: theme.typography.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Flex(
                      direction: constraints.maxWidth >= 400
                          ? Axis.horizontal
                          : Axis.vertical,
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
                        const Gap(5),
                        FlyoutTarget(
                          controller: newEntityFlyoutControl,
                          child: ButtonWithIcon(
                            icon: const Icon(FluentIcons.add),
                            child: Text(appLocal.newBtn),
                            onPressed: () {
                              newEntityFlyoutControl.showFlyout(
                                  builder: (context) {
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
                        const Gap(5),
                        ButtonWithIcon(
                          icon: const Icon(FluentIcons.refresh),
                          child: Text(appLocal.refresh),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    );
                  }),
                ),
                TreeView(
                  selectionMode: TreeViewSelectionMode.single,
                  onSelectionChanged: (selected) async {
                    if (selected.isEmpty) return;

                    FileSystemEntity entity =
                        selected.single.value as FileSystemEntity;
                    if (entity is File) {
                      String basename = p.basename(entity.path);
                      String extension = p.extension(entity.path);

                      ListTile renameFileTile = ListTile(
                        leading: const Icon(FluentIcons.rename),
                        title: Text(appLocal.renameFile),
                        onPressed: () {
                          showFileRenameDialog(
                            context,
                            entity,
                            () {
                              Navigator.pop(context);
                              setState(() {});
                            },
                          );
                        },
                      );
                      ListTile deleteFileTile = ListTile(
                        leading: const Icon(FluentIcons.delete),
                        title: Text(appLocal.delete),
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => ContentDialog(
                              title: Text(appLocal.deleteFile),
                              content: Text(appLocal.fileDeletionConfirmation),
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
                              entity.delete().then((_) => setState(() {}));
                            }
                          });
                        },
                      );
                      String fileSize =
                          SizeUnitConversion.bytesToAppropriateUnits(
                              entity.lengthSync());

                      if (AssetsPage.imageExt.contains(extension)) {
                        var decodedImage = await decodeImageFromList(
                            await entity.readAsBytes());
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return ContentDialog(
                              content: ListView(
                                shrinkWrap: true,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(LineIcons.imageFile,
                                                size: 18),
                                            const Gap(5),
                                            Text(
                                              basename,
                                              style: theme.typography.bodyLarge,
                                            ),
                                          ],
                                        ),
                                        const Gap(5),
                                        Image.file(entity,
                                            height: 200,
                                            alignment: Alignment.centerLeft),
                                        const Gap(5),
                                        Text(
                                          appLocal.imageResolution(
                                            decodedImage.width,
                                            decodedImage.height,
                                          ),
                                        ),
                                        Text(
                                          appLocal.fileSize(fileSize),
                                        ),
                                      ],
                                    ),
                                  ),
                                  renameFileTile,
                                  deleteFileTile,
                                ],
                              ),
                            );
                          },
                        );
                      } else if (AssetsPage.audioExt.contains(extension)) {
                        bool isSupported = true;
                        File metaFile = getMetadataFile(entity);
                        KeyValueDatabase? db;
                        File? alternativeVersion;

                        if (metaFile.existsSync()) {
                          db = KeyValueDatabase(metaFile);
                          await db.loadFromFileAsync();
                        }

                        if (Platform.isWindows &&
                            !AssetsPage.windowsAudioFormat
                                .contains(extension)) {
                          // See if the audio contain an alternative version for Windows
                          if (db != null && db.data["windows"] != null) {
                            alternativeVersion = db.data["windows"];
                          } else {
                            isSupported = false;
                          }
                        }

                        if (!context.mounted) {
                          return;
                        }

                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return ContentDialog(
                                content: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ListTile(
                                      leading: const Icon(LineIcons.audioFile),
                                      title: Text(
                                        basename,
                                        style: theme.typography.bodyStrong,
                                      ),
                                    ),
                                    isSupported
                                        ? AudioPlayerWidget(
                                            DeviceFileSource(
                                              alternativeVersion == null
                                                  ? entity.path
                                                  : alternativeVersion.path,
                                            ),
                                          )
                                        : Text(appLocal.audioNotSupported),
                                    Text(
                                      appLocal.fileSize(fileSize),
                                    ),
                                    renameFileTile,
                                    ListTile(
                                      leading: const Icon(
                                          FluentIcons.document_management),
                                      title: Text(appLocal.advancedOptions),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          FluentPageRoute(
                                            builder: (context) =>
                                                AdvancedAudioFileConfig(
                                              entity,
                                              updateCallback: () =>
                                                  setState(() {}),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    deleteFileTile,
                                  ],
                                ),
                              );
                            });
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return ContentDialog(
                              content: ListView(
                                shrinkWrap: true,
                                children: [
                                  ListTile(
                                    leading: const Icon(FluentIcons.page),
                                    title: Text(basename,
                                        style: theme.typography.bodyStrong),
                                  ),
                                  Text(
                                    appLocal.fileSize(fileSize),
                                  ),
                                  ListTile(
                                    title: Text(appLocal.editAsText),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        FluentPageRoute(
                                          builder: (context) => CodeView(
                                            entity,
                                            onFileDelete: () => setState(() {}),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  renameFileTile,
                                  deleteFileTile,
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                  items: [
                    TreeViewItem(
                      content: Text(appLocal.assets,
                          style: theme.typography.bodyStrong),
                      expanded: true,
                      leading: const Icon(FluentIcons.fabric_folder),
                      collapsable: false,
                      value: assetsFolder,
                      children: AssetsPage.getDirTree(assetsFolder),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
