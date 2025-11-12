class SearchFilterListModel {
  String? status;
  String? message;
  List<SearchData>? searchDataList;

  SearchFilterListModel({
    this.status,
    this.message,
    this.searchDataList,
  });

  factory SearchFilterListModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterListModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      searchDataList: (json['response'] as List<dynamic>?)
          ?.map((e) => SearchData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'response': searchDataList?.map((e) => e.toJson()).toList(),
    };
  }
}

class SearchData {
  int? ledIdSalesmen;
  String? sman;
  int? grpIdArea;
  String? area;
  int? grpIdCity;
  String? city;
  int? grpIdDel;
  String? deliveryRoute;
  int? Pending;

  SearchData({
    this.ledIdSalesmen,
    this.sman,
    this.grpIdArea,
    this.area,
    this.grpIdCity,
    this.city,
    this.grpIdDel,
    this.deliveryRoute,
    this.Pending
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      ledIdSalesmen: json['LedId_Salesmen'] as int?,
      sman: json['Sman'] as String?,
      grpIdArea: json['Grp_Id_Area'] as int?,
      area: json['Area'] as String?,
      grpIdCity: json['Grp_Id_City'] as int?,
      city: json['City'] as String?,
      grpIdDel: json['GrpId_Del'] as int?,
      deliveryRoute: json['DeliveryRoute'] as String?,
      Pending: json['Pending'] as int?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LedId_Salesmen': ledIdSalesmen,
      'Sman': sman,
      'Grp_Id_Area': grpIdArea,
      'Area': area,
      'Grp_Id_City': grpIdCity,
      'City': city,
      'GrpId_Del': grpIdDel,
      'DeliveryRoute': deliveryRoute,
      'Pending':Pending
    };
  }
}
