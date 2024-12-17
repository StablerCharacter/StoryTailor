import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:storytailor/db/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _pb = PocketBaseClient.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
  }

  void login() {
    _pb.collection("users").authWithPassword(
          emailController.text,
          passwordController.text,
        );
    Navigator.pop(context);
  }

  void register() {
    _pb.collection("users").create(body: <String, dynamic>{
      "password": passwordController.text,
      "passwordConfirm": passwordController.text,
      "email": emailController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocal.login),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appLocal.login, style: theme.textTheme.titleLarge),
            SizedBox(
              width: 750,
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: appLocal.email),
              ),
            ),
            SizedBox(
              width: 750,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: appLocal.password),
              ),
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
                OutlinedButton(
                  onPressed: register,
                  child: Text(appLocal.register),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              child: Text(appLocal.or,
                  style: TextStyle(color: theme.dividerColor)),
            ),
            TextButton(
              onPressed: () => _pb.collection("users").authWithOAuth2(
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
