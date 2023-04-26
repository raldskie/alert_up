import 'dart:io';

import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AddPhotos extends StatelessWidget {
  String? label;
  List<PlatformFile> photos;
  Function onAddPhotos;
  Function onDeletePhoto;
  bool? allowMultiple;
  int? maxNumberOfPhotos;

  AddPhotos(
      {Key? key,
      this.label,
      this.allowMultiple = true,
      this.maxNumberOfPhotos,
      required this.photos,
      required this.onAddPhotos,
      required this.onDeletePhoto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconText(
            label: label ?? "Add Photos",
            fontWeight: FontWeight.bold,
            icon: Icons.photo_sharp),
        Material(
          color: Colors.transparent,
          child: IconButton(
              onPressed: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                          withReadStream: !kIsWeb,
                          withData: kIsWeb,
                          allowMultiple: allowMultiple!,
                          type: FileType.image);
                  if (result != null) {
                    if (maxNumberOfPhotos != null &&
                        maxNumberOfPhotos! < result.files.length) {
                      dialogBuilder(context,
                          title: "Error",
                          description:
                              "You can only add a maximum of ${(maxNumberOfPhotos ?? 999)} photo/s.");
                      return;
                    }

                    if (result.files.any((e) => e.size > 5000000)) {
                      dialogBuilder(context,
                          title: "Size limit reached.",
                          description: "Images must not exceed 5mb.");
                      return;
                    }
                    onAddPhotos(result.files);
                  }
                } catch (e) {
                  print(e);
                }
              },
              icon: const Icon(Icons.add)),
        ),
      ]),
      SizedBox(
        height: photos.isNotEmpty ? 200 : 0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: photos.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Image.file(
                //       File(photos[index].path),
                //       fit: BoxFit.cover,
                //       width: 200,
                //       height: MediaQuery.of(context).size.height,
                //     )),
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    child: kIsWeb
                        ? Image.memory(photos[index].bytes!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: MediaQuery.of(context).size.height)
                        : Image.file(File(photos[index].path!),
                            fit: BoxFit.cover,
                            width: 200,
                            height: MediaQuery.of(context).size.height)),
                Positioned(
                  right: 5,
                  top: 5,
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: Material(
                      color: Colors.red,
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(100),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => onDeletePhoto(index),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 15,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const Divider(
        height: 15,
      )
    ]);
  }
}
