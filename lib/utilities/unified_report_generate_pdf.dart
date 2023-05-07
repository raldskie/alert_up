// import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:alert_up_project/utilities/asset_to_file.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'get_date_filter_desc.dart';

Future<bool?> generateUnifiedReportPDF(BuildContext context,
    {required Map reportDescription,
    required List purokReport,
    required List diseaseReport}) async {
  //Create a new PDF document
  PdfDocument document = PdfDocument();

  final PdfPage page = document.pages.add();

  // HEADER START HERE -------------------------------------

  List<int> mc_logo_imageBytes =
      await assetToBytes('assets/images/MC_LOGO.png');
  PdfBitmap mc_logo_image = PdfBitmap(mc_logo_imageBytes);
  page.graphics.drawImage(mc_logo_image, Rect.fromLTWH(80, 0, 320, 70));

  List<int> cho_logo_imageBytes =
      await assetToBytes('assets/images/CHO_MC.jpg');
  PdfBitmap cho_logo_image = PdfBitmap(cho_logo_imageBytes);
  page.graphics.drawImage(cho_logo_image, Rect.fromLTWH(400, 0, 70, 70));

  final PdfTextElement textElement1 = PdfTextElement(
      text: "City Health Office",
      // "${reportDescription['title']}\n\n${reportDescription['description']}\n\n\nBarangay: ${reportDescription['barangayName']} ${reportDescription['barangayName']} | Filtered by: ${reportDescription['dateFilterType']} | ${reportDescription['dates']}}",
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
      ));
  textElement1.draw(
    page: document.pages[0],
    bounds: Rect.fromLTWH(0, 80, page.getClientSize().width, 18),
  );

  final PdfTextElement textElement2 = PdfTextElement(
      text: reportDescription['title'] ??
          "Summary List of Infectious and Contagious Diseases Per Purok",
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
      ));
  textElement2.draw(
    page: document.pages[0],
    bounds: Rect.fromLTWH(0, 100, page.getClientSize().width, 26),
  );

  final PdfTextElement textElement3 = PdfTextElement(
      text: "Barangay ${reportDescription['barangayName']}",
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
      ));
  textElement3.draw(
    page: document.pages[0],
    bounds: Rect.fromLTWH(0, 128, page.getClientSize().width, 26),
  );

  if (reportDescription["dates"] != null) {
    final PdfTextElement textElement4 = PdfTextElement(
        text: dateFilterDescription(
            filterType: reportDescription["dateFilterType"],
            dates: reportDescription["dates"]),
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
        ));
    textElement4.draw(
      page: document.pages[0],
      bounds: Rect.fromLTWH(0, 156, page.getClientSize().width, 26),
    );
  }

  final PdfTextElement textElement5 = PdfTextElement(
    text: "Description: ${reportDescription['description']}",
    font: PdfStandardFont(PdfFontFamily.helvetica, 12),
  );
  textElement5.draw(
    page: document.pages[0],
    bounds: Rect.fromLTWH(0, 190, page.getClientSize().width, 26),
  );

  // HEADER END HERE -------------------------------------

  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 3);
  grid.headers.add(1);
  document.pageSettings.orientation = PdfPageOrientation.landscape;

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'PUROK NUMBER';
  header.cells[1].value = 'TOTAL # OF CASES';
  header.cells[2].value = '# OF CASES PER DISEASE';

  List.generate(purokReport.length, (index) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = purokReport[index]['purokName'] ?? "";
    row.cells[1].value = "${purokReport[index]['totalDisease'] ?? ""}";
    row.cells[2].value =
        ((purokReport[index]['diseases'] ?? []) as List).map((e) {
      return "${e['diseaseName']} - ${e['diseaseCount']}\n";
    }).join("");
  });

  grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
      backgroundBrush: PdfBrushes.wheat,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 25));

  grid.draw(
      page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

  PdfGrid grid2 = PdfGrid();
  grid2.columns.add(count: 3);
  grid2.headers.add(1);
  document.pageSettings.orientation = PdfPageOrientation.landscape;

  PdfGridRow header2 = grid2.headers[0];
  header2.cells[0].value = 'DISEASE NAME';
  header2.cells[1].value = 'TOTAL # OF CASES';
  header2.cells[2].value = '# OF CASES PER PUROK';

  List.generate(diseaseReport.length, (index) {
    PdfGridRow row = grid2.rows.add();
    row.cells[0].value = diseaseReport[index]['diseaseName'] ?? "";
    row.cells[1].value = "${diseaseReport[index]['totalDisease'] ?? ""}";
    row.cells[2].value =
        ((diseaseReport[index]['puroks'] ?? []) as List).map((e) {
      return "${e['purokName']} - ${e['diseaseCount']} \n";
    }).join(",");
  });

  grid2.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
      backgroundBrush: PdfBrushes.wheat,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 25));
  grid2.draw(
      page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

  PdfPage lastPage = document.pages[document.pages.count - 1];
  final PdfTextElement textElement6 = PdfTextElement(
      text: "Ms. Fiona Maquiling RN",
      brush: PdfBrushes.black,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
      ),
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      pen: PdfPen(PdfColor(0, 0, 0), width: 1));
  textElement6.draw(
    page: lastPage,
    bounds: Rect.fromLTWH(0, lastPage.getClientSize().height - 30,
        lastPage.getClientSize().width, 26),
  );
  final PdfTextElement textElement7 = PdfTextElement(
      text: "_______________________",
      brush: PdfBrushes.black,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
      ),
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      pen: PdfPen(PdfColor(0, 0, 0), width: 1));
  textElement7.draw(
    page: lastPage,
    bounds: Rect.fromLTWH(0, lastPage.getClientSize().height - 26,
        lastPage.getClientSize().width, 26),
  );
  final PdfTextElement textElement8 = PdfTextElement(
      text: "City Health Officer",
      brush: PdfBrushes.black,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
      ),
      font: PdfStandardFont(PdfFontFamily.helvetica, 12));
  textElement8.draw(
    page: lastPage,
    bounds: Rect.fromLTWH(0, lastPage.getClientSize().height - 15,
        lastPage.getClientSize().width, 26),
  );

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
