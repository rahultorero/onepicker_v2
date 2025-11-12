import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:onepicker/services/services.dart';

import '../model/DashBoardDataModel.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final searchController = TextEditingController();

  final searchText = ''.obs;
  final selectedCategory = 'InvNo'.obs;
  final isDetailViewVisible = false.obs;
  final selectedItemIndex = (-1).obs;

  // Data variables
  final dbCountData = Rxn<DBcountData>();
  final dbStateList = <DBStateData>[].obs;
  final filteredStateList = <DBStateData>[].obs;
  final dbStateDtlList = <DbStateDtlData>[].obs;

  // NEW: Pagination variables
  final currentPage = 1.obs;
  final itemsPerPage = 20.obs; // Default items per page
  final paginatedList = <DBStateData>[].obs;
  final showDetailView = false.obs;


  // Categories for search
  final categories = ['InvNo', 'TrayNo', 'PName', 'Area'].obs;

  // User data
  final userId = 1.obs;
  final empId = 1.obs;
  final companyId = 1.obs;
  final branchId = 1.obs;
  final isPickManager = true.obs;
  late var workingWithPickupManager = true.obs;

  // Computed properties for pagination
  int get totalPages => (filteredStateList.length / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, filteredStateList.length);

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    // Listen to changes with debouncing for better performance
    ever(searchText, (_) => _debounceSearch());
    ever(selectedCategory, (_) => filterData());
    ever(filteredStateList, (_) => _updatePagination());
    ever(currentPage, (_) => _updatePagination());
    ever(itemsPerPage, (_) => _updatePagination());
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      filterData();
    });
  }




  Future<void> loadInitialData() async {
    final workingWithPickupManagerbool = await ApiConfig.getSyn('WorkingWithPickupManager');
    if (workingWithPickupManagerbool != 0) {
     workingWithPickupManager = true.obs;
    }else{
      workingWithPickupManager = false.obs;
    }
    currentPage.value = 1; // Reset to first page
    getDbCount();
    getDbState();
  }

  String get formattedDate => DateFormat('dd-MMM-yy').format(selectedDate.value);

  Future<void> selectDate() async {
    final DateTime? picked = await Get.dialog<DateTime>(
      AlertDialog(
        title: const Text('Select Date'),
        content: Text('Current: $formattedDate'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              selectedDate.value = DateTime.now();
              Get.back();
              loadInitialData();
            },
            child: const Text('Today'),
          ),
        ],
      ),
    );
  }

  Future<void> getDbCount() async {
    try {
      isLoading.value = true;

      final apiConfig = await ApiConfig.load();
      final user = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}dbcount'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': user?.response?.empId.toString(),
          'empid': user?.response?.empId.toString(),
          'fromdate': formattedDate,
          'companyid': user?.response?.coId.toString(),
          'branchid': user?.response?.brchId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = DBcountModel.fromJson(data);

        if (model.response != null && model.response!.isNotEmpty) {
          dbCountData.value = model.response!.first;
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load count data: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getDbState() async {
    try {
      isLoading.value = true;

      final apiConfig = await ApiConfig.load();
      final user = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}dbinvstat'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': user?.response?.empId.toString(),
          'empid': user?.response?.empId.toString(),
          'fromdate': formattedDate,
          'companyid': user?.response?.coId.toString(),
          'branchid': user?.response?.brchId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Use compute for heavy JSON parsing to avoid blocking UI
        final parsedData = await compute(_parseStateData, data);

        dbStateList.assignAll(parsedData);
        filterData(); // This will trigger pagination update
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load state data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Static method for isolate parsing
  static List<DBStateData> _parseStateData(dynamic jsonData) {
    try {
      final model = DBStateModel.fromJson(jsonData);
      return model.response ?? [];
    } catch (e) {
      print('Error parsing state data: $e');
      return [];
    }
  }


  void filterData() {
    try {
      List<DBStateData> filtered;

      if (searchText.value.isEmpty) {
        filtered = List.from(dbStateList);
      } else {
        final query = searchText.value.toLowerCase();
        filtered = dbStateList.where((item) {
          switch (selectedCategory.value) {
            case 'InvNo':
              return item.invNo?.toLowerCase().contains(query) ?? false;
            case 'TrayNo':
              return item.trayNo?.toLowerCase().contains(query) ?? false;
            case 'PName':
              return item.party?.toLowerCase().contains(query) ?? false;
            case 'Area':
              return item.area?.toLowerCase().contains(query) ?? false;
            default:
              return false;
          }
        }).toList();
      }

      filteredStateList.assignAll(filtered);

      // Reset to first page when filtering
      currentPage.value = 1;

    } catch (e) {
      print('Error filtering data: $e');
      filteredStateList.assignAll(dbStateList);
    }
  }

  void _updatePagination() {
    try {
      final start = startIndex;
      final end = endIndex;

      if (start >= filteredStateList.length) {
        paginatedList.clear();
        return;
      }

      final paginated = filteredStateList.sublist(start, end);
      paginatedList.assignAll(paginated);

    } catch (e) {
      print('Error updating pagination: $e');
      paginatedList.clear();
    }
  }

  // NEW: Pagination methods
  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int items) {
    itemsPerPage.value = items;
    currentPage.value = 1; // Reset to first page
  }

  void debugTapInfo(int paginatedIndex) {
    print('=== DEBUG TAP INFO ===');
    print('Paginated Index: $paginatedIndex');
    print('Paginated List Length: ${paginatedList.length}');
    print('Filtered List Length: ${filteredStateList.length}');
    print('Selected Item Index: ${selectedItemIndex.value}');
    print('Detail View Visible: ${isDetailViewVisible.value}');
    if (paginatedIndex < paginatedList.length) {
      final item = paginatedList[paginatedIndex];
      print('Item sIId: ${item.sIId}');
      print('Item invNo: ${item.invNo}');
      final originalIndex = filteredStateList.indexOf(item);
      print('Original Index: $originalIndex');
    }
    print('======================');
  }





  Future<void> getDbStateDtlForBottomSheet(int sihId, VoidCallback onSuccess) async {
    try {
      final apiConfig = await ApiConfig.load();
      final user = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}dbinvdtl'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': user?.response?.empId.toString(),
          'empid': user?.response?.empId.toString(),
          'companyid': user?.response?.coId.toString(),
          'sihid': sihId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = DbStateDtlModel.fromJson(data);

        if (model.response != null) {
          dbStateDtlList.value = model.response!;
          onSuccess(); // Show bottom sheet after data is loaded
        } else {
          _showErrorSnackbar('No detail data available');
        }
      } else {
        _showErrorSnackbar('Failed to load detail data: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load detail data: $e');
    }
  }

  // Clean up method
  void clearDetailData() {
    selectedItemIndex.value = -1;
    dbStateDtlList.clear();
  }





// Also update the getDbStateDtl method to be more robust:
  Future<void> getDbStateDtl(int sihId, int index) async {
    print('API Call - getDbStateDtl started for sihId: $sihId, index: $index');

    try {
      final apiConfig = await ApiConfig.load();
      final user = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}dbinvdtl'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': user?.response?.empId.toString(),
          'empid': user?.response?.empId.toString(),
          'companyid': user?.response?.coId.toString(),
          'sihid': sihId.toString(),
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = DbStateDtlModel.fromJson(data);

        if (model.response != null) {
          print('API Success - Setting detail data');

          // Set all data without triggering reactive updates
          dbStateDtlList.value = model.response!;
          selectedItemIndex.value = index;
          isDetailViewVisible.value = true;
          showDetailView.value = true;


          // Trigger GetBuilder update
          update(['detail_view']);

        } else {
          _showErrorSnackbar('No detail data available');
        }
      } else {
        _showErrorSnackbar('Failed to load detail data: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      _showErrorSnackbar('Failed to load detail data: $e');
      closeDetailViewFinal();
    }
  }

// Updated close method:
  void closeDetailViewFinal() {
    isDetailViewVisible.value = false;
    selectedItemIndex.value = -1;
    dbStateDtlList.clear();
    update(['detail_view']);
  }
// STEP 5: Update closeDetailView to prevent loops:
  void closeDetailView() {
    isDetailViewVisible.value = false;
    selectedItemIndex.value = -1;
    dbStateDtlList.clear();
  }

  void updateDetailView() {
    update(['detail_view']);
  }


  int calculateStepProgress(DBStateData item) {
    int step = 0;

    if (item.picked == 1) step++;
    if (workingWithPickupManager.value && item.mPicked == 1) step++;
    if (item.checked == 1) step++;
    if (item.packed == 1) step++;
    if (item.delivered == 1) step++;

    return step;
  }

  Future<void> triggerPrint(int siId, String userChoice) async {
    try {
      isLoading.value = true;

      final apiConfig = await ApiConfig.load();
      final user = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}triggerprint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'siId': siId.toString(),
          'printId': '1',
          'userChoice': userChoice,
        },
      );

      if (response.statusCode == 200) {
        final message = userChoice == 'printinv'
            ? 'Invoice Print Successfully'
            : 'Packing Slip Print Successfully';

        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh data to update print status
        loadInitialData();
      } else {
        Get.snackbar(
          'Info',
          'Already printed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _showErrorSnackbar('Print failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    searchController.dispose();

    _debounceTimer?.cancel();
    super.onClose();
  }
}

// Optional: Add this extension for better performance monitoring
extension DashboardControllerExtensions on DashboardController {
  void logPerformanceMetrics() {
    print('Total items: ${dbStateList.length}');
    print('Filtered items: ${filteredStateList.length}');
    print('Current page: ${currentPage.value}');
    print('Items per page: ${itemsPerPage.value}');
    print('Total pages: $totalPages');
    print('Paginated items: ${paginatedList.length}');
  }
}