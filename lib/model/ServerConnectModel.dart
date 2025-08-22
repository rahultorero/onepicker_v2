class ServerConnectModel {
  String? status;
  String? message;
  List<SettingData>? settingData;

  ServerConnectModel({this.status, this.message, this.settingData});

  factory ServerConnectModel.fromJson(Map<String, dynamic> json) {
    return ServerConnectModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      settingData: (json['response'] as List<dynamic>?)
          ?.map((e) => SettingData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'response': settingData?.map((e) => e.toJson()).toList(),
  };
}

class SettingData {
  String? sName;
  int? syn;
  String? sSub;
  String? setting;

  SettingData({this.sName, this.syn, this.sSub, this.setting});

  factory SettingData.fromJson(Map<String, dynamic> json) {
    return SettingData(
      sName: json['SName']?.toString(),
      syn: json['SYN'] != null ? int.tryParse(json['SYN'].toString()) : null,
      sSub: json['SSub']?.toString(),
      setting: json['Setting']?.toString(),
    );
  }



  Map<String, dynamic> toJson() => {
    'SName': sName,
    'SYN': syn?.toString(),
    'SSub': sSub?.toString(),
    'Setting': setting?.toString(),
  };

}
