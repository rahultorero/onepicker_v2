import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../model/UserPerformanceData.dart';

class DashboardApiService {
  static const String baseUrl = 'YOUR_API_BASE_URL';

  Future<DashboardApiResponse> getPickerData({
    required String fromDate,
    required String toDate,
    required String companyId,
    required String branchId,
  }) async {
    // Implement your API call here
    // Example with dio or http package:
    /*
    final response = await dio.post('$baseUrl/picker', data: {
      'pFmDate': fromDate,
      'pToDate': toDate,
      'CompanyId': companyId,
      'BrchId': branchId,
    });
    return DashboardApiResponse.fromJson(response.data);
    */
    throw UnimplementedError('Implement with your HTTP client');
  }

  Future<DashboardApiResponse> getPackerData({
    required String fromDate,
    required String toDate,
    required String companyId,
    required String branchId,
  }) async {
    // Implement similar to getPickerData
    throw UnimplementedError('Implement with your HTTP client');
  }

  Future<DashboardApiResponse> getCheckerData({
    required String fromDate,
    required String toDate,
    required String companyId,
    required String branchId,
  }) async {
    // Implement similar to getPickerData
    throw UnimplementedError('Implement with your HTTP client');
  }

  Future<DashboardApiResponse> getLocationData({
    required String fromDate,
    required String toDate,
    required String companyId,
    required String branchId,
  }) async {
    // Implement similar to getPickerData
    throw UnimplementedError('Implement with your HTTP client');
  }

  Future<DashboardApiResponse> getPickerManagerData({
    required String fromDate,
    required String toDate,
    required String companyId,
    required String branchId,
  }) async {
    // Implement similar to getPickerData
    throw UnimplementedError('Implement with your HTTP client');
  }
}

