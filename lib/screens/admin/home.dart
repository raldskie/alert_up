import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 20),
        Image.asset(
          'assets/images/alert.png',
          height: 80,
          width: 80,
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
                }),
          )
        ]),
        const SizedBox(height: 30),
        Divider(
          color: Colors.grey.withOpacity(.5),
          thickness: .5,
        ),
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
        )
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
