class FfprobeStream {
  Map<String, dynamic> originalData;

  int? get index => originalData["index"];
  String? get codecName => originalData["codec_name"];
  String? get codecType => originalData["codec_type"];
  String? get sampleRate => originalData["sample_rate"];
  String? get bitrate => originalData["bit_rate"];

  FfprobeStream(this.originalData);
}
