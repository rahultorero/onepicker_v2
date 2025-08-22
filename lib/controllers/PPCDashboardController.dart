import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'dart:math' as math;
import '../model/UserPerformanceData.dart';
import '../services/DashboardApiService.dart';



import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../services/services.dart';


class PPCDashboardController extends GetxController {
  // Observable variables
  var selectedDashboardType = 'Picker'.obs;
  var fromDate = DateTime.now().obs;
  var toDate = DateTime.now().obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var sortByLineItems = false.obs;

  // Data variables
  var performanceDataList = <UserPerformanceData>[].obs;
  var filteredDataList = <UserPerformanceData>[].obs;

  // Statistics
  var totalUsers = 0.obs;
  var totalInvoices = 0.obs;
  var totalProducts = 0.obs;
  var totalQuantity = 0.obs;
  var totalLineItems = 0.obs;

  // Dashboard types with branch conditions
  var dashboardTypes = <String>[].obs;

  // Title for current dashboard
  var currentTitle = 'Picked Product'.obs;
  var currentUserLabel = 'T.User'.obs;
  final int? companyId = LoginController.selectedCompanyId;
  final int? branchId = LoginController.selectedBranchId;

  @override
  void onInit() {
    super.onInit();
    setupDashboardTypes();
    fetchDashboardData();

    debounce(searchQuery, (_) => filterData(), time: const Duration(milliseconds: 500));
  }

  void setupDashboardTypes() {
    bool workingWithBranch = false; // Replace with your actual condition

    if (workingWithBranch) {
      dashboardTypes.value = ['Picker', 'Packer', 'Checker', 'PickerManager', 'Location'];
    } else {
      dashboardTypes.value = ['Picker', 'Packer', 'Checker', 'Location'];
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);

      final dateFormat = DateFormat('yyyy-MMM-dd');
      final fromDateStr = dateFormat.format(fromDate.value);
      final toDateStr = dateFormat.format(toDate.value);

      DashboardApiResponse response;

      switch (selectedDashboardType.value) {
        case 'Picker':
          response = await _postRequest("picker", fromDateStr, toDateStr);
          currentTitle.value = 'Picked Product';
          currentUserLabel.value = 'T.User';
          break;
        case 'Packer':
          response = await _postRequest("packer", fromDateStr, toDateStr);
          currentTitle.value = 'Packed Product';
          currentUserLabel.value = 'T.User';
          break;
        case 'Checker':
          response = await _postRequest("daschecker", fromDateStr, toDateStr);
          currentTitle.value = 'Check Product';
          currentUserLabel.value = 'T.User';
          break;
        case 'Location':
          response = await _postRequest("location_n", fromDateStr, toDateStr);
          currentTitle.value = 'Picked Product';
          currentUserLabel.value = 'T.Location';
          break;
        case 'PickerManager':
          response = await _postRequest("picker/manager", fromDateStr, toDateStr);
          currentTitle.value = 'Picked Product';
          currentUserLabel.value = 'T.User';
          break;
        default:
          throw Exception('Unknown dashboard type');
      }

      if (response.status == '200') {
        performanceDataList.value = response.data ?? [];
        updateStatistics();
        filterData();
      } else {
        Get.snackbar('Error','Failed to fetch data');
        print("errror${response.message}");
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: ${e.toString()}');
      print("errror${e.toString()}");
      updateStatistics();
      filterData();
    } finally {
      isLoading(false);
    }
  }

  /// Reusable POST request
  Future<DashboardApiResponse> _postRequest(

      String endpoint, String fromDate, String toDate) async {

    final apiConfig = await ApiConfig.load();


    final url = Uri.parse("${apiConfig.baseUrl}$endpoint");

    final response = await http.post(url, body: {
      "pFmDate": fromDate,
      "pToDate": toDate,
      "CompanyId": companyId.toString(),
      "BrchId": branchId.toString(),
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return DashboardApiResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to fetch data from $endpoint");
    }
  }

  void filterData() {
    var filtered = performanceDataList.where((data) {
      return (data.name ?? "").toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    if (sortByLineItems.value) {
      filtered.sort((a, b) => (b.lineItem ?? 0).compareTo(a.lineItem ?? 0));
    } else {
      filtered.sort((a, b) => (b.tQty ?? 0).compareTo(a.tQty ?? 0));
    }

    filteredDataList.value = filtered;
  }

  void updateStatistics() {
    totalUsers.value = performanceDataList.length;
    totalInvoices.value =
        performanceDataList.fold(0, (sum, item) => sum + (item.noInvoice ?? 0));
    totalProducts.value =
        performanceDataList.fold(0, (sum, item) => sum + (item.noProd ?? 0));
    totalQuantity.value =
        performanceDataList.fold(0, (sum, item) => sum + (item.tQty ?? 0));
    totalLineItems.value =
        performanceDataList.fold(0, (sum, item) => sum + (item.lineItem ?? 0));
  }

  void toggleSort() {
    sortByLineItems.toggle();
    filterData();
  }

  void selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: fromDate.value, end: toDate.value),
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
      fetchDashboardData();
    }
  }

  // Mock Data
}
