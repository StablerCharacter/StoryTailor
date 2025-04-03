import 'package:storytailor/ffmpeg/ffprobe_stream.dart';

class FfprobeOutput {
  Map<String, dynamic>? format;
  List<FfprobeStream>? streams;

  FfprobeOutput();

  factory FfprobeOutput.fromJson(Map<String, dynamic> data) {
    var output = FfprobeOutput();
    output.format = data["format"];
    output.streams =
        (data["streams"] as List).map((v) => FfprobeStream(v)).toList();
    return output;
  }
}
