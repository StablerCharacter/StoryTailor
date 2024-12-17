import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/views/project_related/assets_page.dart';

Future<AssetPickerFileWrapper?> showAssetPicker(
    BuildContext context, Project project,
    {Set<String> fileFormats = const {}}) {
  return Navigator.push<AssetPickerFileWrapper>(
    context,
    MaterialPageRoute(builder: (_) => AssetPicker(project, fileFormats)),
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
  final TreeController treeController = TreeController();
  final Key assetsFolderKey = Key("assetsFolder");

  @override
  void initState() {
    assetsFolder = Directory("${widget.project.projectDirectory.path}/assets/");

    super.initState();

    treeController.expandNode(assetsFolderKey);
    treeController.nodeSelected.subscribe((value) {
      Navigator.pop(context, AssetPickerFileWrapper(value.value.value));
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TreeView(
              treeController: treeController,
              nodes: [
                TreeNode(
                  content: Text(appLocal.noneFile),
                  value: null,
                ),
                TreeNode(
                  key: assetsFolderKey,
                  content: Row(
                    children: [
                      const Icon(Icons.folder),
                      Text(appLocal.assets),
                    ],
                  ),
                  value: assetsFolder.path,
                  children: AssetsPage.getDirTree(assetsFolder,
                      formatFilter: widget.fileFormats),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
