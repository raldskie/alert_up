import 'package:alert_up_project/provider/user_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/dialog_modal.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmPin extends StatefulWidget {
  String email;
  String pin;
  Function onSuccess;
  ConfirmPin(
      {Key? key,
      required this.email,
      required this.pin,
      required this.onSuccess})
      : super(key: key);

  @override
  State<ConfirmPin> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmPin> {
  String pin = "";
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Expanded(child: Container()),
            Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: ACCENT_COLOR.withOpacity(.1)),
                child: Icon(
                  Icons.email_rounded,
                  color: ACCENT_COLOR,
                  size: 30,
                )),
            const SizedBox(height: 30),
            const Text("An email has been sent to"),
            IconText(
              label: widget.email,
              mainAxisAlignment: MainAxisAlignment.center,
              color: ACCENT_COLOR,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 30),
            TextFormField(
                initialValue: pin,
                maxLines: null,
                onChanged: (val) => setState(() => pin = val),
                decoration: textFieldStyle(label: "Enter pin here...")),
            const SizedBox(height: 15),
            Button(
              isLoading: userProvider.loading.contains("submit_confirm_pin"),
              label: "Submit Pin",
              onPress: () {
                if (pin.isEmpty) {
                  dialogBuilder(context,
                      title: "Error", description: "Please enter pin!");
                  return;
                }

                if (widget.pin != pin) {
                  dialogBuilder(context,
                      title: "Error", description: "Pin is incorrect!");
                  return;
                }

                if (widget.pin == pin) {
                  widget.onSuccess();
                  return;
                }
              },
            ),
            Expanded(child: Container()),
          ])),
    );
  }
}
