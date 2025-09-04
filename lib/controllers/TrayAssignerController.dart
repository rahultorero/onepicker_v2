import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/SearchFilterListModel.dart';
import '../model/TrayAssignerModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import 'package:http/http.dart' as http;


import 'package:shared_preferences/shared_preferences.dart';



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

  // API parameters
  int companyId = 1;
  int useAs = 1;
  int branchId = 1;
  int empId = 1;
  int brk = 1;
  int settingEIRN = 1;

  // Tray numbers storage for each item
  var itemTrayNumbers = <int, RxList<String>>{}.obs;

  // Error messages for each item
  var itemErrorMessages = <int, RxString>{}.obs;

  // Global scan list (similar to arrScanList in Java)
  var globalScanList = <String>[].obs;

  // Multi-tray setting (0 = single, 1 = multi)
  var multiTraySetting = 1.obs;

  // Mobile Scanner Controller
  MobileScannerController? mobileScannerController;

  @override
  void onInit() {
    super.onInit();
    fetchTrayAssignerList();
    loadGlobalScanList();
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var controller in trayNumberControllers.values) {
      controller.dispose();
    }
    mobileScannerController?.dispose();
    super.onClose();
  }

  void loadGlobalScanList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedList = prefs.getStringList('tray_list') ?? [];
      globalScanList.value = savedList;
    } catch (e) {
      print('Error loading global scan list: $e');
    }
  }

  void saveGlobalScanList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tray_list', globalScanList.value);
    } catch (e) {
      print('Error saving global scan list: $e');
    }
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
        'useas': '6',
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
        Uri.parse('${apiConfig.baseUrl}list_Area'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': LoginController.selectedCompanyId.toString() ?? '0',
          'useas': '6',
          'branchid': LoginController.selectedBranchId.toString() ?? '0',
          'searchtype': searchType,
          'empid': loginData?.response?.empId?.toString() ?? '0',
          'brk': LoginController.selectedFloorId.toString() ?? '0',
          'settingEIRN': settingEIRN.toString(),
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
      if (type == 'ROUTE') {
        type = 'DROUTE';
      }

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}search_invoice'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': LoginController.selectedCompanyId.toString() ?? '0',
          'useas': '6',
          'branchid': LoginController.selectedBranchId.toString() ?? '0',
          'searchtype': type,
          'searchvalue': selectedFilterId.value.toString(),
          'empid': loginData?.response?.empId?.toString() ?? '0',
          'brk': LoginController.selectedFloorId.toString() ?? '0',
          'settingEIRN': settingEIRN.toString(),
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
    if (filterType == 'ROUTE') {
      fetchSearchFilterList('DROUTE');
    } else {
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
              Get.snackbar(
                'Success',
                'Delivery marked for ${item.invNo}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amberGold,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Get tray numbers list for specific item
  TextEditingController getTrayController(int itemId) {
    if (!trayNumberControllers.containsKey(itemId)) {
      trayNumberControllers[itemId] = TextEditingController();
    }
    return trayNumberControllers[itemId]!;
  }

  // Get tray numbers list for specific item
  List<String> getTrayNumbers(int itemId) {
    if (!itemTrayNumbers.containsKey(itemId)) {
      return [];
    }
    return itemTrayNumbers[itemId]!.value;
  }

  // Initialize tray numbers list for specific item
  void _initializeTrayNumbers(int itemId) {
    if (!itemTrayNumbers.containsKey(itemId)) {
      itemTrayNumbers[itemId] = <String>[].obs;
    }
  }

  // Get error message for specific item
  String getErrorMessage(int itemId) {
    return itemErrorMessages[itemId]?.value ?? '';
  }

  // Initialize error message for specific item
  void _initializeErrorMessage(int itemId) {
    if (!itemErrorMessages.containsKey(itemId)) {
      itemErrorMessages[itemId] = ''.obs;
    }
  }

  // Set error message for specific item
  void setErrorMessage(int itemId, String message) {
    _initializeErrorMessage(itemId);
    itemErrorMessages[itemId]!.value = message;
    update(['error_$itemId']);

    if (message.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        if (itemErrorMessages.containsKey(itemId)) {
          itemErrorMessages[itemId]!.value = '';
          update(['error_$itemId']);
        }
      });
    }
  }

  // Format tray number based on length
  String formatTrayNumber(String input) {
    final length = input.length;
    switch (length) {
      case 1:
        return "9000$input";
      case 2:
        return "900$input";
      case 3:
        return "90$input";
      case 4:
        return "9$input";
      case 5:
        return input;
      default:
        return "";
    }
  }

  // Handle tray number input change
  void onTrayNumberChanged(TrayAssignerData item, String value) {
    final itemId = item.sIId ?? 0;

    if (value.length == 5) {
      addTrayNumber(itemId, value);
      getTrayController(itemId).clear();
    }
  }

  // Handle tray number submission
  void onTrayNumberSubmitted(TrayAssignerData item, String value) {
    final itemId = item.sIId ?? 0;
    final formattedValue = formatTrayNumber(value);

    if (formattedValue.isNotEmpty) {
      addTrayNumber(itemId, formattedValue);
      getTrayController(itemId).clear();
    }
  }

  // Add tray number with validation
  void addTrayNumber(int itemId, String trayNumber) {
    _initializeTrayNumbers(itemId);
    final trayList = itemTrayNumbers[itemId]!;

    // Check if already added to current item
    if (trayList.contains(trayNumber)) {
      setErrorMessage(itemId, "This Tray already added.");
      return;
    }

    // Check if already exists in global scan list
    if (globalScanList.contains(trayNumber)) {
      setErrorMessage(itemId, "Tray already exists in system.");
      return;
    }

    // Add to current item's tray list
    trayList.add(trayNumber);

    // Add to global scan list with size limit
    if (globalScanList.length >= 5) {
      globalScanList.removeAt(0);
    }
    globalScanList.add(trayNumber);
    saveGlobalScanList();

    // Clear any error messages
    setErrorMessage(itemId, "");

    // Update UI
    update(['trays_$itemId', 'submit_$itemId']);

    // If single tray mode, auto-submit
    if (multiTraySetting.value == 0) {
      final item = filteredTrayList.firstWhere((element) => element.sIId == itemId);
      handleManualSubmit(item);
    }
  }

  // Remove tray number from list
  void removeTrayNumber(int itemId, String trayNumber) {
    if (itemTrayNumbers.containsKey(itemId)) {
      itemTrayNumbers[itemId]!.remove(trayNumber);
    }
    globalScanList.remove(trayNumber);
    saveGlobalScanList();

    update(['trays_$itemId', 'submit_$itemId']);
  }

  // Clear all tray numbers for item
  void clearTrayNumbers(int itemId) {
    if (itemTrayNumbers.containsKey(itemId)) {
      final trayList = itemTrayNumbers[itemId]!.value;
      for (String tray in trayList) {
        globalScanList.remove(tray);
      }
      itemTrayNumbers[itemId]!.clear();
    }
    saveGlobalScanList();

    update(['trays_$itemId', 'submit_$itemId']);
  }

  // Handle manual submit
  void handleManualSubmit(TrayAssignerData item) async {
    final itemId = item.sIId ?? 0;
    final trayList = getTrayNumbers(itemId);

    if (trayList.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please add at least one tray number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final trayListString = trayList.join(',');
    await postAssignTray(item, trayListString, trayList.length);
  }

  // Post assign tray API call
  Future<void> postAssignTray(TrayAssignerData item, String trayList, int trayCount) async {
    try {
      isLoading(true);

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      final settingPrint = await ApiConfig.getSsub('PrintInvPicker');
      final settingPP = await ApiConfig.getSyn('LListPrint');

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}assign_tray'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': LoginController.selectedCompanyId.toString(),
          'siid': item.sIId.toString(),
          'useas': '6',
          'empid': loginData?.response?.empId?.toString() ?? '0',
          'trayno': trayList,
          'tcount': trayCount.toString(),
          'settingPrint': settingPrint.toString(),
          'settingPP': settingPP.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      print("📩 Assign Tray API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "200") {
          final itemId = item.sIId ?? 0;
          clearTrayNumbers(itemId);

          filteredTrayList.removeWhere((element) => element.sIId == itemId);
          trayAssignerList.removeWhere((element) => element.sIId == itemId);

          final locationInfo = data['response'] != null &&
              data['response'].isNotEmpty
              ? data['response'][0]['LOCA'] ?? ''
              : '';

          if (locationInfo.isNotEmpty) {
            final locations = locationInfo.split(',');
            locations.sort();
            Get.snackbar(
              'Success',
              'Your next location is ${locations.join(', ')}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          } else {
            Get.snackbar(
              'Success',
              'Tray assigned successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to assign tray',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('🔥 postAssignTray error: $e');
      Get.snackbar(
        'Error',
        'Failed to assign tray: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Enhanced QR Scanner with mobile_scanner
  void openQRScannerForItem(TrayAssignerData item) async {
    // Check camera permission first
    bool hasPermission = await _checkCameraPermission();
    if (!hasPermission) {
      await _requestCameraPermission();
      return;
    }

    Get.to(() => EnhancedQRScannerPage(item: item));
  }

  // Check camera permission
  Future<bool> _checkCameraPermission() async {
    try {
      var status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  // Request camera permission
  Future<void> _requestCameraPermission() async {
    try {
      var status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        Get.snackbar(
          'Permission Required',
          'Camera permission is needed to scan QR codes. Please enable it in settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
    }
  }

  // Manual input dialog
  void openManualTrayInput(TrayAssignerData item) {
    final TextEditingController manualController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Enter Tray Number - ${item.invNo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: manualController,
              decoration: const InputDecoration(
                hintText: 'Enter tray number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  final formattedValue = formatTrayNumber(value.trim());
                  if (formattedValue.isNotEmpty) {
                    addTrayNumber(item.sIId ?? 0, formattedValue);
                    Get.back();
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Format: 1-5 digits will be auto-formatted\n(e.g., 123 → 90123)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
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
              final value = manualController.text.trim();
              if (value.isNotEmpty) {
                final formattedValue = formatTrayNumber(value);
                if (formattedValue.isNotEmpty) {
                  addTrayNumber(item.sIId ?? 0, formattedValue);
                  Get.back();
                } else {
                  Get.snackbar(
                    'Invalid Input',
                    'Please enter 1-5 digits',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
            ),
            child: const Text('Add Tray', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Enhanced QR Scanner Page with focused scanning area
class EnhancedQRScannerPage extends StatefulWidget {
  final TrayAssignerData item;

  const EnhancedQRScannerPage({Key? key, required this.item}) : super(key: key);

  @override
  State<EnhancedQRScannerPage> createState() => _EnhancedQRScannerPageState();
}

class _EnhancedQRScannerPageState extends State<EnhancedQRScannerPage>
    with WidgetsBindingObserver {

  late MobileScannerController scannerController;
  final TrayAssignerController trayController = Get.find<TrayAssignerController>();

  bool isFlashOn = false;
  bool isProcessing = false;
  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanningAreaSize = screenSize.width * 0.7; // 70% of screen width

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Mobile Scanner View (background)
          MobileScanner(
            controller: scannerController,
            onDetect: _handleQRScan,
          ),

          // Dark overlay with transparent scanning area
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanAreaSize: scanningAreaSize,
                borderColor: isProcessing ? Colors.orange : AppTheme.primaryTeal,
              ),
            ),
          ),

          // Processing indicator
          if (isProcessing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Top Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      'Scan QR - ${widget.item.invNo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Flash button
                  CircleAvatar(
                    backgroundColor: isFlashOn ? AppTheme.primaryTeal : Colors.black54,
                    child: IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning instruction text
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Position one QR code in the square frame',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Enhanced bottom section with tray list and send button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Instruction text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        isProcessing
                            ? 'Processing QR code...'
                            : 'Scan QR codes one by one or add manually',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Manual input button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => trayController.openManualTrayInput(widget.item),
                              icon: const Icon(Icons.keyboard, size: 18),
                              label: const Text('Manual'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Flash toggle button
                          ElevatedButton.icon(
                            onPressed: _toggleFlash,
                            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, size: 18),
                            label: Text(isFlashOn ? 'Flash On' : 'Flash Off'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFlashOn ? AppTheme.primaryTeal : Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Added tray numbers section
                    GetBuilder<TrayAssignerController>(
                      id: 'trays_${widget.item.sIId}',
                      builder: (controller) {
                        final trayList = controller.getTrayNumbers(widget.item.sIId ?? 0);

                        if (trayList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[800]?.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'No trays added yet',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800]?.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.inventory, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Added Trays (${trayList.length})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (trayList.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => controller.clearTrayNumbers(widget.item.sIId ?? 0),
                                      child: const Icon(
                                        Icons.clear_all,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: trayList.length,
                                  itemBuilder: (context, index) {
                                    final trayNumber = trayList[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.qr_code, color: Colors.white, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              trayNumber,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => controller.removeTrayNumber(
                                              widget.item.sIId ?? 0,
                                              trayNumber,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Send button
                    GetBuilder<TrayAssignerController>(
                      id: 'submit_${widget.item.sIId}',
                      builder: (controller) {
                        final trayList = controller.getTrayNumbers(widget.item.sIId ?? 0);
                        final canSend = trayList.isNotEmpty;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: canSend
                                  ? () {
                                Get.back(); // Close scanner
                                controller.handleManualSubmit(widget.item);
                              }
                                  : null,
                              icon: Icon(
                                Icons.send,
                                color: canSend ? Colors.white : Colors.grey,
                              ),
                              label: Text(
                                canSend
                                    ? 'Send Trays (${trayList.length})'
                                    : 'Add trays to send',
                                style: TextStyle(
                                  color: canSend ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canSend
                                    ? AppTheme.primaryTeal
                                    : Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRScan(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty || isProcessing) return;

    // Get screen center and scanning area bounds
    final screenSize = MediaQuery.of(context).size;
    final scanningAreaSize = screenSize.width * 0.7;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final halfSize = scanningAreaSize / 2;

    // Filter barcodes that are within the scanning area
    Barcode? validBarcode;
    for (final barcode in barcodes) {
      final corners = barcode.corners;
      if (corners != null && corners.isNotEmpty) {
        // Check if barcode center is within scanning area
        double totalX = 0, totalY = 0;
        for (final corner in corners) {
          totalX += corner.dx;
          totalY += corner.dy;
        }
        final barcodeX = totalX / corners.length;
        final barcodeY = totalY / corners.length;

        // Check if barcode is within scanning frame
        if (barcodeX >= (centerX - halfSize) &&
            barcodeX <= (centerX + halfSize) &&
            barcodeY >= (centerY - halfSize) &&
            barcodeY <= (centerY + halfSize)) {
          validBarcode = barcode;
          break;
        }
      }
    }

    if (validBarcode == null) return;

    final scannedValue = validBarcode.displayValue ?? validBarcode.rawValue;

    if (scannedValue == null || scannedValue.isEmpty) return;

    final currentTime = DateTime.now();

    // Debounce: ignore rapid successive scans of the same code
    if (lastScannedCode == scannedValue &&
        lastScanTime != null &&
        currentTime.difference(lastScanTime!).inSeconds < 2) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    lastScannedCode = scannedValue;
    lastScanTime = currentTime;

    try {
      // Vibrate for feedback
      _vibrate();

      // Validate QR code format if needed
      if (_isValidQRCode(scannedValue)) {
        // Process scanned QR
        String processedValue = scannedValue;

        // If it's a short number, format it
        if (scannedValue.length <= 5 && RegExp(r'^\d+$').hasMatch(scannedValue)) {
          processedValue = trayController.formatTrayNumber(scannedValue);
        }

        final existingTrays = trayController.getTrayNumbers(widget.item.sIId ?? 0);
        if (existingTrays.contains(processedValue)) {
          // Tray already exists
          HapticFeedback.mediumImpact();
          Get.snackbar(
            'Already Scanned',
            'Tray $processedValue is already added',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.warning, color: Colors.white),
          );
        }else{
          trayController.addTrayNumber(widget.item.sIId ?? 0, processedValue);

          // Provide haptic feedback for success
          HapticFeedback.lightImpact();

          // Don't close the scanner, let user add more trays or manually send
          Get.snackbar(
            'Success',
            'Tray added: $processedValue',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }


      } else {
        // Invalid QR code
        _showInvalidQRMessage();
      }
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to process QR code: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  bool _isValidQRCode(String code) {
    // Basic validation - not empty and reasonable length
    if (code.trim().isEmpty || code.length > 500) {
      return false;
    }

    // Add more specific validation based on your QR format
    return true;
  }

  void _showInvalidQRMessage() {
    setState(() {
      isProcessing = false;
    });

    HapticFeedback.heavyImpact();
    Get.snackbar(
      'Invalid QR Code',
      'Please scan a valid QR code',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _toggleFlash() async {
    try {
      await scannerController.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
      HapticFeedback.lightImpact();
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  void _vibrate() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore if vibration not available
    }
  }
}

// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color borderColor;

  ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    // Draw dark overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Calculate scanner frame position
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    // Clear the scanning area
    final clearPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(12),
      ),
      clearPaint,
    );

    // Draw border around scanning area
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Draw corner decorations
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 25.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left - 2, top + cornerLength),
      Offset(left - 2, top - 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left - 2, top - 2),
      Offset(left + cornerLength, top - 2),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top - 2),
      Offset(left + scanAreaSize + 2, top - 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize + 2, top - 2),
      Offset(left + scanAreaSize + 2, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left - 2, top + scanAreaSize - cornerLength),
      Offset(left - 2, top + scanAreaSize + 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left - 2, top + scanAreaSize + 2),
      Offset(left + cornerLength, top + scanAreaSize + 2),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize + 2),
      Offset(left + scanAreaSize + 2, top + scanAreaSize + 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize + 2, top + scanAreaSize + 2),
      Offset(left + scanAreaSize + 2, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}


