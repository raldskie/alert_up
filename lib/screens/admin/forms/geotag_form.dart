import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/location_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/utilities/firebase_upload.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/single_image_picker.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
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
  SingleValueDropDownController purokCont = SingleValueDropDownController();

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
    "diseaseKey": null,
    "diseaseName": null
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

        diseasesProvider.getDiseaseList(callback: (code, message) {});

        if ((widget.dataKey ?? "").isNotEmpty) {
          diseasesProvider.getGeotaggedIndividual(
              dataKey: widget.dataKey!,
              callback: (code, message) {
                if (code == 200) {
                  payload = (diseasesProvider.geoTaggedIndividual?.value ?? {})
                      as Map;
                  if (getPurok(payload['barangayKey'], payload['purokKey']) !=
                      null) {
                    purokCont.dropDownValue = DropDownValueModel(
                        name: getPurok(
                                payload['barangayKey'], payload['purokKey'])!
                            .purokName,
                        value: getPurok(
                                payload['barangayKey'], payload['purokKey'])!
                            .purokKey);
                  }
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
        Provider.of<DiseasesProvider>(context, listen: false)
            .getDiseaseList(callback: (code, message) {});
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
        if (payload['status'] == "Untagged" && payload['untagDate'] == null) {
          payload['untagDate'] = DateTime.now().toLocal().toIso8601String();
        }

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
        body: ["geotagged"].contains(diseasesProvider.loading)
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
                    Row(children: [
                      Checkbox(
                          value: payload['isContagious'] ?? false,
                          onChanged: (val) => setState(() {
                                payload['isContagious'] = val;
                              })),
                      const SizedBox(width: 5),
                      const Text("Is Contagious/Infectious?")
                    ]),
                    const SizedBox(height: 25),
                    if (diseasesProvider.loading == "disease_list")
                      IconText(isLoading: true, label: "Getting disease")
                    else
                      DropDownTextField(
                          initialValue: payload['diseaseName'],
                          clearOption: true,
                          clearIconProperty: IconProperty(color: ACCENT_COLOR),
                          searchDecoration: const InputDecoration(
                              hintText: "enter your custom hint text here"),
                          dropDownItemCount: 6,
                          textFieldDecoration: textFieldStyle(
                              label: "Type of disease", hint: ""),
                          dropdownRadius: 5,
                          dropDownList: diseasesProvider.diseases.map((e) {
                            Map disease = (e.value ?? {}) as Map;

                            return DropDownValueModel(
                              value: e.key,
                              name: disease['disease_name'] ?? "",
                            );
                          }).toList(),
                          onChanged: (val) {
                            payload = {
                              ...payload,
                              "diseaseKey": val.value,
                              "diseaseName": val.name
                            };
                          }),
                    const SizedBox(height: 20),
                    TextFormField(
                        initialValue: (payload['name'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        onChanged: (val) =>
                            setState(() => payload['name'] = val),
                        decoration: textFieldStyle(label: "Age")),
                    const SizedBox(height: 20),
                    TextFormField(
                        initialValue: (payload['age'] ?? "").toString(),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Field required";
                          }
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            setState(() => payload['age'] = val),
                        decoration: textFieldStyle(label: "Age")),
                    const SizedBox(height: 20),
                    // TextFormField(
                    //     initialValue: (payload['purok'] ?? "").toString(),
                    //     validator: (val) {
                    //       if (val!.isEmpty) {
                    //         return "Field required";
                    //       }
                    //     },
                    //     onChanged: (val) =>
                    //         setState(() => payload['purok'] = val),
                    //     decoration: textFieldStyle(label: "Purok")),
                    DropDownTextField(
                        initialValue:
                            getBarangay(payload['barangayKey'])?.barangay,
                        clearOption: true,
                        clearIconProperty: IconProperty(color: ACCENT_COLOR),
                        dropDownItemCount: 6,
                        textFieldDecoration:
                            textFieldStyle(label: "Barangay", hint: ""),
                        dropdownRadius: 5,
                        dropDownList: BARANGAYS.map((e) {
                          return DropDownValueModel(
                            value: e.barangayKey,
                            name: e.barangay,
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            payload = {
                              ...payload,
                              ...getBarangay(val.value)!.toJson(),
                              "purokKey": null,
                              "purokName": null
                            };
                            purokCont.clearDropDown();
                          });
                        }),
                    const SizedBox(height: 20),
                    DropDownTextField(
                        controller: purokCont,
                        isEnabled: payload['barangayKey'] != null,
                        // initialValue: getPurok(
                        //         payload['barangayKey'], payload['purokKey'])
                        //     ?.purokName,
                        clearOption: true,
                        clearIconProperty: IconProperty(color: ACCENT_COLOR),
                        dropDownItemCount: 6,
                        textFieldDecoration:
                            textFieldStyle(label: "Purok", hint: ""),
                        dropdownRadius: 5,
                        dropDownList:
                            (getBarangay(payload['barangayKey'])?.purok ?? [])
                                .map((e) {
                          return DropDownValueModel(
                            value: e.purokKey,
                            name: e.purokName,
                          );
                        }).toList(),
                        onChanged: (val) {
                          payload = {
                            ...payload,
                            ...getPurok(payload['barangayKey'], val.value)!
                                .toJson()
                          };
                        }),
                    const SizedBox(height: 20),
                    DropDownTextField(
                        initialValue:
                            getWeather(payload['weatherKey'])?.weatherName,
                        clearOption: true,
                        clearIconProperty: IconProperty(color: ACCENT_COLOR),
                        dropDownItemCount: 6,
                        textFieldDecoration:
                            textFieldStyle(label: "Current weather", hint: ""),
                        dropdownRadius: 5,
                        dropDownList: WEATHERS.map((e) {
                          return DropDownValueModel(
                            value: e.weatherKey,
                            name: e.weatherName,
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            payload = {
                              ...payload,
                              ...getWeather(val.value)!.toJson(),
                            };
                          });
                        }),
                    const SizedBox(height: 20),
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
                              payload['untagDate'] = null;
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

                          String? imageLink = await uploadFile(
                              file: selectedImage!, folder: "geo_tags");
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
