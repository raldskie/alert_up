import 'dart:convert';
import 'package:alert_up_project/models/address_model.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReportsProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  int _classifiedZone = 0;
  int get classifiedZone => _classifiedZone;

  int _breakIn = 0;
  int get breakIn => _breakIn;

  int _highRiskDisease = 0;
  int get highRiskDisease => _highRiskDisease;

  int _classifiedPurok = 0;
  int get classifiedPurok => _classifiedPurok;

  int _classifiedArea = 0;
  int get classifiedArea => _classifiedArea;

  String _areaOfCasisang = "";
  String get areaOfCasisang => _areaOfCasisang;

  List<Map> _ranking = []; // disease ranking
  List<Map> get ranking => _ranking;

  List<Map> _purokRanking = [];
  List<Map> get purokRanking => _purokRanking;

  List<Map> _purokReport = [];
  List<Map> get purokReport => _purokReport;

  List<Map> _diseaseReport = [];
  List<Map> get diseaseReport => _diseaseReport;

  List<Map> _geotagByDisease = [];
  List<Map> get geotagByDisease => _geotagByDisease;

  int _activeCases = 0;
  int get activeCases => _activeCases;

  int _inActiveCases = 0;
  int get inActiveCases => _inActiveCases;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  getReport({Map<String, DateTime>? dates, required Function callback}) async {
    DateTime? startDate = dates?['startDate'];
    DateTime? endDate = dates?['endDate'];

    setLoading("report");
    DatabaseReference classifiedZoneRef =
        FirebaseDatabase.instance.ref("alerts_zone").child("classified_zone");
    classifiedZoneRef.onValue.listen((event) {
      _classifiedZone = event.snapshot.children.where((e) {
        DateTime? createdAt =
            DateTime.tryParse((e.value as Map)['createdAt'].toString());
        if (createdAt != null && startDate != null && endDate != null) {
          if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
            return true;
        }
        return false;
      }).length;
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });

    // classifiedZoneRef.onValue.listen((event) {
    //   int total_total = 0;
    //   int total_recover = 0;
    //   int total_deat = 0;
    //   int total_actives = 0;

    //   for (DataSnapshot ds in event.snapshot.children) {
    //     Map map = ds.value as Map;

    //     var value_total = map["Radius"];
    //     double avalue = double.parse(value_total);
    //     total_total += avalue.toInt();
    //     double d = 0.001;

    //     double s = double.parse("$total_total");
    //     double sum = s * 0.001;
    //     double kmsq2 = sum * sum;

    //     _areaOfCasisang = "${kmsq2.toStringAsExponential(2)} Km sq";
    //   }

    //   setLoading("stop");
    //   callback(200, FETCH_SUCCESS);
    // }, onError: (error) {
    //   setLoading("stop");
    //   callback(500, FETCH_ERROR);
    // });

    DatabaseReference highRiskRef =
        FirebaseDatabase.instance.ref("alerts_zone/list_of_disease");
    highRiskRef.onValue.listen((event) {
      _highRiskDisease = event.snapshot.children.length;
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });

    DatabaseReference userEnterRef =
        FirebaseDatabase.instance.ref("covid_tool/trigger/user_enter");
    userEnterRef.onValue.listen((event) {
      _breakIn = event.snapshot.children
          .where((e) {
            DateTime? createdAt =
                DateTime.tryParse((e.value as Map)['createdAt'].toString());

            if (createdAt != null && startDate != null && endDate != null) {
              if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
                return true;
            }

            return false;
          })
          .toList()
          .length;
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });

    DatabaseReference purokRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone");
    purokRef.onValue.listen((event) {
      _classifiedPurok = event.snapshot.children.length;
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getRanking({Map? filters, required Function callback}) async {
    setLoading("ranking");
    Query diseaseRef = FirebaseDatabase.instance
        .ref("alerts_zone/list_of_disease")
        .orderByChild("disease_name");

    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");

    diseaseRef.onValue.listen((event) async {
      _ranking = event.snapshot.children
          .toList()
          .map((e) => {"key": e.key, "geotagged": [], ...(e.value as Map)})
          .toList();

      geotaggedRef.onValue.listen((geotagged) {
        geotagged.snapshot.children.where((e) {
          var value = e.value as Map;

          if (filters == null) {
            return true;
          }

          int activeFilters = filters.values
              .fold(0, (value, element) => element != null ? value + 1 : value);
          int trueCount = 0;

          if (filters['dates'] != null) {
            DateTime? createdAt =
                DateTime.tryParse(value['created_At'].toString());
            DateTime? startDate = filters['dates'][0];
            DateTime? endDate = filters['dates'][1];
            if (createdAt != null && startDate != null && endDate != null) {
              if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
                trueCount += 1;
            }
          }

          if (filters['barangayKey'] != null &&
              filters['barangayKey'] == value['barangayKey']) {
            trueCount += 1;
          }

          if (filters['purokKey'] != null &&
              filters['purokKey'] == value['purokKey']) {
            trueCount += 1;
          }

          if (filters['createdAt'] != null) {
            DateTime? createdAt =
                DateTime.tryParse(value['created_At'].toString());
            DateTime? startDate = filters['createdAt'][0];
            DateTime? endDate = filters['createdAt'][1];

            if (createdAt != null && startDate != null && endDate != null) {
              if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
                trueCount += 1;
            }
          }

          return activeFilters == trueCount;
        }).forEach((tag) {
          int index = _ranking.lastIndexWhere(
              (disease) => disease['key'] == (tag.value as Map)['diseaseKey']);
          if (index > -1) {
            bool hasAdded = (_ranking[index]['geotagged'] ?? []).any(
                (user) => user['deviceId'] == (tag.value as Map)['deviceId']);
            if (!hasAdded) {
              _ranking[index] = {
                ..._ranking[index],
                "geotagged": [..._ranking[index]['geotagged'], tag.value as Map]
              };
            }

            _ranking.sort((a, b) => (((a['geotagged'] ?? []).length) >
                    ((b['geotagged'] ?? []).length))
                ? -1
                : 1);
          }
        });
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getPurokRanking(
      {required List<Purok> puroks,
      Map? filters,
      required Function callback}) async {
    setLoading("ranking");

    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");

    geotaggedRef.onValue.listen((event) async {
      _purokRanking = puroks
          .map((e) => {
                "purokName": e.purokName,
                "purokKey": e.purokKey,
                "geotagged": []
              })
          .toList();

      List<DataSnapshot> geotags = event.snapshot.children.toList();

      geotags.where((element) {
        var value = element.value as Map;

        if (filters == null) {
          return true;
        }

        int activeFilters = filters.values
            .fold(0, (value, element) => element != null ? value + 1 : value);
        int trueCount = 0;

        if (filters['diseaseKey'] != null &&
            filters['diseaseKey'] == value['diseaseKey']) {
          trueCount += 1;
        }

        if (filters['barangayKey'] != null &&
            filters['barangayKey'] == value['barangayKey']) {
          trueCount += 1;
        }

        if (filters['createdAt'] != null) {
          DateTime? createdAt =
              DateTime.tryParse(value['created_At'].toString());
          DateTime? startDate = filters['createdAt'][0];
          DateTime? endDate = filters['createdAt'][1];
          if (createdAt != null && startDate != null && endDate != null) {
            if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
              trueCount += 1;
          }
        }

        return activeFilters == trueCount;
      }).forEach((e) {
        Map geotag = e.value as Map;

        int index = _purokRanking
            .lastIndexWhere((purok) => purok['purokKey'] == geotag['purokKey']);

        if (index > -1) {
          bool hasAdded = (_purokRanking[index]['geotagged'] ?? [])
              .any((user) => user['deviceId'] == geotag['deviceId']);
          if (!hasAdded) {
            _purokRanking[index] = Map<String, Object>.from({
              ..._purokRanking[index],
              "geotagged": [..._purokRanking[index]['geotagged'], geotag]
            });
          }
        }
      });

      _purokRanking.sort((a, b) =>
          (((a['geotagged'] ?? []).length) > ((b['geotagged'] ?? []).length))
              ? -1
              : 1);

      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getActiveCasesCount(
      {Map<String, DateTime>? dates, required Function callback}) async {
    DateTime? startDate = dates?['startDate'];
    DateTime? endDate = dates?['endDate'];
    setLoading("active_cases");

    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");

    geotaggedRef.onValue.listen((event) async {
      _activeCases = event.snapshot.children.where((e) {
        DateTime? createdAt =
            DateTime.tryParse((e.value as Map)['created_At'].toString());

        if (createdAt != null && startDate != null && endDate != null) {
          if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
            return true;
        }

        return false;
      }).fold(0, (previousValue, element) {
        return (((element.value ?? {}) as Map)['status'] ?? false) == "Tagged"
            ? previousValue + 1
            : previousValue + 0;
      });
      _inActiveCases = event.snapshot.children.where((e) {
        DateTime? createdAt =
            DateTime.tryParse((e.value as Map)['created_At'].toString());

        if (createdAt != null && startDate != null && endDate != null) {
          if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
            return true;
        }

        return false;
      }).fold(0, (previousValue, element) {
        return (((element.value ?? {}) as Map)['status'] ?? false) == "Untagged"
            ? previousValue + 1
            : previousValue + 0;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  byPurokReport(
      {Map? filters, required List<Purok> puroks, required Function callback}) {
    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");
    setLoading("purok_report");

    geotaggedRef.onValue.listen((event) async {
      _purokReport = puroks
          .map((e) => {
                "purokKey": e.purokKey,
                "purokName": e.purokName,
                "totalDisease": 0,
                "diseases": [
                  // {
                  //   "diseaseKey": "",
                  //   "diseaseName" : "",
                  //   "diseaseCount" : 0
                  // }
                ]
              })
          .toList();

      List<DataSnapshot> geotags = event.snapshot.children.toList();

      geotags.where((element) {
        var value = element.value as Map;

        if (filters == null) {
          return true;
        }

        int activeFilters = filters.values
            .fold(0, (value, element) => element != null ? value + 1 : value);
        int trueCount = 0;

        if (filters['barangayKey'] != null &&
            filters['barangayKey'] == value['barangayKey']) {
          trueCount += 1;
        }

        if (filters['createdAt'] != null) {
          DateTime? createdAt =
              DateTime.tryParse(value['created_At'].toString());
          DateTime? startDate = filters['createdAt'][0];
          DateTime? endDate = filters['createdAt'][1];
          if (createdAt != null && startDate != null && endDate != null) {
            if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
              trueCount += 1;
          }
        }

        return activeFilters == trueCount;
      }).forEach((element) {
        Map geotag = element.value as Map;

        int index = _purokReport.lastIndexWhere(
            (element) => element['purokKey'] == geotag['purokKey']);

        if (index > -1) {
          _purokReport[index]['totalDisease'] += 1;

          int diseaseIndex = (_purokReport[index]['diseases'] as List)
              .lastIndexWhere((e) => e['diseaseKey'] == geotag['diseaseKey']);

          if (diseaseIndex == -1) {
            _purokReport[index]['diseases'].add({
              "diseaseKey": geotag['diseaseKey'],
              "diseaseName": geotag['diseaseName'],
              "diseaseCount": 1
            });
          } else {
            _purokReport[index]['diseases'][diseaseIndex]['diseaseCount'] += 1;
          }

          (_purokReport[index]['diseases'] as List).sort((a, b) =>
              ((a['diseaseCount'] ?? 0) > (b['diseaseCount'] ?? 0)) ? -1 : 1);
        }
      });

      _purokReport.sort((a, b) =>
          ((a['totalDisease'] ?? 0) > (b['totalDisease'] ?? 0)) ? -1 : 1);

      setLoading("stop");
      callback(500, FETCH_ERROR);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  byDiseaseReport(
      {Map? filters,
      required List<DataSnapshot> diseases,
      required Function callback}) {
    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");
    setLoading("disease_report");

    geotaggedRef.onValue.listen((event) async {
      _diseaseReport = diseases.map((e) {
        Map disease = e.value as Map;
        return {
          "diseaseKey": e.key,
          "diseaseName": disease['disease_name'],
          "totalDisease": 0,
          "puroks": [
            // {
            //   "purokKey": "",
            //   "purokName" : "",
            //   "diseaseCount" : 0
            // }
          ]
        };
      }).toList();

      List<DataSnapshot> geotags = event.snapshot.children.toList();

      geotags.where((element) {
        var value = element.value as Map;

        if (filters == null) {
          return true;
        }

        int activeFilters = filters.values
            .fold(0, (value, element) => element != null ? value + 1 : value);
        int trueCount = 0;

        if (filters['barangayKey'] != null &&
            filters['barangayKey'] == value['barangayKey']) {
          trueCount += 1;
        }

        if (filters['createdAt'] != null) {
          DateTime? createdAt =
              DateTime.tryParse(value['created_At'].toString());
          DateTime? startDate = filters['createdAt'][0];
          DateTime? endDate = filters['createdAt'][1];
          if (createdAt != null && startDate != null && endDate != null) {
            if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
              trueCount += 1;
          }
        }

        return activeFilters == trueCount;
      }).forEach((element) {
        Map geotag = element.value as Map;

        int index = _diseaseReport.lastIndexWhere(
            (element) => element['diseaseKey'] == geotag['diseaseKey']);

        if (index > -1) {
          _diseaseReport[index]['totalDisease'] += 1;

          int purokIndex = (_diseaseReport[index]['puroks'] as List)
              .lastIndexWhere((e) => e['purokKey'] == geotag['purokKey']);

          if (purokIndex == -1) {
            _diseaseReport[index]['puroks'].add({
              "purokKey": geotag['purokKey'],
              "purokName": geotag['purokName'],
              "diseaseCount": 1
            });
          } else {
            _diseaseReport[index]['puroks'][purokIndex]['diseaseCount'] += 1;
          }

          (_diseaseReport[index]['puroks'] as List).sort((a, b) =>
              ((a['diseaseCount'] ?? 0) > (b['diseaseCount'] ?? 0)) ? -1 : 1);
        }
      });

      _diseaseReport.sort((a, b) =>
          ((a['totalDisease'] ?? 0) > (b['totalDisease'] ?? 0)) ? -1 : 1);

      setLoading("stop");
      callback(500, FETCH_ERROR);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  reportGeotaggedByDisease(
      {Map? filters,
      required List<DataSnapshot> diseases,
      required Function callback}) {
    Query geotaggedRef = FirebaseDatabase.instance.ref("geotagged_individuals");
    geotaggedRef.onValue.listen((event) async {
      _geotagByDisease = diseases.map((e) {
        Map disease = e.value as Map;
        return {
          "diseaseKey": e.key,
          "diseaseName": disease['disease_name'],
          "activeCases": 0,
          "inActiveCases": 0,
          "totalCases": 0, //TEMP
          "puroks": [],
          "barangays": [],
        };
      }).toList();

      List<DataSnapshot> geotags = event.snapshot.children.toList();

      geotags.where((element) {
        var value = element.value as Map;

        if (filters == null) {
          return true;
        }

        int activeFilters = filters.keys
            .where((e) =>
                //these are excluded here
                !['totalCases', 'activeCases', 'inactiveCases'].contains(e))
            .fold(
                0,
                (value, element) =>
                    filters[element] != null ? value + 1 : value);

        int trueCount = 0;

        if (filters['barangayKey'] != null &&
            filters['barangayKey'] == value['barangayKey']) {
          trueCount += 1;
        }

        if (filters['createdAt'] != null) {
          DateTime? createdAt =
              DateTime.tryParse(value['created_At'].toString());
          DateTime? startDate = filters['createdAt'][0];
          DateTime? endDate = filters['createdAt'][1];
          if (createdAt != null && startDate != null && endDate != null) {
            if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
              trueCount += 1;
          }
        }

        return activeFilters == trueCount;
      }).forEach((element) {
        Map geotag = element.value as Map;

        int index = _geotagByDisease.lastIndexWhere(
            (element) => element['diseaseKey'] == geotag['diseaseKey']);

        if (index > -1) {
          if (geotag['status'] == "Tagged") {
            _geotagByDisease[index]['activeCases'] += 1;
          } else {
            _geotagByDisease[index]['inActiveCases'] += 1;
          }

          _geotagByDisease[index]['totalCases'] += 1;

          int purokIndex = (_geotagByDisease[index]['puroks'] as List)
              .lastIndexWhere((e) => e['purokKey'] == geotag['purokKey']);
          if (purokIndex == -1) {
            _geotagByDisease[index]['puroks'].add({
              "purokKey": geotag['purokKey'],
              "purokName": geotag['purokName']
            });
          }

          int barangayIndex = (_geotagByDisease[index]['barangays'] as List)
              .lastIndexWhere((e) => e['barangayKey'] == geotag['barangayKey']);
          if (barangayIndex == -1) {
            _geotagByDisease[index]['barangays'].add({
              "barangayKey": geotag['barangayKey'],
              "barangayName": geotag['barangay']
            });
          }
        }
      });

      // filter by quantity
      _geotagByDisease = _geotagByDisease.where((element) {
        if (!['totalCases', 'activeCases', 'inactiveCases']
            .any((e) => filters!.keys.contains(e))) {
          return true;
        }

        int activeFilters = filters!.keys
            .where((e) =>
                ['totalCases', 'activeCases', 'inactiveCases'].contains(e))
            .fold(0, (value, element) => element != null ? value + 1 : value);
        int trueCount = 0;

        if (filters['totalCases'] != null) {
          RangeValues totalCases = filters['totalCases'] as RangeValues;
          int cases = int.parse((element['totalCases'] ?? "-1").toString());
          if (cases >= totalCases.start && cases <= totalCases.end)
            trueCount += 1;
        }

        if (filters['activeCases'] != null) {
          RangeValues totalCases = filters['activeCases'] as RangeValues;
          int cases = int.parse((element['activeCases'] ?? "-1").toString());
          if (cases >= totalCases.start && cases <= totalCases.end)
            trueCount += 1;
        }

        if (filters['inactiveCases'] != null) {
          RangeValues totalCases = filters['inactiveCases'] as RangeValues;
          int cases = int.parse((element['inactiveCases'] ?? "-1").toString());
          if (cases >= totalCases.start && cases <= totalCases.end)
            trueCount += 1;
        }

        return activeFilters == trueCount;
      }).toList();

      setLoading("stop");
      callback(500, FETCH_ERROR);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }
}
