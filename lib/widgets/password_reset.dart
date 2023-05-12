import 'package:alert_up_project/provider/user_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/responsive.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordReset extends StatefulWidget {
  PasswordReset({Key? key}) : super(key: key);

  @override
  State<PasswordReset> createState() => _SignUpState();
}

class _SignUpState extends State<PasswordReset> {
  final _formKey = GlobalKey<FormState>();
  bool showPasswordA = false;
  bool showPasswordB = false;
  bool showPasswordC = false;

  Map<String, dynamic> payload = {"newPassword": "", "confirmPassword": ""};

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    onChanged: (e) =>
                        setState(() => payload["newPassword"] = e),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "This field is required";
                      }
                    },
                    obscureText: !showPasswordB,
                    decoration: textFieldStyle(
                        label: "New Password",
                        prefixIcon: const Icon(
                          Icons.key_rounded,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => showPasswordB = !showPasswordB),
                            icon: Icon(
                              Icons.remove_red_eye_rounded,
                              color:
                                  !showPasswordB ? Colors.grey : ACCENT_COLOR,
                            )))),
                const SizedBox(height: 15),
                TextFormField(
                    onChanged: (e) =>
                        setState(() => payload["confirmPassword"] = e),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "This field is required";
                      }
                      if (payload["newPassword"] != val) {
                        return "Passwords don't match";
                      }
                    },
                    obscureText: !showPasswordC,
                    decoration: textFieldStyle(
                        label: "Confirm Password",
                        prefixIcon: const Icon(
                          Icons.key_rounded,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => showPasswordC = !showPasswordC),
                            icon: Icon(
                              Icons.remove_red_eye_rounded,
                              color:
                                  !showPasswordC ? Colors.grey : ACCENT_COLOR,
                            )))),
                const SizedBox(height: 15),
                Button(
                    label: "Reset Password",
                    isLoading: userProvider.loading.contains("change_password"),
                    backgroundColor: ACCENT_COLOR,
                    borderColor: Colors.transparent,
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        Provider.of<UserProvider>(context, listen: false)
                            .changePassword(
                                newPassword: payload['newPassword'],
                                callback: (code, message) {
                                  launchSnackbar(
                                      context: context,
                                      mode: code == 200 ? "SUCCESS" : "ERROR",
                                      message: message ?? "Error!");

                                  if (code != 200) return;

                                  userProvider.logOut();
                                  Navigator.pushNamed(context, "/login");
                                });
                      }
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15))
              ],
            ),
          )),
    );
  }
}
