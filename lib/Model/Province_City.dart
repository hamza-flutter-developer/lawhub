// To parse this JSON data, do
//
//     final temperatures = temperaturesFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Temperatures temperaturesFromJson(String str) => Temperatures.fromJson(json.decode(str));

String temperaturesToJson(Temperatures data) => json.encode(data.toJson());

class Temperatures {
  List<Provinces> province;
  List<City> cities;

  Temperatures({
    required this.province,
    required this.cities,
  });

  factory Temperatures.fromJson(Map<String, dynamic> json) => Temperatures(
    province: List<Provinces>.from(json["province"].map((x) => Provinces.fromJson(x))),
    cities: List<City>.from(json["cities"].map((x) => City.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "province": List<dynamic>.from(province.map((x) => x.toJson())),
    "cities": List<dynamic>.from(cities.map((x) => x.toJson())),
  };
}

class City {
  String provinceId;
  String id;
  String name;

  City({
    required this.provinceId,
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    provinceId: json["ProvinceId"],
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "ProvinceId": provinceId,
    "id": id,
    "name": name,
  };
}

class Provinces {
  String id;
  String name;

  Provinces({
    required this.id,
    required this.name,
  });

  factory Provinces.fromJson(Map<String, dynamic> json) => Provinces(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
