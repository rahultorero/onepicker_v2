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
import '../view/PickerListTab.dart';
import 'HomeScreenController.dart';
import 'LoginController.dart';
import 'PickerController.dart';

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
  final showAllTrays = false.obs; // RxBool


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
            print("checkkkk detailssssss  ${packerDetails.toJson()}");
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
    // if (checkedItems.isEmpty) {
    //     Get.snackbar(
    //       'Warning',
    //       'No items selected for submission',
    //       backgroundColor: Colors.orange.withOpacity(0.1),
    //       colorText: Colors.orange.shade700,
    //     );
    //     return;
    //   }

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

            fetchPackerDetails(pickerData);

            // Success - show success message and navigate back
            print("check result --> ${responseData['message'] }");
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

          } else if (responseData['status'] == '401' || responseData['status'] == '400') {
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
  Future<void> submitCheckedAllItems(PickerData pickerData, List<PickerMenuDetail> checkedItems) async {
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
      final settingPrint = await ApiConfig.getSsub("PrintInvPicker");

      // Construct JSON payload similar to the reference code
      final Map<String, dynamic> jsonBody = {
        "companyId": LoginController.selectedCompanyId.toString(),
        "useas": "2",
        "siid": pickerData.sIId.toString(),
        "brchid": LoginController.selectedBranchId.toString(),
        "empid": loginData?.response?.empId.toString(),
        "settingPCamera": HomeScreenController.selectCamera ?? "",
        "printId": HomeScreenController.selectPrinter ?? "",
        "settingPrint": settingPrint ?? "",
        "brk": LoginController.selectedFloorId.toString(),
        "istempquit": 0,
        "appversion": "V1",
      };

      // Build item details array
      List<Map<String, dynamic>> itemDetailsArray = [];
      for (var item in checkedItems) {
        if (item.pNote != null && item.pNote.toString().isNotEmpty) {
          Map<String, dynamic> itemDetail = {
            "siid": pickerData.sIId.toString(),
            "itemdetailid": item.itemDetailId?.toString() ?? "",
            "batchno": item.batchNo ?? "",
            "mrp": item.mrp?.toString() ?? "",
            "pnote": item.pNote.toString(),
            "nbatch": item.nBatch
          };
          itemDetailsArray.add(itemDetail);
        }
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
          print("check result ------> ${responseData['message']}");

          Get.snackbar(
            'Success',
            responseData['message'] ?? 'Items submitted successfully!',
            backgroundColor: Colors.green.withOpacity(0.85),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            borderRadius: 8,
          );

          // Show celebration dialog
          _showCelebrationDialog(pickerData.trayNo);

        } else if (responseData['status'] == '401' || responseData['status'] == '400') {
          Get.snackbar(
            'Error',
            'Authentication failed. Please login again.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        } else {
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

  void _showCelebrationDialog(String? trayNo) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            children: [
              // Main Content
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ).createShader(bounds),
                      child: const Text(
                        'Success!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Celebration Emojis
                    const Text(
                      '🎉 🎊 ✨ 🎈',
                      style: TextStyle(fontSize: 28),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.green[300]!,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bill Closed Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green[50]!,
                            Colors.green[100]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Your Bill is Closed',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tray Number Section
                    if (trayNo != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green[600]!,
                              Colors.green[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tray Number',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                trayNo,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Floating Success Icon
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green[400]!,
                          Colors.green[600]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Auto close dialog and navigate back after 3 seconds
    // Auto close dialog and navigate back after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Close dialog
      Navigator.of(Get.context!).pop();

      // Wait a bit then close screen
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(Get.context!).pop();

        // Refresh after navigation
        Future.delayed(const Duration(milliseconds: 200), () {
          refreshData();
        });
      });
    });
  }

  Future<void> assignTray({
    required int siId,
    required String trayNumbers,
    required int trayCount,
  }) async {
    try {
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final requestBody = {
        'companyId': LoginController.selectedCompanyId.toString(),
        'useas': '1',
        'siid': siId.toString(),
        'trayno': trayNumbers,
        'tcount': trayCount.toString(),
        'brchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString() ?? '',
        'brk': LoginController.selectedFloorId.toString(),
        'appversion': 'V1',
      };

      print("📤 Assign Tray API Request URL: ${apiConfig.baseUrl}assign_tray");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}assign_tray'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print("📥 Assign Tray Response status: ${response.statusCode}");
      print("📥 Assign Tray Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Assuming the API returns a ResetUserModel or similar response
        if (jsonData['status'] == '200' || jsonData['success'] == true) {
          print("✅ Tray assigned successfully");

          // Update the specific picker item in the list
          final pickerIndex = packerList.indexWhere((picker) => picker.sIId == siId);
          if (pickerIndex != -1) {
            // Create updated picker data with new tray numbers
            final updatedPicker = PickerData(
              sIId: packerList[pickerIndex].sIId,
              invNo: packerList[pickerIndex].invNo,
              trayNo: trayNumbers, // Updated tray numbers
              iTime: packerList[pickerIndex].iTime,
              delType: packerList[pickerIndex].delType,
              // Add other fields as needed
            );

            // Replace the item in the list
            packerList[pickerIndex] = updatedPicker;
            packerList.refresh(); // Trigger UI update
          }

        } else {
          throw Exception(jsonData['message'] ?? 'Failed to assign tray');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error assigning tray: $e');
      throw Exception('Failed to assign tray: $e');
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