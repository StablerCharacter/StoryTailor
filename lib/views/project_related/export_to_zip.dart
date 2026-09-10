import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/l10n/app_localizations.dart';
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
      AppLocalizations appLocal = AppLocalizations.of(context)!;

      Navigator.pop(context);

      if (Platform.isAndroid || Platform.isIOS) {
        SharePlus.instance.share(ShareParams(files: [XFile(widget.fileName)]));
      } else {
        FilePicker
            .saveFile(fileName: "${p.basename(widget.directory.path)}.zip", bytes: File(widget.fileName).readAsBytesSync())
            .then((path) async {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(appLocal.savedTo(path?.toString() ?? widget.fileName)),
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
