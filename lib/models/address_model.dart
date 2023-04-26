import 'dart:convert';

Barangay barangayFromJson(String str) => Barangay.fromJson(json.decode(str));

String barangayToJson(Barangay data) => json.encode(data.toJson());

class Barangay {
  Barangay({
    required this.barangayKey,
    required this.barangay,
    required this.purok,
  });

  String barangayKey;
  String barangay;
  List<Purok> purok;

  factory Barangay.fromJson(Map<String, dynamic> json) => Barangay(
        barangayKey: json["barangayKey"],
        barangay: json["barangay"],
        purok: List<Purok>.from(json["purok"].map((x) => Purok.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "barangayKey": barangayKey,
        "barangay": barangay,
      };
}

class Purok {
  Purok({
    required this.purokKey,
    required this.purokName,
  });

  String purokKey;
  String purokName;

  factory Purok.fromJson(Map<String, dynamic> json) => Purok(
        purokKey: json["purokKey"],
        purokName: json["purokName"],
      );

  Map<String, dynamic> toJson() => {
        "purokKey": purokKey,
        "purokName": purokName,
      };
}
