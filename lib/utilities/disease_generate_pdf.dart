// import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<bool?> generateDiseaseRankingPDF(BuildContext context,
    {required Map reportDescription,
    required List<Map> purokRanking,
    required List classifiedZones}) async {
  //Create a new PDF document
  PdfDocument document = PdfDocument();

  final PdfTextElement textElement = PdfTextElement(
      text:
          "${reportDescription['title']}\n\n${reportDescription['description']}\n\n\nBarangay: ${reportDescription['barangayName']} | Filtered by: ${reportDescription['dateFilterType']} | ${reportDescription['dates']} | Ranked by ${reportDescription['purokNameFilter']}",
      font: PdfStandardFont(PdfFontFamily.helvetica, 12));

  final PdfPage page = document.pages.add();

  textElement.draw(
      page: document.pages[0],
      bounds: Rect.fromLTWH(
          0, 50, page.getClientSize().width, page.getClientSize().height),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate));

  PdfGrid rankingGrid = PdfGrid();
  rankingGrid.columns.add(count: 3);
  rankingGrid.headers.add(1);

  PdfGridRow rankingHeader = rankingGrid.headers[0];
  rankingHeader.cells[0].value = 'Rank';
  rankingHeader.cells[1].value = 'Disease Name';
  rankingHeader.cells[2].value = 'Victim Count';

  List.generate(purokRanking.length, (index) {
    PdfGridRow row = rankingGrid.rows.add();
    row.cells[0].value = (index + 1).toString();
    row.cells[1].value = purokRanking[index]['purokName'];
    row.cells[2].value = (purokRanking[index]['geotagged'].length).toString();
  });

  rankingGrid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
      backgroundBrush: PdfBrushes.wheat,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 25));
  rankingGrid.draw(
      page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 4);
  grid.headers.add(1);
  document.pageSettings.orientation = PdfPageOrientation.landscape;

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'Disease Name';
  header.cells[1].value = 'Purok';
  header.cells[2].value = 'Alert Message';
  header.cells[3].value = 'Description';

  List.generate(classifiedZones.length, (index) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = classifiedZones[index]['Geo_Name'] ?? "";
    row.cells[1].value = classifiedZones[index]?['Purok'] ?? "";
    row.cells[2].value = "${classifiedZones[index]?['alert_message'] ?? ""}";
    row.cells[3].value = classifiedZones[index]['Description'] ?? "";
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
