// ignore_for_file: non_constant_identifier_names
import 'dart:math' show cos, sqrt, asin;
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  String _address = "";
  String get address => _address;

  String _loading = "stop";
  String get loading => _loading;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  determinePosition(
      BuildContext context, Function(dynamic, bool) callback) async {
    setLoading("current_location");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      launchSnackbar(
          context: context,
          mode: "ERROR",
          message: 'Location services are disabled.');
      setLoading("current_location_failed");
      callback(null, false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          launchSnackbar(
              context: context,
              mode: "ERROR",
              message: 'Location permissions are denied');
        }
      }
      setLoading("current_location_failed");
      callback(null, false);
      return;
    }

    if (permission == LocationPermission.deniedForever && context.mounted) {
      launchSnackbar(
          context: context,
          mode: "ERROR",
          message:
              'Location permissions are permanently denied, we cannot request permissions.');
      setLoading("current_location_failed");
      callback(null, false);
    }
    Position res = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.best);
    setLoading("stop");
    callback(LatLng(res.latitude, res.longitude), true);
  }
}
