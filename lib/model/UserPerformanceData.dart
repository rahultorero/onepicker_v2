import 'dart:convert';
import 'package:intl/intl.dart';

class UserPerformanceData {
  String? name;
  int? noInvoice;
  int? noProd;
  int? tQty;
  String? minDate;
  String? maxDate;
  int? lineItem;

  UserPerformanceData({
    this.name,
    this.noInvoice,
    this.noProd,
    this.tQty,
    this.minDate,
    this.maxDate,
    this.lineItem,
  });

  factory UserPerformanceData.fromJson(Map<String, dynamic> json) {
    return UserPerformanceData(
      name: json['Name'],
      noInvoice: json['NoInvoice'],
      noProd: json['NoProd'],
      tQty: json['TQty'],
      minDate: json['MinDate'],
      maxDate: json['MaxDate'],
      lineItem: json['LineItem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "NoInvoice": noInvoice,
      "NoProd": noProd,
      "TQty": tQty,
      "MinDate": minDate,
      "MaxDate": maxDate,
      "LineItem": lineItem,
    };
  }

  /// Helper: Get formatted work duration
  String getWorkDuration() {
    try {
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      final startDate = format.parseUtc(minDate!);
      final endDate = format.parseUtc(maxDate!);

      final duration = endDate.difference(startDate);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      return "$hours hrs $minutes mins";
    } catch (e) {
      return "N/A";
    }
  }

  /// Helper: Productivity score (products per hour, max 5 considered)
  double getProductivityScore() {
    try {
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      final startDate = format.parseUtc(minDate!);
      final endDate = format.parseUtc(maxDate!);

      final duration = endDate.difference(startDate);
      final durationHours = duration.inMilliseconds / (1000 * 60 * 60);

      final productsConsidered = (noProd ?? 0) < 5 ? (noProd ?? 0) : 5;

      return durationHours > 0 ? productsConsidered / durationHours : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

class DashboardApiResponse {
  String? status;
  String? message;
  List<UserPerformanceData>? data;

  DashboardApiResponse({this.status, this.message, this.data});

  factory DashboardApiResponse.fromJson(Map<String, dynamic> json) {
    return DashboardApiResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => UserPerformanceData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data?.map((e) => e.toJson()).toList(),
    };
  }
}
