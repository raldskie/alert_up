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

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _SignUpState();
}

class _SignUpState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  bool showPasswordA = false;
  bool showPasswordB = false;
  bool showPasswordC = false;

  Map<String, dynamic> payload = {
    "oldPassword": "",
    "newPassword": "",
    "confirmPassword": ""
  };

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(context,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: "Change Password",
          centerTitle: true),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView(
              padding: EdgeInsets.only(
                  top: height * .15,
                  bottom: 15,
                  right: isMobile(context) ? 0 : width * .3,
                  left: isMobile(context) ? 0 : width * .3),
              children: [
                TextFormField(
                    onChanged: (e) =>
                        setState(() => payload["oldPassword"] = e),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "This field is required";
                      }
                    },
                    obscureText: !showPasswordA,
                    decoration: textFieldStyle(
                        label: "Old Password",
                        prefixIcon: const Icon(
                          Icons.key_rounded,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => showPasswordA = !showPasswordA),
                            icon: Icon(
                              Icons.remove_red_eye_rounded,
                              color:
                                  !showPasswordA ? Colors.grey : ACCENT_COLOR,
                            )))),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 15),
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
                    label: "Change Password",
                    isLoading: userProvider.loading.contains("change_password"),
                    backgroundColor: ACCENT_COLOR,
                    borderColor: Colors.transparent,
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        if (userProvider.loggedPassword !=
                            payload['oldPassword']) {
                          launchSnackbar(
                              context: context,
                              mode: "ERROR",
                              message: "Old password is incorrect");
                          return;
                        }

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
