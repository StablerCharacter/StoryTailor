import 'dart:io';

import 'package:path/path.dart' as p;

/// Returns a metadata file of the input file.
///
/// The method does not guarantee that the output file will exist.
File getMetadataFile(File file) {
  return File("${p.dirname(file.path)}/${p.basenameWithoutExtension(file.path)}.meta");
}