import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/components/asset_field.dart';
import 'package:storytailor/views/project_related/asset_picker.dart';
import 'package:storytailor/views/project_related/assets_page.dart';

class ImageAssetField extends AssetField<File> {
  const ImageAssetField(
    super.project, {
    super.key,
    super.onAssetSelected,
    super.initialValue,
  });

  @override
  State<AssetField<File>> createState() => _ImageAssetFieldState();
}

class _ImageAssetFieldState extends AssetFieldState<File> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: theme.buttonTheme.padding,
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
            icon: const Icon(Icons.file_open),
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

                  if (widget.onAssetSelected != null) {
                    widget.onAssetSelected!(entity);
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
