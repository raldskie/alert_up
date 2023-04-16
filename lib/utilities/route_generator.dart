import 'package:alert_up_project/screens/admin/forms/classified_zone_form.dart';
import 'package:alert_up_project/screens/admin/forms/disease_form.dart';
import 'package:alert_up_project/screens/admin/forms/geotag_form.dart';
import 'package:alert_up_project/screens/admin/index.dart';
import 'package:alert_up_project/screens/admin/login_form.dart';
import 'package:alert_up_project/screens/admin/summary.dart';
import 'package:alert_up_project/screens/initialize.dart';
import 'package:alert_up_project/screens/user/geofence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments != null ? settings.arguments as Map : null;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Initialize());
      case '/login':
        return MaterialPageRoute(builder: (_) => LogIn());
      case '/admin':
        return MaterialPageRoute(builder: (_) => Admin());
      case '/disease/form':
        return MaterialPageRoute(
            builder: (_) => DiseaseForm(
                  dataKey: args?['dataKey'] ?? "",
                  mode: args?['mode'],
                ));
      case '/classified-zones/form':
        return MaterialPageRoute(
            builder: (_) => ClassifiedZoneForm(
                  dataKey: args?['dataKey'] ?? "",
                  diseaseKey: args?['diseaseKey'] ?? "",
                  mode: args?['mode'],
                ));
      case '/geotag/form':
        return MaterialPageRoute(
            builder: (_) => GeoTagForm(
                  dataKey: args?['dataKey'] ?? "",
                  diseaseKey: args?['diseaseKey'] ?? "",
                  mode: args?['mode'],
                ));
      case '/user':
        return MaterialPageRoute(builder: (_) => GeoFence());
      case '/summary':
        return MaterialPageRoute(builder: (_) => ClassifiedSummary());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: const Text('Something wrong in here')));
    });
  }
}
