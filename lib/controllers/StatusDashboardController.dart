import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'package:onepicker/model/StatusApiResponse.dart';

// controllers/status_dashboard_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/services.dart';

class StatusDashboardController extends GetxController with GetTickerProviderStateMixin {
  // Observable variables
  final RxList<DataItem> DataItemList = <DataItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;
  final RxInt totalInvoices = 0.obs;
  final RxInt totalDeliveryDone = 0.obs;
  final RxInt totalDeliveryPending = 0.obs;
  final RxBool hasData = false.obs;
  final RxString errorMessage = ''.obs;
  RxBool showPickerManager = false.obs;


  // Animation controllers
  late AnimationController barChartAnimationController;
  late AnimationController pieChartAnimationController;
  late AnimationController cardAnimationController;
  late AnimationController listAnimationController;

  // Animations
  late Animation<double> barChartAnimation;
  late Animation<double> pieChartAnimation;
  late Animation<double> cardAnimation;
  late Animation<double> listAnimation;

  // Constants
  final dateFormat = DateFormat('yyyy-MM-dd');

  // User credentials - Get these from SharedPreferences or secure storage
  String get selectedCompanyID => "1"; // Replace with actual company ID
  String get selectedBranchID => "1";  // Replace with actual branch ID

  @override
  void onInit() {
    super.onInit();
    loadData();

    _initializeAnimations();
    _setDefaultDates();
    fetchDashboardData();
  }

  Future<void> loadData() async {
    // Get original data

    // Check condition
    final workingWithPickupManagerbool = await ApiConfig.getSyn('WorkingWithPickupManager');
    showPickerManager.value = workingWithPickupManagerbool != 0;

  }

  // In StatusDashboardController
  List<DataItem> getFilteredDataItems() {


    if (showPickerManager.value) {
      return DataItemList;
    }

    final filtered = DataItemList.where((item) {
      final status = item.status?.toLowerCase() ?? '';
      final shouldRemove = status.contains('picker manager');
      // print('🔍 Status: $status, Contains picker manager: $shouldRemove');
      return !shouldRemove;
    }).toList();

    return filtered;
  }

  void _initializeAnimations() {
    // Bar chart animation
    barChartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    barChartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: barChartAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Pie chart animation
    pieChartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    pieChartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pieChartAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Card animation
    cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // List animation
    listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: listAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    fromDate.value = dateFormat.format(now);
    toDate.value = dateFormat.format(now);
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFormat.parse(fromDate.value),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = dateFormat.format(picked);
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFormat.parse(toDate.value),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      toDate.value = dateFormat.format(picked);
    }
  }

  bool validateDateRange() {
    final from = dateFormat.parse(fromDate.value);
    final to = dateFormat.parse(toDate.value);
    return !from.isAfter(to);
  }

  Future<void> fetchDashboardData() async {
    if (!validateDateRange()) {
      Get.snackbar(
        'Invalid Date Range',
        'From date cannot be after To date',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    hasData.value = false;
    errorMessage.value = '';

    try {
      // Reset animations
      barChartAnimationController.reset();
      pieChartAnimationController.reset();
      cardAnimationController.reset();
      listAnimationController.reset();

      // Prepare request body
      final Map<String, String> requestBody = {
        'pFmDate': fromDate.value,
        'pToDate': toDate.value,
        'CompanyId': LoginController.selectedCompanyId.toString(),
        'BrchId': LoginController.selectedBranchId.toString(),
      };

      print('API Request - Body: $requestBody');

      final apiConfig = await ApiConfig.load();


      // Make HTTP POST request
      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}status'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Please check your internet connection');
        },
      );

      print('API Response - Status Code: ${response.statusCode}');
      print('API Response - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final StatusApiResponse apiResponse = StatusApiResponse.fromJson(jsonResponse);

        if (apiResponse.status == "200") {
          _processApiResponse(apiResponse);

          if (hasData.value) {
            // Start animations sequentially
            await cardAnimationController.forward();
            await Future.delayed(const Duration(milliseconds: 200));

            barChartAnimationController.forward();
            pieChartAnimationController.forward();
            listAnimationController.forward();
          }


        } else {
          throw Exception(apiResponse.message!.isNotEmpty
              ? apiResponse.message
              : 'Failed to fetch data from server');
        }

      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }

    } catch (e) {
      print('API Error: $e');
      errorMessage.value = e.toString();

      // Show user-friendly error message
      String userMessage = 'Failed to fetch data';
      if (e.toString().contains('timeout')) {
        userMessage = 'Request timeout - Please check your internet connection';
      } else if (e.toString().contains('SocketException')) {
        userMessage = 'No internet connection - Please check your network';
      } else if (e.toString().contains('FormatException')) {
        userMessage = 'Invalid response from server';
      } else if (e.toString().contains('Server error')) {
        userMessage = 'Server is temporarily unavailable';
      }

      Get.snackbar(
        'Error',
        userMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );

    } finally {
      isLoading.value = false;
    }
  }

  void _processApiResponse(StatusApiResponse apiResponse) {
    DataItemList.clear();

    int totalInvoicesCount = 0;
    int totalDeliveryDoneCount = 0;
    int totalDeliveryPendingCount = 0;

    if (apiResponse.data!.isNotEmpty) {
      DataItemList.addAll(apiResponse.data!);

      // Calculate totals
      totalInvoicesCount = apiResponse.data!.first.noInvoice!;

      // Find delivery data
      final deliveryData = apiResponse.data!.firstWhere(
            (item) => item.status!.toLowerCase() == 'delivery',
        orElse: () => DataItem(status: '', noInvoice: 0, done: 0, pend: 0),
      );

      totalDeliveryDoneCount = deliveryData.done!;
      totalDeliveryPendingCount = deliveryData.pend!;

      hasData.value = true;
      print('Processed ${DataItemList.length} status items');

    } else {
      hasData.value = false;
      print('No data received from API');
    }

    // Update summary data
    totalInvoices.value = totalInvoicesCount;
    totalDeliveryDone.value = totalDeliveryDoneCount;
    totalDeliveryPending.value = totalDeliveryPendingCount;

    print('Summary - Total: $totalInvoicesCount, Done: $totalDeliveryDoneCount, Pending: $totalDeliveryPendingCount');
  }

  int getStageValue(int index) {
    if (index == 0 || DataItemList.isEmpty) return 0;
    if (index >= DataItemList.length) return 0;

    final previousDone = DataItemList[index - 1].done;
    final currentDone = DataItemList[index].done;
    return previousDone! - currentDone!;
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  // Clear data
  void clearData() {
    DataItemList.clear();
    totalInvoices.value = 0;
    totalDeliveryDone.value = 0;
    totalDeliveryPending.value = 0;
    hasData.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    barChartAnimationController.dispose();
    pieChartAnimationController.dispose();
    cardAnimationController.dispose();
    listAnimationController.dispose();
    super.onClose();
  }
}