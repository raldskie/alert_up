import 'package:flutter/material.dart';

bool isMobile(BuildContext context) {
  return 600 > MediaQuery.of(context).size.width;
}