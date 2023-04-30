import 'package:alert_up_project/provider/admin_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/firebase_upload.dart';
import 'package:alert_up_project/widgets/add_photo.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/image_view.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Posters extends StatefulWidget {
  Posters({Key? key}) : super(key: key);

  @override
  State<Posters> createState() => _PostersState();
}

class _PostersState extends State<Posters> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getPosterList(
          callback: (code, message) {
        if (code != 200) {
          launchSnackbar(context: context, mode: "ERROR", message: message);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AdminProvider adminProvider = context.watch<AdminProvider>();
    double width = MediaQuery.of(context).size.width;

    addImagePicker() {
      showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            bool isUploadingImage = false;
            List<PlatformFile> photosToAdd = [];

            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: 400,
                  height: 400,
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    AddPhotos(
                        label: "Add Posters",
                        photos: photosToAdd,
                        onAddPhotos: (photos) {
                          setState(() {
                            photosToAdd = photos;
                          });
                        },
                        onDeletePhoto: (index) {
                          setState(() {
                            photosToAdd.removeAt(index);
                          });
                        }),
                    Expanded(child: Container()),
                    Row(children: [
                      Button(
                        label: "Cancel",
                        backgroundColor: Colors.transparent,
                        textColor: Colors.red,
                        onPress: isUploadingImage
                            ? null
                            : () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Button(
                              isLoading: isUploadingImage,
                              label: "Upload Posters",
                              onPress: photosToAdd.isEmpty
                                  ? null
                                  : () async {
                                      for (int i = 0;
                                          i < photosToAdd.length;
                                          i++) {
                                        setState(() {
                                          isUploadingImage = true;
                                        });

                                        String? imageLink = await uploadFile(
                                            file: photosToAdd[i],
                                            folder: "posters");
                                        if (imageLink != null) {
                                          adminProvider.addPost(
                                              payload: {"imageUrl": imageLink},
                                              callback: (code, message) {
                                                if (code != 200) {
                                                  dialogBuilder(context,
                                                      title: "ERROR",
                                                      description:
                                                          "Failed to post the image.");
                                                }
                                              });
                                        } else {
                                          if (!mounted) return;
                                          dialogBuilder(context,
                                              title: "ERROR",
                                              description:
                                                  "Failed to upload the image.");
                                        }
                                      }

                                      setState(() {
                                        isUploadingImage = false;
                                      });
                                      Navigator.pop(context);
                                    })),
                    ])
                  ]),
                ),
              );
            });
          });
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: ACCENT_COLOR,
          child: Icon(Icons.post_add_outlined),
          onPressed: () {
            addImagePicker();
          }),
      backgroundColor: Colors.white,
      body: adminProvider.loading == "poster_list"
          ? Center(
              child: CircularProgressIndicator(
              color: ACCENT_COLOR,
              strokeWidth: 2,
            ))
          : GridView.builder(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 20, bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: .65,
                  crossAxisCount: width < 700
                      ? 2
                      : width < 1000
                          ? 3
                          : width < 1400
                              ? 4
                              : 5),
              itemCount: adminProvider.posters.length,
              itemBuilder: (context, index) {
                Object? value = adminProvider.posters[index].value;
                Map poster = value is Map ? value : {};

                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: ImageViewer(
                                photos: List<String>.from(adminProvider.posters
                                    .map((e) => (e.value as Map)['imageUrl'])
                                    .toList()),
                                index: index)));
                  },
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Expanded(
                            child: Text(
                          DateFormat()
                              .format(DateTime.parse(poster['createdAt'])),
                          maxLines: 1,
                          style: TextStyle(fontSize: 10),
                        )),
                        if (adminProvider.loading == "delete_poster_$index")
                          Container(
                              height: 20,
                              width: 20,
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))
                        else
                          IconButton(
                              onPressed: () {
                                dialogWithAction(context,
                                    title: "This will delete the poster!",
                                    actions: [
                                      Button(
                                          label: "Yes, please proceed",
                                          onPress: () {
                                            Navigator.pop(context, "OK");
                                            adminProvider.deletePoster(
                                                loading: "delete_poster_$index",
                                                key: adminProvider
                                                        .posters[index].key ??
                                                    "",
                                                callback: (code, message) {
                                                  launchSnackbar(
                                                      context: context,
                                                      mode: code == 200
                                                          ? "SUCCESS"
                                                          : "ERROR",
                                                      message: message);
                                                });
                                          })
                                    ]);
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.red,
                              ))
                      ]),
                    ),
                    Expanded(
                      child: Image.network(
                        poster['imageUrl'] ?? USER_PLACEHOLDER_IMAGE,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ]),
                );
              }),
    );
  }
}
