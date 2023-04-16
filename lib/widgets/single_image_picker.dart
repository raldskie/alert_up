import 'dart:io';

import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SingleImagePicker extends StatelessWidget {
  String label;
  dynamic urlValue; // Value can be json encoded Photo model
  PlatformFile? value;
  Function(PlatformFile) onPick;
  SingleImagePicker(
      {Key? key,
      required this.label,
      this.urlValue,
      this.value,
      required this.onPick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
                withReadStream: !kIsWeb,
                withData: kIsWeb,
                type: FileType.image);
            if (result != null) {
              onPick(result.files[0]);
            }
          },
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.1),
                borderRadius: BorderRadius.circular(6)),
            child: value == null && urlValue != null
                ? Image.network(
                    urlValue! ?? urlValue,
                    fit: BoxFit.cover,
                  )
                : value != null
                    ? kIsWeb
                        ? Image.memory(
                            value!.bytes!,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(value!.path!),
                            fit: BoxFit.cover,
                          )
                    : const Icon(Icons.add_box_rounded),
          )),
      const SizedBox(height: 10),
      IconText(
        label: label,
        color: Colors.grey,
        size: 10,
        fontWeight: FontWeight.bold,
      ),
    ]);
  }
}
