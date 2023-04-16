import 'dart:convert';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
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
      callback(200, FETCH_SUCCESS);
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

  getClassifiedZones({required Function callback}) async {
    setLoading("classified_list");
    Query diseaseRef =
        FirebaseDatabase.instance.ref("alerts_zone/classified_zone");

    diseaseRef.onValue.listen((event) async {
      _classifiedZones = event.snapshot.children.toList();
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
      await diseaseRef.child(newKey ?? payload['Geo_Name']).set({...payload});
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
    } catch (e) {
      callback(500, FETCH_ERROR);
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

  getGeotaggedList({required Function callback}) async {
    setLoading("geotagged_list");
    Query diseaseRef = FirebaseDatabase.instance.ref("geotagged_individuals");

    diseaseRef.onValue.listen((event) async {
      _geotaggedIndividuals = event.snapshot.children.toList();
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
