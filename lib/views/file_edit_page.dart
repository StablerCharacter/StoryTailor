import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/components/button_with_icon.dart';

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
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          p.basename(widget.file.path),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          ButtonWithIcon(
            icon: const Icon(Icons.save),
            child: const Text("Save"),
            onPressed: () {
              widget.file.writeAsString(textFieldControl.text).then(
                (value) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("File saved successfully."),
                      ),
                    );
                  }
                },
              );
            },
          )
        ],
      ),
      body: TextField(
        controller: textFieldControl,
        style: GoogleFonts.jetBrainsMono(),
        maxLines: null,
      ),
    );
  }
}
