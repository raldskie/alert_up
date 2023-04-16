import 'package:alert_up_project/utilities/constants.dart';
import 'package:flutter/material.dart';

launchSnackbar(
    {required BuildContext context,
    required String mode,
    IconData? icon,
    int? duration,
    required String message}) {
  Color? color;
  IconData? _icon;

  if (mode == "SUCCESS") {
    color = Colors.green;
    _icon = Icons.check_box_outlined;
  }
  if (mode == "ERROR") {
    color = Colors.red;
    _icon = Icons.warning_amber_rounded;
  }

  final snackBar = SnackBar(
    duration: Duration(milliseconds: duration ?? 3000),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? _icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    ),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
