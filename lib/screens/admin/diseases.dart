import 'dart:convert';

import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Diseases extends StatefulWidget {
  Diseases({Key? key}) : super(key: key);

  @override
  State<Diseases> createState() => _EditState();
}

class _EditState extends State<Diseases> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseasesProvider>(context, listen: false)
          .getDiseaseList(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    if (diseasesProvider.loading == "disease_list") {
      return Center(child: PumpingAnimation());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: ACCENT_COLOR,
          onPressed: () {
            Navigator.pushNamed(context, '/disease/form',
                arguments: {'mode': 'ADD'});
          },
          child: const Icon(Icons.add_box)),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          itemCount: diseasesProvider.diseases.length,
          itemBuilder: (context, index) {
            Object? value = diseasesProvider.diseases[index].value;
            Map disease = value is Map ? value : {};

            if (disease['disease_name'] == null) {
              return Container();
            }

            return Container(
              margin: EdgeInsets.only(top: index == 0 ? 0 : 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease['disease_name'] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 5),
                    Text(disease['disease_description'] ?? ""),
                    const SizedBox(height: 15),
                    IconText(
                      label: "Alert Message",
                      fontWeight: FontWeight.bold,
                      icon: Icons.warning_rounded,
                    ),
                    Text(disease['alert_message'] ?? ""),
                    const SizedBox(height: 15),
                    Row(children: [
                      Button(
                          icon: Icons.add_box,
                          label: "Add Classified Zone",
                          onPress: () {
                            Navigator.pushNamed(
                                context, '/classified-zones/form', arguments: {
                              'diseaseKey':
                                  diseasesProvider.diseases[index].key,
                              'mode': 'ADD'
                            });
                          }),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Button(
                        icon: Icons.edit_document,
                        label: "Edit",
                        backgroundColor: Colors.black,
                        borderColor: Colors.black,
                        onPress: () {
                          Navigator.pushNamed(context, '/disease/form',
                              arguments: {
                                'dataKey': diseasesProvider.diseases[index].key,
                                'mode': 'EDIT'
                              });
                        },
                      )),
                      // const SizedBox(width: 15),
                      // Button(
                      //   isLoading:
                      //       diseasesProvider.loading == "delete_disease_$index",
                      //   label: "Delete",
                      //   borderColor: Colors.red,
                      //   backgroundColor: Colors.red,
                      //   onPress: () => diseasesProvider.deleteDisease(
                      //       loading: "delete_disease_$index",
                      //       key: diseasesProvider.diseases[index].key ?? "",
                      //       callback: (code, message) {
                      //         launchSnackbar(
                      //             context: context,
                      //             mode: code == 200 ? "SUCCESS" : "ERROR",
                      //             message: message);
                      //       }),
                      // )
                    ])
                  ]),
            );
          }),
    );
  }
}
