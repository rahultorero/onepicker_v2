import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onepicker/controllers/LoginController.dart';

import '../model/SearchFilterListModel.dart';
import '../model/TrayAssignerModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import 'package:http/http.dart' as http;

class TrayAssignerController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isSearchLoading = false.obs;
  var trayAssignerList = <TrayAssignerData>[].obs;
  var filteredTrayList = <TrayAssignerData>[].obs;
  var searchFilterList = <SearchData>[].obs;
  var selectedFilterType = 'ALL'.obs;
  var selectedFilterValue = ''.obs;
  var selectedFilterId = 0.obs;
  var showFilterDropdown = false.obs;

  // Filter types
  final filterTypes = ['ALL', 'CITY', 'AREA', 'SMAN', 'ROUTE'];

  // Individual tray number controllers for each item
  var trayNumberControllers = <int, TextEditingController>{}.obs;

  // API parameters (you can set these from your app's global state)
  int companyId = 1;
  int useAs = 1;
  int branchId = 1;
  int empId = 1;
  int brk = 1;
  int settingEIRN = 1;

  @override
  void onInit() {
    super.onInit();
    fetchTrayAssignerList();
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var controller in trayNumberControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  // Get or create controller for specific item
  TextEditingController getTrayController(int itemId) {
    if (!trayNumberControllers.containsKey(itemId)) {
      trayNumberControllers[itemId] = TextEditingController();
    }
    return trayNumberControllers[itemId]!;
  }

// Fetch initial tray list from API
  Future<void> fetchTrayAssignerList() async {
    try {
      print("🚀 fetchTrayAssignerList started...");

      isLoading(true);
      print("⏳ isLoading set to true");

      final apiConfig = await ApiConfig.load();
      print("🔧 Loaded ApiConfig: baseUrl=${apiConfig.baseUrl}");

      final loginData = await ApiConfig.getLoginData();
      final settingEIRN = await ApiConfig.getSyn('SEIRNInv');

      print("👤 Login Data: empId=${loginData?.response?.empId}, "
          "companyId=${LoginController.selectedCompanyId}, "
          "branchId=${LoginController.selectedBranchId}, "
          "floorId=${LoginController.selectedFloorId}");

      final requestBody = {
        'companyid': LoginController.selectedCompanyId.toString() ?? '',
        'useas': '6', // ensure string, since form-urlencoded usually needs string
        'branchid': LoginController.selectedBranchId.toString() ?? '',
        'empid': loginData?.response?.empId.toString() ?? '',
        'brk': LoginController.selectedFloorId.toString() ?? '',
        'settingEIRN': settingEIRN.toString(),
      };

      print("📤 API Request Body: $requestBody");

      final response = await http
          .post(
        Uri.parse('${apiConfig.baseUrl}invoice_list_for_tray'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      )
          .timeout(const Duration(seconds: 10));

      print("📩 API Raw Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ JSON Decoded Successfully: $data");

        final trayResponse = TrayAssignerModel.fromJson(data);
        print("📦 Parsed TrayAssignerModel: "
            "status=${trayResponse.status}, message=${trayResponse.message}, "
            "itemsCount=${trayResponse.trayAssignerData?.length ?? 0}");

        if (trayResponse.status == "200" &&
            trayResponse.trayAssignerData != null) {
          trayAssignerList.value = trayResponse.trayAssignerData!;
          filteredTrayList.value = trayAssignerList.value;

          print("📋 TrayAssignerList Updated: count=${trayAssignerList.length}");

          for (var item in trayAssignerList) {
            print("➡️ Processing Tray Item: sIId=${item.sIId}, customer=${item.sman}");
            if (item.sIId != null) {
              print("🔄 Calling getTrayController for sIId=${item.sIId}");
              getTrayController(item.sIId!);
            } else {
              print("⚠️ Skipped Tray Item with null sIId");
            }
          }
        } else {
          print("❌ Tray Response Failed: message=${trayResponse.message}");
          Get.snackbar('Error', trayResponse.message ?? 'Failed to load tray list');
        }
      } else {
        print("❌ API Error: statusCode=${response.statusCode}");
        Get.snackbar('Error', 'Server returned ${response.statusCode}');
      }
    } catch (e, s) {
      print('🔥 fetchTrayAssignerList Exception: $e');
      print('📌 Stacktrace: $s');
      Get.snackbar('Error', 'Failed to fetch tray list: $e');
    } finally {
      isLoading(false);
      print("✅ fetchTrayAssignerList completed, isLoading set to false");
    }
  }

// Fetch search filter list from API
  Future<void> fetchSearchFilterList(String searchType) async {
    try {
      isSearchLoading(true);

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      final settingEIRN = await ApiConfig.getSyn('SEIRNInv');

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}list_Area'), // ✅ replace with actual API endpoint
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': LoginController.selectedCompanyId.toString() ?? '0',
          'useas': '6',
          'branchid': LoginController.selectedBranchId.toString() ?? '0',
          'searchtype': searchType,
          'empid': loginData?.response?.empId?.toString() ?? '0',
          'brk': LoginController.selectedFloorId.toString() ?? '0',
          'settingEIRN':  settingEIRN.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      print("📩 Search Filter API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final filterResponse = SearchFilterListModel.fromJson(data);

        if (filterResponse.status == "200" && filterResponse.searchDataList != null) {
          searchFilterList.value = filterResponse.searchDataList!;
        } else {
          Get.snackbar('Error', filterResponse.message ?? 'Failed to load filters');
        }
      }
    } catch (e, s) {
      print('🔥 fetchSearchFilterList error: $e');
      print('📌 Stacktrace: $s');
      Get.snackbar('Error', 'Failed to fetch search filters: $e');
    } finally {
      isSearchLoading(false);
    }
  }

