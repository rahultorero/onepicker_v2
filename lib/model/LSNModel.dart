class LSNModel {
  String? status;
  String? message;
  List<LSNList>? response;

  LSNModel({this.status, this.message, this.response});

  factory LSNModel.fromJson(Map<String, dynamic> json) {
    return LSNModel(
      status: json['status'],
      message: json['message'],
      response: json['response'] != null
          ? (json['response'] as List)
          .map((e) => LSNList.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': response?.map((e) => e.toJson()).toList(),
    };
  }
}

class LSNList {
  String? lsn; // change from int? to String?

  LSNList({this.lsn});

  factory LSNList.fromJson(Map<String, dynamic> json) {
    return LSNList(
      lsn: json['LSN'].toString(), // store everything as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LSN': lsn,
    };
  }
}
