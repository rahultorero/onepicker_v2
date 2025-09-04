class StatusApiResponse {
  final String? status;
  final String? message;
  final List<DataItem>? data;

  StatusApiResponse({this.status, this.message, this.data});

  factory StatusApiResponse.fromJson(Map<String, dynamic> json) {
    return StatusApiResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DataItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class DataItem {
  final String? status;
  final int? noInvoice;
  final int? done;
  final int? pend;

  DataItem({this.status, this.noInvoice, this.done, this.pend});

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      status: json['Status'] as String?,
      noInvoice: json['NoInvoice'] as int?,
      done: json['Done'] as int?,
      pend: json['Pend'] as int?,
    );
  }

  double get completionPercentage {
    if (noInvoice == 0) return 0.0;
    return (done! / noInvoice!) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'NoInvoice': noInvoice,
      'Done': done,
      'Pend': pend,
    };
  }
}
