import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/generate_pdf.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassifiedSummary extends StatefulWidget {
  ClassifiedSummary({Key? key}) : super(key: key);

  @override
  State<ClassifiedSummary> createState() => _ClassifiedSummaryState();
}

class _ClassifiedSummaryState extends State<ClassifiedSummary> {
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

    return Scaffold(
        appBar: customAppBar(context, actions: [
          Button(
              label: "Generate PDF",
              icon: Icons.picture_as_pdf_rounded,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: ACCENT_COLOR,
              onPress: () {
                generatePDF(context,
                    classifiedZones: diseasesProvider.classifiedZones
                        .map((e) => e.value is Map ? e.value as Map : null)
                        .toList()
                        .where((element) => element != null)
                        .toList());
              })
        ]),
        body: diseasesProvider.loading == "classified_list"
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: const [
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
                              child: Text(classifiedZone['alert_message']))),
                          DataCell(SizedBox(
                              width: 200,
                              child: Text(classifiedZone['Description']))),
                          // DataCell(Button(label: "Show On Map")),
                        ]);
                      }
                      return DataRow(cells: [
                        DataCell(Text("No Data")),
                        DataCell(Text("No Data")),
                        DataCell(SizedBox(width: 200, child: Text("No Data"))),
                        DataCell(SizedBox(width: 200, child: Text("No Data"))),
                        // DataCell(Button(label: "Show On Map")),
                      ]);
                    })
                  ]),
                ),
              ));
  }
}
