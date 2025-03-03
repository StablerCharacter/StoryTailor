import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:storytailor/db/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _pb = PocketBaseClient.instance;
  RecordService get _users => _pb.collection("users");

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
  }

  void login() {
    _users.authWithPassword(
      emailController.text,
      passwordController.text,
    );
    Navigator.pop(context);
  }

  void register() {
    _users.create(
      body: {
        "email": emailController.text,
        "password": passwordController.text,
        "passwordConfirm": passwordController.text
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ScaffoldPage(
      header: Container(
        margin: const EdgeInsets.fromLTRB(30, 15, 30, 0),
        child: PageHeader(
          title: Text(appLocal.login),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x43434343),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appLocal.login, style: theme.typography.title),
            TextBox(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              placeholder: appLocal.email,
            ),
            PasswordBox(
              controller: passwordController,
              revealMode: PasswordRevealMode.peekAlways,
              placeholder: appLocal.password,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: login,
                  child: Text(appLocal.login),
                ),
                const SizedBox(width: 10),
                Button(
                  onPressed: register,
                  child: Text(appLocal.register),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              child: Text(appLocal.or,
                  style: TextStyle(color: theme.inactiveColor)),
            ),
            OutlinedButton(
              onPressed: () => _users.authWithOAuth2(
                "google",
                (url) async {
                  await launchUrl(url);
                },
              ),
              child: Text(appLocal.continueGoogle),
            ),
          ],
        ),
      ),
    );
  }
}
