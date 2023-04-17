import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_classified_zone.dart';
import 'package:alert_up_project/widgets/bottom_modal.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassifiedZones extends StatefulWidget {
  ClassifiedZones({Key? key}) : super(key: key);

  @override
  State<ClassifiedZones> createState() => _ClassifiedZonesState();
}

class _ClassifiedZonesState extends State<ClassifiedZones> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseasesProvider>(context, listen: false)
          .getClassifiedZones(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    if (diseasesProvider.loading == "classified_list") {
      return Center(child: PumpingAnimation());
    }

    return Scaffold(
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          itemCount: diseasesProvider.classifiedZones.length,
          itemBuilder: (context, index) {
            Object? value = diseasesProvider.classifiedZones[index].value;
            Map classifiedZone = value is Map ? value : {};

            if (classifiedZone['Geo_Name'] == null) {
              return Container();
            }

            return InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isDismissible: false,
                    enableDrag: false,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setModalState) {
                        return Modal(
                            title: "Classified Zone",
                            heightInPercentage: .9,
                            content: ViewClassifiedZone(
                                dataKey: diseasesProvider
                                    .classifiedZones[index].key!));
                      });
                    });
              },
              child: Container(
                margin: EdgeInsets.only(top: index == 0 ? 0 : 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Purok",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        classifiedZone['Purok'] ?? "No data",
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        classifiedZone['Geo_Name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        classifiedZone['Description'],
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Alert Message",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        classifiedZone['alert_message'],
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 15),
                      Row(children: [
                        Expanded(
                            child: Button(
                          label: "Update Details",
                          backgroundColor: Colors.black,
                          borderColor: Colors.black,
                          onPress: () {
                            Navigator.pushNamed(
                                context, '/classified-zones/form', arguments: {
                              'dataKey':
                                  diseasesProvider.classifiedZones[index].key,
                              'mode': 'EDIT'
                            });
                          },
                        )),
                        const SizedBox(width: 15),
                        Button(
                          isLoading:
                              diseasesProvider.loading == "delete_cz_$index",
                          label: "Delete",
                          borderColor: Colors.red,
                          backgroundColor: Colors.red,
                          onPress: () {
                            dialogWithAction(context,
                                title: "Are you sure?",
                                description:
                                    "This will delete this data forever.",
                                actions: [
                                  Button(
                                      label: "Yes, please proceed.",
                                      onPress: () {
                                        Navigator.pop(context, "OK");
                                        diseasesProvider.deleteClassifiedZone(
                                            loading: "delete_cz_$index",
                                            key: diseasesProvider
                                                    .classifiedZones[index]
                                                    .key ??
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
                        )
                      ])
                    ]),
              ),
            );
          }),
    );
  }
}
