import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/find_barangay.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class PurokFilter extends StatelessWidget {
  final String? purokKey;
  final String? barangayKey;
  final Function(String?) onChange;
  const PurokFilter(
      {Key? key,
      required this.purokKey,
      required this.onChange,
      this.barangayKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text("Disease Ranking by Purok",
          style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Container()),
      DropdownButton2<String>(
          value: purokKey, // getBarangay()?.barangay,
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
          hint: Text("Select Purok",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          items: getBarangay(barangayKey)!
              .purok
              .map((e) => DropdownMenuItem<String>(
                    value: e.purokKey,
                    child: Text(e.purokName),
                  ))
              .toList())
    ]);
  }
}
