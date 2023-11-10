import 'package:fluent_ui/fluent_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileTutorialPage extends StatelessWidget {
  final WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(
        "https://stablercharacter.github.io/StoryTailor/introduction.html"));

  MobileTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: webViewController);
  }
}
