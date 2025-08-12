class LoginModel {
  String? status;
  String? message;
  UserGeneralData? response;

  LoginModel({
    this.status,
    this.message,
    this.response,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json['status'],
    message: json['message'],
    response: json['response'] != null
        ? UserGeneralData.fromJson(json['response'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'response': response?.toJson(),
  };
}

class UserGeneralData {
  int? empId;
  String? eCode;
  String? eName;
  bool? picker;
  bool? pickMan;
  bool? checker;
  bool? solver;
  bool? packer;
  bool? admin;
  bool? tray;
  bool? trayPick;
  int? brchId;
  dynamic brchName; // Object in Java = dynamic in Dart
  int? coId;
  String? coName;
  bool? locked;
  int? selectedCompanyID;
  int? selectedBranchID;
  int? selectedFloorID;

  UserGeneralData({
    this.empId,
    this.eCode,
    this.eName,
    this.picker,
    this.pickMan,
    this.checker,
    this.solver,
    this.packer,
    this.admin,
    this.tray,
    this.trayPick,
    this.brchId,
    this.brchName,
    this.coId,
    this.coName,
    this.locked,
    this.selectedCompanyID,
    this.selectedBranchID,
    this.selectedFloorID,
  });

  factory UserGeneralData.fromJson(Map<String, dynamic> json) => UserGeneralData(
    empId: int.tryParse(json['EmpId']?.toString() ?? ''),
    eCode: json['ECode'],
    eName: json['EName'],
    picker: json['Picker'],
    pickMan: json['PickMan'],
    checker: json['Checker'],
    solver: json['Solver'],
    packer: json['Packer'],
    admin: json['Admin'],
    tray: json['Tray'],
    trayPick: json['TrayPick'],
    brchId: int.tryParse(json['BrchId']?.toString() ?? ''),
    brchName: json['BrchName'],
    coId: int.tryParse(json['CoId']?.toString() ?? ''),
    coName: json['CoName'],
    locked: json['Locked'],
    selectedCompanyID: int.tryParse(json['selectedCompanyID']?.toString() ?? ''),
    selectedBranchID: int.tryParse(json['selectedBranchID']?.toString() ?? ''),
    selectedFloorID: int.tryParse(json['selectedFloorID']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'EmpId': empId,
    'ECode': eCode,
    'EName': eName,
    'Picker': picker,
    'PickMan': pickMan,
    'Checker': checker,
    'Solver': solver,
    'Packer': packer,
    'Admin': admin,
    'Tray': tray,
    'TrayPick': trayPick,
    'BrchId': brchId,
    'BrchName': brchName,
    'CoId': coId,
    'CoName': coName,
    'Locked': locked,
    'selectedCompanyID': selectedCompanyID,
    'selectedBranchID': selectedBranchID,
    'selectedFloorID': selectedFloorID,
  };
}
