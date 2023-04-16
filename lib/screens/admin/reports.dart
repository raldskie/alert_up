import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Reports extends StatefulWidget {
  Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false)
          .getReport(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = context.watch<ReportsProvider>();

    if (reportsProvider.loading == "report") {
      return CircularProgressIndicator();
    }

    return Scaffold(
        body: Container(
            child: Column(children: [
      Text("No. of Classified Zone ${reportsProvider.classifiedZone}"),
      Text("Break In ${reportsProvider.breakIn}"),
      Text("High Risk Disease ${reportsProvider.highRiskDisease}"),
      Text("No. of classified purok ${reportsProvider.classifiedPurok}"),
      Text("Total area of casisang 32.84 Km sq"),
    ])));
  }
}
