import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DiseaseFilter extends StatelessWidget {
  final List<DataSnapshot> diseases;
  final String? diseaseKey;
  final Function(String?) onChange;
  const DiseaseFilter(
      {Key? key,
      required this.diseases,
      required this.diseaseKey,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text("Purok Ranking by Disease"),
      Expanded(child: Container()),
      DropdownButton2<String>(
          value: diseaseKey, // getBarangay()?.barangay,
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
          hint: Text("Select Disease",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          items: diseases.map((e) {
            return DropdownMenuItem<String>(
              value: e.key,
              child: Text((e.value as Map)['disease_name']),
            );
          }).toList())
    ]);
  }
}
