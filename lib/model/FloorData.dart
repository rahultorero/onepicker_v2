class FloorListModel {
  String? status;
  String? message;
  List<FloorData>? response;

  FloorListModel({this.status, this.message, this.response});

  factory FloorListModel.fromJson(Map<String, dynamic> json) {
    return FloorListModel(
      status: json['status'],
      message: json['message'],
      response: json['response'] != null
          ? (json['response'] as List)
          .map((item) => FloorData.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': response?.map((item) => item.toJson()).toList(),
    };
  }
}

class FloorData {
  int? brk;

  FloorData({this.brk});

  factory FloorData.fromJson(Map<String, dynamic> json) {
    return FloorData(
      brk: json['brk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brk': brk,
    };
  }
}
