import './chapter.dart' show KeyNotFoundException;

class Dialog {
  String? speaker = "";
  String text;

  Dialog(this.text, { this.speaker = "" });

  factory Dialog.fromJson(Map<String, dynamic> data) {
    String? text = data["text"] as String?;
    if (text == null) {
      throw KeyNotFoundException("Text key not found in Dialog data.");
    }
    return Dialog(text, speaker: data["speaker"] as String?);
  }

  Map<String, String> toJson() {
    return {
      "speaker": speaker ?? "",
      "text": text,
    };
  }
}
