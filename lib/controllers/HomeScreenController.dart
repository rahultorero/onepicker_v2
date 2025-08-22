import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:onepicker/controllers/LoginController.dart';
import 'dart:convert';

import '../bottomsheets/LocationSelectionBottomSheet.dart';
import '../model/LocationModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';
import '../theme/AppTheme.dart';
import '../view/AdminScreen.dart';
import '../view/PickerScreen.dart';
import '../view/TrayAssignerScreen.dart';

class HomeScreenController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController cardController;
  late AnimationController headerController;
  late List<Animation<Offset>> cardAnimations;
  late Animation<double> headerAnimation;

  var userName = ''.obs;
  var notificationCount = 3.obs;

  // Location related observables
  var isLoadingLocations = false.obs;
  var locations = <LocationData>[].obs;
  var selectedLocation = Rxn<LocationData>();
  static String? selectLocation = "";

  // API configuration
  static const String baseUrl = 'your_base_url_here'; // Replace with your actual base URL

  final List<Map<String, dynamic>> quickServices = [
    {
      'title': 'Admin',
      'subtitle': 'Real Time Labour Monitoring',
      'icon': Icons.computer_sharp,
      'color': AppTheme.primaryBlue,
      'gradient': AppTheme.primaryGradient,
      'isNew': false,
    },
    {
      'title': 'Tray Assigner',
      'subtitle': 'Real Time NST Test Tracking',
      'icon': Icons.assignment_turned_in_outlined,
      'color': AppTheme.purple,
      'gradient': [AppTheme.purple, AppTheme.primaryBlue],
      'isNew': false,
    },
    {
      'title': 'Picker',
      'subtitle': 'Track your BabyBeat NST Test',
      'icon': Icons.delivery_dining_outlined,
      'color': AppTheme.orange,
      'gradient': [AppTheme.orange, AppTheme.gold],
      'isNew': false,
    },
    {
      'title': 'Picker Manager',
      'subtitle': 'Take UTI test and get report instantly',
      'icon': Icons.manage_accounts_rounded,
      'color': AppTheme.medicalTeal,
      'gradient': [AppTheme.medicalTeal, AppTheme.mintGreen],
      'isNew': false,
    },
    {
      'title': 'Checker',
      'subtitle': 'Live ApneBoot Device Monitoring',
      'icon': Icons.fact_check_outlined,
      'color': AppTheme.accent,
      'gradient': AppTheme.accentGradient,
      'isNew': false,
    },
    {
      'title': 'Packer',
      'subtitle': 'Live ApneBoot Device Monitoring',
      'icon': Icons.backpack,
      'color': Color(0xFF199A8E),
      'gradient': AppTheme.primaryGradient,
      'isNew': false,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    setupAnimations();
  }

  void setupAnimations() {
    cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    cardAnimations = List.generate(
      quickServices.length,
          (index) => Tween<Offset>(
        begin: const Offset(0.0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: cardController,
          curve: Interval(
            index * 0.1,
            0.8 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: headerController,
      curve: Curves.easeOutCubic,
    ));

    headerController.forward();
    cardController.forward();
  }

  // API call to fetch locations using HTTP
  Future<void> fetchLocations() async {
    try {
      isLoadingLocations(true);
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}location'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'userid': loginData!.response!.empId.toString(), // Replace with actual user ID from your app state
          'empid': loginData.response!.empId.toString(),  // Replace with actual employee ID
          'branchid': LoginController.selectedBranchId.toString(), // Replace with actual branch ID
          'appversion': 'V1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final locationModel = LocationModel.fromJson(jsonData);

        if (locationModel.status == '200') {
          // Always add "All" as the first option
          locations.assignAll([
            LocationData(loca: 'All Location'),
            ...(locationModel.locationDataList ?? []),
          ]);

          if (locations.isEmpty) {
            Get.snackbar(
              'Info',
              'No locations available',
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              colorText: AppTheme.primaryBlue,
            );
          }
        }
        else {
          Get.snackbar(
            'Error',
            locationModel.message ?? 'Failed to fetch locations',
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
      print('Error fetching locations: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch locations. Please check your internet connection.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingLocations(false);
    }
  }

  // Handle service tap
  void onServiceTap(Map<String, dynamic> service) {
    if (service['title'] == 'Admin') {
      Get.to(() => AdminScreen());
    } else if (service['title'] == 'Tray Assigner') {
      Get.to(() => TrayAssignerScreen());
    } else if (service['title'] == 'Picker') {
      // Show location selection bottom sheet
      showLocationBottomSheet();
    } else {
      Get.snackbar(
        service['title'],
        'Opening ${service['title']}...',
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
        colorText: AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Show location selection bottom sheet
  void showLocationBottomSheet() {
    // Reset selection
    selectedLocation.value = LocationData(loca: 'All Location');

    // Fetch locations first, then show bottom sheet
    fetchLocations().then((_) {
      if (locations.isNotEmpty) {
        Get.bottomSheet(
          LocationSelectionBottomSheet(),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      }
    });
  }

  // Handle next button tap
  void onNextButtonTap() {
    if (selectedLocation.value != null) {
      // Save selected location to static variable
      selectLocation = selectedLocation.value!.loca;
      if(selectLocation == "All Location"){
        selectLocation = 'ZZZ999';
      }

      // Close bottom sheet

      Get.back();
      print(selectLocation);

      // TODO: Navigate to your Picker screen
      Get.to(() => PickerScreen());
    } else {
      Get.snackbar(
        'Warning',
        'Please select a location first',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
    }
  }

  @override
  void onClose() {
    cardController.dispose();
    headerController.dispose();
    super.onClose();
  }
}
