import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/button_with_icon.dart';
import '../utils/string_utility.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  TextEditingController controller = TextEditingController();
  String get mailTemplate =>
      "mailto:linesofcodes@dailitation.xyz?subject=[StoryTailor%20Bug%20Report]&body=Hello,%0AI%20have%20found%20a%20bug%20inside%20StoryTailor.%20Bug%20details:%0A${encodeForUrlParam(controller.text)}";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          appLocal.bugReport,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          appLocal.bugDetails,
          textAlign: TextAlign.center,
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: appLocal.bugDetailsPlaceholder),
          minLines: 5,
          maxLines: 20,
        ),
        ButtonWithIcon(
          icon: const Icon(Icons.flag),
          onPressed: () {
            launchUrl(Uri.parse(mailTemplate));
          },
          child: Text(appLocal.reportBug),
        ),
      ],
    );
  }
}
