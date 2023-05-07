String getQuarterNameByMonth(dynamic month) {
  if ([1, 2, 3].contains(month)) {
    return "1st Quarter";
  }

  if ([4, 5, 6].contains(month)) {
    return "2nd Quarter";
  }

  if ([7, 8, 9].contains(month)) {
    return "3rd Quarter";
  }

  if ([10, 11, 12].contains(month)) {
    return "3rd Quarter";
  }

  return "Unknown Quarter";
}
