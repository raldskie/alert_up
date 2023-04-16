import 'package:alert_up_project/provider/user_provider.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();

  Map payload = {
    "username": "",
    "password": "",
  };

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
              initialValue: (payload['username'] ?? "").toString(),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Field required";
                }
              },
              onChanged: (val) => setState(() => payload['username'] = val),
              decoration: textFieldStyle(
                label: "Username",
              )),
          const SizedBox(height: 15),
          TextFormField(
              initialValue: (payload['password'] ?? "").toString(),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Field required";
                }
              },
              obscureText: true,
              onChanged: (val) => setState(() => payload['password'] = val),
              decoration: textFieldStyle(
                label: "Password",
              )),
          const SizedBox(height: 15),
          Button(
              isLoading: userProvider.loading == "login",
              icon: Icons.login_rounded,
              label: "Login",
              onPress: () {
                if (!_formKey.currentState!.validate()) {
                  launchSnackbar(
                      context: context,
                      mode: "ERROR",
                      message: "Please fill all fields.");
                  return;
                }
                userProvider.userLogin(
                    payload: payload,
                    callback: (code, message) {
                      if (code != 200) {
                        launchSnackbar(
                            context: context, mode: "ERROR", message: message);
                        return;
                      }
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/admin", (route) => false);
                    });
              })
        ]),
      ),
    ));
  }
}
