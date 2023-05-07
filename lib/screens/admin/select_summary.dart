import 'package:alert_up_project/screens/admin/reports/report_geotagged.dart';
import 'package:alert_up_project/screens/admin/reports/report_geotagged_by_disease.dart';
import 'package:alert_up_project/screens/admin/reports/unified_reports.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SelectSummary extends StatefulWidget {
  SelectSummary({Key? key}) : super(key: key);

  @override
  State<SelectSummary> createState() => _SelectSummaryState();
}

class _SelectSummaryState extends State<SelectSummary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context,
            title: "Reports",
            centerTitle: true,
            bottom: TabBar(
                controller: _tabController,
                indicatorColor: ACCENT_COLOR,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                labelColor: ACCENT_COLOR,
                tabs: const [
                  Tab(
                    text: "Geofence",
                  ),
                  Tab(
                    text: "Geotag by Person",
                  ),
                  Tab(
                    text: "Geotag by Disease",
                  ),
                ])),
        backgroundColor: Colors.white,
        body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              UnifiedRanking(),
              GeotaggedReport(),
              ReportGeotaggedByDisease()
            ]));
  }
}


// Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           // Button(
//           //   label: "Geofence | Purok Ranking",
//           //   padding: const EdgeInsets.symmetric(vertical: 80),
//           //   backgroundColor: Colors.white,
//           //   textColor: ACCENT_COLOR,
//           //   borderRadius: 10,
//           //   onPress: () {
//           //     Navigator.pushNamed(context, "/geofence/purok-ranking",
//           //         arguments: {"mode": "Geofence"});
//           //   },
//           // ),
//           // const SizedBox(height: 15),
//           // Button(
//           //   label: "Geofence | Disease Ranking",
//           //   padding: const EdgeInsets.symmetric(vertical: 80),
//           //   backgroundColor: Colors.white,
//           //   textColor: ACCENT_COLOR,
//           //   borderRadius: 10,
//           //   onPress: () {
//           //     Navigator.pushNamed(context, "/geofence/disease-ranking",
//           //         arguments: {"mode": "Geofence"});
//           //   },
//           // ),
//           Button(
//             label: "Reports",
//             padding: const EdgeInsets.symmetric(vertical: 80),
//             backgroundColor: Colors.white,
//             textColor: ACCENT_COLOR,
//             borderRadius: 10,
//             onPress: () {
//               Navigator.pushNamed(context, "/reports/unified",
//                   arguments: {"mode": "Geofence"});
//             },
//           ),
//           const SizedBox(height: 15),
//           Button(
//             label: "Geotagging",
//             padding: const EdgeInsets.symmetric(vertical: 80),
//             backgroundColor: Colors.white,
//             textColor: ACCENT_COLOR,
//             borderRadius: 10,
//             onPress: () {
//               Navigator.pushNamed(context, "/geotagged-report",
//                   arguments: {"mode": "Geotagging"});
//             },
//           ),
//         ]),
//       ),