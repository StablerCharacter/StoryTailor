import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

import 'package:storytailor/game_objects/project.dart';
import 'package:storytailor/views/project_related/asset_picker.dart';
import 'package:storytailor/views/project_related/assets_page.dart';

class ImageAssetField extends StatefulWidget {
  const ImageAssetField(
    this.project, {
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.onImageSelected,
    this.initialValue,
  });

  final File? initialValue;
  final Project project;
  final MainAxisAlignment mainAxisAlignment;
  final Function(File?)? onImageSelected;

  @override
  State<ImageAssetField> createState() => _ImageAssetFieldState();
}

class _ImageAssetFieldState extends State<ImageAssetField> {
  File? entity;

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
            image: entity != null
                ? DecorationImage(
                    image: FileImage(entity!),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  )
                : null,
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
              showAssetPicker(context, widget.project,
                      fileFormats: AssetsPage.imageExt)
                  .then(
                (value) {
                  if (value == null) {
                    return;
                  }

                  if (value.isClearingField) {
                    entity = null;
                  }

                  if (value.entity != null && value.entity is File) {
                    entity = value.entity as File?;
                  }

                  if (widget.onImageSelected != null) {
                    widget.onImageSelected!(entity);
                  }
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
