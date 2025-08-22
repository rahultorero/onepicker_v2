class TrayAssignerModel {
  String? status;
  String? message;
  List<TrayAssignerData>? trayAssignerData;

  TrayAssignerModel({this.status, this.message, this.trayAssignerData});

  factory TrayAssignerModel.fromJson(Map<String, dynamic> json) {
    return TrayAssignerModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      trayAssignerData: (json['response'] as List<dynamic>?)
          ?.map((e) => TrayAssignerData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': trayAssignerData?.map((e) => e.toJson()).toList(),
    };
  }
}

class TrayAssignerData {
  int? sIId;
  String? invNo;
  String? invDate;
  String? lsn;
  String? delType;
  double? invAmt;
  String? party;
  String? lMark;
  String? area;
  String? city;
  String? deliveryRoute;
  String? sman;
  int? lItem;
  int? nItem;
  int? sIUsrId;
  int? despId;
  String? dTime;
  bool? hold;

  TrayAssignerData({
    this.sIId,
    this.invNo,
    this.invDate,
    this.lsn,
    this.delType,
    this.invAmt,
    this.party,
    this.lMark,
    this.area,
    this.city,
    this.deliveryRoute,
    this.sman,
    this.lItem,
    this.nItem,
    this.sIUsrId,
    this.despId,
    this.dTime,
    this.hold,
  });

  factory TrayAssignerData.fromJson(Map<String, dynamic> json) {
    return TrayAssignerData(
      sIId: json['SIId'] is int ? json['SIId'] : int.tryParse(json['SIId']?.toString() ?? ''),
      invNo: json['InvNo']?.toString(),
      invDate: json['InvDate']?.toString(),
      lsn: json['LSN']?.toString(),
      delType: json['DelType']?.toString(),
      invAmt: (json['InvAmt'] != null) ? (json['InvAmt'] as num).toDouble() : null,
      party: json['Party']?.toString(),
      lMark: json['LMark']?.toString(),
      area: json['Area']?.toString(),
      city: json['City']?.toString(),
      deliveryRoute: json['DeliveryRoute']?.toString(),
      sman: json['Sman']?.toString(),
      lItem: json['LItem'] is int ? json['LItem'] : int.tryParse(json['LItem']?.toString() ?? ''),
      nItem: json['NItem'] is int ? json['NItem'] : int.tryParse(json['NItem']?.toString() ?? ''),
      sIUsrId: json['SIUsrId'] is int ? json['SIUsrId'] : int.tryParse(json['SIUsrId']?.toString() ?? ''),
      despId: json['DespId'] is int ? json['DespId'] : int.tryParse(json['DespId']?.toString() ?? ''),
      dTime: json['DTime']?.toString(),
      hold: json['Hold'] is bool ? json['Hold'] : (json['Hold']?.toString().toLowerCase() == "true"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SIId': sIId,
      'InvNo': invNo,
      'InvDate': invDate,
      'LSN': lsn,
      'DelType': delType,
      'InvAmt': invAmt,
      'Party': party,
      'LMark': lMark,
      'Area': area,
      'City': city,
      'DeliveryRoute': deliveryRoute,
      'Sman': sman,
      'LItem': lItem,
      'NItem': nItem,
      'SIUsrId': sIUsrId,
      'DespId': despId,
      'DTime': dTime,
      'Hold': hold,
    };
  }
}
