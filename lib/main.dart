import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytailor/db/pocketbase.dart';
import 'package:storytailor/utils/screen_size_utility.dart';
import 'package:storytailor/views/mobile_tutorial_page.dart';
import 'package:storytailor/views/project_list.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'views/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(350, 460));
  }

  Animate.restartOnHotReload = true;

  FFMpegHelper.instance.initialize();

  SystemTheme.fallbackColor = Colors.blue;
  await SystemTheme.accentColor.load();

  final prefs = await SharedPreferences.getInstance();

  PocketBaseClient.initialize();

  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp(this.prefs, {super.key});

  TextTheme applyFont(TextTheme textTheme, Locale locale) {
    if (locale.languageCode == "th") {
      return textTheme.apply(
          fontFamily: GoogleFonts.ibmPlexSansThai().fontFamily);
    }
    return textTheme;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color accentColor = SystemTheme.accentColor.accent;
    ThemeData lightThemeData = ThemeData.light();
    ThemeData darkThemeData = ThemeData.dark();

    return ChangeNotifierProvider(
      create: (_) => ModelSettings(prefs),
      child: Consumer<ModelSettings>(
        builder: (context, ModelSettings themeNotifier, child) {
          return MaterialApp(
            title: 'StoryTailor',
            color: accentColor,
            theme: lightThemeData.copyWith(
              textTheme:
                  applyFont(lightThemeData.textTheme, themeNotifier.language),
            ),
            darkTheme: darkThemeData.copyWith(
              textTheme:
                  applyFont(darkThemeData.textTheme, themeNotifier.language),
            ),
            themeMode: themeNotifier.getThemeMode(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: themeNotifier.language,
            home: const MyHomePage(title: 'StoryTailor'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    List<NavigationDestination> navDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.folder),
        label: appLocal.projects,
      ),
      NavigationDestination(
        icon: const Icon(Icons.help),
        label: appLocal.tutorials,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings),
        label: appLocal.preferences,
      ),
    ];
    Widget body = [
      const ProjectList(),
      Platform.isAndroid || Platform.isIOS
          ? MobileTutorialPage()
          : Container(
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(appLocal.tutorials, style: theme.textTheme.titleLarge),
                  const Gap(10),
                  FilledButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://stablercharacter.github.io/StoryTailor/introduction.html"));
                    },
                    child: Text(appLocal.openTutorial),
                  ),
                ],
              ),
            ),
      const SettingsPage()
    ][selectedTab];

    if (ScreenSizeUtility.isMediumScreen(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              destinations: [
                ...navDestinations.map(
                  (dest) => NavigationRailDestination(
                    icon: dest.icon,
                    label: Text(dest.label),
                  ),
                ),
              ],
              labelType: NavigationRailLabelType.selected,
              selectedIndex: selectedTab,
              onDestinationSelected: (newValue) => setState(() {
                selectedTab = newValue;
              }),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (newValue) => setState(() {
          selectedTab = newValue;
        }),
        destinations: navDestinations,
        selectedIndex: selectedTab,
      ),
      body: body,
    );
  }
}
