import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class KeyValueDatabase {
  Map<String, dynamic> data = HashMap();
  File targetFile;

  KeyValueDatabase(this.targetFile);

  factory KeyValueDatabase.loadFromFile(File targetFile) {
    KeyValueDatabase db = KeyValueDatabase(targetFile);
    db.data = jsonDecode(targetFile.readAsStringSync());
    return db;
  }

  Future<void> loadFromFileAsync() async =>
      data = jsonDecode(await targetFile.readAsString());
  Future<File> saveToFile() async => targetFile.writeAsString(jsonEncode(data));
}
