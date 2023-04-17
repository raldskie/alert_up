import 'dart:math' as Math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart' as math;

String calculateDistance(LatLng position1, LatLng position2) {
  const double earthRadius = 6371; // km

  double dLat = math.radians(position2.latitude - position1.latitude);
  double dLon = math.radians(position2.longitude - position2.longitude);

  double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(math.radians(position1.latitude)) *
          Math.cos(math.radians(position2.latitude)) *
          Math.sin(dLon / 2) *
          Math.sin(dLon / 2);

  double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  double distance = earthRadius * c;

  return distance.toStringAsFixed(2);
}
