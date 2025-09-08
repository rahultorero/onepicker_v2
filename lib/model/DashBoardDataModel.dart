import 'dart:convert';

/// ================== DBcountModel ==================
class DBcountModel {
  String? status;
  String? message;
  List<DBcountData>? response;

  DBcountModel({this.status, this.message, this.response});

  factory DBcountModel.fromJson(Map<String, dynamic> json) => DBcountModel(
    status: json['status'],
    message: json['message'],
    response: (json['response'] as List<dynamic>?)
        ?.map((e) => DBcountData.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'response': response?.map((e) => e.toJson()).toList(),
  };
}

class DBcountData {
  int? total;
  int? tray;
  int? picked;
  int? mPicked;
  int? checked;
  int? packed;
  int? delivered;

  DBcountData({
    this.total,
    this.tray,
    this.picked,
    this.mPicked,
    this.checked,
    this.packed,
    this.delivered,
  });

  factory DBcountData.fromJson(Map<String, dynamic> json) => DBcountData(
    total: json['Total'],
    tray: json['Tray'],
    picked: json['Picked'],
    mPicked: json['MPicked'],
    checked: json['Checked'],
    packed: json['Packed'],
    delivered: json['Delivered'],
  );

  Map<String, dynamic> toJson() => {
    'Total': total,
    'Tray': tray,
    'Picked': picked,
    'MPicked': mPicked,
    'Checked': checked,
    'Packed': packed,
    'Delivered': delivered,
  };
}

/// ================== DBStateModel ==================
class DBStateModel {
  String? status;
  String? message;
  List<DBStateData>? response;

  DBStateModel({this.status, this.message, this.response});

  factory DBStateModel.fromJson(Map<String, dynamic> json) => DBStateModel(
    status: json['status'],
    message: json['message'],
    response: (json['response'] as List<dynamic>?)
        ?.map((e) => DBStateData.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'response': response?.map((e) => e.toJson()).toList(),
  };
}

class DBStateData {
  int? sIId;
  String? invNo;
  String? invDate;
  String? trayNo;
  String? delType;
  String? orderNo;
  dynamic orderDate;
  String? party;
  String? lMark;
  String? area;
  String? city;
  String? dRoute;
  String? iTime;
  String? dTime;
  int? despId;
  String? trayTime;
  String? gRNNo;
  String? loca;
  String? lsn;
  int? tCount;
  dynamic camera;
  int? picked;
  int? mPicked;
  int? checked;
  int? packed;
  int? delivered;
  int? printed;
  int? plprn;

  DBStateData({
    this.sIId,
    this.invNo,
    this.invDate,
    this.trayNo,
    this.delType,
    this.orderNo,
    this.orderDate,
    this.party,
    this.lMark,
    this.area,
    this.city,
    this.dRoute,
    this.iTime,
    this.dTime,
    this.despId,
    this.trayTime,
    this.gRNNo,
    this.loca,
    this.lsn,
    this.tCount,
    this.camera,
    this.picked,
    this.mPicked,
    this.checked,
    this.packed,
    this.delivered,
    this.printed,
    this.plprn,
  });

  factory DBStateData.fromJson(Map<String, dynamic> json) => DBStateData(
    sIId: json['SIId'],
    invNo: json['InvNo'],
    invDate: json['InvDate'],
    trayNo: json['TrayNo'],
    delType: json['DelType'],
    orderNo: json['OrderNo'],
    orderDate: json['OrderDate'],
    party: json['Party'],
    lMark: json['LMark'],
    area: json['Area'],
    city: json['City'],
    dRoute: json['DRoute'],
    iTime: json['ITime'],
    dTime: json['DTime'],
    despId: json['DespId'],
    trayTime: json['TrayTime'],
    gRNNo: json['GRNNo'],
    loca: json['LOCA'],
    lsn: json['LSN'],
    tCount: json['TCount'],
    camera: json['Camera'],
    picked: json['Picked'],
    mPicked: json['MPicked'],
    checked: json['Checked'],
    packed: json['Packed'],
    delivered: json['Delivered'],
    printed: json['Printed'],
    plprn: json['PLPrn'],
  );

  Map<String, dynamic> toJson() => {
    'SIId': sIId,
    'InvNo': invNo,
    'InvDate': invDate,
    'TrayNo': trayNo,
    'DelType': delType,
    'OrderNo': orderNo,
    'OrderDate': orderDate,
    'Party': party,
    'LMark': lMark,
    'Area': area,
    'City': city,
    'DRoute': dRoute,
    'ITime': iTime,
    'DTime': dTime,
    'DespId': despId,
    'TrayTime': trayTime,
    'GRNNo': gRNNo,
    'LOCA': loca,
    'LSN': lsn,
    'TCount': tCount,
    'Camera': camera,
    'Picked': picked,
    'MPicked': mPicked,
    'Checked': checked,
    'Packed': packed,
    'Delivered': delivered,
    'Printed': printed,
    'PLPrn': plprn,
  };
}

/// ================== DbStateDtl_Model ==================
class DbStateDtlModel {
  String? status;
  String? message;
  List<DbStateDtlData>? response;

  DbStateDtlModel({this.status, this.message, this.response});

  factory DbStateDtlModel.fromJson(Map<String, dynamic> json) =>
      DbStateDtlModel(
        status: json['status'],
        message: json['message'],
        response: (json['response'] as List<dynamic>?)
            ?.map((e) => DbStateDtlData.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'response': response?.map((e) => e.toJson()).toList(),
  };
}

class DbStateDtlData {
  String? loca;
  int? lsn;
  int? pick;
  int? pickM;

  DbStateDtlData({this.loca, this.lsn, this.pick, this.pickM});

  factory DbStateDtlData.fromJson(Map<String, dynamic> json) => DbStateDtlData(
    loca: json['LOCA'],
    lsn: json['LSN'],
    pick: json['Pick'],
    pickM: json['PickM'],
  );

  Map<String, dynamic> toJson() => {
    'LOCA': loca,
    'LSN': lsn,
    'Pick': pick,
    'PickM': pickM,
  };
}
