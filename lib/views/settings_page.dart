import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:storytailor/components/button_with_icon.dart';
import 'package:storytailor/views/about_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _supabase = Supabase.instance.client;

  late final SharedPreferences prefs;
  late StreamSubscription<AuthState> _authSubscription;

  String loggedIn = "Signed in";
  String loggedOut = "Signed out";

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => prefs = value);

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        showSnackbar(context, Snackbar(content: Text(loggedIn)));
      } else if (event == AuthChangeEvent.signedOut) {
        showSnackbar(context, Snackbar(content: Text(loggedOut)));
      }
      setState(() {});
    }, onError: (error) {
      showSnackbar(context, Snackbar(content: Text(error)), duration: snackbarLongDuration);
    });
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

    loggedIn = appLocal.loginSuccess;
    loggedOut = appLocal.loggedOut;

    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Visibility(
                visible: _supabase.auth.currentUser == null,
                replacement: Column(
                  children: [
                    ButtonWithIcon(
                      icon: const Icon(FluentIcons.player_settings),
                      child: Text(appLocal.accountSettings),
                      onPressed: () {},
                    ),
                    ButtonWithIcon(
                      icon: const Icon(FluentIcons.sign_out),
                      child: Text(appLocal.logOut),
                      onPressed: () {
                        _supabase.auth.signOut();
                      },
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
