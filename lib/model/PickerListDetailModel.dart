class PickerListDetailModel {
  String? status;
  String? message;
  List<PickerMenuDetail>? menuDetailList;

  PickerListDetailModel({this.status, this.message, this.menuDetailList});

  factory PickerListDetailModel.fromJson(Map<String, dynamic> json) {
    return PickerListDetailModel(
      status: json['status'],
      message: json['message'],
      menuDetailList: json['response'] != null
          ? List<PickerMenuDetail>.from(
          json['response'].map((x) => PickerMenuDetail.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "response": menuDetailList?.map((x) => x.toJson()).toList(),
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
  dynamic gar;
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
    this.pNote = "",
    this.isSelected = false,
  });

  factory PickerMenuDetail.fromJson(Map<String, dynamic> json) {
    return PickerMenuDetail(
      itemDetailId: json['ItemDetailId'] is int ? json['ItemDetailId'] : int.tryParse(json['ItemDetailId'].toString()),
      pLedId: json['PLed_Id'] is int ? json['PLed_Id'] : int.tryParse(json['PLed_Id'].toString()),
      itemName: json['itemName']?.toString(),
      packing: json['Packing']?.toString(),
      loca: json['LOCA']?.toString(),
      locn: json['LOCN'] is int ? json['LOCN'] : int.tryParse(json['LOCN'].toString()),
      batchNo: json['BatchNo']?.toString(),
      sExpDate: json['SExpDate']?.toString(),
      mrp: json['MRP'] != null ? double.tryParse(json['MRP'].toString()) : null,
      tQty: json['TQty'] is int ? json['TQty'] : int.tryParse(json['TQty'].toString()),
      dNick: json['DNick']?.toString(),
      bCount: json['BCount'] is int ? json['BCount'] : int.tryParse(json['BCount'].toString()),
      mCount: json['MCount'] is int ? json['MCount'] : int.tryParse(json['MCount'].toString()),
      claimDesc: json['ClaimDesc']?.toString(),
      remark: json['Remark']?.toString(),
      ccp: json['CCP'] is int ? json['CCP'] : int.tryParse(json['CCP'].toString()),
      gar: json['GAR'], // leave as dynamic
      casePack: json['CasePack'] is int ? json['CasePack'] : int.tryParse(json['CasePack'].toString()),
      boxPack: json['BoxPack'] is int ? json['BoxPack'] : int.tryParse(json['BoxPack'].toString()),
      caseQ: json['CaseQ'] is int ? json['CaseQ'] : int.tryParse(json['CaseQ'].toString()),
      caseL: json['CaseL'] is int ? json['CaseL'] : int.tryParse(json['CaseL'].toString()),
      isChk: json['IsChk']?.toString(),   // force to String
      pNote: json['PNote']?.toString() ?? "",
      isSelected: false,
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
      // ⚠️ NOTE: isSelected is not included in API payload
    };
  }

  @override
  String toString() {
    return "PickerMenuDetail(itemDetailId: $itemDetailId, pLedId: $pLedId, "
        "itemName: $itemName, packing: $packing, loca: $loca, locn: $locn, "
        "batchNo: $batchNo, sExpDate: $sExpDate, mrp: $mrp, tQty: $tQty, "
        "dNick: $dNick, bCount: $bCount, mCount: $mCount, claimDesc: $claimDesc, "
        "remark: $remark, ccp: $ccp, gar: $gar, casePack: $casePack, boxPack: $boxPack, "
        "caseQ: $caseQ, caseL: $caseL, isChk: $isChk, pNote: $pNote, isSelected: $isSelected)";
  }
}
