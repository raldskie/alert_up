import 'package:alert_up_project/screens/admin/forms/classified_zone_form.dart';
import 'package:alert_up_project/screens/admin/forms/disease_form.dart';
import 'package:alert_up_project/screens/admin/forms/geotag_form.dart';
import 'package:alert_up_project/screens/admin/index.dart';
import 'package:alert_up_project/screens/admin/login_form.dart';
import 'package:alert_up_project/screens/admin/reports/report_geotagged.dart';
import 'package:alert_up_project/screens/admin/reports/geofence_disease.dart';
import 'package:alert_up_project/screens/admin/reports/geofence_purok.dart';
import 'package:alert_up_project/screens/admin/reports/unified_reports.dart';
import 'package:alert_up_project/screens/admin/scan_qr.dart';
import 'package:alert_up_project/screens/admin/select_summary.dart';
import 'package:alert_up_project/screens/admin/report_classified_zones.dart';
import 'package:alert_up_project/screens/initialize.dart';
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
                  uniqueId: args?['uniqueId'] ?? "",
                  dataKey: args?['dataKey'] ?? "",
                  diseaseKey: args?['diseaseKey'] ?? "",
                  mode: args?['mode'],
                ));
      case '/select-summary':
        return MaterialPageRoute(builder: (_) => SelectSummary());
      case '/classified-zone-report':
        return MaterialPageRoute(builder: (_) => ClassifiedSummary());
      case '/geotagged-report':
        return MaterialPageRoute(builder: (_) => GeotaggedReport());
      case '/geofence/purok-ranking':
        return MaterialPageRoute(builder: (_) => GeofencePurokRanking());
      case '/geofence/disease-ranking':
        return MaterialPageRoute(builder: (_) => GeofenceDiseaseRanking());
      case '/reports/unified':
        return MaterialPageRoute(builder: (_) => UnifiedRanking());
      case '/scan/qr':
        return MaterialPageRoute(
            builder: (_) => QRScanner(
                  purpose: args?['purpose'] ?? "",
                ));
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
