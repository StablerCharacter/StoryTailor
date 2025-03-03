import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/utils/size_unit_conversion.dart';
import 'package:storytailor/views/project_related/assets_page.dart';

Future<AssetPickerFileWrapper?> showAssetPicker(
    BuildContext context, Project project,
    {Set<String> fileFormats = const {}}) {
  return Navigator.push<AssetPickerFileWrapper>(
    context,
    FluentDialogRoute(
        builder: (_) => AssetPicker(project, fileFormats), context: context),
  );
}

class AssetPickerFileWrapper {
  FileSystemEntity? entity;
  bool isClearingField = false;

  AssetPickerFileWrapper(this.entity, {this.isClearingField = false});
}

class AssetPicker extends StatefulWidget {
  const AssetPicker(this.project, this.fileFormats, {super.key});

  final Set<String> fileFormats;
  final Project project;

  @override
  State<AssetPicker> createState() => _AssetPickerState();
}

class _AssetPickerState extends State<AssetPicker> {
  late Directory assetsFolder;

  @override
  void initState() {
    assetsFolder = Directory("${widget.project.projectDirectory.path}/assets/");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return Container(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Acrylic(),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: TreeView(
                selectionMode: TreeViewSelectionMode.single,
                onSelectionChanged: (selected) async {
                  if (selected.isEmpty) return;

                  if (selected.single.value == null) {
                    Navigator.pop(context,
                        AssetPickerFileWrapper(null, isClearingField: true));
                    return;
                  }

                  FileSystemEntity entity =
                      selected.single.value as FileSystemEntity;
                  if (entity is File) {
                    String basename = p.basename(entity.path);

                    if (AssetsPage.imageExt
                        .contains(p.extension(entity.path))) {
                      var decodedImage =
                          await decodeImageFromList(await entity.readAsBytes());
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: Text(basename),
                            content: ListView(
                              shrinkWrap: true,
                              children: [
                                // Text(
                                //   basename,
                                //   style: theme.typography.bodyLarge,
                                //   textAlign: TextAlign.center,
                                // ),
                                Image.file(
                                  entity,
                                  height: 300,
                                ),
                                Text(
                                  appLocal.imageResolution(
                                    decodedImage.width,
                                    decodedImage.height,
                                  ),
                                  textAlign: TextAlign.center,
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
                                  child: Text(appLocal.chooseFile),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context,
                                        AssetPickerFileWrapper(entity));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: Text(basename),
                            content: ListView(
                              shrinkWrap: true,
                              children: [
                                // ListTile(
                                //   leading: const Icon(FluentIcons.page),
                                //   title: Text(basename,
                                //       style: theme.typography.bodyStrong),
                                // ),
                                ListTile(
                                  title: Text(appLocal.chooseFile),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context,
                                        AssetPickerFileWrapper(entity));
                                  },
                                ),
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
                    content: Text(appLocal.noneFile),
                    value: null,
                  ),
                  TreeViewItem(
                    content: Text(appLocal.assets,
                        style: theme.typography.bodyStrong),
                    expanded: true,
                    leading: const Icon(FluentIcons.fabric_folder),
                    collapsable: false,
                    value: assetsFolder,
                    children: AssetsPage.getDirTree(assetsFolder,
                        formatFilter: widget.fileFormats),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
