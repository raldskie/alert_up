class Weather {
  Weather({
    required this.weatherKey,
    required this.weatherName,
  });

  String weatherKey;
  String weatherName;

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        weatherKey: json["weatherKey"],
        weatherName: json["weatherName"],
      );

  Map<String, dynamic> toJson() => {
        "weatherKey": weatherKey,
        "weatherName": weatherName,
      };
}
