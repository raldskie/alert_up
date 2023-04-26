import 'package:alert_up_project/screens/admin/records/classified_zones.dart';
import 'package:alert_up_project/screens/admin/records/geotagged_individuals.dart';
import 'package:alert_up_project/screens/admin/records/posters.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:flutter/material.dart';

class Records extends StatefulWidget {
  Records({Key? key}) : super(key: key);

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> with SingleTickerProviderStateMixin {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
              controller: _tabController,
              indicatorColor: ACCENT_COLOR,
              unselectedLabelColor: Colors.grey,
              labelColor: ACCENT_COLOR,
              tabs: const [
                Tab(
                  icon: Icon(Icons.map_rounded),
                  text: "Classified Zones",
                ),
                Tab(
                  icon: Icon(Icons.person_pin_rounded),
                  text: "Geotagged",
                ),
                Tab(
                  icon: Icon(Icons.insert_photo_sharp),
                  text: "Posters",
                ),
              ])),
      body: TabBarView(
        controller: _tabController,
        children: [ClassifiedZones(), GeoTaggedIndividuals(), Posters()],
      ),
    );
  }
}
