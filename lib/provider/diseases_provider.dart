import 'dart:convert';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DiseasesProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  List<DataSnapshot> _diseases = [];
  List<DataSnapshot> get diseases => _diseases;

  List<DataSnapshot> _classifiedZones = [];
  List<DataSnapshot> get classifiedZones => _classifiedZones;

  List<DataSnapshot> _geotaggedIndividuals = [];
  List<DataSnapshot> get geotaggedIndividuals => _geotaggedIndividuals;

  DataSnapshot? _disease;
  DataSnapshot? get disease => _disease;

  DataSnapshot? _classifiedZone;
  DataSnapshot? get classifiedZone => _classifiedZone;

  DataSnapshot? _geoTaggedIndividual;
  DataSnapshot? get geoTaggedIndividual => _geoTaggedIndividual;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  getDisease({required String key, required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/list_of_disease/$key");

    try {
      setLoading("disease");
      diseaseRef.onValue.listen((event) async {
        if (event.snapshot.value != null) {
          _disease = event.snapshot;
          callback(200, FETCH_SUCCESS);
          await Future.delayed(const Duration(milliseconds: 500));
          setLoading("stop");
        } else {
          callback(500, FETCH_ERROR);
          setLoading("stop");
        }
      });
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  deleteDisease(
      {required String loading,
      required String key,
      required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/list_of_disease/$key");

    try {
      setLoading(loading);
      await diseaseRef.set(null);
      callback(200, "Data deleted successfully");
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  addDisease({required Map payload, required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/list_of_disease");

    final newKey = diseaseRef.push().key;

    try {
      setLoading("disease_add");
      await diseaseRef
          .child(newKey ?? payload['disease_name'])
          .set({...payload});
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  updateDisease(
      {required String key,
      required Map payload,
      required Function callback}) async {
    setLoading("disease_edit");
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/list_of_disease/$key");

    try {
      await diseaseRef.update({...payload});
      callback(200, FETCH_SUCCESS);
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  getDiseaseList({required Function callback}) async {
    setLoading("disease_list");
    Query diseaseRef = FirebaseDatabase.instance
        .ref("alerts_zone/list_of_disease")
        .orderByChild("disease_name");

    diseaseRef.onValue.listen((event) async {
      _diseases = event.snapshot.children.toList();
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getClassifiedZones({Map? filters, required Function callback}) async {
    setLoading("classified_list");
    Query diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone");

    diseaseRef.onValue.listen((event) async {
      if (filters != null) {
        _classifiedZones = event.snapshot.children.where((element) {
          var value = element.value as Map;

          int activeFilters = filters.values
              .fold(0, (value, element) => element != null ? value + 1 : value);

          int trueCount = 0;

          if (filters['barangayKey'] != null &&
              filters['barangayKey'] == value['barangayKey']) {
            trueCount += 1;
          }

          if (filters['purokKey'] != null &&
              filters['purokKey'] == value['purokKey']) {
            trueCount += 1;
          }

          if (filters['diseaseKey'] != null &&
              filters['diseaseKey'] == value['diseaseKey']) {
            trueCount += 1;
          }

          return activeFilters == trueCount;
        }).toList();
      } else {
        _classifiedZones = event.snapshot.children.toList();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getClassifiedZone({required String key, required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone/$key");

    try {
      setLoading("c_zone");
      diseaseRef.onValue.listen((event) async {
        if (event.snapshot.value != null) {
          _classifiedZone = event.snapshot;
          callback(200, FETCH_SUCCESS);
          await Future.delayed(const Duration(milliseconds: 500));
          setLoading("stop");
        } else {
          callback(500, FETCH_ERROR);
          setLoading("stop");
        }
      });
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  addClassifiedZones({required Map payload, required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone");

    final newKey = diseaseRef.push().key;

    try {
      setLoading("add_cz");
      await diseaseRef.child(newKey ?? payload['Geo_Name']).set({
        ...payload,
        "createdAt": DateTime.now().toLocal().toIso8601String()
      });
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, "Successfully Added");
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  updateClassifiedZone(
      {required String key,
      required Map payload,
      required Function callback}) async {
    setLoading("classified_zone_edit");
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone/$key");

    try {
      await diseaseRef.update({...payload});
      callback(200, FETCH_SUCCESS);
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  deleteClassifiedZone(
      {required String loading,
      required String key,
      required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone/$key");

    try {
      setLoading(loading);
      await diseaseRef.set(null);
      callback(200, FETCH_SUCCESS);
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  addGeotag({required Map payload, required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("geotagged_individuals");

    try {
      setLoading("add_geotag");
      await diseaseRef
          .child(payload['deviceId'])
          .set({...payload, "created_At": DateTime.now().toIso8601String()});
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  updateGeotag(
      {required String key,
      required Map payload,
      required Function callback}) async {
    setLoading("geotag_edit");
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("geotagged_individuals/$key");

    try {
      await diseaseRef.update({...payload});
      callback(200, FETCH_SUCCESS);
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  getGeotaggedList({Map? filters, required Function callback}) async {
    setLoading("geotagged_list");
    Query diseaseRef = FirebaseDatabase.instance.ref("geotagged_individuals");

    diseaseRef.onValue.listen((event) async {
      if (filters == null || filters.keys.isEmpty) {
        _geotaggedIndividuals = event.snapshot.children.toList();
      } else {
        _geotaggedIndividuals = event.snapshot.children.where((element) {
          var value = element.value as Map;

          int activeFilters = filters.values
              .fold(0, (value, element) => element != null ? value + 1 : value);

          int trueCount = 0;

          if (filters['barangayKey'] != null &&
              filters['barangayKey'] == value['barangayKey']) {
            trueCount += 1;
          }

          if (filters['gender'] != null &&
              filters['gender'] == value['gender']) {
            trueCount += 1;
          }

          if (filters['name'] != null &&
              (value['name'] as String)
                  .toLowerCase()
                  .contains(filters['name'].toLowerCase())) {
            trueCount += 1;
          }

          if (filters['age'] != null) {
            RangeValues age = filters['age'] as RangeValues;
            int userAge = int.parse(value['age'] ?? "-1");
            if (userAge >= age.start && userAge <= age.end) trueCount += 1;
          }

          if (filters['dateTagged'] != null) {
            DateTime? createdAt =
                DateTime.tryParse(value['created_At'].toString());
            DateTime? startDate = filters['dateTagged'][0];
            DateTime? endDate = filters['dateTagged'][1];

            if (createdAt != null && startDate != null && endDate != null) {
              if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
                trueCount += 1;
            }
          }

          if (filters['dateUntagged'] != null) {
            DateTime? createdAt =
                DateTime.tryParse(value['untagDate'].toString());
            DateTime? startDate = filters['dateUntagged'][0];
            DateTime? endDate = filters['dateUntagged'][1];

            if (createdAt != null && startDate != null && endDate != null) {
              if (startDate.isBefore(createdAt) && endDate.isAfter(createdAt))
                trueCount += 1;
            }
          }

          // print(filters.values);
          // print(activeFilters);
          // print(trueCount);

          return activeFilters == trueCount;
        }).toList();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  getGeotaggedIndividual(
      {required String dataKey, required Function callback}) async {
    setLoading("geotagged");
    Query diseaseRef =
        FirebaseDatabase.instance.ref("geotagged_individuals/$dataKey");

    diseaseRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        _geoTaggedIndividual = event.snapshot;
        callback(200, FETCH_SUCCESS);
        await Future.delayed(const Duration(milliseconds: 500));
        setLoading("stop");
      } else {
        callback(500, FETCH_ERROR);
        setLoading("stop");
      }
    });
  }
}
