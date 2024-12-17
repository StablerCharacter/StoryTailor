import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(appLocal.storyStage, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
