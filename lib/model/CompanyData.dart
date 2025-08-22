class CompanyListModel {
  String? status;
  String? message;
  List<CompanyData>? response;

  CompanyListModel({this.status, this.message, this.response});

  factory CompanyListModel.fromJson(Map<String, dynamic> json) {
    return CompanyListModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      response: json['response'] != null
          ? (json['response'] as List)
          .map((item) => CompanyData.fromJson(item))
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

class CompanyData {
  int? companyid;
  String? companyname;
  String? gstin;

  CompanyData({this.companyid, this.companyname, this.gstin});

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      companyid: json['companyid'] != null
          ? int.tryParse(json['companyid'].toString())
          : null,
      companyname: json['companyname']?.toString(),
      gstin: json['gstin']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyid': companyid,
      'companyname': companyname,
      'gstin': gstin,
    };
  }
}
