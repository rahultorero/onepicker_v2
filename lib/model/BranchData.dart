class BranchListModel {
  String? status;
  String? message;
  List<BranchData>? response;

  BranchListModel({this.status, this.message, this.response});

  factory BranchListModel.fromJson(Map<String, dynamic> json) {
    return BranchListModel(
      status: json['status'],
      message: json['message'],
      response: json['response'] != null
          ? (json['response'] as List)
          .map((item) => BranchData.fromJson(item))
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

class BranchData {
  int? brchid;
  String? brchname;
  String? gstin;

  BranchData({this.brchid, this.brchname, this.gstin});

  factory BranchData.fromJson(Map<String, dynamic> json) {
    return BranchData(
      brchid: json['brchid'],
      brchname: json['brchname'],
      gstin: json['gstin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brchid': brchid,
      'brchname': brchname,
      'gstin': gstin,
    };
  }
}
