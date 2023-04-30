// import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<bool?> generateGeotagPDF(BuildContext context,
    {required Map reportDescription, required List geotagged}) async {
  //Create a new PDF document
  PdfDocument document = PdfDocument();

  final PdfTextElement textElement = PdfTextElement(
      text:
          "${reportDescription['title']}\n\n${reportDescription['description']}\n\n\nBarangay: ${reportDescription['barangayName']}",
      font: PdfStandardFont(PdfFontFamily.helvetica, 12));

  final PdfPage page = document.pages.add();

  textElement.draw(
      page: document.pages[0],
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate));

  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 9);
  grid.headers.add(1);
  document.pageSettings.orientation = PdfPageOrientation.landscape;

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'Name';
  header.cells[1].value = 'Barangay';
  header.cells[2].value = 'Age';
  header.cells[3].value = 'Gender';
  header.cells[4].value = 'Disease';
  header.cells[5].value = 'Contagious/Infectious';
  header.cells[6].value = 'Current Weather';
  header.cells[7].value = 'Date Tagged';
  header.cells[8].value = 'Date Untagged';

  List.generate(geotagged.length, (index) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = geotagged[index]['name'] ?? "";
    row.cells[1].value = geotagged[index]['barangay'] ?? "";
    row.cells[2].value = geotagged[index]['age'] ?? "";
    row.cells[3].value = geotagged[index]['gender'] ?? "";
    row.cells[4].value = geotagged[index]['diseaseName'] ?? "";
    row.cells[5].value =
        (geotagged[index]['isContagious'] ?? false) ? "Yes" : "No";
    row.cells[6].value = geotagged[index]['weatherName'] ?? "";
    row.cells[7].value = geotagged[index]['created_At'] != null
        ? DateFormat()
            .format(DateTime.parse(geotagged[index]['created_At']).toLocal())
        : "Not recorded";
    row.cells[8].value = geotagged[index]['untagDate'] != null
        ? DateFormat()
            .format(DateTime.parse(geotagged[index]['untagDate']).toLocal())
        : "Not recorded";
  });

  grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
      backgroundBrush: PdfBrushes.wheat,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 25));

  grid.draw(
      page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

  // document.pages.add().graphics.drawString(
  //     "Total Count: $totalCount", PdfStandardFont(PdfFontFamily.timesRoman, 25),
  //     bounds: const Rect.fromLTWH(0, 0, 200, 50));

  try {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    }

    if (Platform.isAndroid &&
        await Permission.manageExternalStorage.isGranted) {
      Directory? extDir = await getExternalStorageDirectory();
      String dirPath = '${extDir!.path}/alert_up_project';
      dirPath = dirPath.replaceAll(
          "Android/data/com.example.alert_up_project/files/", "");

      String fileName =
          "alert_up_${DateFormat("yyyy_MMM_dd_hh_mm_ss").format(DateTime.now())}";

      await Directory(dirPath).create(recursive: true);
      final imagePath = await File('$dirPath/$fileName.pdf').create();
      await imagePath.writeAsBytes(await document.save());
      if (context.mounted) {
        launchSnackbar(
            context: context,
            mode: "SUCCESS",
            message: "PDF has been saved to /alert_up_project/$fileName.pdf.");
      }
      return true;
    }
  } catch (e) {
    print(e);
    launchSnackbar(context: context, mode: "ERROR", message: "Failed to save");
    return false;
  }

  document.dispose();
}
