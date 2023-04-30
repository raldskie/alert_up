import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/utilities/generate_pdf.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/disease_filter.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/purok_filter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class GeofencePurokRanking extends StatefulWidget {
  GeofencePurokRanking({Key? key}) : super(key: key);

  @override
  State<GeofencePurokRanking> createState() => _GeofencePurokRankingState();
}

class _GeofencePurokRankingState extends State<GeofencePurokRanking> {
  Map query = {};
  Map purokRankingFilter = {};

  getClassifiedZones() {
    Provider.of<DiseasesProvider>(context, listen: false)
        .getClassifiedZones(filters: query, callback: (code, message) {});
  }

  getPurokRanking() {
    Provider.of<ReportsProvider>(context, listen: false).getPurokRanking(
        puroks: getBarangay(query['barangayKey'])!.purok,
        filters: purokRankingFilter,
        callback: (code, message) {});
  }

  getDiseases() {
    Provider.of<DiseasesProvider>(context, listen: false)
        .getDiseaseList(callback: (code, message) {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getClassifiedZones();
      getDiseases();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isGeneratingPDF = false;
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();
    ReportsProvider reportsProvider = context.watch<ReportsProvider>();

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
                await generatePDF(context,
                    classifiedZones: diseasesProvider.classifiedZones
                        .map((e) => e.value is Map ? e.value as Map : null)
                        .toList()
                        .where((element) => element != null)
                        .toList());
                setState(() {
                  isGeneratingPDF = false;
                });
              })
        ]),
        body: diseasesProvider.loading == "classified_list"
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: BarangayFilter(
                          barangayKey: query['barangayKey'],
                          onChange: (value) {
                            setState(() {
                              query = {...query, "barangayKey": value};
                              purokRankingFilter = {
                                ...purokRankingFilter,
                                "barangayKey": value
                              };
                            });
                            getClassifiedZones();
                            getPurokRanking();
                          })),
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
                              purokRankingFilter['createdAt'] = [
                                startDate,
                                endDate
                              ];
                            });
                            getClassifiedZones();
                            getPurokRanking();
                          },
                          startDate: "",
                          endDate: "")),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DiseaseFilter(
                                diseases: diseasesProvider.diseases,
                                diseaseKey: purokRankingFilter['diseaseKey'],
                                onChange: (val) {
                                  setState(() {
                                    purokRankingFilter = {
                                      ...purokRankingFilter,
                                      "diseaseKey": val
                                    };
                                    query = {...query, "diseaseKey": val};
                                  });
                                  getClassifiedZones();
                                  getPurokRanking();
                                }),
                            ...reportsProvider.purokRanking
                                .mapIndexed((index, e) {
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
                                        "${index + 1}. ${e['purokName']}",
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child:
                                  DataTable(dataRowHeight: 100, columns: const [
                                DataColumn(
                                  label: Text('Purok'),
                                ),
                                DataColumn(
                                  label: Text('Disease Name'),
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
                                DataColumn(
                                  label: Text('Recorded at'),
                                ),
                              ], rows: [
                                ...diseasesProvider.classifiedZones
                                    .map((value) {
                                  if (value.value is Map) {
                                    Map classifiedZone = value.value as Map;

                                    return DataRow(cells: [
                                      DataCell(Text(
                                          classifiedZone['purokName'] ?? "")),
                                      DataCell(
                                          Text(classifiedZone['Geo_Name'])),
                                      DataCell(Text(
                                          classifiedZone['barangay'] ?? "")),
                                      DataCell(SizedBox(
                                          width: 200,
                                          child: Text(classifiedZone[
                                              'alert_message']))),
                                      DataCell(SizedBox(
                                          width: 200,
                                          child: Text(
                                              classifiedZone['Description']))),
                                      DataCell(SizedBox(
                                          width: 200,
                                          child: Text(
                                              classifiedZone['createdAt'] !=
                                                      null
                                                  ? DateFormat().format(
                                                      DateTime.parse(
                                                              classifiedZone[
                                                                  'createdAt'])
                                                          .toLocal())
                                                  : "Not recorded"))),
                                    ]);
                                  }
                                  return DataRow(cells: [
                                    DataCell(Text("No Data")),
                                    DataCell(Text("No Data")),
                                    DataCell(SizedBox(
                                        width: 200, child: Text("No Data"))),
                                    DataCell(SizedBox(
                                        width: 200, child: Text("No Data"))),
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
