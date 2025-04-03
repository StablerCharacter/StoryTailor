import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytailor/ffmpeg/ffprobe_output.dart';

enum FfmpegProgressPhase { inactive, downloading, decompressing }

class FfmpegProgress {
  FfmpegProgressPhase phase;
  int fileSize;
  int downloaded;

  FfmpegProgress({
    required this.phase,
    required this.fileSize,
    required this.downloaded,
  });
}

class FfmpegManager {
  static late FfmpegManager instance;
  String? folderPath;
  Map<String, String> cliPaths = {};

  static void initialize(SharedPreferences prefs) {
    instance = FfmpegManager();
    instance.folderPath = prefs.getString("ffmpegFolderPath");
  }

  String getCliPath(String name) {
    if (cliPaths.containsKey(name)) {
      return cliPaths[name]!;
    }

    cliPaths[name] = folderPath == null ? name : p.join(folderPath!, name);

    return cliPaths[name]!;
  }

  // Original code from FFmpeg CLI library, Modified to fit my needs
  Future<FfprobeOutput> ffprobe(String filePath) async {
    print("ffprobe run requested on $filePath");

    final result = await Process.run("ffprobe", [
      "-v",
      "quiet",
      "-print_format",
      "json",
      "-show_format",
      "-show_streams",
      filePath
    ]);

    if (result.exitCode != 0) {
      throw Exception(
          "ffprobe returned error: ${result.exitCode}\n${result.stderr}");
    }

    if (result.stdout == null ||
        result.stdout is! String ||
        (result.stdout as String).isEmpty) {
      throw Exception("ffprobe did not output expected data: ${result.stdout}");
    }

    return FfprobeOutput.fromJson(jsonDecode(result.stdout));
  }

  Future<bool> isFfmpegPresent() async {
    if (Platform.isAndroid || Platform.isIOS) return false;

    try {
      Process process = await Process.start("ffmpeg", ["-version"]);
      return await process.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> extractFile(Map<String, String> data) async {
    try {
      await extractFileToDisk(data["from"]!, data["to"]!);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Original code from package ffmpeg_helper. Original method:
  // https://github.com/abhay-s-rawat/ffmpeg_helper/blob/main/lib/helpers/ffmpeg_helper_class.dart#L398
  Future<bool> setupForWindows(
      {void Function(FfmpegProgress progress)? onProgress}) async {
    if (!Platform.isWindows) return true;

    var inactiveState = FfmpegProgress(
      phase: FfmpegProgressPhase.inactive,
      fileSize: 0,
      downloaded: 0,
    );
    var docsDir = await getApplicationDocumentsDirectory();
    var ffmpegDir = p.join(docsDir.path, "StoryTailor", "ffmpeg");
    var tempDir = await getTemporaryDirectory();
    var zipPath = p.join(tempDir.path, "ffmpeg.zip");
    var dio = Dio();

    var zipFile = File(zipPath);
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    var downloadResponse = await dio.download(
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip",
      zipPath,
      onReceiveProgress: (count, total) {
        onProgress?.call(FfmpegProgress(
          phase: FfmpegProgressPhase.downloading,
          fileSize: total,
          downloaded: count,
        ));
      },
    );

    if (downloadResponse.statusCode != HttpStatus.ok) {
      onProgress?.call(inactiveState);
      return false;
    }

    var extractResult = await compute(extractFile, {
      "from": zipPath,
      "to": ffmpegDir,
    });

    if (!extractResult) {
      onProgress?.call(inactiveState);
      return false;
    }

    folderPath = p.join(ffmpegDir, "ffmpeg-master-latest-win64-gpl", "bin");
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("ffmpegFolderPath", folderPath!);

    return true;
  }
}
