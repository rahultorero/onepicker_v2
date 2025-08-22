class PickerListModel {
  String? status;
  String? message;
  List<PickerData>? pickerData;

  PickerListModel({this.status, this.message, this.pickerData});

  factory PickerListModel.fromJson(Map<String, dynamic> json) {
    return PickerListModel(
      status: json['status'],
      message: json['message'],
      pickerData: json['response'] != null
          ? (json['response'] as List)
          .map((item) => PickerData.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "response": pickerData?.map((item) => item.toJson()).toList(),
    };
  }
}

class PickerData {
  int? sIId;
  String? invNo;
  String? invDate;
  String? trayNo;
  String? delType;
  String? orderNo;
  dynamic orderDate; // Object in Java -> dynamic in Dart
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
  String? gopend;

  PickerData({
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
    this.gopend,
  });

  factory PickerData.fromJson(Map<String, dynamic> json) {
    return PickerData(
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
      gopend: json['GOPend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "SIId": sIId,
      "InvNo": invNo,
      "InvDate": invDate,
      "TrayNo": trayNo,
      "DelType": delType,
      "OrderNo": orderNo,
      "OrderDate": orderDate,
      "Party": party,
      "LMark": lMark,
      "Area": area,
      "City": city,
      "DRoute": dRoute,
      "ITime": iTime,
      "DTime": dTime,
      "DespId": despId,
      "TrayTime": trayTime,
      "GRNNo": gRNNo,
      "GOPend": gopend,
    };
  }
}
