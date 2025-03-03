import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

class FileEditPage extends StatefulWidget {
  final File file;

  const FileEditPage(this.file, {super.key});

  @override
  State<FileEditPage> createState() => _FileEditState();
}

class _FileEditState extends State<FileEditPage> {
  TextEditingController textFieldControl = TextEditingController();

  @override
  void initState() {
    widget.file.readAsString().then((value) => textFieldControl.text = value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: PageHeader(
          leading: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            p.basename(widget.file.path),
            style: theme.typography.bodyLarge,
          ),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.save),
                label: const Text("Save"),
                onPressed: () {
                  widget.file.writeAsString(textFieldControl.text).then(
                        (value) => displayInfoBar(
                          context,
                          builder: (context, close) => const InfoBar(
                            title: Text("File saved successfully."),
                          ),
                        ),
                      );
                },
              )
            ],
          ),
        ),
      ),
      content: TextBox(
        controller: textFieldControl,
        style: GoogleFonts.jetBrainsMono(),
        maxLines: null,
      ),
    );
  }
}
