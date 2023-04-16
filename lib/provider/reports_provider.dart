import 'dart:convert';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
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

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  getReport({required Function callback}) async {
    setLoading("report");
    DatabaseReference classifiedZoneRef =
        FirebaseDatabase.instance.ref("alerts_zone").child("classified_zone");
    classifiedZoneRef.onValue.listen((event) {
      _classifiedZone = event.snapshot.children.length;
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });

    classifiedZoneRef.onValue.listen((event) {
      int total_total = 0;
      int total_recover = 0;
      int total_deat = 0;
      int total_actives = 0;

      for (DataSnapshot ds in event.snapshot.children) {
        Map map = ds.value as Map;

        var value_total = map["Radius"];
        double avalue = double.parse(value_total);
        total_total += avalue.toInt();
        double d = 0.001;

        double s = double.parse("$total_total");
        double sum = s * 0.001;
        double kmsq2 = sum * sum;

        _areaOfCasisang = "${kmsq2.toStringAsExponential(2)} Km sq";
      }

      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });

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
      _breakIn = event.snapshot.children.length;
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
}
