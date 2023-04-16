import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/location_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/firebase_upload.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/single_image_picker.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeoTagForm extends StatefulWidget {
  String? uniqueId;
  String? dataKey;
  String? diseaseKey;
  String mode;
  GeoTagForm(
      {Key? key,
      this.uniqueId,
      this.dataKey,
      this.diseaseKey,
      required this.mode})
      : super(key: key);

  @override
  State<GeoTagForm> createState() => _GeoTagFormState();
}

class _GeoTagFormState extends State<GeoTagForm> {
  PlatformFile? selectedImage;
  bool isUploadingImage = false;

  Map payload = {
    "deviceId": "",
    "imageUrl": null,
    "name": "",
    "gender": "Male",
    "purok": "",
    "barangay": "",
    "contact": "",
    "isConfidential": false,
    "created_At": "",
    "last_latitude": null,
    "last_longitude": null,
    "detected_latitude": null,
    "detected_longitude": null,
    "status": "Tagged",
  };

  getLocation() {
    Provider.of<LocationProvider>(context, listen: false)
        .determinePosition(context, (result, isSuccess) {
      payload['last_latitude'] = result.latitude;
      payload['last_longitude'] = result.longitude;
      payload['detected_latitude'] = result.latitude;
      payload['detected_longitude'] = result.longitude;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == "EDIT") {
        DiseasesProvider diseasesProvider =
            Provider.of<DiseasesProvider>(context, listen: false);

        if ((widget.dataKey ?? "").isNotEmpty) {
          diseasesProvider.getGeotaggedIndividual(
              dataKey: widget.dataKey!,
              callback: (code, message) {
                if (code == 200) {
                  payload = (diseasesProvider.geoTaggedIndividual?.value ?? {})
                      as Map;
                  return;
                }
                launchSnackbar(
                    context: context,
                    mode: code == 200 ? "SUCCESS" : "ERROR",
                    message: message);
                Navigator.pop(context);
              });
        }
      } else {
        getLocation();
        payload['deviceId'] = widget.uniqueId;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();
    LocationProvider locationProvider = context.watch<LocationProvider>();

    onSaveData() {
      if (widget.mode == "EDIT") {
        diseasesProvider.updateGeotag(
            key: diseasesProvider.geoTaggedIndividual!.key!,
            payload: payload,
            callback: (code, message) {
              launchSnackbar(
                  context: context,
                  mode: code == 200 ? "SUCCESS" : "ERROR",
                  message: message);

              if (code == 200) {
                Navigator.pop(context);
              }
            });
        return;
      }

      diseasesProvider.addGeotag(
          payload: payload,
          callback: (code, message) {
            launchSnackbar(
                context: context,
                mode: code == 200 ? "SUCCESS" : "ERROR",
                message: message);

            if (code == 200) {
              Navigator.pop(context);
            }
            setState(() {
              isUploadingImage = false;
            });
          });
    }

    return Scaffold(
        appBar: customAppBar(context, title: "Geotag Form", centerTitle: true),
        backgroundColor: Colors.white,
        body: diseasesProvider.loading == "geotagged"
            ? Center(child: PumpingAnimation())
            : Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Form(
                      child: Column(children: [
                    if (widget.mode == "ADD")
                      Column(children: [
                        const SizedBox(height: 30),
                        if (locationProvider.loading == "current_location")
                          IconText(isLoading: true, label: "Getting location"),
                        if (locationProvider.loading ==
                            "current_location_failed")
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconText(
                                    isLoading: true,
                                    label: "Failed to detect location"),
                                Button(
                                    label: "Retry",
                                    textColor: ACCENT_COLOR,
                                    backgroundColor: Colors.transparent,
                                    fontSize: 10,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 10),
                                    onPress: () => getLocation())
                              ]),
                        if ((payload['detected_latitude'] != null &&
                            payload['detected_longitude'] != null))
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconText(
                                    color: Colors.green,
                                    icon: Icons.location_history_rounded,
                                    label: "Location detected"),
                                Button(
                                    label: "Update Location",
                                    textColor: ACCENT_COLOR,
                                    backgroundColor: Colors.transparent,
                                    fontSize: 10,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 10),
                                    onPress: () => getLocation())
                              ])
                      ]),
                    const SizedBox(height: 40),
                    SingleImagePicker(
                        urlValue: payload['imageUrl'],
                        value: selectedImage,
                        label: "Select Image",
                        onPick: (selectedImage) {
                          setState(() {
                            this.selectedImage = selectedImage;
                          });
                        }),
                    const SizedBox(height: 15),
                    Row(children: [
                      Checkbox(
                          value: payload['isConfidential'] ?? false,
                          onChanged: (val) => setState(() {
                                payload['isConfidential'] = val;
                              })),
                      const SizedBox(width: 5),
                      const Text("Is Confidential?")
                    ]),
                    const SizedBox(height: 15),
                    TextFormField(
                        initialValue: (payload['name'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        onChanged: (val) =>
                            setState(() => payload['name'] = val),
                        decoration: textFieldStyle(label: "Full Name")),
                    const SizedBox(height: 15),
                    TextFormField(
                        initialValue: (payload['purok'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        onChanged: (val) =>
                            setState(() => payload['purok'] = val),
                        decoration: textFieldStyle(label: "Purok")),
                    const SizedBox(height: 15),
                    TextFormField(
                        initialValue: (payload['barangay'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        onChanged: (val) =>
                            setState(() => payload['barangay'] = val),
                        decoration: textFieldStyle(label: "Barangay")),
                    const SizedBox(height: 15),
                    TextFormField(
                        initialValue: (payload['contact'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            setState(() => payload['contact'] = val),
                        maxLength: 10,
                        decoration: textFieldStyle(
                            label: "Contact No.", prefix: "+63")),
                    IconText(
                      label: "Gender",
                      fontWeight: FontWeight.bold,
                    ),
                    RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Male'),
                        value: "Male",
                        groupValue: payload['gender'],
                        onChanged: (value) => setState(() {
                              payload['gender'] = value;
                            })),
                    RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Female'),
                        value: "Female",
                        groupValue: payload['gender'],
                        onChanged: (value) => setState(() {
                              payload['gender'] = value;
                            })),
                    const SizedBox(height: 15),
                    IconText(
                      label: "Status",
                      fontWeight: FontWeight.bold,
                    ),
                    RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tagged'),
                        value: "Tagged",
                        groupValue: payload['status'],
                        onChanged: (value) => setState(() {
                              payload['status'] = value;
                            })),
                    RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Untagged'),
                        value: "Untagged",
                        groupValue: payload['status'],
                        onChanged: (value) => setState(() {
                              payload['status'] = value;
                            })),
                    const SizedBox(height: 40),
                    Button(
                        isLoading: ["add_geotag", "geotag_edit"]
                                .contains(diseasesProvider.loading) ||
                            isUploadingImage,
                        label: widget.mode == "EDIT"
                            ? "Save Changes"
                            : "Add Geotag",
                        onPress: () async {
                          if (selectedImage == null) {
                            onSaveData();
                            return;
                          }

                          setState(() {
                            isUploadingImage = true;
                          });

                          String? imageLink = await uploadFile(selectedImage);
                          if (imageLink != null) {
                            payload['imageUrl'] = imageLink;
                            onSaveData();
                          } else {
                            setState(() {
                              isUploadingImage = false;
                            });
                            if (!mounted) return;
                            launchSnackbar(
                                context: context,
                                mode: "ERROR",
                                message: "Failed to upload the image.");
                          }
                        }),
                    const SizedBox(height: 30),
                  ])),
                )),
              ]));
  }
}
