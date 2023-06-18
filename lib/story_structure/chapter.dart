import 'dart:convert';
import 'dart:io';

import 'branch.dart';
import 'dialog.dart';

class KeyNotFoundException implements Exception {
  final String? message;

  KeyNotFoundException([this.message]);

  @override
  String toString() {
    if (message == null) return "KeyNotFoundException";
    return "KeyNotFoundException: $message";
  }
}

class Chapter {
  String name;
  String? newName;
  String currentBranch;
  Map<String, Branch>? branches;
  File? chaptersFile;

  Chapter(this.name, this.branches, {this.currentBranch = "main"});

  Branch getCurrentBranch() {
    Branch? current = branches?[currentBranch];
    if (current == null) {
      throw KeyNotFoundException("Branch with key $currentBranch not found.");
    }
    return current;
  }

  Dialog getCurrentDialog() {
    Branch current = getCurrentBranch();
    return current.dialogs[current.dialogIndex];
  }

  Dialog getNextDialog() {
    Branch current = getCurrentBranch();
    if (++current.dialogIndex == current.dialogs.length) {
      return current.dialogs[--current.dialogIndex];
    }
    return current.dialogs[current.dialogIndex];
  }

  factory Chapter.fromJson(Map<String, dynamic> data) {
    String name = data["chapter_info"]["name"];
    data.remove("chapter_info");
    return Chapter(name, null);
  }

  void loadFromFile() {
    if (chaptersFile == null) {
      return;
    }
    Map<String, dynamic> data = jsonDecode(chaptersFile!.readAsStringSync());
    name = data["chapter_info"]["name"];
    data.remove("chapter_info");
    branches = data.map(
        (key, value) => MapEntry(key, Branch.fromJson(value as List<dynamic>)));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> branchesJson =
        branches!.map((key, value) => MapEntry(key, value.toJson()));

    branchesJson.addAll({
      "chapter_info": {
        "name": name,
      }
    });
    return branchesJson;
  }
}
