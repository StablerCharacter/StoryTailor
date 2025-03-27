import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytailor/db/pocketbase.dart';
import 'package:storytailor/l10n/app_localizations.dart';
import 'package:storytailor/views/mobile_tutorial_page.dart';
import 'package:storytailor/views/project_list.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'views/bug_report.dart';
import 'views/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(500, 460));
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

  Typography? applyFont(Typography typography, Locale locale) {
    if (locale.languageCode == "th") {
      return typography.apply(
          fontFamily: GoogleFonts.ibmPlexSansThai().fontFamily);
    }
    return typography;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AccentColor accentColor = SystemTheme.accentColor.accent.toAccentColor();

    return ChangeNotifierProvider(
      create: (_) => ModelSettings(prefs),
      child: Consumer<ModelSettings>(
        builder: (context, ModelSettings themeNotifier, child) {
          return FluentApp(
            title: 'StoryTailor',
            theme: FluentThemeData.light().copyWith(
              accentColor: accentColor,
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              typography: applyFont(
                Typography.fromBrightness(brightness: Brightness.light),
                themeNotifier.language,
              ),
            ),
            darkTheme: FluentThemeData.dark().copyWith(
              accentColor: accentColor,
              typography: applyFont(
                Typography.fromBrightness(brightness: Brightness.dark),
                themeNotifier.language,
              ),
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
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return NavigationView(
      appBar: NavigationAppBar(
        leading: Container(
          margin: const EdgeInsets.fromLTRB(10, 15, 2.5, 7.5),
          child: const Image(
            image: AssetImage('assets/icon.png'),
          ),
        ),
        title: Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 30, 0),
            child: Text(
              "StoryTailor",
              style: theme.typography.title,
            )),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.fabric_folder),
            title: Text(appLocal.projects, style: theme.typography.body),
            body: const ProjectList(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.documentation),
            title: Text(appLocal.tutorials, style: theme.typography.body),
            body: Platform.isAndroid || Platform.isIOS
                ? MobileTutorialPage()
                : Container(
                    margin: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(appLocal.tutorials,
                            style: theme.typography.titleLarge),
                        const Gap(10),
                        Button(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://stablercharacter.github.io/StoryTailor/introduction.html"));
                          },
                          child: Text(appLocal.openTutorial),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.bug),
            body: const BugReportPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            body: const SettingsPage(),
          ),
        ],
        selected: selectedTab,
        onChanged: (newValue) => setState(() {
          selectedTab = newValue;
        }),
      ),
    );
  }
}
