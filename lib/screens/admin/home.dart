import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminHome extends StatefulWidget {
  AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String startDate = "2022-07-01";
  String endDate = "2022-07-30";

  getStats() {
    Provider.of<ReportsProvider>(context, listen: false).getReport(
        dates: {
          "startDate": DateTime.parse(startDate),
          "endDate": DateTime.parse(endDate)
        },
        callback: (code, message) {
          if (code == 200) {
            Provider.of<ReportsProvider>(context, listen: false).getRanking(
                dates: {
                  "startDate": DateTime.parse(startDate),
                  "endDate": DateTime.parse(endDate)
                },
                callback: (code, message) {
                  if (code == 200) {
                    Provider.of<ReportsProvider>(context, listen: false)
                        .getActiveCasesCount(
                            dates: {
                          "startDate": DateTime.parse(startDate),
                          "endDate": DateTime.parse(endDate)
                        },
                            callback: (code, message) {
                              if (code == 200) {}
                            });
                  }
                });
          }
        });
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

      Provider.of<AppProvider>(context, listen: false)
          .setStartDate(DateTime.parse(startDate));
      Provider.of<AppProvider>(context, listen: false)
          .setEndDate(DateTime.parse(endDate));

      getStats();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = context.watch<ReportsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/alert.png',
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 10),
            IconText(
              label: "Alert UP",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              mainAxisAlignment: MainAxisAlignment.center,
              size: 20,
            ),
            const SizedBox(height: 80),
            Row(children: [
              Expanded(
                child: HomeButtons(
                    label: "Track User",
                    icon: Icons.qr_code_rounded,
                    onPress: () {
                      Navigator.pushNamed(context, '/scan/qr',
                          arguments: {"purpose": "TRACK_GEOTAG"});
                    }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: HomeButtons(
                    label: "Geotag",
                    icon: Icons.person_pin_rounded,
                    onPress: () {
                      Navigator.pushNamed(context, '/scan/qr',
                          arguments: {"purpose": "ADD_GEOTAG"});
                      // Navigator.pushNamed(context, "/geotag/form", arguments: {
                      //   "uniqueId": "f762dbb7e796a8f5",
                      //   "mode": "ADD",
                      // });
                    }),
              )
            ]),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(.5),
              thickness: .5,
            ),
            DateFilter(
                onApplyFilter: (startDate, endDate) {
                  this.startDate = DateFormat('yyyy-MM-dd').format(startDate);
                  this.endDate = DateFormat('yyyy-MM-dd').format(endDate);
                  getStats();
                },
                startDate: startDate,
                endDate: endDate),
            IconText(
              label: "Reports",
              size: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            Row(children: [
              ReportStatBox(
                  label: "Classified Zones",
                  isLoading: reportsProvider.loading == "report",
                  value: reportsProvider.classifiedZone.toString()),
              const SizedBox(width: 20),
              ReportStatBox(
                  label: "Break Ins",
                  isLoading: reportsProvider.loading == "report",
                  value: reportsProvider.breakIn.toString()),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              ReportStatBox(
                  label: "High Risk Diseases",
                  isLoading: reportsProvider.loading == "report",
                  value: reportsProvider.highRiskDisease.toString()),
              const SizedBox(width: 20),
              ReportStatBox(
                  label: "Classified Puroks",
                  isLoading: reportsProvider.loading == "report",
                  value: reportsProvider.classifiedPurok.toString()),
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                ReportStatBox(
                    label: "Total area of Malaybalay",
                    isLoading: reportsProvider.loading == "report",
                    value: "984.4 km\u00B2"),
              ],
            ),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(.5),
              thickness: .5,
            ),
            IconText(
              isLoading: reportsProvider.loading == "ranking",
              label: "Ranking",
              size: 20,
              fontWeight: FontWeight.bold,
            ),
            ...reportsProvider.ranking.mapIndexed((index, e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}. ${e['disease_name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 15),
                            decoration: BoxDecoration(
                                color: ACCENT_COLOR,
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                              "${e['geotagged'].length} Case",
                              style: const TextStyle(color: Colors.white),
                            ))
                      ]),
                )),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(.5),
              thickness: .5,
            ),
            IconText(
              isLoading: reportsProvider.loading == "ranking",
              label: "Victims per disease",
              size: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 30),
            SizedBox(
                height: 300,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(decimalPlaces: 0, interval: 1),
                    series: <ChartSeries>[
                      BarSeries<ChartData, String>(
                          dataSource: [
                            ...reportsProvider.ranking.map((e) => ChartData(
                                label: e['disease_name'] ?? "",
                                value: (e['geotagged'].length)))
                          ],
                          color: ACCENT_COLOR,
                          xValueMapper: (ChartData data, _) => data.label,
                          yValueMapper: (ChartData data, _) => data.value),
                    ])),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(.5),
              thickness: .5,
            ),
            IconText(
              isLoading: reportsProvider.loading == "active_cases",
              label: "Active Cases",
              size: 20,
              fontWeight: FontWeight.bold,
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                reportsProvider.activeCases.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(.5),
              thickness: .5,
            ),
            IconText(
              isLoading: reportsProvider.loading == "active_cases",
              label: "Cases Healed",
              size: 20,
              fontWeight: FontWeight.bold,
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                reportsProvider.inActiveCases.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
            const SizedBox(height: 20),
          ]),
    );
  }
}

class ReportStatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool? isLoading;
  const ReportStatBox(
      {Key? key, required this.label, required this.value, this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 234, 29, 29),
                Color.fromARGB(255, 239, 93, 25),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.grey.withOpacity(.3), width: 0),
            borderRadius: BorderRadius.circular(7)),
        child: Column(children: [
          if (isLoading ?? false)
            const CircularProgressIndicator(
              color: Colors.white,
            )
          else
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ]),
      ),
    );
  }
}

class HomeButtons extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function onPress;
  const HomeButtons(
      {Key? key,
      required this.label,
      required this.icon,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress(),
      borderRadius: BorderRadius.circular(7),
      splashColor: ACCENT_COLOR.withOpacity(.1),
      focusColor: Colors.transparent,
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(7)),
          child: Column(children: [
            Icon(
              icon,
              color: ACCENT_COLOR,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: ACCENT_COLOR),
            )
          ])),
    );
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData({
    required this.label,
    required this.value,
  });
}
