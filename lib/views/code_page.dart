import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/python.dart';
import 'package:path/path.dart' as p;
import 'package:system_theme/system_theme.dart';

import 'file_edit_page.dart';

class CodeView extends StatefulWidget {
  final File file;
  final void Function()? onFileDelete;

  const CodeView(this.file, {super.key, this.onFileDelete});

  @override
  State<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeView> {
  CodeController codeController = CodeController();
  List<bool> buttonHoverStates = [false, false, false];

  @override
  void initState() {
    widget.file.readAsString().then((value) => codeController.text = value);
    setLanguageByFileExt();

    super.initState();
  }

  void setLanguageByFileExt() {
    String extension = p.extension(widget.file.path);

    switch (extension) {
      case ".py":
        codeController.language = python;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemAccentColor accentColor = SystemTheme.accentColor;
    ButtonStyle filledButtonStyle = ButtonStyle(
        backgroundColor: MaterialStateProperty.all(accentColor.accent));

    return Scaffold(
      backgroundColor:
          androidstudioTheme["root"]?.backgroundColor ?? Colors.grey.shade900,
      appBar: AppBar(
        title: Text(p.basename(widget.file.path)),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(FluentIcons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileEditPage(widget.file),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: CodeTheme(
          data: CodeThemeData(styles: androidstudioTheme),
          child: CodeField(
            textStyle: GoogleFonts.jetBrainsMono(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
            wrap: true,
            controller: codeController,
            readOnly: true,
          ),
        ),
      ),
    );
  }
}
