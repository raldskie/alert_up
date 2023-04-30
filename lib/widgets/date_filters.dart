import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DateFilter extends StatelessWidget {
  Function onApplyFilter;
  String startDate; //YYYY-MM-DD
  String? endDate; //YYYY-MM-DD
  double? margin;
  int? padding;
  bool? compactMode;
  Color? backgroundColor;
  DateFilter(
      {Key? key,
      required this.onApplyFilter,
      required this.startDate,
      required this.endDate,
      this.compactMode,
      this.margin,
      this.padding,
      this.backgroundColor})
      : super(key: key);

  getDay(day, week, month, year) {
    DateTime startDate = DateTime(year, month[0], day[0]);
    DateTime endDate = DateTime(year, month[0], day[0] + 1);

    onApplyFilter(startDate, endDate);
  }

  getWeek(week, month, year) {
    DateTime startDate =
        DateTime(year, month[0], week[0] * 7).subtract(const Duration(days: 7));
    DateTime endDate = DateTime(year, month[0], week[0] * 7);
    onApplyFilter(startDate, endDate);
  }

  getMonth(month, year) {
    onApplyFilter(DateTime(year, month[0], 1), DateTime(year, month[0] + 1, 0));
  }

  getQuarter(quarter, year) {
    onApplyFilter(DateTime(year, quarter[0], 1), DateTime(year, quarter[1], 0));
  }

  getYear(int year) {
    onApplyFilter(DateTime(year, 1, 1), DateTime(year, 13, 0));
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = context.watch<AppProvider>();
    double width = MediaQuery.of(context).size.width;

    return Container(
        margin: EdgeInsets.all(margin ?? 0),
        color: backgroundColor ?? Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padding?.toDouble() ?? 15),
          child: Row(children: [
            Expanded(
              child: DropdownButton2<String>(
                  value: appProvider.DATE_FILTER_TYPE,
                  underline: Container(
                    color: Colors.grey[100],
                    height: 0,
                  ),
                  iconStyleData: const IconStyleData(
                      icon: Icon(
                    Icons.filter_list_rounded,
                    size: 14,
                  )),
                  dropdownStyleData: DropdownStyleData(width: width * .5),
                  onChanged: (String? e) {
                    appProvider.setDateFilterType(e!);
                    if (e == "Weekly") {
                      getWeek(
                          appProvider.WEEK_SELECTED,
                          appProvider.MONTH_SELECTED,
                          appProvider.YEAR_SELECTED);
                    }
                    if (e == "Monthly") {
                      getMonth(appProvider.MONTH_SELECTED,
                          appProvider.YEAR_SELECTED);
                    }
                    if (e == "Quarterly") {
                      getQuarter(appProvider.QUARTER_SELECTED,
                          appProvider.YEAR_SELECTED);
                    }
                    if (e == "Yearly") {
                      getYear(appProvider.YEAR_SELECTED);
                    }
                  },
                  items: const ["Weekly", "Monthly", "Quarterly", "Yearly"]
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList()),
            ),
            Expanded(child: Container()),
            if (["Monthly", "Weekly"].contains(appProvider.DATE_FILTER_TYPE))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: PopupMenuButton<List>(
                  child: IconText(
                    label: DateFormat('MMMM')
                        .format(DateTime(0, appProvider.MONTH_SELECTED[0])),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    size: 15,
                    icon: Icons.arrow_drop_down_rounded,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: [1, "January"], child: Text("January")),
                    const PopupMenuItem(
                        value: [2, "February"], child: Text("February")),
                    const PopupMenuItem(
                        value: [3, "March"], child: Text("March")),
                    const PopupMenuItem(
                        value: [4, "April"], child: Text("April")),
                    const PopupMenuItem(value: [5, "May"], child: Text("May")),
                    const PopupMenuItem(
                        value: [6, "June"], child: Text("June")),
                    const PopupMenuItem(
                        value: [7, "July"], child: Text("July")),
                    const PopupMenuItem(
                        value: [8, "August"], child: Text("August")),
                    const PopupMenuItem(
                        value: [9, "September"], child: Text("September")),
                    const PopupMenuItem(
                        value: [10, "October"], child: Text("October")),
                    const PopupMenuItem(
                        value: [11, "November"], child: Text("November")),
                    const PopupMenuItem(
                        value: [12, "December"], child: Text("December")),
                  ],
                  offset: const Offset(0, 30),
                  elevation: 2,
                  onSelected: (e) {
                    getMonth(e, appProvider.YEAR_SELECTED);
                    appProvider.setMonth(e);
                  },
                ),
              ),
            if (["Weekly"].contains(appProvider.DATE_FILTER_TYPE))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: PopupMenuButton<List>(
                  child: IconText(
                    label: appProvider.WEEK_SELECTED[1],
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    size: 15,
                    icon: Icons.arrow_drop_down_rounded,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: [1, "Wk 1"], child: Text("Wk 1")),
                    const PopupMenuItem(
                        value: [2, "Wk 2"], child: Text("Wk 2")),
                    const PopupMenuItem(
                        value: [3, "Wk 3"], child: Text("Wk 3")),
                    const PopupMenuItem(
                        value: [4, "Wk 4"], child: Text("Wk 4")),
                    const PopupMenuItem(
                        value: [5, "Wk 5"], child: Text("Wk 5")),
                  ],
                  offset: const Offset(0, 30),
                  elevation: 2,
                  onSelected: (e) {
                    getWeek(e, appProvider.MONTH_SELECTED,
                        appProvider.YEAR_SELECTED);
                    appProvider.setWeek(e);
                  },
                ),
              ),
            if (appProvider.DATE_FILTER_TYPE == "Quarterly")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: PopupMenuButton<List>(
                  child: IconText(
                    label: appProvider.QUARTER_SELECTED[2],
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    size: 15,
                    icon: Icons.arrow_drop_down_rounded,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: [1, 4, "1st Quarter"],
                        child: Text("1st Quarter")),
                    const PopupMenuItem(
                        value: [4, 7, "2nd Quarter"],
                        child: Text("2nd Quarter")),
                    const PopupMenuItem(
                        value: [7, 10, "3rd Quarter"],
                        child: Text("3rd Quarter")),
                    const PopupMenuItem(
                        value: [10, 13, "4th Quarter"],
                        child: Text("4th Quarter")),
                  ],
                  offset: const Offset(0, 30),
                  elevation: 2,
                  onSelected: (e) {
                    getQuarter(e, appProvider.YEAR_SELECTED);
                    appProvider.setQuarter(e);
                  },
                ),
              ),
            if (["Yearly", "Quarterly", "Monthly", "Weekly"]
                .contains(appProvider.DATE_FILTER_TYPE))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: PopupMenuButton<int>(
                  child: IconText(
                    label: appProvider.YEAR_SELECTED.toString(),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    icon: Icons.arrow_drop_down_rounded,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 2022, child: Text("2022")),
                    const PopupMenuItem(value: 2023, child: Text("2023")),
                    const PopupMenuItem(value: 2024, child: Text("2024")),
                    const PopupMenuItem(value: 2025, child: Text("2025")),
                    const PopupMenuItem(value: 2026, child: Text("2026")),
                    const PopupMenuItem(value: 2027, child: Text("2027")),
                    const PopupMenuItem(value: 2028, child: Text("2028")),
                    const PopupMenuItem(value: 2029, child: Text("2029")),
                  ],
                  offset: const Offset(0, 30),
                  elevation: 2,
                  onSelected: (e) {
                    getYear(e);
                    appProvider.setYear(e);
                  },
                ),
              ),
          ]),
        ));
  }
}
