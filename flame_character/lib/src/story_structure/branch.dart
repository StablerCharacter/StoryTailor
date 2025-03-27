import 'dialog.dart';

class Branch {
  int dialogIndex = 0;
  List<Dialog> dialogs;

  Branch(this.dialogs);

  factory Branch.fromJson(List<dynamic> data) {
    return Branch(
        data.map((e) => Dialog.fromJson(e as Map<String, dynamic>)).toList());
  }

  List<Map<String, String>> toJson() {
    return dialogs.map((e) => e.toJson()).toList(growable: false);
  }
}
