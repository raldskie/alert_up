import 'dart:convert';
import 'dart:math';

import 'package:alert_up_project/provider/user_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/confirm_pin.dart';
import 'package:alert_up_project/widgets/dialog_modal.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/password_reset.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String pin = "";
  final _formKey = GlobalKey<FormState>();

  bool isSendingEmail = false;

  Map payload = {
    "username": "",
    "password": "",
  };

  List<String> registeredEmails = ["alertupminco5@gmail.com"];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    UserProvider userProvider = context.watch<UserProvider>();

    onResetPassword() {
      setState(() {
        isSendingEmail = true;
      });
      String _email = "";
      dialogWithAction(context,
          title: "Reset Password Request",
          barrierDismissible: false, onDismiss: () {
        setState(() {
          isSendingEmail = false;
        });
      }, actions: [
        TextFormField(
            initialValue: _email,
            validator: (val) {
              if (val!.isEmpty) {
                return "Field required";
              }
            },
            onChanged: (val) => setState(() => _email = val.trim()),
            decoration: textFieldStyle(
                prefixIcon: const Icon(Icons.email_rounded),
                label: "Your Email")),
        const SizedBox(height: 15),
        Button(
            label: "Send Reset Link",
            backgroundColor: ACCENT_COLOR,
            borderColor: Colors.transparent,
            onPress: () async {
              if (_email.isEmpty) {
                dialogBuilder(context,
                    title: "Error", description: "Please enter your email!");
                return;
              }

              if (!EmailValidator.validate(_email)) {
                dialogBuilder(context,
                    title: "Error", description: "Email invalid!");
                return;
              }

              if (!registeredEmails.contains(_email)) {
                dialogBuilder(context,
                    title: "Error", description: "Email is not registered!");
                return;
              }

              try {
                pin = "";
                Navigator.pop(context);
                var rng = Random();
                for (var i = 0; i < 7; i++) {
                  pin += rng.nextInt(10).toString();
                }

                final url =
                    Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
                const serviceId = 'service_br6i0z7';
                const templateId = 'template_pt6gxjd';
                const userId = 'TK53HK6sfcN6zf7C1';
                final response = await http.post(url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'service_id': serviceId,
                      'template_id': templateId,
                      'user_id': userId,
                      'accessToken': 'upuCVFwT1g5MNFUSYD0Lk',
                      'template_params': {'to_email': _email, 'pin': pin}
                    }));

                setState(() {
                  isSendingEmail = false;
                });

                if (response.statusCode == 200) {
                  userProvider.setToResetUserName(email: _email);

                  showDialogModal(context,
                      title: "Email Confirmation",
                      barrierDismissible: false,
                      width: 400,
                      height: height * .60,
                      content: ConfirmPin(
                        email: _email,
                        pin: pin,
                        onSuccess: () {
                          Navigator.pop(context);
                          showDialogModal(context,
                              title: "Passwor Reset",
                              barrierDismissible: false,
                              width: 400,
                              height: height * .60,
                              content: PasswordReset());
                        },
                      ));
                  launchSnackbar(
                      context: context, mode: "SUCCESS", message: "Email sent");
                } else {
                  launchSnackbar(
                      context: context,
                      mode: "ERROR",
                      message: "Failed to send email. Please try again.");
                }
              } catch (e) {
                setState(() {
                  isSendingEmail = false;
                });
                print("ERROR");
                print(e);
              }
            })
      ]);
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 246, 18, 18),
              Color.fromARGB(255, 245, 100, 32),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/alert.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 25),
                        IconText(
                          label: "Admin Sign Up",
                          fontWeight: FontWeight.bold,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const SizedBox(height: 50),
                        TextFormField(
                            initialValue:
                                (payload['username'] ?? "").toString(),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            onChanged: (val) =>
                                setState(() => payload['username'] = val),
                            decoration: textFieldStyle(
                              label: "Username",
                            )),
                        const SizedBox(height: 15),
                        TextFormField(
                            initialValue:
                                (payload['password'] ?? "").toString(),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            obscureText: true,
                            onChanged: (val) =>
                                setState(() => payload['password'] = val),
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
                                          context: context,
                                          mode: "ERROR",
                                          message: message);
                                      return;
                                    }
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, "/admin", (route) => false);
                                  });
                            }),
                        const SizedBox(height: 20),
                        TextButton(
                            onPressed: () => onResetPassword(),
                            child: IconText(
                                isLoading: isSendingEmail,
                                mainAxisAlignment: MainAxisAlignment.center,
                                label: "I forgot my password"))
                      ]),
                ),
              ),
            ],
          ),
        ));
  }
}
