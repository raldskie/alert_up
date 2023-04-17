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
