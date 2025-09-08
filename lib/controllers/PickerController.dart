import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onepicker/controllers/HomeScreenController.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'dart:convert';

import '../bottomsheets/PickerDetailsBottomSheet.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerMenuDetailModel.dart';
import '../model/StockDetailDataModel.dart';
import '../model/StockDetailModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';

class PickerController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Observables
  var isLoadingPickerList = false.obs;
  var isLoadingPickerDetails = false.obs;
  var isLoadingStockList = false.obs;
  var isLoadingStockDetail = false.obs; // New loading state for stock detail
  var pickerList = <PickerData>[].obs;
  var pickerDetails = <PickerMenuDetail>[].obs;
  var stockList = <StockDetail>[].obs;
  var stockDetailList = <StockDetailData>[].obs; // New observable for stock detail data
  var selectedLocation = ''.obs;
  var selectedPickerIndex = (-1).obs;
  var selectedDetailIds = <String>[].obs;

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
    selectedDetailIds.clear(); // Clear previous selections when switching picker items
    fetchPickerDetails(pickerData);

    // Force UI update to highlight selected picker card
    selectedPickerIndex.refresh();
  }

  void onDetailSelectionChanged(String detailId, bool isSelected) {
    if (isSelected) {
      if (!selectedDetailIds.contains(detailId)) {
        selectedDetailIds.add(detailId);
      }
    } else {
      selectedDetailIds.remove(detailId);
    }
    selectedDetailIds.refresh(); // Force UI update
  }

  // Select all detail items
  void selectAllDetails() {
    selectedDetailIds.clear();
    for (var detail in pickerDetails) {
      selectedDetailIds.add(detail.itemDetailId.toString());
    }
    selectedDetailIds.refresh();
  }

  // Deselect all detail items
  void deselectAllDetails() {
    selectedDetailIds.clear();
    selectedDetailIds.refresh();
  }

  // Check if all details are selected
  bool get areAllDetailsSelected {
    return pickerDetails.isNotEmpty && selectedDetailIds.length == pickerDetails.length;
  }

  // Get selection progress text
  String get selectionProgressText {
    if (pickerDetails.isEmpty) return '0/0';
    return '${selectedDetailIds.length}/${pickerDetails.length}';
  }

  void submitSelectedItems() {
    if (selectedDetailIds.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select at least one item to submit',
        backgroundColor: AppTheme.amberGold.withOpacity(0.1),
        colorText: AppTheme.amberGold,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final isAllSelected = areAllDetailsSelected;
    final selectedCount = selectedDetailIds.length;
    final totalCount = pickerDetails.length;

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text(isAllSelected ? 'Submit All Items' : 'Submit Selected Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAllSelected
                  ? 'Are you sure you want to submit all $totalCount items?'
                  : 'Are you sure you want to submit $selectedCount out of $totalCount items?',
            ),
            const SizedBox(height: 8),
            Text(
              'Selected items will be processed and cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processSubmission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAllSelected ? AppTheme.accentGreen : AppTheme.primaryTeal,
            ),
            child: Text(
              isAllSelected ? 'Submit All' : 'Submit Selected',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _processSubmission() {
    // Get selected picker data
    final selectedPicker = pickerList[selectedPickerIndex.value];

    // Get selected detail items
    final selectedDetails = pickerDetails.where((detail) =>
        selectedDetailIds.contains(detail.itemDetailId.toString())).toList();

    // This could be an API call to submit the selected items
    print('Submitting ${selectedDetails.length} items for invoice: ${selectedPicker.invNo}');
    for (var detail in selectedDetails) {
      print('- ${detail.itemName} (Qty: ${detail.tQty})');
    }

    // Show success message
    Get.snackbar(
      'Success',
      '${selectedDetails.length} items submitted successfully!',
      backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
      colorText: AppTheme.accentGreen,
      duration: const Duration(seconds: 3),
    );

    // Clear selections after successful submission
    selectedDetailIds.clear();
    selectedDetailIds.refresh();
  }

  // NEW METHOD: API call to fetch stock detail for a specific item
  Future<void> fetchStockDetail(int itemDetailId, String itemName,bool show) async {
    try {
      isLoadingStockDetail(true);
      stockDetailList.clear();

      print("🔵 Fetching stock detail for item: $itemName (ID: $itemDetailId)");

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final requestBody = {
        'useas': '1',
        'branchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString() ?? '',
        'itemdetailid': itemDetailId.toString(),
        'appversion': 'V1',
      };

      print("📤 Stock Detail API Request URL: ${apiConfig.baseUrl}item_stock");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}item_stock'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print("📥 Stock Detail Response status: ${response.statusCode}");
      print("📥 Stock Detail Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final stockDetailModel = StockDetailModel.fromJson(jsonData);

        if (stockDetailModel.status == '200') {
          stockDetailList.assignAll(stockDetailModel.stockDetailData ?? []);
          print("📊 Stock detail fetched. Count=${stockDetailList.length}");

          // Show the stock detail dialog
          if(show){
            showStockDetailDialog(itemName);

          }

        } else {
          print("❌ API returned error: ${stockDetailModel.message}");
          Get.snackbar(
            'Error',
            stockDetailModel.message ?? 'Failed to fetch stock detail',
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
      print('🔥 Exception while fetching stock detail: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch stock detail. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStockDetail(false);
    }
  }

  void showStockDetailDialog(String itemName) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Obx(() {
                  if (isLoadingStockDetail.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading stock details...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (stockDetailList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppTheme.primaryTeal.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Stock Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No stock details found for this item',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurface.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.05),
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Batch No.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Exp Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'MRP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Godown',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stock List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: stockDetailList.length,
                          itemBuilder: (context, index) {
                            final stockDetail = stockDetailList[index];

                            // Format expiry date like your Java code
                            String formattedExpDate = 'E:';
                            if (stockDetail.expDate?.isNotEmpty == true) {
                              try {
                                final inputFormat = DateFormat('dd-MM-yyyy');
                                final outputFormat = DateFormat('MM/yy');
                                final date = inputFormat.parse(stockDetail.expDate!);
                                formattedExpDate = outputFormat.format(date);
                              } catch (e) {
                                formattedExpDate = 'E:';
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.onSurface.withOpacity(0.05),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Batch Number
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.accentGreen.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        stockDetail.batchNo ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentGreen,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Exp Date
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      formattedExpDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.onSurface.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // MRP
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${stockDetail.mrp ?? 0}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface.withOpacity(0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // Stock Quantity
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${stockDetail.stock ?? 0}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryTeal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Godown Quantity
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.amberGold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${stockDetail.gdwnQty ?? 0}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.amberGold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.onSurface.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Records Count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: 16,
                            color: AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stockDetailList.length} Records',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Close Button
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // NEW METHOD: Method to be called from UI to show stock detail
  void showItemStockDetail(int itemDetailId, String itemName) {
    fetchStockDetail(itemDetailId, itemName,true);
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
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
              colorText: AppTheme.primaryTeal,
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
      selectedDetailIds.clear(); // Clear selections when loading new details

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
            // Get.snackbar(
            //   'Info',
            //   'No stock data available',
            //   backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
            //   colorText: AppTheme.primaryTeal,
            // );
          }
        } else {
          print("❌ API returned error: ${stockModel.message}");
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');

      }
    } catch (e) {
      print('🔥 Exception while fetching stock list: $e');

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
    selectedPickerIndex.value = -1; // Reset selection
    selectedDetailIds.clear(); // Clear detail selections
    await fetchPickerList();
  }

  Future<void> refreshStockData() async {
    await fetchStockList();
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
          final pickerIndex = pickerList.indexWhere((picker) => picker.sIId == siId);
          if (pickerIndex != -1) {
            // Create updated picker data with new tray numbers
            final updatedPicker = PickerData(
              sIId: pickerList[pickerIndex].sIId,
              invNo: pickerList[pickerIndex].invNo,
              trayNo: trayNumbers, // Updated tray numbers
              iTime: pickerList[pickerIndex].iTime,
              delType: pickerList[pickerIndex].delType,
              // Add other fields as needed
            );

            // Replace the item in the list
            pickerList[pickerIndex] = updatedPicker;
            pickerList.refresh(); // Trigger UI update
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



  // API call to submit picker with selected items
  Future<void> submitPicker() async {
    if (selectedDetailIds.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select at least one item to submit',
        backgroundColor: AppTheme.amberGold.withOpacity(0.1),
        colorText: AppTheme.amberGold,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedPickerIndex.value == -1) {
      Get.snackbar(
        'Error',
        'No picker selected',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoadingPickerDetails(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final selectedPicker = pickerList[selectedPickerIndex.value];

      // Get selected detail items
      final selectedDetails = pickerDetails.where((detail) =>
          selectedDetailIds.contains(detail.itemDetailId.toString())).toList();

      // Build the request body similar to Java version
      final Map<String, dynamic> requestBody = {
        'companyId': LoginController.selectedCompanyId,
        'useas': 1,
        'siid': selectedPicker.sIId,
        'branchid': LoginController.selectedBranchId,
        'location': selectedLocation.value,
        'empid': loginData?.response?.empId,
        'brk': LoginController.selectedFloorId,
        'istempquit': 1,
        'appversion': 'V1',
        'itemdetails': selectedDetails.map((detail) => {
          'siid': selectedPicker.sIId,
          'itemdetailid': detail.itemDetailId,
          'batchno': detail.batchNo ?? '',
          'mrp': detail.mrp ?? 0.0,
          'pnote': detail.pNote ?? '',
        }).toList(),
      };

      print("📤 Submit Picker API Request URL: ${apiConfig.baseUrl}saveproduct");
      print("📤 Request Body: ${json.encode(requestBody)}");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveproduct'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      );

      print("📥 Submit Picker Response status: ${response.statusCode}");
      print("📥 Submit Picker Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == '200') {
          print("✅ Picker submitted successfully");

          // Get location array from response (similar to Java) - Fixed type casting
          List<String> locationArray = <String>[];

          // Debug: Print the response structure
          print("🔍 Response structure: ${jsonData.keys}");

          // Try different possible response structures
          String? locationStr;
          if (jsonData['response'] != null && jsonData['response'] is List && jsonData['response'].isNotEmpty) {
            locationStr = jsonData['response'][0]['location']?.toString();
            print("📍 Found location in response[0]['location']: $locationStr");
          } else if (jsonData['locationLists'] != null && jsonData['locationLists'] is List && jsonData['locationLists'].isNotEmpty) {
            locationStr = jsonData['locationLists'][0]['location']?.toString();
            print("📍 Found location in locationLists[0]['location']: $locationStr");
          } else if (jsonData['location'] != null) {
            locationStr = jsonData['location'].toString();
            print("📍 Found location in root: $locationStr");
          }

          if (locationStr != null && locationStr.isNotEmpty) {
            // Explicit type casting to List<String>
            locationArray = locationStr
                .split(',')
                .map((loc) => loc.trim())
                .where((loc) => loc.isNotEmpty)
                .cast<String>() // Explicit cast to String
                .toList();
            locationArray.sort(); // Sort alphabetically like in Java
            print("📍 Processed locationArray: $locationArray");
          } else {
            print("⚠️ No location data found in response");
          }

          // Remove the submitted picker from the list (similar to Java logic)
          pickerList.removeWhere((picker) => picker.sIId == selectedPicker.sIId);
          pickerList.refresh();

          // Clear selections and refresh data
          selectedPickerIndex.value = -1;
          selectedDetailIds.clear();
          pickerDetails.clear();

          // Refresh the picker list
          await fetchPickerList();

          // Call pending location API after successful submission
          await _getPendingLocation(
            siId: selectedPicker.sIId ?? 0,
            locationArray: locationArray,
          );

          Get.snackbar(
            'Success',
            '${selectedDetails.length} items submitted successfully!',
            backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
            colorText: AppTheme.accentGreen,
            duration: const Duration(seconds: 3),
          );

        } else {
          throw Exception(jsonData['message'] ?? 'Failed to submit picker');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error submitting picker: $e');
      Get.snackbar(
        'Error',
        'Failed to submit picker: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPickerDetails(false);
    }
  }

  // API call to get pending location after submission
// API call to get pending location after submission
  Future<void> _getPendingLocation({
    required int siId,
    required List<String> locationArray,
  }) async {
    try {
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final requestBody = {
        'useas': '1',
        'siid': siId.toString(),
        'branchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString() ?? '',
        'appversion': 'V1',
      };

      print("📤 Pending Location API Request URL: ${apiConfig
          .baseUrl}pend_location");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}pend_location'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print("📥 Pending Location Response status: ${response.statusCode}");
      print("📥 Pending Location Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug logs - THIS IS WHERE THE LOGS ARE ADDED
        print("🔍 Debug Info:");
        print("📍 selectedLocation.value: '${selectedLocation.value}'");
        print("📍 locationArray: $locationArray");
        print("📍 locationArray.length: ${locationArray.length}");
        print("📍 penLocData exists: ${jsonData['penLocData'] != null}");

        // Following exact Java logic
        if (jsonData['response'] != null) {
          print("✅ penLocData is NOT NULL - processing location array logic");

          // Has pending location data - process location array logic
          if (locationArray.contains(selectedLocation.value)) {
            print("✅ locationArray CONTAINS selectedLocation");

            final currentLocationIndex = locationArray.indexOf(
                selectedLocation.value);
            print("📍 currentLocationIndex: $currentLocationIndex");
            print("📍 locationArray.length - 1: ${locationArray.length - 1}");
            print("📍 Is last location? ${locationArray[locationArray.length -
                1] == selectedLocation.value}");

            // Check if current location is the last one in array
            if (locationArray[locationArray.length - 1] ==
                selectedLocation.value) {
              print("✅ Current location IS the LAST location in array");

              // Java has a weird condition here: if (loaction_arr.size() == 0)
              // This is logically impossible since we already checked contains() and got the last element
              // But following Java logic exactly:
              if (locationArray.isEmpty) {
                print("⚠️ Array is empty (impossible case)");
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  const SnackBar(
                    content: Text('Your Bill is closed'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                print("📢 Showing: Check Your Pending location");
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  const SnackBar(
                    content: Text('Check Your Pending location'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              print(
                  "✅ Current location is NOT the last - showing NEXT location");
              final nextLocation = locationArray[currentLocationIndex + 1];
              print("📢 Next location: '$nextLocation'");

              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(
                  content: Text('Next Location: $nextLocation'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            print("❌ locationArray does NOT contain selectedLocation");
            print("📢 No action taken (following Java logic)");
            // Java code doesn't show any message if selectedLoc is not in locationArray
          }
        } else {
          print("❌ penLocData is NULL - checking settings for merger logic");
          // No pending location data - check settings and call saveMerger if needed
          await _handleMergerLogic(siId);
        }
      }
    } catch (e) {
      print('🔥 Error getting pending location: $e');
      // Don't show error for this since it's secondary to the main submit
    }
  }

  // Handle merger logic when no pending location data
  Future<void> _handleMergerLogic(int siId) async {
    try {
      // Check settings - you'll need to implement these based on your settings storage
      // For now, assuming they return 0 (false) to match Java logic
      final eTrayMerger = await ApiConfig.getSyn('ETrayMerger'); // Implement this
      final workingWithPickupManager = await ApiConfig.getSyn('WorkingWithPickupManager'); // Implement this
      final printInvPicker = await ApiConfig.getSsub('PrintInvPicker'); // Implement this

      if (eTrayMerger == 0) {
        if (workingWithPickupManager == 0) {
          // Call saveMerger API
          await _saveMerger(siId, printInvPicker);
        }
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Your Bill is closed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('🔥 Error handling merger logic: $e');
    }
  }

  // API call to save merger
  Future<void> _saveMerger(int siId, String printSetting) async {
    try {
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final requestBody = {
        'companyid': LoginController.selectedCompanyId.toString(),
        'useas': '7',
        'siid': siId.toString(),
        'branchid': LoginController.selectedBranchId.toString(),
        'empid': loginData?.response?.empId.toString() ?? '',
        'brk': LoginController.selectedFloorId.toString(),
        'settingPrint': printSetting.toString(),
        'appversion': 'V1',
      };

      print("📤 Save Merger API Request URL: ${apiConfig.baseUrl}saveproduct");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveproduct'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print("📥 Save Merger Response status: ${response.statusCode}");
      print("📥 Save Merger Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == '200') {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text('Your Bill is closed'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('🔥 Error saving merger: $e');
    }
  }


  // Show submit button ONLY when ALL items are selected
  bool get shouldShowSubmitButton {
    return pickerDetails.isNotEmpty &&
        selectedDetailIds.length == pickerDetails.length &&
        selectedPickerIndex.value != -1;
  }

  // Get submit button text - always shows "Submit All" since button only appears when all selected
  String get submitButtonText {
    return 'Submit All (${pickerDetails.length})';
  }

  // Show confirmation dialog before submitting
  void showSubmitConfirmationDialog() {
    if (!shouldShowSubmitButton) return;

    final totalCount = pickerDetails.length;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.done_all,
              color: AppTheme.accentGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'Submit All Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.accentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are about to submit all $totalCount items.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone. The submitted items will be processed.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              submitPicker();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Submit All',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}