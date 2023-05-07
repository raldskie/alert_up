import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/debouncer.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/utilities/geotag_by_disease_generate_pdf.dart';
import 'package:alert_up_project/widgets/accordion.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ReportGeotaggedByDisease extends StatefulWidget {
  ReportGeotaggedByDisease({Key? key}) : super(key: key);

  @override
  State<ReportGeotaggedByDisease> createState() =>
      _ReportGeotaggedByDiseaseState();
}

class _ReportGeotaggedByDiseaseState extends State<ReportGeotaggedByDisease> {
  Map reportDescription = {};
  final _debouncer = Debouncer(milliseconds: 1000);
  Map query = {"barangayKey": null};

  getGeotagged() {
    Provider.of<ReportsProvider>(context, listen: false)
        .reportGeotaggedByDisease(
            filters: query,
            callback: (code, message) {},
            diseases:
                Provider.of<DiseasesProvider>(context, listen: false).diseases);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseasesProvider>(context, listen: false).getDiseaseList(
          callback: (code, message) {
        if (code == 200) {
          getGeotagged();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = context.watch<AppProvider>();
    ReportsProvider reportsProvider = context.watch<ReportsProvider>();

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

                        await geotagByDiseaseGeneratePDF(context,
                            reportDescription: {
                              ...reportDescription,
                              "dateFilterType": query['createdAt'] != null
                                  ? appProvider.DATE_FILTER_TYPE
                                  : "None",
                              "createdAt": query['createdAt'] != null
                                  ? "${query['createdAt'][0]} ${query['createdAt'][1]}"
                                  : null,
                              "barangayName":
                                  getBarangay(query['barangayKey'])?.barangay ??
                                      "None",
                            },
                            disease: reportsProvider.geotagByDisease);
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
      floatingActionButton: FloatingActionButton(
          backgroundColor: ACCENT_COLOR,
          child: Icon(Icons.picture_as_pdf_rounded),
          onPressed: () {
            addReportInfo();
          }),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: BarangayFilter(
                  barangayKey: query['barangayKey'],
                  onChange: (value) {
                    setState(() {
                      query = {...query, "barangayKey": value};
                    });
                    getGeotagged();
                  })),
          Accordion(
              titleIcon: Icons.filter_alt,
              title: "Filters",
              content: Container(
                color: ACCENT_COLOR.withOpacity(.05),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date Recorded",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Opacity(
                        opacity: query['createdAt'] != null ? 1 : .5,
                        child: DateFilter(
                            backgroundColor: Colors.transparent,
                            padding: 0,
                            onApplyFilter:
                                (DateTime startDate, DateTime endDate) {
                              setState(() {
                                query['createdAt'] = [startDate, endDate];
                              });
                              getGeotagged();
                            },
                            startDate: "",
                            endDate: ""),
                      ),
                      const SizedBox(height: 15),
                      Text(
                          "Inactive cases ${query['inactiveCases'] != null ? "| ${query['inactiveCases'].start.toInt()} to ${query['inactiveCases'].end.toInt()}" : ""}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [
                        Text("0"),
                        Expanded(
                          child: RangeSlider(
                            activeColor: ACCENT_COLOR,
                            values: query['inactiveCases'] != null
                                ? query['inactiveCases']
                                : RangeValues(0, 100000),
                            max: 100000,
                            divisions: 1000,
                            onChanged: (RangeValues values) {
                              setState(() {
                                query['inactiveCases'] = values;
                              });
                              _debouncer.run(() {
                                getGeotagged();
                              });
                            },
                          ),
                        ),
                        Text("100000"),
                      ]),
                      const SizedBox(height: 15),
                      Text(
                          "Active cases ${query['activeCases'] != null ? "| ${query['activeCases'].start.toInt()} to ${query['activeCases'].end.toInt()}" : ""}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [
                        Text("0"),
                        Expanded(
                          child: RangeSlider(
                            activeColor: ACCENT_COLOR,
                            values: query['activeCases'] != null
                                ? query['activeCases']
                                : RangeValues(0, 100000),
                            max: 100000,
                            divisions: 1000,
                            onChanged: (RangeValues values) {
                              setState(() {
                                query['activeCases'] = values;
                              });
                              _debouncer.run(() {
                                getGeotagged();
                              });
                            },
                          ),
                        ),
                        Text("100000"),
                      ]),
                      const SizedBox(height: 15),
                      Text(
                          "Total cases ${query['totalCases'] != null ? "| ${query['totalCases'].start.toInt()} to ${query['totalCases'].end.toInt()}" : ""}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [
                        Text("0"),
                        Expanded(
                          child: RangeSlider(
                            activeColor: ACCENT_COLOR,
                            values: query['totalCases'] != null
                                ? query['totalCases']
                                : RangeValues(0, 100000),
                            max: 100000,
                            divisions: 1000,
                            onChanged: (RangeValues values) {
                              setState(() {
                                query['totalCases'] = values;
                              });
                              _debouncer.run(() {
                                getGeotagged();
                              });
                            },
                          ),
                        ),
                        Text("100000"),
                      ]),
                    ]),
              )),
          Expanded(
            child: reportsProvider.loading == "disease_report"
                ? Center(
                    child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: ACCENT_COLOR,
                  ))
                : Zoom(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(columns: [
                              DataColumn(
                                label: Text('Disease Name'),
                              ),
                              DataColumn(
                                label: Text('Purok'),
                              ),
                              DataColumn(
                                label: Text('Brngy'),
                              ),
                              DataColumn(
                                label: Text('No. of active cases'),
                              ),
                              DataColumn(
                                label: Text('No. of inactive cases'),
                              ),
                              DataColumn(
                                label: Text('Total of cases'),
                              ),
                            ], rows: [
                              ...reportsProvider.geotagByDisease.map((disease) {
                                return DataRow(cells: [
                                  DataCell(Text(disease['diseaseName'] ?? "")),
                                  DataCell(Text(
                                      ((disease['puroks'] ?? []) as List)
                                          .map((e) => e['purokName'])
                                          .join(", "))),
                                  DataCell(Text((disease['barangays'] ?? [])
                                      .map((e) => e['barangayName'])
                                      .join(", "))),
                                  DataCell(
                                      Text("${disease['activeCases'] ?? ""}")),
                                  DataCell(Text(
                                      "${disease['inActiveCases'] ?? ""}")),
                                  DataCell(
                                      Text("${disease['totalCases'] ?? ""}")),
                                ]);
                              })
                            ]))),
                  ),
          ),
        ],
      ),
    );
  }
}