// Search with selected filter from API
  Future<void> searchWithFilter() async {
    if (selectedFilterType.value == 'ALL') {
      filteredTrayList.value = trayAssignerList.value;
      return;
    }

    if (selectedFilterValue.value.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select a ${selectedFilterType.value.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading(true);

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      final settingEIRN = await ApiConfig.getSyn('SEIRNInv');

      String type = selectedFilterType.value;
      if(type == 'ROUTE'){
        type = 'DROUTE';
      }

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}search_invoice'), // ✅ replace with actual API endpoint
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': LoginController.selectedCompanyId.toString() ?? '0',
          'useas': '6',
          'branchid': LoginController.selectedBranchId.toString() ?? '0',
          'searchtype': type,
          'searchvalue': selectedFilterId.value.toString(),
          'empid': loginData?.response?.empId?.toString() ?? '0',
          'brk': LoginController.selectedFloorId.toString() ?? '0',
          'settingEIRN':  settingEIRN.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      print("📩 Search Assign API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trayResponse = TrayAssignerModel.fromJson(data);

        if (trayResponse.status == "200" && trayResponse.trayAssignerData != null) {
          filteredTrayList.value = trayResponse.trayAssignerData!;

          for (var item in filteredTrayList) {
            if (item.sIId != null) {
              getTrayController(item.sIId!);
            }
          }
        } else {
          Get.snackbar('Error', trayResponse.message ?? 'No results found');
        }
      }
    } catch (e, s) {
      print('🔥 searchWithFilter error: $e');
      print('📌 Stacktrace: $s');
      Get.snackbar('Error', 'Failed to search: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      filteredTrayList.value = trayAssignerList;
    } else {
      filteredTrayList.value = trayAssignerList.where((item) {
        return (item.invNo?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (item.party?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (item.city?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (item.area?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
  }


  // Handle filter type change
  void onFilterTypeChanged(String filterType) {
    selectedFilterType.value = filterType;
    selectedFilterValue.value = '';
    selectedFilterId.value = 0;
    showFilterDropdown.value = false;

    if (filterType == 'ALL') {
      filteredTrayList.value = trayAssignerList.value;
    }
    if(filterType == 'ROUTE'){
      fetchSearchFilterList('DROUTE');
    }
    else {
      fetchSearchFilterList(filterType);
    }
  }

  // Handle filter value selection
  void onFilterValueSelected(SearchData searchData) {
    switch (selectedFilterType.value) {
      case 'CITY':
        selectedFilterValue.value = searchData.city ?? '';
        selectedFilterId.value = searchData.grpIdCity ?? 0;
        break;
      case 'AREA':
        selectedFilterValue.value = searchData.area ?? '';
        selectedFilterId.value = searchData.grpIdArea ?? 0;
        break;
      case 'SMAN':
        selectedFilterValue.value = searchData.sman ?? '';
        selectedFilterId.value = searchData.ledIdSalesmen ?? 0;
        break;
      case 'ROUTE':
        selectedFilterValue.value = searchData.deliveryRoute ?? '';
        selectedFilterId.value = searchData.grpIdDel ?? 0;

        break;
    }
    showFilterDropdown.value = false;
    searchWithFilter();
  }

  // Open QR scanner for specific item
  void openQRScannerForItem(TrayAssignerData item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 280,
          height: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Scan QR for ${item.invNo}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 60,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Position QR code in the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // TODO: Process scanned QR result
                      Get.snackbar(
                        'Success',
                        'QR scanned for ${item.invNo}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle delivery action
  void handleDelivery(TrayAssignerData item) {
    final trayController = getTrayController(item.sIId!);

    if (trayController.text.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'Please enter Tray Number first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delivery'),
        content: Text('Mark ${item.invNo} as delivered with Tray No: ${trayController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Call delivery API
              Get.snackbar(
                'Success',
                'Delivery marked for ${item.invNo}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Mock data for testing - replace with actual API data
}