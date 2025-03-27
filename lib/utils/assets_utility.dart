import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:storytailor/project.dart';

/// Returns a metadata file of the input file.
///
/// The method does not guarantee that the output file will exist.
File getMetadataFile(File file) {
  return File(
      "${p.dirname(file.path)}/${p.basenameWithoutExtension(file.path)}.meta");
}

String getRelativePathFromAsset(Project project, String path) {
  return p.relative(
    path,
    from: "${project.projectDirectory.path}/assets/",
  );
}

File getAssetFromRelativePath(Project project, String path) {
  return File("${project.projectDirectory.path}/assets/$path");
}
