import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/l10n/app_localizations.dart';
import 'package:storytailor/project.dart';

class ProjectSettingsPage extends StatefulWidget {
  const ProjectSettingsPage(this.project, {super.key});

  final Project project;

  @override
  State<ProjectSettingsPage> createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettingsPage> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    FluentThemeData theme = FluentTheme.of(context);

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text(
                appLocal.projectSettings,
                style: theme.typography.title,
              ),
              Text(appLocal.projectName, style: theme.typography.bodyStrong),
              Text(widget.project.name),
              Text(appLocal.toRename, style: theme.typography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
