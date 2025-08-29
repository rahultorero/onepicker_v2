import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onepicker/controllers/HomeScreenController.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'dart:convert';

import '../bottomsheets/PickerDetailsBottomSheet.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerMenuDetailModel.dart';
import '../model/StockDetailModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';

class PickerController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Observables
  var isLoadingPickerList = false.obs;
  var isLoadingPickerDetails = false.obs;
  var isLoadingStockList = false.obs;
  var pickerList = <PickerData>[].obs;
  var pickerDetails = <PickerMenuDetail>[].obs;
  var stockList = <StockDetail>[].obs;
  var selectedLocation = ''.obs;
  var selectedPickerIndex = (-1).obs;


  // Tab index
  var currentTabIndex = 0.obs;

  // API configuration

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    // Get selected location from static storage
    selectedLocation.value = HomeScreenController.selectLocation ?? 'Unknown Location';

    // Load initial data
    fetchPickerList();
    fetchStockList();

  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void onPickerItemSelect(int index, PickerData pickerData) {
    selectedPickerIndex.value = index;
    fetchPickerDetails(pickerData);
  }

  // API call to fetch picker list
  Future<void> fetchPickerList() async {
    try {
      isLoadingPickerList(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}invoice_list'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'useas': '1',
          'branchid': LoginController.selectedBranchId.toString(),
          'location': selectedLocation.value,
          'empid': loginData?.response?.empId.toString(),
          'brk': LoginController.selectedFloorId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pickerListModel = PickerListModel.fromJson(jsonData);

        if (pickerListModel.status == '200' ) {
          pickerList.assignAll(pickerListModel.pickerData ?? []);
          if (pickerList.isEmpty) {
            Get.snackbar(
              'Info',
              'No picker data available',
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              colorText: AppTheme.primaryBlue,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            pickerListModel.message ?? 'Failed to fetch picker list',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('Error fetching picker list: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch picker list. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPickerList(false);
    }
  }

  // API call to fetch picker details
  Future<void> fetchPickerDetails(PickerData pickerData) async {
    try {
      isLoadingPickerDetails(true);
      pickerDetails.clear();

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}invoice_dtls'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'useas': '1',
          'siid': pickerData.sIId.toString(),
          'trayno': pickerData.trayNo ?? '',
          'branchid': LoginController.selectedBranchId.toString(),
          'location': selectedLocation.value,
          'empid': loginData?.response?.empId.toString(),
          'brk': LoginController.selectedFloorId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pickerMenuModel = PickerMenuModel.fromJson(jsonData);

        if (pickerMenuModel.status == '200') {
          pickerDetails.assignAll(pickerMenuModel.menuDetailList ?? []);
          // Remove the showPickerDetailsBottomSheet call
        } else {
          Get.snackbar(
            'Error',
            pickerMenuModel.message ?? 'Failed to fetch picker details',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('Error fetching picker details: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch picker details. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPickerDetails(false);
    }
  }

  Future<void> fetchStockList() async {
    try {
      isLoadingStockList(true);
      stockList.clear();

      print("🔵 Fetching stock list started...");

      final apiConfig = await ApiConfig.load();
      print("✅ ApiConfig loaded: baseUrl=${apiConfig.baseUrl}");

      final loginData = await ApiConfig.getLoginData();
      print("✅ Login data loaded: empId=${loginData?.response?.empId}");

      final requestBody = {
        'companyId': LoginController.selectedCompanyId.toString(),
        'useas': '1',
        'brchid': LoginController.selectedBranchId.toString(),
        'location': selectedLocation.value,
        'empid': loginData?.response?.empId.toString(),
        'brk': LoginController.selectedFloorId.toString(),
        'appversion': 'V1',
      };

      print("📤 API Request URL: ${apiConfig.baseUrl}stock");
      print("📤 Request Headers: {Content-Type: application/x-www-form-urlencoded}");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}stock'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("📦 Parsed JSON: $jsonData");

        final stockModel = PickerStockModel.fromJson(jsonData);
        print("✅ Parsed StockModel: status=${stockModel.status}, message=${stockModel.message}");

        if (stockModel.status == '200') {
          stockList.assignAll(stockModel.stockDetailList ?? []);
          print("📊 Stock list fetched. Count=${stockList.length}");

          if (stockList.isEmpty) {
            Get.snackbar(
              'Info',
              'No stock data available',
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              colorText: AppTheme.primaryBlue,
            );
          }
        } else {
          print("❌ API returned error: ${stockModel.message}");
          Get.snackbar(
            'Error',
            stockModel.message ?? 'Failed to fetch stock list',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('🔥 Exception while fetching stock list: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch stock list. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStockList(false);
      print("🟢 Fetch stock list process finished.");
    }
  }

  // Show picker details bottom sheet
  void showPickerDetailsBottomSheet(PickerData pickerData) {
    Get.bottomSheet(
      PickerDetailsBottomSheet(pickerData: pickerData),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  // Handle picker item tap
  void onPickerItemTap(PickerData pickerData) {
    fetchPickerDetails(pickerData);
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchPickerList();
  }

  Future<void> refreshStockData() async {
    await fetchStockList();
  }
}