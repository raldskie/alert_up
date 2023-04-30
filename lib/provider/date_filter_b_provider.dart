// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:flutter/cupertino.dart';

class DateFilterBProvider extends ChangeNotifier {
  //SAVE CUSTOM WIDGETS' STATE
  int _YEAR_SELECTED = DateTime.now().year;
  int get YEAR_SELECTED => _YEAR_SELECTED;

  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now();
  DateTime get endDate => _endDate;

  List _QUARTER_SELECTED = [1, 3, "1st Quarter"];
  List get QUARTER_SELECTED => _QUARTER_SELECTED;

  List _MONTH_SELECTED = [
    DateTime.now().month,
    DateTime.now().month.toString()
  ];
  List get MONTH_SELECTED => _MONTH_SELECTED;

  List _WEEK_SELECTED = [1, "Wk 1"];
  List get WEEK_SELECTED => _WEEK_SELECTED;

  List _DAY_SELECTED = [DateTime.now().day, "${DateTime.now().day}"];
  List get DAY_SELECTED => _DAY_SELECTED;

  String _DATE_FILTER_TYPE = "Weekly";
  String get DATE_FILTER_TYPE => _DATE_FILTER_TYPE;

  List<String> _loading = [];
  List<String> get loading => _loading;

  addLoading(String loading) async {
    _loading.add(loading);
    notifyListeners();
  }

  stopLoading(String loading) async {
    _loading.removeWhere((element) => element == loading);
    notifyListeners();
  }

  setYear(int year) {
    _YEAR_SELECTED = year;
    notifyListeners();
  }

  setDateFilterType(String dateFilterType) {
    _DATE_FILTER_TYPE = dateFilterType;
    notifyListeners();
  }

  setQuarter(List quarter) {
    _QUARTER_SELECTED = quarter;
    notifyListeners();
  }

  setMonth(List month) {
    _MONTH_SELECTED = month;
    notifyListeners();
  }

  setWeek(List week) {
    _WEEK_SELECTED = week;
    notifyListeners();
  }

  setDay(List day) {
    _DAY_SELECTED = day;
    notifyListeners();
  }

  setStartDate(DateTime startDate) {
    _startDate = startDate;
    notifyListeners();
  }

  setEndDate(DateTime endDate) {
    _endDate = endDate;
    notifyListeners();
  }
}
