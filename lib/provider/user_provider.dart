import 'dart:convert';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

class UserProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  userLogin({required Map payload, required Function callback}) async {
    setLoading("login");

    Query diseaseRef =
        FirebaseDatabase.instance.ref("users/${payload['username']}");

    diseaseRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        if ((event.snapshot.value as Map)['password'] != payload['password']) {
          callback(500, "Password incorrect. Try again.");
          return;
        }
        callback(200, FETCH_SUCCESS);
        setLoading("stop");
      } else {
        callback(500, "Username not found. Try again.");
        setLoading("stop");
      }
    });
  }

  hasEnteredClassifiedArea(
      {required Map payload, required Function callback}) async {}
}
