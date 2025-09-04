import 'dart:convert';

class StockDetailModel {
  String? status;
  String? message;
  List<StockDetailData>? stockDetailData;

  StockDetailModel({this.status, this.message, this.stockDetailData});

  factory StockDetailModel.fromJson(Map<String, dynamic> json) {
    return StockDetailModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      stockDetailData: (json['response'] as List<dynamic>?)
          ?.map((e) => StockDetailData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': stockDetailData?.map((e) => e.toJson()).toList(),
    };
  }
}

class StockDetailData {
  String? batchNo;
  String? expDate; // keeping it String since API sends as string
  double? mrp;
  String? godown;
  String? hld;
  int? stock;
  int? gdwnQty;

  StockDetailData({
    this.batchNo,
    this.expDate,
    this.mrp,
    this.godown,
    this.hld,
    this.stock,
    this.gdwnQty,
  });

  factory StockDetailData.fromJson(Map<String, dynamic> json) {
    return StockDetailData(
      batchNo: json['BatchNo'] as String?,
      expDate: json['ExpDate'] as String?,
      mrp: (json['MRP'] as num?)?.toDouble(),
      godown: json['Godown'] as String?,
      hld: json['HLD'] as String?,
      stock: json['Stock'] as int?,
      gdwnQty: json['GdwnQty'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BatchNo': batchNo,
      'ExpDate': expDate,
      'MRP': mrp,
      'Godown': godown,
      'HLD': hld,
      'Stock': stock,
      'GdwnQty': gdwnQty,
    };
  }
}
