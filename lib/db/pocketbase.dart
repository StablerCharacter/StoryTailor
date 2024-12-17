import 'package:pocketbase/pocketbase.dart';

class PocketBaseClient {
  static late final PocketBase instance;

  static void initialize({String server = "http://127.0.0.1:8090"}) {
    instance = PocketBase(server);
  }
}
