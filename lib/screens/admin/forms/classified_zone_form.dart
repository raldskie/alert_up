import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/widgets/bottom_modal.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/form/map_picker.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ClassifiedZoneForm extends StatefulWidget {
  String? dataKey;
  String? diseaseKey;
  String mode;
  ClassifiedZoneForm(
      {Key? key, this.dataKey, this.diseaseKey, required this.mode})
      : super(key: key);

  @override
  State<ClassifiedZoneForm> createState() => _ClassifiedZoneFormState();
}

class _ClassifiedZoneFormState extends State<ClassifiedZoneForm> {
  Map payload = {
    "Radius": 1,
    "Purok": "",
    "Geo_Name": "", // diseases collection
    "Description": "", // diseases collection
    "alert_message": "", // diseases collection
    "latitude": null,
    "longitude": null,
    "pinnedLocations": []
  };

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiseasesProvider diseasesProvider =
          Provider.of<DiseasesProvider>(context, listen: false);

      if ((widget.dataKey ?? "").isNotEmpty) {
        diseasesProvider.getClassifiedZone(
            key: widget.dataKey!,
            callback: (code, message) {
              if (code == 200) {
                payload = (diseasesProvider.classifiedZone?.value ?? {}) as Map;
                return;
              }
              launchSnackbar(
                  context: context,
                  mode: code == 200 ? "SUCCESS" : "ERROR",
                  message: message);
              Navigator.pop(context);
            });
      } else {
        diseasesProvider.getDisease(
            key: widget.diseaseKey!,
            callback: (code, message) {
              if (code == 200) {
                Map disease = (diseasesProvider.disease?.value ?? {}) as Map;
                payload = {
                  ...payload,
                  "diseaseKey": diseasesProvider.disease?.key,
                  "Geo_Name": disease['disease_name'],
                  "Description": disease['disease_description'],
                  "alert_message": disease['alert_message'],
                };
                return;
              }
              launchSnackbar(
                  context: context,
                  mode: code == 200 ? "SUCCESS" : "ERROR",
                  message: message);
              Navigator.pop(context);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    bool isLatLongValid() {
      if (payload['latitude'] == null || payload['longitude'] == null) {
        return false;
      }

      if (payload['latitude'] is String || payload['longitude'] is String) {
        return false;
      }

      return true;
    }

    return Scaffold(
      appBar: customAppBar(context,
          title: "${widget.mode == "EDIT" ? "Edit" : "Add"} Classified Zone",
          centerTitle: true),
      backgroundColor: Colors.white,
      body: diseasesProvider.loading == "c_zone" ||
              diseasesProvider.loading == "disease"
          ? Center(child: PumpingAnimation())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                  child: Column(children: [
                const SizedBox(height: 20),
                // TextFormField(
                //     initialValue: (payload['Purok'] ?? "").toString(),
                //     validator: (val) {
                //       if (val!.isEmpty) {
                //         return "Field required";
                //       }
                //     },
                //     onChanged: (val) => setState(() => payload['Purok'] = val),
                //     decoration: textFieldStyle(label: "Purok")),
                // const SizedBox(height: 15),
                // TextFormField(
                //     initialValue: (payload['Radius'] ?? "").toString(),
                //     validator: (val) {
                //       if (val!.isEmpty) {
                //         return "Field required";
                //       }

                //       if (int.tryParse(val) == null) {
                //         return "Input invalid!";
                //       }
                //     },
                //     keyboardType: TextInputType.number,
                //     onChanged: (val) => setState(() => payload['Radius'] = val),
                //     decoration: textFieldStyle(label: "Radius")),
                DropDownTextField(
                    initialValue: getBarangay(payload['barangayKey'])?.barangay,
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
                          ...getBarangay(val.value)!.toJson()
                        };
                      });
                    }),
                const SizedBox(height: 20),
                DropDownTextField(
                    isEnabled: payload['barangayKey'] != null,
                    initialValue:
                        getPurok(payload['barangayKey'], payload['purokKey'])
                            ?.purokName,
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
                        ...getPurok(payload['barangayKey'], val.value)!.toJson()
                      };
                    }),
                const SizedBox(height: 15),
                Button(
                    icon: Icons.pin_drop_rounded,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.red,
                    label: "Pin On Map",
                    onPress: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          enableDrag: false,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setModalState) {
                              return Modal(
                                  title: "Select an area",
                                  heightInPercentage: .9,
                                  content: SelectLocation(
                                    value: isLatLongValid()
                                        ? LatLng(payload['latitude'],
                                            payload['longitude'])
                                        : null,
                                    pinnedLocations: List<LatLng>.from(
                                        (payload['pinnedLocations'] ?? [])
                                            .map((e) => LatLng(
                                                e['latitude'], e['longitude']))
                                            .toList()),
                                    onSelectLocation:
                                        (List<Map> pinnedLocations) {
                                      setState(() {
                                        // payload['latitude'] = latLng.latitude;
                                        // payload['longitude'] = latLng.longitude;
                                        payload['pinnedLocations'] =
                                            pinnedLocations;
                                      });
                                    },
                                  ));
                            });
                          });
                    }),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                TextFormField(
                    initialValue: payload['Geo_Name'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    maxLines: null,
                    onChanged: (val) =>
                        setState(() => payload['Geo_Name'] = val),
                    decoration: textFieldStyle(label: "Disease Name")),
                const SizedBox(height: 15),
                TextFormField(
                    initialValue: payload['Description'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    maxLines: null,
                    onChanged: (val) =>
                        setState(() => payload['Description'] = val),
                    decoration: textFieldStyle(label: "Disease Description")),
                const SizedBox(height: 15),
                TextFormField(
                    initialValue: payload['alert_message'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    maxLines: null,
                    onChanged: (val) =>
                        setState(() => payload['alert_message'] = val),
                    decoration: textFieldStyle(label: "Alert Message")),
                const SizedBox(height: 15),
                Button(
                    isLoading: ["add_cz", "classified_zone_edit"]
                        .contains(diseasesProvider.loading),
                    label: "Save Changes",
                    onPress: () {
                      if ((payload['pinnedLocations'] ?? []).isEmpty) {
                        launchSnackbar(
                            context: context,
                            mode: "ERROR",
                            message: "Please pin location");
                        return;
                      }

                      if (widget.mode == "ADD") {
                        diseasesProvider.addClassifiedZones(
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
                      } else {
                        diseasesProvider.updateClassifiedZone(
                            key: widget.dataKey!,
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
                      }
                    }),
                const SizedBox(height: 20),
              ]))),
    );
  }
}
