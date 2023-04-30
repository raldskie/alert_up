import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SelectSummary extends StatefulWidget {
  SelectSummary({Key? key}) : super(key: key);

  @override
  State<SelectSummary> createState() => _SelectSummaryState();
}

class _SelectSummaryState extends State<SelectSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Reports", centerTitle: true),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Button(
            label: "Geofence | Purok Ranking",
            padding: const EdgeInsets.symmetric(vertical: 80),
            backgroundColor: Colors.transparent,
            textColor: ACCENT_COLOR,
            borderRadius: 10,
            onPress: () {
              Navigator.pushNamed(context, "/geofence/purok-ranking",
                  arguments: {"mode": "Geofence"});
            },
          ),
          const SizedBox(height: 15),
          Button(
            label: "Geofence | Disease Ranking",
            padding: const EdgeInsets.symmetric(vertical: 80),
            backgroundColor: Colors.transparent,
            textColor: ACCENT_COLOR,
            borderRadius: 10,
            onPress: () {
              Navigator.pushNamed(context, "/geofence/disease-ranking",
                  arguments: {"mode": "Geofence"});
            },
          ),
          const SizedBox(height: 15),
          Button(
            label: "Geotagging",
            padding: const EdgeInsets.symmetric(vertical: 80),
            backgroundColor: Colors.transparent,
            textColor: ACCENT_COLOR,
            borderRadius: 10,
            onPress: () {
              Navigator.pushNamed(context, "/geotagged-report",
                  arguments: {"mode": "Geotagging"});
            },
          ),
        ]),
      ),
    );
  }
}
