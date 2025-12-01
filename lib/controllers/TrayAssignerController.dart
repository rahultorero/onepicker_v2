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
  var nextItemIdForScanner = Rxn<int>(); // Nullable Rx for next item ID
  // Individual tray number controllers for each item
  var trayNumberControllers = <int, TextEditingController>{}.obs;
  var trayFocusNodes = <int, FocusNode>{}.obs;

  // ADD THIS: ScrollController to maintain scroll position
  ScrollController scrollController = ScrollController();

  // ADD THIS: Map to track item positions for scrolling
  var itemKeys = <int, GlobalKey>{}.obs;


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
    loadMultiTraySetting();
  }

  void loadMultiTraySetting() async {
    final trayValue = await ApiConfig.getSyn("MultiTray");
    print("MultiTray setting loaded: ${trayValue}");

    multiTraySetting.value = int.tryParse(trayValue.toString())!;
    print("MultiTray setting loaded: ${multiTraySetting.value}");
  }

  @override
  void onClose() {
    // Dispose all controllers and focus nodes
    for (var controller in trayNumberControllers.values) {
      controller.dispose();
    }
    for (var focusNode in trayFocusNodes.values) {
      focusNode.dispose();
    }
    scrollController.dispose(); // ADD THIS
    mobileScannerController?.dispose();
    super.onClose();
  }

  // Add this method to get GlobalKey for each item
  GlobalKey getItemKey(int itemId) {
    if (!itemKeys.containsKey(itemId)) {
      itemKeys[itemId] = GlobalKey();
    }
    return itemKeys[itemId]!;
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

  TextEditingController getTrayController(int itemId) {
    if (!trayNumberControllers.containsKey(itemId)) {
      trayNumberControllers[itemId] = TextEditingController();
    }

    // Also create focus node if not exists
    if (!trayFocusNodes.containsKey(itemId)) {
      trayFocusNodes[itemId] = FocusNode();
    }

    return trayNumberControllers[itemId]!;
  }

  // Add getter for focus node
  FocusNode getTrayFocusNode(int itemId) {
    if (!trayFocusNodes.containsKey(itemId)) {
      trayFocusNodes[itemId] = FocusNode();
    }
    return trayFocusNodes[itemId]!;
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

      final trayValue = await ApiConfig.getSyn("MultiTray");
      print("check the trayy valuess ${trayValue}");

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

          focusFirstAvailableItem();

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

    if (searchType.trim().toLowerCase() == "all") {
      print("✅ Matched condition: searchType == 'All'");
      fetchTrayAssignerList();
      return;
    }

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
          searchWithFilter();
        } else {
          Get.snackbar('Error', filterResponse.message ?? 'Failed to load filters');
        }
      }
    } catch (e, s) {
      print('🔥 fetchSearchFilterList error: $e');
      print('📌 Stacktrace: $s');
    } finally {
      isSearchLoading(false);
    }
  }

  void _logKeyboardState(String location) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardVisible = MediaQuery.of(Get.context!).viewInsets.bottom > 0;
      print("⌨️ [$location] Keyboard visible: $keyboardVisible");
    });
  }


  void _scrollToItemAndFocus(TrayAssignerData item, int itemIndex) {
    final itemId = item.sIId ?? 0;

    print("📜 ========== START _scrollToItemAndFocus ==========");
    print("📜 Item index: $itemIndex, itemId: $itemId");

    // STEP 1: Focus FIRST (before any scrolling)
    final nextFocusNode = getTrayFocusNode(itemId);
    print("🔍 Requesting focus for $itemId BEFORE scroll");

    nextFocusNode.requestFocus();

    // Give focus a moment to take effect
    Future.delayed(const Duration(milliseconds: 100), () {
      print("✅ Focus should be set, now scrolling...");
      _logKeyboardState("After focus, before scroll");

      // STEP 2: Now scroll (keyboard should stay open because field has focus)
      if (scrollController.hasClients) {
        final screenWidth = Get.width;
        final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);
        final rowIndex = (itemIndex / crossAxisCount).floor();

        const double estimatedItemHeight = 200.0;
        const double spacing = 16.0;

        final double targetScrollPosition = (rowIndex * (estimatedItemHeight + spacing)) + 16;
        final maxScroll = scrollController.position.maxScrollExtent;
        final targetPosition = targetScrollPosition.clamp(0.0, maxScroll);

        print("📍 Scrolling to position: $targetPosition (row: $rowIndex)");

        // Use jumpTo instead of animateTo to avoid keyboard closing
        scrollController.jumpTo(targetPosition);

        print("📍 Scroll completed (instant jump)");
        _logKeyboardState("After scroll complete");
      }
    });

    print("📜 ========== END _scrollToItemAndFocus ==========");
  }


  // Add this method to focus first non-hold item
