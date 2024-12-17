import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

import 'file_edit_page.dart';

class CodeView extends StatefulWidget {
  final File file;
  final void Function()? onFileDelete;

  const CodeView(this.file, {super.key, this.onFileDelete});

  @override
  State<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeView> {
  String language = "";
  late Future<String> code;

  @override
  void initState() {
    code = widget.file.readAsString();
    setLanguageByFileExt();

    super.initState();
  }

  void setLanguageByFileExt() {
    String extension = p.extension(widget.file.path);

    switch (extension) {
      case ".py":
        language = "python";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          androidstudioTheme["root"]?.backgroundColor ?? Colors.grey.shade900,
      appBar: AppBar(
        title: Text(p.basename(widget.file.path)),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
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
        child: FutureBuilder(
          future: code,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return HighlightView(
                snapshot.data!,
                language: language,
                theme: androidstudioTheme,
                padding: const EdgeInsets.all(15),
                tabSize: 4,
                textStyle: GoogleFonts.jetBrainsMono(),
              );
            } else {
              return const CircularProgressIndicator.adaptive();
            }
          },
        ),
      ),
    );
  }
}
