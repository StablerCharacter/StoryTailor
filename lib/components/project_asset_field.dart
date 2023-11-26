import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/views/project_related/asset_picker.dart';

class ProjectAssetField extends StatefulWidget {
  const ProjectAssetField(
    this.project, {
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
        this.onAssetSelected,
        this.initialValue,
  });

  final Project project;
  final MainAxisAlignment mainAxisAlignment;
  final FileSystemEntity? initialValue;
  final Function(FileSystemEntity)? onAssetSelected;

  @override
  State<ProjectAssetField> createState() => _ProjectAssetFieldState();
}

class _ProjectAssetFieldState extends State<ProjectAssetField> {
  FileSystemEntity? entity;

  @override
  void initState() {
    super.initState();

    entity = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      children: [
        Container(
          padding: kDefaultButtonPadding,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: Text(
            entity == null ? appLocal.noFileSelected : p.basename(entity!.path),
          ),
        ),
        const Gap(5),
        Tooltip(
          message: appLocal.chooseFile,
          child: IconButton(
            icon: const Icon(FluentIcons.open_file),
            onPressed: () {
              showAssetPicker(
                context,
                widget.project,
              ).then(
                (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    entity = value.entity;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
