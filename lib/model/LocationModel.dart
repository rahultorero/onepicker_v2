class LocationModel {
  String? status;
  String? message;
  List<LocationData>? locationDataList;

  LocationModel({this.status, this.message, this.locationDataList});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      status: json['status'],
      message: json['message'],
      locationDataList: json['response'] != null
          ? (json['response'] as List)
          .map((item) => LocationData.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "response": locationDataList?.map((item) => item.toJson()).toList(),
    };
  }
}

class LocationData {
  String? loca;

  LocationData({this.loca});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      loca: json['LOCA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "LOCA": loca,
    };
  }
}