import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/disease_generate_pdf.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/purok_filter.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class GeofenceDiseaseRanking extends StatefulWidget {
  GeofenceDiseaseRanking({Key? key}) : super(key: key);

  @override
  State<GeofenceDiseaseRanking> createState() => _GeofenceDiseaseRankingState();
}

class _GeofenceDiseaseRankingState extends State<GeofenceDiseaseRanking> {
  Map reportDescription = {};
  Map query = {};

  getClassifiedZones() {
    Provider.of<DiseasesProvider>(context, listen: false)
        .getClassifiedZones(filters: query, callback: (code, message) {});
  }

  getRanking() {
    Provider.of<ReportsProvider>(context, listen: false)
        .getRanking(filters: query, callback: (code, message) {});
  }

  getDiseases() {
    Provider.of<DiseasesProvider>(context, listen: false)
        .getDiseaseList(callback: (code, message) {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getClassifiedZones();
      getRanking();
      getDiseases();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isGeneratingPDF = false;
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();
    ReportsProvider reportsProvider = context.watch<ReportsProvider>();
    AppProvider appProvider = context.watch<AppProvider>();

    addReportInfo() {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: 400,
                  height: 400,
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(children: [
                        const SizedBox(height: 15),
                        TextFormField(
                            initialValue: reportDescription['title'],
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            onChanged: (val) => setState(
                                () => reportDescription['title'] = val),
                            decoration: textFieldStyle(label: "Title")),
                        const SizedBox(height: 15),
                        TextFormField(
                            initialValue: reportDescription['description'],
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            maxLines: null,
                            onChanged: (val) => setState(
                                () => reportDescription['description'] = val),
                            decoration: textFieldStyle(label: "Description")),
                      ]),
                    )),
                    const SizedBox(height: 15),
                    Button(
                      label: "Generate PDF",
                      onPress: () async {
                        if (reportDescription['description'] == null &&
                            reportDescription['title'] == null) {
                          dialogBuilder(context,
                              title: "ERROR",
                              description: "Please add title and description");
                          return;
                        }

                        await generateDiseaseRankingPDF(context,
                            reportDescription: {
                              ...reportDescription,
                              "barangayName":
                                  getBarangay(query['barangayKey'])?.barangay ??
                                      "None",
                              "dateFilterType": query['createdAt'] != null
                                  ? appProvider.DATE_FILTER_TYPE
                                  : "None",
                              "dates": query['createdAt'] != null
                                  ? "${query['createdAt'][0]} ${query['createdAt'][1]}"
                                  : "",
                              "purokNameFilter": query['purokKey'] != null &&
                                      query['barangayKey'] != null
                                  ? getPurok(
                                      query['barangayKey'], query['purokKey'])
                                  : "None"
                            },
                            purokRanking: reportsProvider.purokRanking,
                            classifiedZones: diseasesProvider.classifiedZones
                                .map((e) =>
                                    e.value is Map ? e.value as Map : null)
                                .toList()
                                .where((element) => element != null)
                                .toList());
                        Navigator.pop(context);
                      },
                    )
                  ]),
                ),
              );
            });
          });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(context, actions: [
          Button(
              isLoading: isGeneratingPDF,
              label: "Generate PDF",
              icon: Icons.picture_as_pdf_rounded,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: ACCENT_COLOR,
              onPress: () async {
                setState(() {
                  isGeneratingPDF = true;
                });
                // await generatePDF(context,
                //     classifiedZones: diseasesProvider.classifiedZones
                //         .map((e) => e.value is Map ? e.value as Map : null)
                //         .toList()
                //         .where((element) => element != null)
                //         .toList());
                setState(() {
                  isGeneratingPDF = false;
                });
              })
        ]),
        body: diseasesProvider.loading == "classified_list"
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BarangayFilter(
                          barangayKey: query['barangayKey'],
                          onChange: (value) {
                            setState(() {
                              query = {
                                ...query,
                                "barangayKey": value,
                                "purokKey": null
                              };
                            });
                            getClassifiedZones();
                            getRanking();
                          })),
                  const Divider(),
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DateFilter(
                          backgroundColor: Colors.transparent,
                          padding: 0,
                          onApplyFilter:
                              (DateTime startDate, DateTime endDate) {
                            setState(() {
                              query['createdAt'] = [startDate, endDate];
                            });
                            getClassifiedZones();
                            getRanking();
                          },
                          startDate: "",
                          endDate: "")),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (query['barangayKey'] != null)
                              PurokFilter(
                                  purokKey: query['purokKey'],
                                  barangayKey: query['barangayKey'],
                                  onChange: (val) {
                                    setState(() {
                                      query = {...query, "purokKey": val};
                                    });
                                    getClassifiedZones();
                                    getRanking();
                                  }),
                            ...reportsProvider.ranking.mapIndexed((index, e) {
                              if (index > 2) {
                                return Container();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${index + 1}. ${e['disease_name']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 15),
                                          decoration: BoxDecoration(
                                              color: ACCENT_COLOR,
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: Text(
                                            "${e['geotagged'].length} Case",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ))
                                    ]),
                              );
                            }),
                            const SizedBox(height: 15),
                            const Divider(),
                            Text("Geofence Purok List"),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  dataRowHeight: 100,
                                  border: TableBorder.all(
                                      width: 1, color: Colors.grey),
                                  columns: const [
                                    DataColumn(
                                      label: Text('Disease Name'),
                                    ),
                                    DataColumn(
                                      label: Text('Purok'),
                                    ),
                                    DataColumn(
                                      label: Text('Barangay'),
                                    ),
                                    DataColumn(
                                      label: Text('Alert Message'),
                                    ),
                                    DataColumn(
                                      label: Text('Description'),
                                    ),
                                    // DataColumn(
                                    //   label: Text('Actions'),
                                    // ),
                                  ],
                                  rows: [
                                    ...diseasesProvider.classifiedZones
                                        .map((value) {
                                      if (value.value is Map) {
                                        Map classifiedZone = value.value as Map;

                                        return DataRow(cells: [
                                          DataCell(
                                              Text(classifiedZone['Geo_Name'])),
                                          DataCell(Text(
                                              classifiedZone['purokName'] ??
                                                  "")),
                                          DataCell(Text(
                                              classifiedZone['barangay'] ??
                                                  "")),
                                          DataCell(SizedBox(
                                              width: 200,
                                              child: Text(classifiedZone[
                                                  'alert_message']))),
                                          DataCell(SizedBox(
                                              width: 200,
                                              child: Text(classifiedZone[
                                                  'Description']))),
                                          // DataCell(Button(label: "Show On Map")),
                                        ]);
                                      }
                                      return DataRow(cells: [
                                        DataCell(Text("No Data")),
                                        DataCell(Text("No Data")),
                                        DataCell(SizedBox(
                                            width: 200,
                                            child: Text("No Data"))),
                                        DataCell(SizedBox(
                                            width: 200,
                                            child: Text("No Data"))),
                                        // DataCell(Button(label: "Show On Map")),
                                      ]);
                                    })
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
