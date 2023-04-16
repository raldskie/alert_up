import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:flutter/material.dart';

dialogBuilder(context, {required String title, required String description}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Text(description),
      actions: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: IconText(
              icon: Icons.close,
              label: "Dismiss",
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ]),
      ],
    ),
  );
}

dialogWithAction(context,
    {required String title,
    String? description,
    bool? barrierDismissible,
    required List<Widget> actions}) {
  showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: description != null ? Text(description) : null,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      actions: <Widget>[
        ...actions,
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: IconText(
                  icon: Icons.close,
                  label: "Dismiss",
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
          ],
        ),
      ],
    ),
  );
}
