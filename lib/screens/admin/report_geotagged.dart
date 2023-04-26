import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GeotaggedReport extends StatefulWidget {
  GeotaggedReport({Key? key}) : super(key: key);

  @override
  State<GeotaggedReport> createState() => _GeotaggedReportState();
}

class _GeotaggedReportState extends State<GeotaggedReport> {
  Map query = {"barangayKey": null};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseasesProvider>(context, listen: false)
          .getGeotaggedList(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    return Scaffold(
        appBar: customAppBar(context, title: "Geotag Report", actions: [
          Button(
              label: "Generate PDF",
              icon: Icons.picture_as_pdf_rounded,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: ACCENT_COLOR,
              onPress: () async {})
        ]),
        backgroundColor: Colors.white,
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
                            });
                          })),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(dataRowHeight: 100, columns: const [
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Age'),
                          ),
                          DataColumn(
                            label: Text('Gender'),
                          ),
                          DataColumn(
                            label: Text('Disease'),
                          ),
                          DataColumn(
                            label: Text('Contagious/Infectious'),
                          ),
                          DataColumn(
                            label: Text('Date Tagged'),
                          ),
                          DataColumn(
                            label: Text('Date Untagged'),
                          ),
                        ], rows: [
                          ...diseasesProvider.geotaggedIndividuals.map((value) {
                            if (value.value is Map) {
                              Map geotagged = value.value as Map;

                              return DataRow(cells: [
                                DataCell(Text(geotagged['name'] ?? "")),
                                DataCell(Text(geotagged['age'] ?? "")),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['gender'] ?? ""))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child:
                                        Text(geotagged['diseaseName'] ?? ""))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(
                                        (geotagged['isContagious'] ?? false)
                                            ? "Yes"
                                            : "No"))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['created_At'] != null
                                        ? DateFormat().format(DateTime.parse(
                                                geotagged['created_At'])
                                            .toLocal())
                                        : "Not recorded"))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['untagDate'] != null
                                        ? DateFormat().format(DateTime.parse(
                                                geotagged['untagDate'])
                                            .toLocal())
                                        : geotagged['status'] == "Untagged"
                                            ? "Not recorded"
                                            : "Still tagged"))),
                              ]);
                            }
                            return DataRow(cells: [
                              DataCell(Text("No Data")),
                              DataCell(Text("No Data")),
                              DataCell(
                                  SizedBox(width: 200, child: Text("No Data"))),
                              DataCell(
                                  SizedBox(width: 200, child: Text("No Data"))),
                              // DataCell(Button(label: "Show On Map")),
                            ]);
                          })
                        ]),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
