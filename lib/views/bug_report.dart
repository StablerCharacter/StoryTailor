import 'package:flame_character/flame_character.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/components/button_with_icon.dart';
import 'package:storytailor/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
      children: [
        Text(
          appLocal.bugReport,
          style: theme.typography.title,
          textAlign: TextAlign.center,
        ),
        Text(
          appLocal.bugDetails,
          textAlign: TextAlign.center,
        ),
        TextBox(
          controller: controller,
          placeholder: appLocal.bugDetailsPlaceholder,
          minLines: 5,
          maxLines: 20,
        ),
        ButtonWithIcon(
          icon: const Icon(FluentIcons.flag),
          onPressed: () {
            launchUrl(Uri.parse(mailTemplate));
          },
          child: Text(appLocal.reportBug),
        ),
      ],
    );
  }
}
