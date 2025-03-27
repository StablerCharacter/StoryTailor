import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/l10n/app_localizations.dart';

class StoryConfigPage extends StatefulWidget {
  const StoryConfigPage({super.key});

  @override
  State<StoryConfigPage> createState() => _StoryConfigState();
}

class _StoryConfigState extends State<StoryConfigPage> {
  _StoryConfigState();

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(appLocal.storyStage, style: theme.typography.title),
            ],
          ),
        ),
      ),
    );
  }
}
