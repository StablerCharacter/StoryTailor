import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class ExportProjectToZip extends StatefulWidget {
  const ExportProjectToZip(this.directory, this.fileName, {super.key});

  final Directory directory;
  final String fileName;

  @override
  State<ExportProjectToZip> createState() => _ExportProjectToZipState();
}

class _ExportProjectToZipState extends State<ExportProjectToZip> {
  double compressProgress = 0;

  @override
  void initState() {
    super.initState();

    ZipFileEncoder().zipDirectory(
      widget.directory,
      filename: widget.fileName,
      onProgress: (progress) {
        setState(() {
          compressProgress = progress;
        });
      },
    ).then((_) {
      if (!context.mounted) return;
      Navigator.pop(context);

      if (Platform.isAndroid || Platform.isIOS) {
        Share.shareXFiles([XFile(widget.fileName)]);
      } else {
        FilePicker.platform
            .saveFile(fileName: "${p.basename(widget.directory.path)}.zip")
            .then((path) async {
          AppLocalizations appLocal = AppLocalizations.of(context)!;

          if (path != null) {
            File oldFile = File(widget.fileName);
            await oldFile.copy(path);
            await oldFile.delete();
          }

          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(appLocal.savedTo(path ?? widget.fileName)),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(appLocal.exportingProject),
      content: Container(
        alignment: Alignment.center,
        child: ProgressBar(value: compressProgress * 100),
      ),
    );
  }
}
