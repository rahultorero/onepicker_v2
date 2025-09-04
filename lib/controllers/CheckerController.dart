import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:onepicker/view/CheckerDetailScreen.dart';

import '../bottomsheets/PackerDetailsBottomSheet.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerListDetailModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import 'HomeScreenController.dart';
import 'LoginController.dart';

class CheckerController extends GetxController {
  // Observables
  var isLoadingPackerList = false.obs;
  var isLoadingPackerDetails = false.obs;
  var isSubmittingData = false.obs; // Added for submit loading state
  var packerList = <PickerData>[].obs;
  var filteredPackerList = <PickerData>[].obs;
  var packerDetails = <PickerMenuDetail>[].obs;
  var selectedLocation = ''.obs;
  var searchQuery = ''.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = HomeScreenController.selectLocation ?? 'Unknown Location';
    fetchPackerList();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterPackerList();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Filter packer list based on search query
  void filterPackerList() {
    if (searchQuery.value.isEmpty) {
      filteredPackerList.assignAll(packerList);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredPackerList.assignAll(packerList.where((item) {
        final invNo = item.invNo?.toLowerCase() ?? '';
        final trayNo = item.trayNo?.toLowerCase() ?? '';
        return invNo.contains(query) || trayNo.contains(query);
      }).toList());
    }
  }

  // API call to fetch packer list
  Future<void> fetchPackerList() async {
    try {
      isLoadingPackerList(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}invoice_list'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'useas': '2',
          'branchid': LoginController.selectedBranchId.toString(),
          'empid': loginData?.response?.empId.toString(),
          'brk': LoginController.selectedFloorId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final packerListModel = PickerListModel.fromJson(jsonData);

        if (packerListModel.status == '200') {
          packerList.assignAll(packerListModel.pickerData ?? []);
          filterPackerList();
          if (packerList.isEmpty) {
            Get.snackbar(
              'Info',
              'No packer data available',
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
              colorText: AppTheme.primaryTeal,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            packerListModel.message ?? 'Failed to fetch packer list',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch packer list. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPackerList(false);
    }
  }

  // API call to fetch packer details
  Future<void> fetchPackerDetails(PickerData packerData) async {
    try {
      isLoadingPackerDetails(true);
      packerDetails.clear();

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final body = {
        'companyid': LoginController.selectedCompanyId.toString(),
        'useas': '2',
        'siid': packerData.sIId.toString(),
        'trayno': packerData.trayNo ?? '',
        'branchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString(),
        'brk': LoginController.selectedFloorId.toString(),
        'appversion': 'V1',
      };

      print("📦 Request body: $body");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}invoice_dtls'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final detailModel = PickerListDetailModel.fromJson(jsonData);

        if (detailModel.status == '200') {
          packerDetails.assignAll(detailModel.menuDetailList ?? []);
          if (packerDetails.isNotEmpty) {
            Get.to(CheckerDetailScreen(pickerData: packerData,));
            print("checkkkk value  ${packerDetails.toJson()}");
          } else {
            Get.snackbar(
              'Info',
              'No details available for this item',
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
              colorText: AppTheme.primaryTeal,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            detailModel.message ?? 'Failed to fetch packer details',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch packer details. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPackerDetails(false);
    }
  }

  // API call to submit checked items
  Future<void> submitCheckedItems(PickerData pickerData, List<PickerMenuDetail> checkedItems) async {
    if (checkedItems.isEmpty) {
      Get.snackbar(
        'Warning',
        'No items selected for submission',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange.shade700,
      );
      return;
    }

    try {
      isSubmittingData(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      // Construct JSON payload similar to the reference code
      final Map<String, dynamic> jsonBody = {
        "companyId": LoginController.selectedCompanyId.toString(),
        "useas": "2",
        "siid": pickerData.sIId.toString(),
        "brchid": LoginController.selectedBranchId.toString(),
        "empid": loginData?.response?.empId.toString(),
        "settingPCamera": HomeScreenController.selectCamera ?? "", // Camera setting
        "brk": LoginController.selectedFloorId.toString(),
        "istempquit": 1,
        "appversion": "V1",
      };

      // Build item details array
      List<Map<String, dynamic>> itemDetailsArray = [];
      for (var item in checkedItems) {
        Map<String, dynamic> itemDetail = {
          "siid": pickerData.sIId.toString(),
          "itemdetailid": item.itemDetailId?.toString() ?? "",
          "batchno": item.batchNo ?? "",
          "mrp": item.mrp?.toString() ?? "",
        };
        itemDetailsArray.add(itemDetail);
      }

      jsonBody["itemdetails"] = itemDetailsArray;

      print("🚀 Submit payload: ${json.encode(jsonBody)}");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveproduct'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(jsonBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == '200') {
          // Success - show success message and navigate back
          Get.snackbar(
            'Success',
            responseData['message'] ?? 'Items submitted successfully!',
            backgroundColor: Colors.green.withOpacity(0.85),
            colorText: Colors.white, // 👈 more contrast
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            borderRadius: 8,
          );


          // Navigate back to previous screen after short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.back();
            // Refresh the packer list to reflect updated status
            refreshData();
          });

        } else if (responseData['status'] == '401') {
          // Authentication error
          Get.snackbar(
            'Error',
            'Authentication failed. Please login again.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        } else {
          // Other error status
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to submit items',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Submit error: $e");
      Get.snackbar(
        'Error',
        'Failed to submit items. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSubmittingData(false);
    }
  }

  // Handle packer item tap
  void onPackerItemTap(PickerData packerData) {
    fetchPackerDetails(packerData);
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterPackerList();
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchPackerList();
  }
}