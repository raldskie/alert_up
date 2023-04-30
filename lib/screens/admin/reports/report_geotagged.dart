import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/debouncer.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:alert_up_project/utilities/geotag_generate_pdf.dart';
import 'package:alert_up_project/widgets/accordion.dart';
import 'package:alert_up_project/widgets/barangay_filter.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/date_filter_b.dart';
import 'package:alert_up_project/widgets/date_filters.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/search_bar.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:alert_up_project/widgets/weather_filter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GeotaggedReport extends StatefulWidget {
  GeotaggedReport({Key? key}) : super(key: key);

  @override
  State<GeotaggedReport> createState() => _GeotaggedReportState();
}

class _GeotaggedReportState extends State<GeotaggedReport> {
  Map reportDescription = {};
  final _debouncer = Debouncer(milliseconds: 1000);
  Map query = {"barangayKey": null};

  getGeotagged() {
    Provider.of<DiseasesProvider>(context, listen: false)
        .getGeotaggedList(filters: query, callback: (code, message) {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getGeotagged();
      Provider.of<DiseasesProvider>(context, listen: false)
          .getDiseaseList(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();
    AppProvider appProvider = context.watch<AppProvider>();

    addReportInfo() {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: 400,
                  height: 400,
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(children: [
                        const SizedBox(height: 15),
                        TextFormField(
                            initialValue: reportDescription['title'],
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            onChanged: (val) => setState(
                                () => reportDescription['title'] = val),
                            decoration: textFieldStyle(label: "Title")),
                        const SizedBox(height: 15),
                        TextFormField(
                            initialValue: reportDescription['description'],
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Field required";
                              }
                            },
                            maxLines: null,
                            onChanged: (val) => setState(
                                () => reportDescription['description'] = val),
                            decoration: textFieldStyle(label: "Description")),
                      ]),
                    )),
                    const SizedBox(height: 15),
                    Button(
                      label: "Generate PDF",
                      onPress: () async {
                        if (reportDescription['description'] == null &&
                            reportDescription['title'] == null) {
                          dialogBuilder(context,
                              title: "ERROR",
                              description: "Please add title and description");
                          return;
                        }

                        await generateGeotagPDF(context,
                            reportDescription: {
                              ...reportDescription,
                              "barangayName":
                                  getBarangay(query['barangayKey'])?.barangay ??
                                      "None",
                            },
                            geotagged: diseasesProvider.geotaggedIndividuals
                                .map((e) =>
                                    e.value is Map ? e.value as Map : null)
                                .toList()
                                .where((element) => element != null)
                                .toList());
                        Navigator.pop(context);
                      },
                    )
                  ]),
                ),
              );
            });
          });
    }

    return Scaffold(
        appBar: customAppBar(context, title: "Geotag Report", actions: [
          Button(
              label: "Generate PDF",
              icon: Icons.picture_as_pdf_rounded,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: ACCENT_COLOR,
              onPress: () async {
                addReportInfo();
              })
        ]),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 5),
            Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: BarangayFilter(
                    barangayKey: query['barangayKey'],
                    onChange: (value) {
                      setState(() {
                        query = {...query, "barangayKey": value};
                      });
                      getGeotagged();
                    })),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Accordion(
                        titleIcon: Icons.filter_alt,
                        title: "Filters",
                        content: Container(
                          color: ACCENT_COLOR.withOpacity(.05),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 25),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Search Name",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                SearchBar(
                                    searchKey: query['name'] ?? "",
                                    backgroundColor:
                                        ACCENT_COLOR.withOpacity(.1),
                                    onChanged: (val) {
                                      query['name'] = val;
                                      _debouncer.run(() {
                                        getGeotagged();
                                      });
                                    }),
                                const SizedBox(height: 20),
                                Text(
                                    "Age Range ${query['age'] != null ? "| ${query['age'].start.toInt()} to ${query['age'].end.toInt()}" : ""}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Row(children: [
                                  Text("0"),
                                  Expanded(
                                    child: RangeSlider(
                                      activeColor: ACCENT_COLOR,
                                      values: query['age'] != null
                                          ? query['age']
                                          : RangeValues(0, 100),
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          query['age'] = values;
                                        });
                                        _debouncer.run(() {
                                          getGeotagged();
                                        });
                                      },
                                    ),
                                  ),
                                  Text("100"),
                                ]),
                                const SizedBox(height: 20),
                                Text("Current weather when recorded",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                WeatherFilter(
                                    weatherKey: query['weatherKey'],
                                    onChange: (value) {
                                      query['weatherKey'] = value;
                                      getGeotagged();
                                    }),
                                const SizedBox(height: 20),
                                Text("Date Tagged",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Opacity(
                                  opacity: query['dateTagged'] != null ? 1 : .5,
                                  child: DateFilter(
                                      backgroundColor: Colors.transparent,
                                      padding: 0,
                                      onApplyFilter: (DateTime startDate,
                                          DateTime endDate) {
                                        setState(() {
                                          query['dateTagged'] = [
                                            startDate,
                                            endDate
                                          ];
                                        });
                                        _debouncer.run(() {
                                          getGeotagged();
                                        });
                                      },
                                      startDate: "",
                                      endDate: ""),
                                ),
                                const SizedBox(height: 20),
                                Text("Date Untagged",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Opacity(
                                  opacity: query['dateTagged'] != null ? 1 : .5,
                                  child: DateFilterB(
                                      backgroundColor: Colors.transparent,
                                      padding: 0,
                                      onApplyFilter: (DateTime startDate,
                                          DateTime endDate) {
                                        setState(() {
                                          query['dateUntagged'] = [
                                            startDate,
                                            endDate
                                          ];
                                        });
                                        _debouncer.run(() {
                                          getGeotagged();
                                        });
                                      },
                                      startDate: "",
                                      endDate: ""),
                                ),
                              ]),
                        )),
                    if (diseasesProvider.loading == "geotagged_list")
                      Padding(
                        padding: const EdgeInsets.all(50),
                        child: const Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: ACCENT_COLOR,
                        )),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(dataRowHeight: 100, columns: [
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Barangay'),
                          ),
                          DataColumn(
                            label: Text('Age'),
                          ),
                          DataColumn(
                            label: DropdownButton2<String>(
                                value: query['gender'],
                                underline: Container(
                                  color: Colors.grey[100],
                                  height: 0,
                                ),
                                iconStyleData: const IconStyleData(
                                    icon: Icon(
                                  Icons.filter_list_rounded,
                                  size: 14,
                                )),
                                dropdownStyleData: DropdownStyleData(
                                    padding: EdgeInsets.zero, width: 100),
                                onChanged: (String? e) {
                                  setState(() {
                                    query = {...query, "gender": e};
                                  });
                                  getGeotagged();
                                },
                                hint: Text(
                                  "Gender",
                                  style: TextStyle(color: Colors.black),
                                ),
                                items: const [
                                  "Male",
                                  "Female",
                                ]
                                    .map((e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList()),
                          ),
                          DataColumn(
                            label: DropdownButton2<String>(
                                value: null,
                                underline: Container(
                                  color: Colors.grey[100],
                                  height: 0,
                                ),
                                iconStyleData: const IconStyleData(
                                    icon: Icon(
                                  Icons.filter_list_rounded,
                                  size: 14,
                                )),
                                dropdownStyleData: DropdownStyleData(
                                    padding: EdgeInsets.zero, width: 200),
                                onChanged: (String? e) {},
                                hint: Text(
                                  "Disease",
                                  style: TextStyle(color: Colors.black),
                                ),
                                items: (diseasesProvider.diseases).map((e) {
                                  Object? value = e.value;
                                  Map disease = value is Map ? value : {};
                                  return DropdownMenuItem<String>(
                                    value: e.key,
                                    child: Text(disease['disease_name']),
                                  );
                                }).toList()),
                          ),
                          DataColumn(
                              label: DropdownButton2<String>(
                                  value: null,
                                  underline: Container(
                                    color: Colors.grey[100],
                                    height: 0,
                                  ),
                                  iconStyleData: const IconStyleData(
                                      icon: Icon(
                                    Icons.filter_list_rounded,
                                    size: 14,
                                  )),
                                  dropdownStyleData: DropdownStyleData(
                                      padding: EdgeInsets.zero, width: 100),
                                  onChanged: (String? e) {},
                                  hint: Text(
                                    'Contagious/Infectious',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  items: const [
                                    "Yes",
                                    "No",
                                  ]
                                      .map((e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList())),
                          DataColumn(
                            label: Text('Current Weather'),
                          ),
                          DataColumn(
                            label: Text('Date Tagged'),
                          ),
                          DataColumn(
                            label: Text('Date Untagged'),
                          ),
                        ], rows: [
                          ...diseasesProvider.geotaggedIndividuals.map((value) {
                            if (value.value is Map) {
                              Map geotagged = value.value as Map;

                              return DataRow(cells: [
                                DataCell(Text(geotagged['name'] ?? "")),
                                DataCell(Text(geotagged['barangay'] ?? "")),
                                DataCell(Text(geotagged['age'] ?? "")),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['gender'] ?? ""))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child:
                                        Text(geotagged['diseaseName'] ?? ""))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(
                                        (geotagged['isContagious'] ?? false)
                                            ? "Yes"
                                            : "No"))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child:
                                        Text(geotagged['weatherName'] ?? ""))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['created_At'] != null
                                        ? DateFormat().format(DateTime.parse(
                                                geotagged['created_At'])
                                            .toLocal())
                                        : "Not recorded"))),
                                DataCell(SizedBox(
                                    width: 200,
                                    child: Text(geotagged['untagDate'] != null
                                        ? DateFormat().format(DateTime.parse(
                                                geotagged['untagDate'])
                                            .toLocal())
                                        : geotagged['status'] == "Untagged"
                                            ? "Not recorded"
                                            : "Still tagged"))),
                              ]);
                            }
                            return DataRow(cells: [
                              DataCell(Text("No Data")),
                              DataCell(Text("No Data")),
                              DataCell(
                                  SizedBox(width: 200, child: Text("No Data"))),
                              DataCell(
                                  SizedBox(width: 200, child: Text("No Data"))),
                              // DataCell(Button(label: "Show On Map")),
                            ]);
                          })
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
