import 'package:intl/intl.dart';

import 'get_quarter_by_month.dart';

String dateFilterDescription(
    {required String filterType, required String dates}) {
  if (dates.isEmpty) {
    return "";
  }

  List<String> dateFilter = dates.split(" ");
  DateTime? startDate =
      dateFilter.isNotEmpty ? DateTime.tryParse(dateFilter[0]) : null;
  DateTime? endDate =
      dateFilter.length > 1 ? DateTime.tryParse(dateFilter[1]) : null;

  if (startDate == null && endDate == null) {
    return "";
  }

  if (filterType == "Monthly") {
    return "For the month of ${DateFormat('MMMM yyyy').format(startDate!)}";
  }

  if (filterType == "Quarterly") {
    return "For the ${getQuarterNameByMonth(startDate!.month)} of ${startDate.year}";
  }

  if (filterType == "Yearly") {
    return "For the Year ${startDate!.year}";
  }

  return "";
}
