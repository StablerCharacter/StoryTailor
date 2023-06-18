import './chapter.dart' show KeyNotFoundException;

class Dialog {
  String text;

  Dialog(this.text);

  factory Dialog.fromJson(Map<String, dynamic> data) {
    String? text = data["text"] as String?;
    if (text == null) {
      throw KeyNotFoundException("Text key not found in Dialog data.");
    }
    return Dialog(text);
  }

  Map<String, String> toJson() {
    return {
      "text": text,
    };
  }
}
