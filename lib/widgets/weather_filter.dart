import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WeatherFilter extends StatelessWidget {
  final String? weatherKey;
  final Function(String?) onChange;
  const WeatherFilter(
      {Key? key, required this.weatherKey, required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text("Select weather"),
      Expanded(child: Container()),
      DropdownButton2<String>(
          value: weatherKey,
          underline: Container(
            color: Colors.grey[100],
            height: 0,
          ),
          iconStyleData: const IconStyleData(
              icon: Icon(
            Icons.filter_list_rounded,
            size: 14,
          )),
          // dropdownStyleData: DropdownStyleData(width: 30),
          onChanged: (String? e) => onChange(e),
          hint: Text("Select weather",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          items: WEATHERS.map((e) {
            return DropdownMenuItem<String>(
              value: e.weatherKey,
              child: Text(
                e.weatherName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            );
          }).toList())
    ]);
  }
}
