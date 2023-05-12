import 'package:flutter/material.dart';

import 'icon_text.dart';


showDialogModal(context,
    {required String title,
    bool? barrierDismissible,
    double? height,
    double? width,
    Function? onClose,
    Color? backgroundColor,
    Color? foregroundColor,
    required Widget content}) {
  var screenWidth = MediaQuery.of(context).size.width;
  var screenHeight = MediaQuery.of(context).size.height;

  showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible ?? true,
      builder: (BuildContext context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 15),
            backgroundColor: backgroundColor ?? Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: width,
              height: height,
              child: Column(children: [
                Row(children: [
                  const SizedBox(width: 15),
                  IconText(
                    label: title,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor ?? Colors.black,
                  ),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        if (onClose != null) {
                          onClose();
                        }
                        Navigator.pop(context, 'OK');
                      },
                      icon: Icon(
                        Icons.close,
                        color: foregroundColor ?? Colors.black,
                      ))
                ]),
                Expanded(child: content)
              ]),
            ),
          ));
}
