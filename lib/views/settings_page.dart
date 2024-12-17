import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/material.dart';
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;
    Axis buttonsAxis = MediaQuery.of(context).size.width >= 600
        ? Axis.horizontal
        : Axis.vertical;

    loggedIn = appLocal.loginSuccess;
    loggedOut = appLocal.loggedOut;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Flex(
                direction: buttonsAxis,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _pb.authStore.record == null,
                    replacement: Flex(
                      direction: buttonsAxis,
                      children: [
                        ButtonWithIcon(
                          icon: const Icon(Icons.logout),
                          child: Text(appLocal.logOut),
                          onPressed: () {
                            _pb.authStore.clear();
                          },
                        ),
                        const Gap(5),
                      ],
                    ),
                    child: ButtonWithIcon(
                      icon: const Icon(Icons.login),
                      child: Text(appLocal.login),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: _pb.authStore.record != null,
                    child: ButtonWithIcon(
                      icon: const Icon(Icons.manage_accounts),
                      child: Text(appLocal.accountSettings),
                      onPressed: () {},
                    ),
                  ),
                  const Gap(5),
                  ButtonWithIcon(
                    icon: const Icon(Icons.info),
                    child: Text(appLocal.about),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(appLocal.preferences, style: theme.textTheme.titleLarge),
              Consumer<ModelSettings>(
                builder: (context, ModelSettings value, child) {
                  return Column(
                    children: [
                      Text(
                        appLocal.theme,
                        style: theme.textTheme.bodyLarge,
                      ),
                      SegmentedButton(
                        segments: [
                          ButtonSegment(
                            icon: const Icon(Icons.dark_mode),
                            value: "dark",
                            label: Text(appLocal.darkTheme),
                          ),
                          ButtonSegment(
                            icon: const Icon(Icons.light_mode),
                            value: "light",
                            label: Text(appLocal.lightTheme),
                          ),
                          ButtonSegment(
                            value: "system",
                            label: Text(appLocal.systemTheme),
                          ),
                        ],
                        selected: {value.theme},
                        onSelectionChanged: (newValue) => setState(() {
                          value.theme = newValue.first;
                        }),
                      ),
                      const Gap(10),
                      Text(
                        appLocal.language,
                        style: theme.textTheme.bodyLarge,
                      ),
                      SizedBox(
                        width: 750,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Radio.adaptive(
                                value: "en",
                                groupValue: value.language.languageCode,
                                onChanged: (newValue) => setState(() {
                                  value.language = Locale(newValue!);
                                }),
                              ),
                              title: const Text("English"),
                            ),
                            ListTile(
                              leading: Radio.adaptive(
                                value: "th",
                                groupValue: value.language.languageCode,
                                onChanged: (newValue) => setState(() {
                                  value.language = Locale(newValue!);
                                }),
                              ),
                              title: const Text("ไทย"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Gap(10),
              Text("FFmpeg", style: theme.textTheme.bodyLarge),
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
                          const Icon(Icons.check),
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
                            const Icon(Icons.close),
                            const Gap(5),
                            Text(appLocal.ffmpegNotInstalled),
                          ],
                        ),
                        const Gap(5),
                        OutlinedButton(
                          onPressed: () {
                            if (Platform.isWindows) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FFmpegWindowsSetup(),
                                ),
                              );
                            } else if (Platform.isLinux) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog.adaptive(
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

                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
