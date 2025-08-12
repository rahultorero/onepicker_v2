class UserListModel {
  String? status;
  String? message;
  List<UserData>? userData;

  UserListModel({this.status, this.message, this.userData});

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      status: json['status'],
      message: json['message'],
      userData: json['response'] != null
          ? List<UserData>.from(
          json['response'].map((x) => UserData.fromJson(x)))
          : null,
    );
  }
}

class UserData {
  int? empId;
  String? eName;
  String? mobile;
  String? pwd;
  String? eCode;
  bool? picker;
  bool? pickMan;
  bool? checker;
  bool? solver;
  bool? packer;
  bool? admin;
  bool? trayPick;
  bool? tray;
  bool? locked;
  String? email;
  String? cmail;
  String? brchId;
  String? brchName;
  String? coId;
  String? coName;

  UserData({
    this.empId,
    this.eName,
    this.mobile,
    this.pwd,
    this.eCode,
    this.picker,
    this.pickMan,
    this.checker,
    this.solver,
    this.packer,
    this.admin,
    this.trayPick,
    this.tray,
    this.locked,
    this.email,
    this.cmail,
    this.brchId,
    this.brchName,
    this.coId,
    this.coName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      empId: json['EmpId'],
      eName: json['EName']?.toString(),
      mobile: json['Mobile']?.toString(),
      pwd: json['Pwd']?.toString(),
      eCode: json['ECode']?.toString(),
      picker: json['Picker'],
      pickMan: json['PickMan'],
      checker: json['Checker'],
      solver: json['Solver'],
      packer: json['Packer'],
      admin: json['Admin'],
      trayPick: json['TrayPick'],
      tray: json['Tray'],
      locked: json['Locked'],
      email: json['Email']?.toString(),
      cmail: json['Cmail']?.toString(),
      brchId: json['BrchId']?.toString(),
      brchName: json['BrchName']?.toString(),
      coId: json['CoId']?.toString(),
      coName: json['CoName']?.toString(),
    );
  }


  List<String> get assignedRoles {
    List<String> roles = [];
    if (admin == true) roles.add('Admin');
    if (tray == true) roles.add('Tray');
    if (trayPick == true) roles.add('Tray Assigner');
    if (picker == true) roles.add('Picker');
    if (pickMan == true) roles.add('Picker Manager');
    if (checker == true) roles.add('Checker');
    if (packer == true) roles.add('Packer');
    if (solver == true) roles.add('Solver');
    return roles;
  }
}