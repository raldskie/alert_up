import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  Function onChanged;
  String searchKey;
  String? label;
  EdgeInsets? margin;
  EdgeInsets? contentPadding;
  Color? backgroundColor;
  double? width;
  List<Widget>? rightWidgets;
  SearchBar({
    Key? key,
    this.label,
    this.margin,
    this.contentPadding,
    this.width,
    this.backgroundColor,
    this.rightWidgets,
    required this.searchKey,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        Expanded(
          child: TextFormField(
              initialValue: searchKey,
              onChanged: (e) => onChanged(e),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(7),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  hintText: label ?? "Search",
                  prefixIcon: const Icon(Icons.search_rounded))),
        ),
        const SizedBox(
          width: 15,
        ),
        if (rightWidgets != null) ...rightWidgets!
      ]),
    );
  }
}