// Add this method to focus first non-hold item WITH SCROLLING
  void focusFirstAvailableItem() {
    print("🎯 Attempting to focus first available item...");

    // Find first non-hold item
    TrayAssignerData? firstAvailable;
    int firstAvailableIndex = -1;

    for (int i = 0; i < filteredTrayList.length; i++) {
      final item = filteredTrayList[i];
      final isOnHold = item.hold ?? false;
      if (!isOnHold) {
        firstAvailable = item;
        firstAvailableIndex = i;
        print("✅ Found first available item: ${item.invNo} (${item.sIId}) at index $i");
        break;
      }
    }

    // Focus and scroll to it if found
    if (firstAvailable != null && firstAvailableIndex >= 0) {
      final itemId = firstAvailable.sIId ?? 0;

      // Delay to ensure UI is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        // Focus first
        final focusNode = getTrayFocusNode(itemId);
        if (focusNode.canRequestFocus) {
          focusNode.requestFocus();
          print("✅ Focused first available item: $itemId");

          // Then scroll to it
          if (scrollController.hasClients) {
            final screenWidth = Get.width;
            final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);
            final rowIndex = (firstAvailableIndex / crossAxisCount).floor();

            const double estimatedItemHeight = 200.0;
            const double spacing = 16.0;

            final double targetScrollPosition = (rowIndex * (estimatedItemHeight + spacing)) + 16;
            final maxScroll = scrollController.position.maxScrollExtent;
            final targetPosition = targetScrollPosition.clamp(0.0, maxScroll);

            print("📍 Scrolling to first item position: $targetPosition (row: $rowIndex)");

            // Instant scroll to avoid keyboard issues
            scrollController.jumpTo(targetPosition);

            print("📍 Scrolled to first available item");
          }
        } else {
          print("❌ Cannot focus first item: $itemId");
        }
      });
    } else {
      print("⚠️ No available items to focus (all on hold)");
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

          focusFirstAvailableItem();

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
  // Handle tray number submission
  void onTrayNumberSubmitted(TrayAssignerData item, String value) {
    final itemId = item.sIId ?? 0;
    final formattedValue = formatTrayNumber(value);

    if (formattedValue.isNotEmpty) {
      addTrayNumber(itemId, formattedValue);
      getTrayController(itemId).clear();

      // IMPORTANT: Don't let focus move yet if in single tray mode
      // The controller will handle it after API completes
    }
  }

  // Add tray number with validation
// Add tray number with validation
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
      print("alreadyyy addeddd");

      // Show snackbar
      Get.snackbar(
        'Already Added',
        'Tray $trayNumber already exists in system.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.warning, color: Colors.white),
      );

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

    // FIXED: Check for single tray mode (0), auto-submit immediately
    if (multiTraySetting.value == 0) {
      // REMOVED: Don't unfocus - keep keyboard open
      // final currentFocusNode = getTrayFocusNode(itemId);
      // if (currentFocusNode.hasFocus) {
      //   currentFocusNode.unfocus();
      // }

      final item = filteredTrayList.firstWhere((element) => element.sIId == itemId);

      // Shorter delay since we're not waiting for keyboard
      Future.delayed(const Duration(milliseconds: 50), () {
        _autoSubmitSingleTray(item);
      });
    }
  }


  void _autoSubmitSingleTray(TrayAssignerData item) async {
    print("🎯 ========== START _autoSubmitSingleTray ==========");
    final itemId = item.sIId ?? 0;
    final trayList = getTrayNumbers(itemId);

    _logKeyboardState("Start of _autoSubmitSingleTray");

    if (trayList.isNotEmpty) {
      // Store current index BEFORE API call
      final currentIndex = filteredTrayList.indexWhere((e) => e.sIId == itemId);

      print("🔍 Current item index: $currentIndex, itemId: $itemId, invNo: ${item.invNo}");

      // Store the sIId of the next non-hold item BEFORE API removes current item
      int? nextItemId;
      int nextItemIndex = -1;
      for (int i = currentIndex + 1; i < filteredTrayList.length; i++) {
        final candidate = filteredTrayList[i];
        final isOnHold = candidate.hold ?? false;

        if (!isOnHold) {
          nextItemId = candidate.sIId;
          nextItemIndex = i;
          print("✅ Found next item at index $i: itemId=${candidate.sIId}, invNo=${candidate.invNo}");
          break;
        } else {
          print("⏭️ Skipping on-hold item at index $i: itemId=${candidate.sIId}, invNo=${candidate.invNo}");
        }
      }

      nextItemIdForScanner.value = nextItemId;
      print("📝 Stored nextItemId for scanner: $nextItemId");

      final trayListString = trayList.join(',');
      print("📤 Calling API to assign tray for item: $itemId");

      _logKeyboardState("Before postAssignTray call");

      // Call the API (this will remove current item from list)
      final isLastItem = await postAssignTray(item, trayListString, trayList.length);

      print("✅ API completed. List size now: ${filteredTrayList.length}");
      _logKeyboardState("After postAssignTray completed");

      // Check if list is empty FIRST
      if (filteredTrayList.isEmpty) {
        print("✅ No more items in list, closing screen");
        nextItemIdForScanner.value = null;
        await Future.delayed(const Duration(seconds: 2));
        return;
      }

      // List is not empty, find next item to focus AND scroll
      if (nextItemId != null) {
        TrayAssignerData? nextItem;
        int actualNextIndex = -1;

        try {
          nextItem = filteredTrayList.firstWhere((e) => e.sIId == nextItemId);
          actualNextIndex = filteredTrayList.indexWhere((e) => e.sIId == nextItemId);
        } catch (e) {
          nextItem = null;
        }

        if (nextItem != null && actualNextIndex >= 0) {
          print("✅ Found next item by ID: ${nextItem.invNo} (${nextItem.sIId}) at index $actualNextIndex");
          print("🎯 About to call _scrollToItemAndFocus");
          _logKeyboardState("Before _scrollToItemAndFocus call");

          // Scroll to the item and focus (keyboard stays open)
          _scrollToItemAndFocus(nextItem, actualNextIndex);

          print("🎯 ========== END _autoSubmitSingleTray ==========");
          return;
        }
      }

      print("⚠️ Original next item not found, finding any non-hold item");
      _handleNoNextItemWithScroll();
    }
  }

  void _handleNoNextItemWithScroll() {
    // Find any available non-hold item
    TrayAssignerData? firstAvailable;
    int firstAvailableIndex = -1;

    for (int i = 0; i < filteredTrayList.length; i++) {
      final item = filteredTrayList[i];
      final isOnHold = item.hold ?? false;
      if (!isOnHold) {
        firstAvailable = item;
        firstAvailableIndex = i;
        print("✅ First available item: ${firstAvailable.invNo} at index $i");
        break;
      }
    }

    if (firstAvailable != null && firstAvailableIndex >= 0) {
      nextItemIdForScanner.value = firstAvailable.sIId;
      _scrollToItemAndFocus(firstAvailable, firstAvailableIndex);
    } else {
      // All items are on hold, but DON'T close the screen
      print("⚠️ All remaining items are on hold, but keeping screen open");
      nextItemIdForScanner.value = null;

      Get.snackbar(
        'Info',
        'All remaining items are on hold',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _focusSpecificItem(TrayAssignerData item) {
    final itemId = item.sIId ?? 0;

    Future.delayed(const Duration(milliseconds: 300), () {
      final focusNode = getTrayFocusNode(itemId);

      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
        print("✅ Focus requested for item: $itemId");

        // Scroll to this item if needed (optional - helps user see the focused item)
        // You can add scrolling logic here if you have a ScrollController
      } else {
        print("❌ Cannot request focus for item: $itemId");
      }
    });
  }

  void _focusNextItem() {
    // Find the next item in the filtered list
    if (filteredTrayList.isNotEmpty) {
      final nextItem = filteredTrayList.first;
      final nextItemId = nextItem.sIId ?? 0;

      // Focus on the next item's tray focus node
      final nextFocusNode = getTrayFocusNode(nextItemId);

      // Use Future.delayed to ensure the UI has updated before requesting focus
      Future.delayed(const Duration(milliseconds: 500), () {
        if (nextFocusNode.canRequestFocus) {
          nextFocusNode.requestFocus();
        }
      });
    } else {
      // Just close - DON'T refresh
      Get.back();
      // REMOVED: fetchSearchFilterList(selectedFilterType.value);
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
// Update postAssignTray with logs:
  Future<bool> postAssignTray(TrayAssignerData item, String trayList, int trayCount) async {
    try {
      print("🚀 ========== START postAssignTray ==========");
      _logKeyboardState("Start of postAssignTray");

      isLoading(true);

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      final settingPrint = await ApiConfig.getSsub('PrintInvPicker');
      final settingPP = await ApiConfig.getSyn('LListPrint');

      print("📤 Calling API...");
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

      print("📩 API Response received");
      _logKeyboardState("After API response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "200") {
          final itemId = item.sIId ?? 0;

          print("🗑️ Removing item from lists...");
          _logKeyboardState("Before list removal");

          filteredTrayList.removeWhere((element) => element.sIId == itemId);
          trayAssignerList.removeWhere((element) => element.sIId == itemId);

          print("🗑️ Item removed from lists");
          _logKeyboardState("After list removal");

          final locationInfo = data['response'] != null &&
              data['response'].isNotEmpty
              ? data['response'][0]['LOCA'] ?? ''
              : '';

          print("📢 Preparing to show SnackBar...");
          _logKeyboardState("Before SnackBar");

          if (locationInfo.isNotEmpty) {
            final locations = locationInfo.split(',');
            locations.sort();

            final context = Get.context;
            if (context != null) {
              print("📢 Showing location SnackBar");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your next location is ${locations.join(', ')}',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );

              // Check keyboard after snackbar
              Future.delayed(const Duration(milliseconds: 100), () {
                _logKeyboardState("100ms after SnackBar shown");
              });
            }
          } else {
            final context = Get.context;
            if (context != null) {
              print("📢 Showing success SnackBar");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tray assigned successfully',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );

              Future.delayed(const Duration(milliseconds: 100), () {
                _logKeyboardState("100ms after success SnackBar shown");
              });
            }
          }

          print("🚀 ========== END postAssignTray (SUCCESS) ==========");
          return filteredTrayList.isEmpty;
        } else {
          print("❌ API returned error status");
          final context = Get.context;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Failed to assign tray'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      }
    } catch (e) {
      print('🔥 postAssignTray error: $e');
      _logKeyboardState("After error");

      final context = Get.context;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign tray: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print("🏁 postAssignTray finally block");
      _logKeyboardState("In finally block");
      isLoading(false);
    }

    return false;
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
                  Get.back();

                  Future.delayed(const Duration(milliseconds: 500), () {
                    addTrayNumber(item.sIId ?? 0, formattedValue);
                  });

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
// Enhanced QR Scanner Page with focused scanning area
class EnhancedQRScannerPage extends StatefulWidget {
  TrayAssignerData item;

  EnhancedQRScannerPage({Key? key, required this.item}) : super(key: key);

  @override
  State<EnhancedQRScannerPage> createState() => _EnhancedQRScannerPageState();
}

class _EnhancedQRScannerPageState extends State<EnhancedQRScannerPage>
    with WidgetsBindingObserver {

  late MobileScannerController scannerController;
  final TrayAssignerController trayController = Get.find<TrayAssignerController>();

  late Rx<TrayAssignerData> currentItem;

  bool isFlashOn = false;
  bool isProcessing = false;
  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item.obs; // Initialize with the passed item

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
    final scanningAreaSize = screenSize.width * 0.7;

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
                    child: Obx(() => Text(
                      'Scan QR - ${currentItem.value.invNo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
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
            top: MediaQuery.of(context).size.height * 0.21,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position one QR code in the square frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Enhanced bottom section - SCROLLABLE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.33,
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

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Invoice Details Card - MOVED TO TOP
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Obx(() {
                                final item = currentItem.value;
                                final deliveryType = item.delType ?? '';
                                final cardColors = _getDeliveryTypeColors(deliveryType);

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[850]!.withOpacity(0.95),
                                        Colors.grey[900]!.withOpacity(0.95),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: cardColors['primary']!.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header Row - Compact
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: cardColors['primary'],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              deliveryType,
                                              style: TextStyle(
                                                color: cardColors['primaryText'],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.invNo ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            ApiConfig.dateConvert(item.invDate) ?? '',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Party Name - Compact
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.business_rounded,
                                              size: 12,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.party ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // Location and Sales Rep - Compact
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  size: 10,
                                                  color: AppTheme.coralPink.withOpacity(0.8),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${item.area ?? ''} ${item.city ?? ''}',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person_rounded,
                                                  size: 10,
                                                  color: AppTheme.sage.withOpacity(0.8),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.sman ?? '',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // Items Count - Compact
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.info.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.inventory_outlined,
                                              size: 10,
                                              color: AppTheme.info,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item.lItem ?? 0} Items',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // Action buttons row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [

                                  ElevatedButton.icon(
                                    onPressed: _toggleFlash,
                                    icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, size: 16),
                                    label: Text(isFlashOn ? 'On' : 'Off', style: const TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFlashOn ? AppTheme.primaryTeal : Colors.grey[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tray numbers section
                            Obx(() => GetBuilder<TrayAssignerController>(
                              id: 'trays_${currentItem.value.sIId}',
                              builder: (controller) {
                                final trayList = controller.getTrayNumbers(currentItem.value.sIId ?? 0);

                                if (trayList.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800]?.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.grey, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'No trays added yet',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  constraints: const BoxConstraints(maxHeight: 100),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800]?.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.inventory, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Trays (${trayList.length})',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (trayList.isNotEmpty)
                                            GestureDetector(
                                              onTap: () => controller.clearTrayNumbers(currentItem.value.sIId ?? 0),
                                              child: const Icon(Icons.clear_all, color: Colors.red, size: 18),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: trayList.length,
                                          itemBuilder: (context, index) {
                                            final trayNumber = trayList[index];
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 3),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryTeal.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.qr_code, color: Colors.white, size: 14),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      trayNumber,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () => controller.removeTrayNumber(
                                                      currentItem.value.sIId ?? 0,
                                                      trayNumber,
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(3),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 10,
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
                            )),

                            const SizedBox(height: 12),

                            // Send button
                            Obx(() => GetBuilder<TrayAssignerController>(
                              id: 'submit_${currentItem.value.sIId}',
                              builder: (controller) {
                                final trayList = controller.getTrayNumbers(currentItem.value.sIId ?? 0);
                                final canSend = trayList.isNotEmpty;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: canSend
                                          ? () {
                                        Get.back();
                                        controller.handleManualSubmit(currentItem.value);
                                      }
                                          : null,
                                      icon: Icon(
                                        Icons.send,
                                        color: canSend ? Colors.white : Colors.grey,
                                        size: 18,
                                      ),
                                      label: Text(
                                        canSend ? 'Send Trays (${trayList.length})' : 'Add trays to send',
                                        style: TextStyle(
                                          color: canSend ? Colors.white : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: canSend ? AppTheme.primaryTeal : Colors.grey[700],
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


// Add this helper method at the bottom of your _EnhancedQRScannerPageState class
  Map<String, dynamic> _getDeliveryTypeColors(String deliveryType) {
    switch (deliveryType.toUpperCase()) {
      case 'URGENT':
        return {
          'primary': AppTheme.error,
          'primaryText': Colors.white,
        };
      case 'PICK-UP':
        return {
          'primary': AppTheme.success,
          'primaryText': Colors.white,
        };
      case 'DELIVERY':
        return {
          'primary': AppTheme.amberGold,
          'primaryText': Colors.white,
        };
      case 'MEDREP':
        return {
          'primary': AppTheme.warning,
          'primaryText': Colors.white,
        };
      case 'COD':
        return {
          'primary': AppTheme.lavender,
          'primaryText': Colors.white,
        };
      case 'OUTSTATION':
        return {
          'primary': AppTheme.info,
          'primaryText': Colors.white,
        };
      default:
        return {
          'primary': AppTheme.primaryTeal,
          'primaryText': Colors.white,
        };
    }
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

        final existingTrays = trayController.getTrayNumbers(currentItem.value.sIId ?? 0);
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
        } else {
          // Add tray number - this will trigger auto-submit if single tray mode
          trayController.addTrayNumber(currentItem.value.sIId ?? 0, processedValue);

          // Provide haptic feedback for success
          HapticFeedback.lightImpact();

          // Check if single tray mode for continuous scanning
          if (trayController.multiTraySetting.value == 0) {
            // Wait for API and list update, then switch to next item in scanner
            await _waitForControllerToFinish();
          } else {
            // Multi-tray mode - show success message
            Get.snackbar(
              'Success',
              'Tray added: $processedValue',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
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

// NEW METHOD: Just wait for controller and update UI
// NEW METHOD: Just wait for controller and sync with its decision
  Future<void> _waitForControllerToFinish() async {
    print("🔄 Waiting for controller to finish API call...");

    // Wait for API to complete
    while (trayController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print("✅ Controller finished. Checking for next item...");

    // Small delay for UI update
    await Future.delayed(const Duration(milliseconds: 200));

    // Get the next item ID that controller decided on
    final nextItemId = trayController.nextItemIdForScanner.value;

    print("📝 Scanner received nextItemId: $nextItemId");

    if (nextItemId != null) {
      // Find this specific item in the list
      TrayAssignerData? nextItem;
      try {
        nextItem = trayController.filteredTrayList.firstWhere((e) => e.sIId == nextItemId);

        setState(() {
          currentItem.value = nextItem!;
          widget.item = nextItem;
        });

        print("✅ QR Scanner synced to controller's decision: ${nextItem.invNo} (ID: ${nextItem.sIId})");
      } catch (e) {
        print("❌ Next item $nextItemId not found in list, closing scanner");
        Get.back();
      }
    } else {
      // No next item, close scanner
      print("✅ No more items, closing scanner");
      Get.back();
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
    final double scanAreaLeft = (size.width - scanAreaSize) / 2;
    final double scanAreaTop = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(
      scanAreaLeft,
      scanAreaTop,
      scanAreaSize,
      scanAreaSize,
    );

    // Draw dark overlay AROUND the scanning area, not over it
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanArea)
      ..fillType = PathFillType.evenOdd; // THIS IS CRITICAL

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // Draw the border around scanning area
    canvas.drawRect(
      scanArea,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.borderColor != borderColor;
  }
}

