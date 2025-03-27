import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Mica(
      child: ScaffoldPage(
        header: Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
          child: PageHeader(
            title: Text(appLocal.about),
            leading: IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        content: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x43434343),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                Text("StoryTailor", style: theme.typography.titleLarge),
                Text(appLocal.appSlogan, style: theme.typography.subtitle),
                Text(appLocal.aboutApp, softWrap: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
