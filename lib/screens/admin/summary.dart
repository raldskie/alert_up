import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/generate_pdf.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClassifiedSummary extends StatefulWidget {
  ClassifiedSummary({Key? key}) : super(key: key);

  @override
  State<ClassifiedSummary> createState() => _ClassifiedSummaryState();
}

class _ClassifiedSummaryState extends State<ClassifiedSummary> {
  String startDate = "2022-07-01";
  String endDate = "2022-07-30";

  getClassifiedZones() {
    Provider.of<DiseasesProvider>(context, listen: false).getClassifiedZones(
        dates: {
          "startDate": DateTime.parse(startDate),
          "endDate": DateTime.parse(endDate)
        },
        callback: (code, message) {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime now = DateTime.now();
      setState(() {
        startDate =
            DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, 1));
        endDate = DateFormat("yyyy-MM-dd")
            .format(DateTime(now.year, now.month + 1, 0));
      });
      getClassifiedZones();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isGeneratingPDF = false;
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    return Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DateFilter(
                        onApplyFilter: (startDate, endDate) {
                          this.startDate =
                              DateFormat('yyyy-MM-dd').format(startDate);
                          this.endDate =
                              DateFormat('yyyy-MM-dd').format(endDate);
                          getClassifiedZones();
                        },
                        startDate: startDate,
                        endDate: endDate),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(dataRowHeight: 100, columns: const [
                          DataColumn(
                            label: Text('Disease Name'),
                          ),
                          DataColumn(
                            label: Text('Purok'),
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
                        ], rows: [
                          ...diseasesProvider.classifiedZones.map((value) {
                            if (value.value is Map) {
                              Map classifiedZone = value.value as Map;

                              return DataRow(cells: [
                                DataCell(Text(classifiedZone['Geo_Name'])),
                                DataCell(Text(classifiedZone['Purok'] ?? "")),
                                DataCell(SizedBox(
                                    width: 200,
                                    child:
                                        Text(classifiedZone['alert_message']))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child:
                                        Text(classifiedZone['Description']))),
                                // DataCell(Button(label: "Show On Map")),
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
