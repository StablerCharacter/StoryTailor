import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytailor/components/button_with_icon.dart';
import 'package:storytailor/db/pocketbase.dart';
import 'package:storytailor/views/about_page.dart';
import 'package:storytailor/views/ffmpeg_windows_setup.dart';

import 'login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class ModelSettings extends ChangeNotifier {
  String _theme = 'system';
  String get theme => _theme;
  Locale _language = const Locale('en', 'US');
  Locale get language => _language;

  ModelSettings(SharedPreferences prefs) {
    theme = prefs.getString('theme') ?? 'system';
    String? languageCode = prefs.getString('language');
    language =
        languageCode == null ? const Locale('en', 'US') : Locale(languageCode);
  }

  set theme(String newValue) {
    _theme = newValue;
    SharedPreferences.getInstance()
        .then((value) => value.setString('theme', _theme));
    notifyListeners();
  }

  set language(Locale newValue) {
    _language = newValue;
    SharedPreferences.getInstance()
        .then((value) => value.setString('language', _language.languageCode));
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    switch (_theme) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final _pb = PocketBaseClient.instance;

  late final SharedPreferences prefs;
  late StreamSubscription<AuthStoreEvent> _authSubscription;

  Future<bool>? isFfmpegPresent;

  String loggedIn = "Signed in";
  String loggedOut = "Signed out";

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => prefs = value);

    _authSubscription = _pb.authStore.onChange.listen((data) {
      setState(() {});
    }, onError: (error) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: Text(error),
          severity: InfoBarSeverity.error,
        ),
      );
    });

    isFfmpegPresent = FFMpegHelper.instance.isFFMpegPresent();
  }

  @override
  void dispose() {
    super.dispose();

    _authSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    Axis buttonsAxis = MediaQuery.of(context).size.width >= 600
        ? Axis.horizontal
        : Axis.vertical;

    loggedIn = appLocal.loginSuccess;
    loggedOut = appLocal.loggedOut;

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Flex(
                direction: buttonsAxis,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _pb.authStore.isValid,
                    replacement: Flex(
                      direction: buttonsAxis,
                      children: [
                        ButtonWithIcon(
                          icon: const Icon(FluentIcons.sign_out),
                          child: Text(appLocal.logOut),
                          onPressed: () {
                            _pb.authStore.clear();
                          },
                        ),
                        const Gap(5),
                      ],
                    ),
                    child: ButtonWithIcon(
                      icon: const Icon(FluentIcons.signin),
                      child: Text(appLocal.login),
                      onPressed: () {
                        Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: !_pb.authStore.isValid,
                    child: ButtonWithIcon(
                      icon: const Icon(FluentIcons.player_settings),
                      child: Text(appLocal.accountSettings),
                      onPressed: () {},
                    ),
                  ),
                  const Gap(5),
                  ButtonWithIcon(
                    icon: const Icon(FluentIcons.info),
                    child: Text(appLocal.about),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(appLocal.preferences, style: theme.typography.titleLarge),
              Consumer<ModelSettings>(
                builder: (context, ModelSettings value, child) {
                  return Column(
                    children: [
                      InfoLabel(
                        label: appLocal.theme,
                        labelStyle: theme.typography.bodyStrong,
                      ),
                      ComboBox(
                        items: [
                          ComboBoxItem(
                            value: "dark",
                            child: Text(appLocal.darkTheme),
                          ),
                          ComboBoxItem(
                            value: "light",
                            child: Text(appLocal.lightTheme),
                          ),
                          ComboBoxItem(
                            value: "system",
                            child: Text(appLocal.systemTheme),
                          ),
                        ],
                        value: value.theme,
                        onChanged: (newValue) => setState(() {
                          value.theme = newValue!;
                        }),
                      ),
                      const Gap(10),
                      InfoLabel(
                        label: appLocal.language,
                        labelStyle: theme.typography.bodyStrong,
                      ),
                      ComboBox(
                        items: const [
                          ComboBoxItem(value: "en", child: Text("English")),
                          ComboBoxItem(value: "th", child: Text("ไทย")),
                        ],
                        value: value.language.languageCode,
                        onChanged: (newValue) => setState(() {
                          value.language = Locale(newValue!);
                        }),
                      ),
                    ],
                  );
                },
              ),
              const Gap(10),
              Text("FFmpeg", style: theme.typography.bodyStrong),
              Text(
                appLocal.ffmpegDescription,
                textAlign: TextAlign.center,
              ),
              FutureBuilder(
                future: isFfmpegPresent,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == true) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FluentIcons.check_mark),
                          const Gap(5),
                          Text(appLocal.ffmpegInstalled)
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.chrome_close),
                            const Gap(5),
                            Text(appLocal.ffmpegNotInstalled),
                          ],
                        ),
                        const Gap(5),
                        Button(
                          onPressed: () {
                            if (Platform.isWindows) {
                              Navigator.push(
                                context,
                                FluentPageRoute(
                                  builder: (context) =>
                                      const FFmpegWindowsSetup(),
                                ),
                              );
                            } else if (Platform.isLinux) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ContentDialog(
                                      title: Text(appLocal.ffmpegLinux),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(appLocal.ffmpegLinuxInstall),
                                          const SelectableText(
                                              "sudo apt-get install ffmpeg\nsudo snap install ffmpeg"),
                                        ],
                                      ),
                                      actions: [
                                        FilledButton(
                                          child: Text(
                                              appLocal.returnToPreviousPage),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                          child: Text(appLocal.installFFmpeg),
                        )
                      ],
                    );
                  }

                  return const ProgressRing();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
