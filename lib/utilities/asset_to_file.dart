import 'package:flutter/services.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<List<int>> assetToBytes(String assetPath) async {
  ByteData byteData = await rootBundle.load(assetPath);
  List<int> bytes = byteData.buffer.asUint8List();
  return bytes;
}
