import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/views/project_related/asset_picker.dart';

class AssetField<F extends FileSystemEntity> extends StatefulWidget {
  const AssetField(
    this.project, {
    super.key,
    this.onAssetSelected,
    this.initialValue,
  });

  final Project project;
  final F? initialValue;
  final void Function(F?)? onAssetSelected;

  @override
  State<AssetField> createState() => AssetFieldState<F>();
}

class AssetFieldState<F extends FileSystemEntity> extends State<AssetField<F>> {
  F? entity;

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
      mainAxisSize: MainAxisSize.min,
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
                    entity = value.entity as F?;
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
