import 'dart:convert';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

class UserProvider extends ChangeNotifier {
  String _loggedEmail = "";
  String get loggedEmail => _loggedEmail;

  String _loggedUserName = "";
  String get loggedUserName => _loggedUserName;

  String _loggedPassword = "";
  String get loggedPassword => _loggedPassword;

  String _loading = "stop";
  String get loading => _loading;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  logOut() {
    _loggedEmail = "";
    _loggedUserName = "";
    _loggedPassword = "";
  }

  userLogin({required Map payload, required Function callback}) async {
    setLoading("login");

    Query diseaseRef =
        FirebaseDatabase.instance.ref("users/${payload['username']}");

    diseaseRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        if ((event.snapshot.value as Map)['password'] != payload['password']) {
          callback(500, "Password incorrect. Try again.");
          setLoading("stop");
          return;
        }
        _loggedEmail = (event.snapshot.value as Map)['email'];
        _loggedUserName = (event.snapshot.value as Map)['username'];
        // P.S. sorry but dinalian nani, lmao
        _loggedPassword = (event.snapshot.value as Map)['password'];
        callback(200, FETCH_SUCCESS);
        setLoading("stop");
      } else {
        callback(500, "Username not found. Try again.");
        setLoading("stop");
      }
    });
  }

  setToResetUserName({required String email}) {
    Query diseaseRef = FirebaseDatabase.instance.ref("users");
    diseaseRef.onValue.listen((event) async {
      event.snapshot.children.forEach((element) {
        if (element.value is Map) {
          Map val = element.value as Map;
          if (val['email'].trim() == email.trim()) {
            _loggedUserName = val['username'];
          }
        }
      });
    });
  }

  changePassword(
      {required String newPassword, required Function callback}) async {
    setLoading("change_password");

    DatabaseReference userRef =
        FirebaseDatabase.instance.ref("users/$loggedUserName");

    try {
      await userRef.update({"password": newPassword});
      callback(200, FETCH_SUCCESS);
      await Future.delayed(const Duration(milliseconds: 500));
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  hasEnteredClassifiedArea(
      {required Map payload, required Function callback}) async {
    if (payload['deviceId'] == null) {
      return;
    }

    DatabaseReference diseaseRef =
        FirebaseDatabase.instance.ref("covid_tool/trigger/user_enter");
    try {
      setLoading("disease_add");
      await diseaseRef.child(payload['deviceId']).set({...payload});
      await Future.delayed(const Duration(milliseconds: 500));
      callback(200, FETCH_SUCCESS);
      setLoading("stop");
    } catch (e) {
      callback(500, FETCH_ERROR);
      setLoading("stop");
    }
  }

  updateLocationOfTaggedPerson(
      {required String deviceId, required Map payload}) async {
    DatabaseReference taggedPerson =
        FirebaseDatabase.instance.ref("geotagged_individuals/$deviceId");

    taggedPerson.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        if (((event.snapshot.value as Map)['status'] ?? "").toLowerCase() ==
            "tagged") {
          try {
            await taggedPerson.update({...payload});
          } catch (e) {
            print(e);
          }
        }
      }
    });
  }
}
