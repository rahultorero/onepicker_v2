import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../model/PickerDataModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import 'HomeScreenController.dart';
import 'LoginController.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MergerController extends GetxController {
  // Observables
  var isLoadingMergerList = false.obs;
  var mergerList = <PickerData>[].obs;
  var filteredMergerList = <PickerData>[].obs;
  var selectedLocation = ''.obs;
  var searchQuery = ''.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = HomeScreenController.selectLocation ?? 'Unknown Location';
    fetchMergerList();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterMergerList();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Get current date in the required format (dd/MMM/yyyy)
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MMM/yyyy');
    return formatter.format(now);
  }

  // Filter merger list based on search query
  void filterMergerList() {
    if (searchQuery.value.isEmpty) {
      filteredMergerList.assignAll(mergerList);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredMergerList.assignAll(mergerList.where((item) {
        final invNo = item.invNo?.toLowerCase() ?? '';
        final trayNo = item.trayNo?.toLowerCase() ?? '';
        final party = item.party?.toLowerCase() ?? '';
        final area = item.area?.toLowerCase() ?? '';
        return invNo.contains(query) ||
            trayNo.contains(query) ||
            party.contains(query) ||
            area.contains(query);
      }).toList());
    }
  }

  // API call to fetch merger list
  Future<void> fetchMergerList() async {
    try {
      isLoadingMergerList(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      // Get setting for EIRN (assuming it's stored in shared preferences)
      final settingEIRN = await ApiConfig.getSyn('settingEIRN') ?? 0;

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}invoice_list_for_tray'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'useas': '7', // Fixed value as per your Java code
          'fromdate': getCurrentDate(), // Current date in dd/MMM/yyyy format
          'branchid': LoginController.selectedBranchId.toString(),
          'empid': loginData?.response?.empId.toString() ?? '',
          'brk': LoginController.selectedFloorId.toString(),
          'settingEIRN': settingEIRN.toString(),
          'appversion': 'V1',
        },
      );

      print("📦 [MERGER LIST] Request body => {");
      print("  companyid: ${LoginController.selectedCompanyId}");
      print("  useas: 7");
      print("  fromdate: ${getCurrentDate()}");
      print("  branchid: ${LoginController.selectedBranchId}");
      print("  empid: ${loginData?.response?.empId}");
      print("  brk: ${LoginController.selectedFloorId}");
      print("  settingEIRN: $settingEIRN");
      print("  appversion: V1");
      print("}");

      print("🌐 [MERGER LIST] Response status => ${response.statusCode}");
      print("🌐 [MERGER LIST] Raw response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mergerListModel = PickerListModel.fromJson(jsonData);

        print("🔎 [MERGER LIST] Decoded JSON => $jsonData");

        if (mergerListModel.status == '200') {
          mergerList.assignAll(mergerListModel.pickerData ?? []);
          filterMergerList();

          print("✅ [MERGER LIST] Success => ${mergerList.length} items loaded");

          if (mergerList.isEmpty) {
            Get.snackbar(
              'Info',
              'No merger data available for today',
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
              colorText: AppTheme.primaryTeal,
              icon: const Icon(Icons.info_outline, color: AppTheme.primaryTeal),
            );
          }
        } else {
          print("❌ [MERGER LIST] Status not 200 => ${mergerListModel.status}");
          Get.snackbar(
            'Error',
            mergerListModel.message ?? 'Failed to fetch merger list',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      } else {
        print("❌ [MERGER LIST] HTTP Error => ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e, stack) {
      print("🔥 [MERGER LIST] Exception => $e");
      print("🔥 [MERGER LIST] Stacktrace => $stack");

      Get.snackbar(
        'Error',
        'Failed to fetch merger list. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingMergerList(false);
    }
  }

  // Handle merger item tap - show merge confirmation dialog
  void onMergerItemTap(PickerData mergerData) {
    _showMergeConfirmationDialog(mergerData);
  }

  // Show merge confirmation dialog
  void _showMergeConfirmationDialog(PickerData mergerData) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppTheme.primaryTeal.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.merge_type,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Merge Tray',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Tray Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.amberGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.amberGold.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.amberGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: AppTheme.amberGold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tray Number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mergerData.trayNo ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DelType Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getDelTypeColor(mergerData.delType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getDelTypeColor(mergerData.delType).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getDelTypeColor(mergerData.delType).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_shipping,
                              color: _getDelTypeColor(mergerData.delType),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Type',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mergerData.delType ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question
                    Text(
                      'Do you want to merge this tray?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(); // Close dialog
                              _saveMerger(mergerData);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Yes, Merge',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Get color for delivery type
  Color _getDelTypeColor(String? delType) {
    switch (delType?.toUpperCase()) {
      case 'URGENT':
        return const Color(0xFFF50E0E); // Red
      case 'PICK-UP':
        return const Color(0xFF15EE81); // Green
      case 'DELIVERY':
        return const Color(0xFFFFB266); // Orange
      case 'MEDREP':
        return const Color(0xFFEAF207); // Yellow
      case 'COD':
        return const Color(0xFFFF99FF); // Pink
      case 'OUTSTATION':
        return const Color(0xFF99FFFF); // Sky Blue
      default:
        return AppTheme.primaryTeal;
    }
  }

  // Save merger API call
  Future<void> _saveMerger(PickerData mergerData) async {
    try {
      // Show loading dialog
      Get.dialog(
        const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryTeal),
              SizedBox(height: 16),
              Text(
                'Merging tray...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      final settingPrint = await ApiConfig.getSsub('PrintInvPicker') ?? 0;

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveproduct'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'useas': '7', // Fixed value as per your Java code
          'siid': mergerData.sIId.toString(),
          'branchid': LoginController.selectedBranchId.toString(),
          'empid': loginData?.response?.empId.toString() ?? '',
          'brk': LoginController.selectedFloorId.toString(),
          'settingPrint': settingPrint.toString(),
          'appversion': 'V1',
        },
      );

      print("📦 [SAVE MERGER] Request body => {");
      print("  companyid: ${LoginController.selectedCompanyId}");
      print("  useas: 7");
      print("  siid: ${mergerData.sIId}");
      print("  branchid: ${LoginController.selectedBranchId}");
      print("  empid: ${loginData?.response?.empId}");
      print("  brk: ${LoginController.selectedFloorId}");
      print("  settingPrint: $settingPrint");
      print("  appversion: V1");
      print("}");

      // FORCE CLOSE ALL DIALOGS FIRST
      while (Get.isDialogOpen == true) {
        Get.back();
      }

      print("🌐 [SAVE MERGER] Response status => ${response.statusCode}");
      print("🌐 [SAVE MERGER] Raw response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("🔎 [SAVE MERGER] Decoded JSON => $jsonData");

        if (jsonData['status'] == '200') {
          print("✅ [SAVE MERGER] Success => ${jsonData['message']}");

          // Show success message
          Get.snackbar(
            'Success',
            jsonData['message'] ?? 'Tray merged successfully',
            backgroundColor: Colors.green.shade700, // darker green background
            colorText: Colors.white, // white text for contrast
            icon: const Icon(Icons.check_circle, color: Colors.white), // white icon
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM, // optional: bottom placement
            margin: const EdgeInsets.all(12), // optional: add spacing
            borderRadius: 8, // optional: rounded snackbar
          );

          // Remove merged item from list
          mergerList.removeWhere((item) => item.invNo == mergerData.invNo);
          filterMergerList();

        } else {
          print("❌ [SAVE MERGER] Status not 200 => ${jsonData['status']}");
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to merge tray',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      } else {
        print("❌ [SAVE MERGER] HTTP Error => ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Server error while merging tray',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e, stack) {
      // FORCE CLOSE ALL DIALOGS
      while (Get.isDialogOpen == true) {
        Get.back();
      }

      print("🔥 [SAVE MERGER] Exception => $e");
      print("🔥 [SAVE MERGER] Stacktrace => $stack");

      Get.snackbar(
        'Error',
        'Failed to merge tray. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterMergerList();
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchMergerList();
  }
}