import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocal.about),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
              Text("StoryTailor", style: theme.textTheme.titleLarge),
              Text(appLocal.appSlogan, style: theme.textTheme.titleMedium),
              Text(appLocal.aboutApp, softWrap: true),
            ],
          ),
        ),
      ),
    );
  }
}
