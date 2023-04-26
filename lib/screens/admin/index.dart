import 'package:alert_up_project/screens/admin/diseases.dart';
import 'package:alert_up_project/screens/admin/home.dart';
import 'package:alert_up_project/screens/admin/records.dart';
import 'package:alert_up_project/screens/admin/view_map.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context,
          automaticallyImplyLeading: false,
          title: "AlertUP",
          elevation: .2,
          actions: [
            Button(
              icon: Icons.summarize_rounded,
              label: "Reports",
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: ACCENT_COLOR,
              onPress: () => Navigator.pushNamed(context, '/select-summary'),
            )
          ]),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
            controller: tabController,
            indicator: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            unselectedLabelColor: Colors.grey,
            labelColor: ACCENT_COLOR,
            tabs: const [
              Tab(icon: Icon(Icons.home_rounded), text: 'Home'),
              Tab(icon: Icon(Icons.map_rounded), text: 'Map View'),
              Tab(icon: Icon(Icons.edit_document), text: 'Records'),
              Tab(icon: Icon(Icons.sick_rounded), text: 'Diseases'),
            ]),
      ),
      body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            AdminHome(),
            ViewMap(),
            Records(),
            Diseases(),
          ]),
    );
  }
}
