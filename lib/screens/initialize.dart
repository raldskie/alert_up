import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Initialize extends StatefulWidget {
  Initialize({Key? key}) : super(key: key);

  @override
  State<Initialize> createState() => _InitializeState();
}

class _InitializeState extends State<Initialize> {
  String buildFor = "USER"; // ADMIN, USER

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, buildFor == "ADMIN" ? '/login' : '/user', (route) => false);
    });
    super.initState();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(
          context,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
        body: Center(child: PumpingAnimation()));
  }
}
