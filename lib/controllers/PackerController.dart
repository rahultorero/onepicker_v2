import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:onepicker/view/PickerListTab.dart';

import '../bottomsheets/PackerDetailsBottomSheet.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerListDetailModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import '../view/PackerDetailsScreen.dart';
import '../widget/AppLoader.dart';
import 'HomeScreenController.dart';
import 'LoginController.dart';

class PackerController extends GetxController {
  // Observables
  var isLoadingPackerList = false.obs;
  var isLoadingPackerDetails = false.obs;
  var packerList = <PickerData>[].obs;
  var filteredPackerList = <PickerData>[].obs;
  var packerDetails = <PickerMenuDetail>[].obs;
  var selectedPackerDetails = <PickerMenuDetail>[].obs;
  var isAllSelected = false.obs;
  var selectedLocation = ''.obs;
  var searchQuery = ''.obs;

  // Current packer data for API calls
  var currentPackerData = Rxn<PickerData>();

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Case and Weight controllers
  final TextEditingController caseController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

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
    caseController.dispose();
    weightController.dispose();
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

  // Toggle selection for a specific packer detail
  void togglePackerDetailSelection(PickerMenuDetail detail) {
    if (selectedPackerDetails.contains(detail)) {
      selectedPackerDetails.remove(detail);
    } else {
      selectedPackerDetails.add(detail);
    }
    _updateSelectAllState();
  }

  // Toggle select all functionality
  void toggleSelectAll() {
    if (isAllSelected.value) {
      // Deselect all
      selectedPackerDetails.clear();
      isAllSelected.value = false;
    } else {
      // Select all
      selectedPackerDetails.assignAll(packerDetails);
      isAllSelected.value = true;
    }
  }

  // Update select all state based on current selection
  void _updateSelectAllState() {
    if (selectedPackerDetails.isEmpty) {
      isAllSelected.value = false;
    } else if (selectedPackerDetails.length == packerDetails.length) {
      isAllSelected.value = true;
    } else {
      isAllSelected.value = false;
    }
  }

  // Clear all selections
  void clearSelections() {
    selectedPackerDetails.clear();
    isAllSelected.value = false;
  }

  // Submit selected items - now opens case weight dialog
  void submitSelectedItems() {
    if (selectedPackerDetails.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select at least one item to submit',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        icon: const Icon(Icons.warning, color: Colors.orange),
      );
      return;
    }

    // Clear previous input
    caseController.clear();
    weightController.clear();

    // Show case and weight dialog
    _showCaseWeightDialog();
  }

  // Show case and weight input dialog
  void _showCaseWeightDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.primaryTeal,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Add Case & Weight',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Items: ${selectedPackerDetails.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Case Number Input
              Text(
                'Case Number (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caseController,
                decoration: InputDecoration(
                  hintText: 'Enter case number',
                  hintStyle: TextStyle(
                    color: AppTheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16),

              // Weight Input
              Text(
                'Weight (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  hintText: 'Enter weight',
                  hintStyle: TextStyle(
                    color: AppTheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleSkip(),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleCaseWeightSubmit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Handle skip button
  void _handleSkip() {
    Get.back(); // Close dialog
    // Go back to packer list
    Get.back();
  }

  // Handle case weight submit
  void _handleCaseWeightSubmit() {
    Get.back(); // Close dialog

    final caseNo = caseController.text.trim();
    final weight = weightController.text.trim();

    if (caseNo.isEmpty) {
      // Direct packer save without case weight
      _performPackerSave();
    } else {
      // First post case weight, then packer save
      _postCaseWeight(caseNo, weight);
    }
  }

  // Post case weight API call
  Future<void> _postCaseWeight(String caseNo, String weight) async {
    try {

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}case_weight'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'userid': loginData?.response?.empId.toString() ?? '',
          'useas': '3',
          'siid': currentPackerData.value?.sIId.toString() ?? '',
          'empid': loginData?.response?.empId.toString() ?? '',
          'caseno': caseNo,
          'weight': weight,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == '200') {
          print(jsonData['message']);
          _performPackerSave();
        } else {
          print(jsonData['message']);
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error while saving case weight',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to save case weight. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Perform packer save API call
  Future<void> _performPackerSave() async {
    try {
      // Show loading dialog
      Get.dialog(
         AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(),
              SizedBox(height: 16),
              Text('Submitting selected items...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      // Prepare JSON body
      final Map<String, dynamic> requestBody = {
        'companyId': LoginController.selectedCompanyId.toString(),
        'useas': '3',
        'siid': currentPackerData.value?.sIId.toString(),
        'brchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString(),
        'brk': LoginController.selectedFloorId.toString(),
        'istempquit': 0,
        'settingPrint': '', // You might need to get this from shared preferences
        'appversion': 'V1',
        'itemdetails': selectedPackerDetails.map((detail) => {
          'itemdetailid': detail.itemDetailId.toString(),
          'batchno': detail.batchNo.toString(),
          'mrp': detail.mrp.toString(),
          'pnote': detail.pNote?.toString() ?? '',
        }).toList(),
      };

      print("📦 [PACKER SAVE] Request body => $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveproduct'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      );

      // FORCE CLOSE ALL DIALOGS FIRST
      while (Get.isDialogOpen == true) {
        Get.back();
      }

      print("🌐 [PACKER SAVE] Response status => ${response.statusCode}");
      print("🌐 [PACKER SAVE] Raw response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("🔎 [PACKER SAVE] Decoded JSON => $jsonData");

        if (jsonData['status'] == '200') {
          print("✅ [PACKER SAVE] Success => ${jsonData['message']}");


          // Clear selections and go back
          clearSelections();
          Future.delayed(const Duration(seconds: 1), () {
            if (Get.isOverlaysOpen) return; // avoid closing snackbar overlay
            Get.back(); // now go back to packer list
          });

        } else {
          print("❌ [PACKER SAVE] Status not 200 => ${jsonData['status']}");
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to submit items',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      } else {
        print("❌ [PACKER SAVE] HTTP Error => ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Server error while submitting items',
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

      print("🔥 [PACKER SAVE] Exception => $e");
      print("🔥 [PACKER SAVE] Stacktrace => $stack");

      Get.snackbar(
        'Error',
        'Failed to submit items. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
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
          'useas': '3',
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
      clearSelections(); // Clear previous selections
      currentPackerData.value = packerData; // Store current packer data

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final body = {
        'companyid': LoginController.selectedCompanyId.toString(),
        'useas': '3',
        'siid': packerData.sIId.toString(),
        'trayno': packerData.trayNo ?? '',
        'branchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString(),
        'brk': LoginController.selectedFloorId.toString(),
        'appversion': 'V1',
      };

      print("📦 Request body => $body");

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
            navigateToPackerDetailsScreen(packerData);
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

  // Navigate to packer details screen
  void navigateToPackerDetailsScreen(PickerData packerData) {
    Get.to(
          () => PackerDetailsScreen(packerData: packerData),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
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