import 'dart:convert';

class PickerStockModel {
  String? status;
  String? message;
  List<StockDetail>? stockDetailList;

  PickerStockModel({this.status, this.message, this.stockDetailList});

  factory PickerStockModel.fromJson(Map<String, dynamic> json) {
    return PickerStockModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      stockDetailList: (json['response'] as List<dynamic>?)
          ?.map((e) => StockDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': stockDetailList?.map((e) => e.toJson()).toList(),
    };
  }
}

class StockDetail {
  String? itemName;
  String? packing;
  String? loca;
  int? locn;
  String? batchNo;
  String? expDate;
  double? mrp;
  String? godown;
  String? hld;
  int? stock;
  int? gdwnQty;
  int? bCount;
  int? mCount;

  StockDetail({
    this.itemName,
    this.packing,
    this.loca,
    this.locn,
    this.batchNo,
    this.expDate,
    this.mrp,
    this.godown,
    this.hld,
    this.stock,
    this.gdwnQty,
    this.bCount,
    this.mCount,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      itemName: json['ItemName'] as String?,
      packing: json['Packing'] as String?,
      loca: json['LOCA'] as String?,
      locn: json['LOCN'] as int?,
      batchNo: json['BatchNo'] as String?,
      expDate: json['ExpDate'] as String?,
      mrp: (json['MRP'] != null)
          ? double.tryParse(json['MRP'].toString())
          : null,
      godown: json['Godown'] as String?,
      hld: json['HLD'] as String?,
      stock: json['Stock'] as int?,
      gdwnQty: json['GdwnQty'] as int?,
      bCount: json['BCount'] as int?,
      mCount: json['MCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemName': itemName,
      'Packing': packing,
      'LOCA': loca,
      'LOCN': locn,
      'BatchNo': batchNo,
      'ExpDate': expDate,
      'MRP': mrp,
      'Godown': godown,
      'HLD': hld,
      'Stock': stock,
      'GdwnQty': gdwnQty,
      'BCount': bCount,
      'MCount': mCount,
    };
  }
}
