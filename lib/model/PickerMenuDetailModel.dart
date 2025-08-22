class PickerMenuModel {
  String? status;
  String? message;
  List<PickerMenuDetail>? menuDetailList;

  PickerMenuModel({this.status, this.message, this.menuDetailList});

  factory PickerMenuModel.fromJson(Map<String, dynamic> json) {
    return PickerMenuModel(
      status: json['status'],
      message: json['message'],
      menuDetailList: json['response'] != null
          ? (json['response'] as List)
          .map((item) => PickerMenuDetail.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "response": menuDetailList?.map((e) => e.toJson()).toList(),
    };
  }
}

class PickerMenuDetail {
  int? itemDetailId;
  int? pLedId;
  String? itemName;
  String? packing;
  String? loca;
  int? locn;
  String? batchNo;
  String? sExpDate;
  double? mrp;
  int? tQty;
  String? dNick;
  int? bCount;
  int? mCount;
  String? claimDesc;
  String? remark;
  int? ccp;
  dynamic gar; // Object in Java -> dynamic in Dart
  int? casePack;
  int? boxPack;
  int? caseQ;
  int? caseL;
  String? isChk;
  String? pNote;
  bool isSelected;

  PickerMenuDetail({
    this.itemDetailId,
    this.pLedId,
    this.itemName,
    this.packing,
    this.loca,
    this.locn,
    this.batchNo,
    this.sExpDate,
    this.mrp,
    this.tQty,
    this.dNick,
    this.bCount,
    this.mCount,
    this.claimDesc,
    this.remark,
    this.ccp,
    this.gar,
    this.casePack,
    this.boxPack,
    this.caseQ,
    this.caseL,
    this.isChk,
    this.pNote,
    this.isSelected = false, // default
  });

  factory PickerMenuDetail.fromJson(Map<String, dynamic> json) {
    return PickerMenuDetail(
      itemDetailId: json['ItemDetailId'],
      pLedId: json['PLed_Id'],
      itemName: json['itemName'],
      packing: json['Packing'],
      loca: json['LOCA'],
      locn: json['LOCN'],
      batchNo: json['BatchNo'],
      sExpDate: json['SExpDate'],
      mrp: (json['MRP'] != null)
          ? (json['MRP'] as num).toDouble()
          : null,
      tQty: json['TQty'],
      dNick: json['DNick'],
      bCount: json['BCount'],
      mCount: json['MCount'],
      claimDesc: json['ClaimDesc'],
      remark: json['Remark'],
      ccp: json['CCP'],
      gar: json['GAR'],
      casePack: json['CasePack'],
      boxPack: json['BoxPack'],
      caseQ: json['CaseQ'],
      caseL: json['CaseL'],
      isChk: json['IsChk'],
      pNote: json['PNote'] ?? "", // default empty string
      isSelected: false, // not from API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ItemDetailId": itemDetailId,
      "PLed_Id": pLedId,
      "itemName": itemName,
      "Packing": packing,
      "LOCA": loca,
      "LOCN": locn,
      "BatchNo": batchNo,
      "SExpDate": sExpDate,
      "MRP": mrp,
      "TQty": tQty,
      "DNick": dNick,
      "BCount": bCount,
      "MCount": mCount,
      "ClaimDesc": claimDesc,
      "Remark": remark,
      "CCP": ccp,
      "GAR": gar,
      "CasePack": casePack,
      "BoxPack": boxPack,
      "CaseQ": caseQ,
      "CaseL": caseL,
      "IsChk": isChk,
      "PNote": pNote,
      // ⚠️ not sending isSelected back to API since it's UI-only
    };
  }

  @override
  String toString() {
    return "PickerMenuDetail(itemDetailId: $itemDetailId, pLedId: $pLedId, itemName: $itemName, packing: $packing, loca: $loca, locn: $locn, batchNo: $batchNo, sExpDate: $sExpDate, mrp: $mrp, tQty: $tQty, dNick: $dNick, bCount: $bCount, mCount: $mCount, claimDesc: $claimDesc, remark: $remark, ccp: $ccp, gar: $gar, casePack: $casePack, boxPack: $boxPack, caseQ: $caseQ, caseL: $caseL, isChk: $isChk, pNote: $pNote, isSelected: $isSelected)";
  }
}
