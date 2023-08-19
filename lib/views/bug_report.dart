import 'package:fluent_ui/fluent_ui.dart';
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
      "mailto:linesofcodes@proton.me?subject=[StoryTailor%20Bug%20Report]&body=Hello,%0AI%20have%20found%20a%20bug%20inside%20StoryTailor.%20Bug%20details:%0A${encodeForUrlParam(controller.text)}";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              appLocal.bugreport,
              style: theme.typography.title,
            ),
            InfoLabel(label: appLocal.bugdetails),
            TextBox(
              controller: controller,
              placeholder: appLocal.bugdetailsplaceholder,
              minLines: 5,
              maxLines: 20,
            ),
            ButtonWithIcon(
              icon: const Icon(FluentIcons.flag),
              onPressed: () {
                launchUrl(Uri.parse(mailTemplate));
              },
              child: Text(appLocal.reportbug),
            ),
          ],
        ),
      ),
    );
  }
}
