import 'package:alert_up_project/models/address_model.dart';
import 'package:alert_up_project/models/weather_model.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:collection/collection.dart';

Barangay? getBarangay(String? barangayKey) {
  return BARANGAYS
      .lastWhereOrNull((element) => element.barangayKey == barangayKey);
}

Purok? getPurok(String? barangayKey, String? purokKey) {
  Barangay? barangay = BARANGAYS
      .lastWhereOrNull((element) => element.barangayKey == barangayKey);

  if (barangay != null) {
    return barangay.purok.lastWhereOrNull((e) => e.purokKey == purokKey);
  }

  return null;
}

Weather? getWeather(String? weatherKey) {
  return WEATHERS.lastWhereOrNull((e) => e.weatherKey == weatherKey);
}
