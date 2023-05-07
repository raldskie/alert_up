import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/utilities/unified_report_generate_pdf.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:zoom_widget/zoom_widget.dart';

class UnifiedRanking extends StatefulWidget {
  UnifiedRanking({Key? key}) : super(key: key);

  @override
  State<UnifiedRanking> createState() => _UnifiedRankingState();
}

class _UnifiedRankingState extends State<UnifiedRanking> {
  Map reportDescription = {};
  Map query = {};
  Map purokRankingFilter = {};

  double zoomLevel = (.7 / 2.5) * 100;

  getDiseases() {
    Provider.of<DiseasesProvider>(context, listen: false).getDiseaseList(
        callback: (code, message) {
      if (code == 200) {
        getDiseaseReport();
      }
    });
  }

  getPurokReport() {
    if (query['barangayKey'] != null) {
      Provider.of<ReportsProvider>(context, listen: false).byPurokReport(
          filters: query,
          puroks: getBarangay(query['barangayKey'])!.purok,
          callback: (code, message) {});
    }
  }

  getDiseaseReport() {
    if (query['barangayKey'] != null) {
      Provider.of<ReportsProvider>(context, listen: false).byDiseaseReport(
          filters: query,
          diseases:
              Provider.of<DiseasesProvider>(context, listen: false).diseases,
          callback: (code, message) {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDiseases();
      getPurokReport();
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

                        await generateUnifiedReportPDF(context,
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
                                  : null,
                              "diseaseNameFilter":
                                  purokRankingFilter['diseaseKey'] != null
                                      ? (diseasesProvider.diseases
                                          .lastWhereOrNull((e) =>
                                              e.key ==
                                              purokRankingFilter['diseaseKey'])
                                          ?.value as Map)['disease_name']
                                      : "None"
                            },
                            purokReport: reportsProvider.purokReport,
                            diseaseReport: reportsProvider.diseaseReport);
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
        // appBar: customAppBar(context, actions: [
        //   Button(
        //       isLoading: isGeneratingPDF,
        //       label: "Generate PDF",
        //       icon: Icons.picture_as_pdf_rounded,
        //       backgroundColor: Colors.transparent,
        //       borderColor: Colors.transparent,
        //       textColor: ACCENT_COLOR,
        //       onPress: () async {
        //         addReportInfo();
        //       })
        // ]),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.picture_as_pdf_rounded),
            backgroundColor: ACCENT_COLOR,
            onPressed: () {
              addReportInfo();
            }),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                      getPurokReport();
                      getDiseaseReport();
                    })),
            const Divider(),
            Opacity(
              opacity: query['createdAt'] != null ? 1 : .5,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DateFilter(
                      backgroundColor: Colors.transparent,
                      padding: 0,
                      onApplyFilter: (DateTime startDate, DateTime endDate) {
                        setState(() {
                          query['createdAt'] = [startDate, endDate];
                          purokRankingFilter['createdAt'] = [
                            startDate,
                            endDate
                          ];
                        });
                        getPurokReport();
                        getDiseaseReport();
                      },
                      startDate: "",
                      endDate: "")),
            ),
            const Divider(),
            if (query['barangayKey'] == null)
              Expanded(
                child: Center(
                  child: Text(
                    "Please select barangay",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (["purok_report", "disease_report"]
                .contains(diseasesProvider.loading))
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Stack(children: [
                  Zoom(
                    initScale: .7,
                    onScaleUpdate: (p0, p1) {
                      setState(() {
                        zoomLevel =
                            (double.parse(p1.toStringAsFixed(1)) / 2.5) * 100;
                      });
                    },
                    centerOnScale: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DataTable(
                                dataRowHeight: 150,
                                border: TableBorder.all(
                                    width: 1, color: Colors.grey),
                                columns: const [
                                  DataColumn(
                                    label: Text('PUROK NUMBER'),
                                  ),
                                  DataColumn(
                                    label: Text('TOTAL # OF CASES'),
                                  ),
                                  DataColumn(
                                    label: Text('# OF CASES PER DISEASE'),
                                  ),
                                ],
                                rows: [
                                  ...reportsProvider.purokReport.map((purok) {
                                    return DataRow(cells: [
                                      DataCell(Text(purok['purokName'] ?? "")),
                                      DataCell(
                                          Text("${purok['totalDisease']}")),
                                      DataCell(Column(
                                          children: (purok["diseases"] as List)
                                              .mapIndexed((i, e) {
                                        if (i > 2) return Container();

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconText(
                                                    backgroundColor: Colors.red,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    color: Colors.white,
                                                    label:
                                                        "${e['diseaseName']}"),
                                                IconText(
                                                    backgroundColor: Colors.red,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    color: Colors.white,
                                                    label:
                                                        "${e['diseaseCount']}"),
                                              ]),
                                        );
                                      }).toList())),
                                    ]);
                                  })
                                ]),
                            const SizedBox(width: 15),
                            DataTable(
                                dataRowHeight: 150,
                                border: TableBorder.all(
                                    width: 1, color: Colors.grey),
                                columns: const [
                                  DataColumn(
                                    label: Text('DISEASE NAME'),
                                  ),
                                  DataColumn(
                                    label: Text('TOTAL # OF CASES'),
                                  ),
                                  DataColumn(
                                    label: Text('# OF CASES PER PUROK'),
                                  ),
                                ],
                                rows: [
                                  ...reportsProvider.diseaseReport
                                      .map((disease) {
                                    return DataRow(cells: [
                                      DataCell(
                                          Text(disease['diseaseName'] ?? "")),
                                      DataCell(
                                          Text("${disease['totalDisease']}")),
                                      DataCell(Column(
                                          children: ((disease["puroks"] ?? [])
                                                  as List)
                                              .mapIndexed((i, e) {
                                        if (i > 2) return Container();

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconText(
                                                    backgroundColor: Colors.red,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    color: Colors.white,
                                                    label: "${e['purokName']}"),
                                                IconText(
                                                    backgroundColor: Colors.red,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    color: Colors.white,
                                                    label:
                                                        "${e['diseaseCount']}"),
                                              ]),
                                        );
                                      }).toList())),
                                    ]);
                                  })
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 30,
                    child: IconText(
                      label: "${zoomLevel.toInt()}%",
                      padding: const EdgeInsets.all(5),
                      borderRadius: 100,
                      size: 10,
                      color: Colors.white,
                      backgroundColor: Colors.black54,
                    ),
                  )
                ]),
              ),
          ],
        ));
  }
}
