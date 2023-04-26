import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  List<DataSnapshot> _posters = [];
  List<DataSnapshot> get posters => _posters;

  addPost({required Map payload, required Function callback}) async {
    DatabaseReference diseaseRef = FirebaseDatabase.instance.ref("posters");

    final newKey = diseaseRef.push().key;

    try {
      setLoading("add_poster");
      await diseaseRef
          .child(newKey!)
          .set({...payload, "createdAt": DateTime.now().toIso8601String()});
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  getPosterList({required Function callback}) async {
    setLoading("poster_list");
    Query diseaseRef = FirebaseDatabase.instance.ref("posters");

    diseaseRef.onValue.listen((event) async {
      _posters = event.snapshot.children.toList();
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
      callback(200, FETCH_SUCCESS);
    }, onError: (error) {
      setLoading("stop");
      callback(500, FETCH_ERROR);
    });
  }

  deletePoster(
      {required String loading,
      required String key,
      required Function callback}) async {
    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("posters/$key");

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
}
