import 'package:alert_up_project/models/address_model.dart';
import 'package:flutter/material.dart';

const Color ACCENT_COLOR = Colors.red;
Map<int, Color> color = {
  50: const Color.fromARGB(255, 24, 64, 116).withOpacity(.05),
  100: const Color.fromARGB(255, 24, 64, 116).withOpacity(.1),
  200: const Color.fromARGB(255, 24, 64, 116).withOpacity(.2),
  300: const Color.fromARGB(255, 24, 64, 116).withOpacity(.3),
  400: const Color.fromARGB(255, 24, 64, 116).withOpacity(.4),
  500: const Color.fromARGB(255, 24, 64, 116),
  600: const Color.fromARGB(255, 20, 54, 99),
  700: const Color.fromARGB(255, 16, 45, 82),
  800: const Color.fromARGB(255, 16, 44, 81),
  900: const Color.fromARGB(255, 13, 35, 65),
};
MaterialColor APP_COLOR_THEME = MaterialColor(0xFF880E4F, color);

const String FETCH_SUCCESS = "Success";
const String FETCH_ERROR = "An error occurred.";

const USER_PLACEHOLDER_IMAGE =
    "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png?20170328184010";

List<Barangay> BARANGAYS = [
  Barangay(barangayKey: "CAS", barangay: "Casisang", purok: [
    Purok(purokKey: "CAS-P1", purokName: "Purok 1"),
    Purok(purokKey: "CAS-P2", purokName: "Purok 2"),
    Purok(purokKey: "CAS-P3", purokName: "Purok 3"),
    Purok(purokKey: "CAS-P4", purokName: "Purok 4"),
    Purok(purokKey: "CAS-P5", purokName: "Purok 5"),
    Purok(purokKey: "CAS-P6", purokName: "Purok 6"),
    Purok(purokKey: "CAS-P7", purokName: "Purok 7"),
    Purok(purokKey: "CAS-P8", purokName: "Purok 8"),
    Purok(purokKey: "CAS-P9", purokName: "Purok 9"),
    Purok(purokKey: "CAS-P10", purokName: "Purok 10"),
    Purok(purokKey: "CAS-P11", purokName: "Purok 11"),
    Purok(purokKey: "CAS-P12", purokName: "Purok 12"),
    Purok(purokKey: "CAS-P13", purokName: "Purok 13"),
  ]),
  Barangay(barangayKey: "AGL", barangay: "Aglayan", purok: [
    Purok(purokKey: "AGL-P1", purokName: "Purok 1"),
    Purok(purokKey: "AGL-P2", purokName: "Purok 2"),
  ])
];
