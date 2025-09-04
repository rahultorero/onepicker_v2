import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:onepicker/bottomsheets/LsnSelectionBottomSheet.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'package:onepicker/model/LSNModel.dart';
import 'package:onepicker/view/CheckerScreen.dart';
import 'package:onepicker/view/MergerScreen.dart';
import 'package:onepicker/view/PackerScreen.dart';
import 'package:onepicker/view/PickerManager.dart';
import 'dart:convert';

import '../bottomsheets/LocationSelectionBottomSheet.dart';
import '../bottomsheets/PrinterSelectionBottomSheet.dart';
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
  var lsns = <LSNList>[].obs;

  var selectedLocation = Rxn<LocationData>();
  var selectedLsn =  Rxn<LSNList>();
  static String? selectLsn = '';
  static String? selectLocation = "";
  static String? selectPrinter = '';
  static String? selectCamera = '';


  final List<Map<String, dynamic>> quickServices = [
    {
      'title': 'Admin',
      'subtitle': 'Manage users, roles & settings',
      'icon': Icons.computer_sharp,
      'color': AppTheme.primaryTeal,
      'gradient': AppTheme.primaryGradient,
      'isNew': false,
    },
    {
      'title': 'Tray Assigner',
      'subtitle': 'Assign trays for seamless order flow',
      'icon': Icons.assignment_turned_in_outlined,
      'color': AppTheme.lavender,
      'gradient': AppTheme.lavenderGradient,
      'isNew': false,
    },
    {
      'title': 'Picker',
      'subtitle': 'Pick items quickly & accurately',
      'icon': Icons.delivery_dining_outlined,
      'color': AppTheme.amberGold,
      'gradient': AppTheme.bronzeGradient,
      'isNew': false,
    },
    {
      'title': 'Picker Manager',
      'subtitle': 'Monitor and manage picking process',
      'icon': Icons.manage_accounts_rounded,
      'color': AppTheme.primaryTeal,
      'gradient': AppTheme.coolGradient,
      'isNew': false,
    },
    {
      'title': 'Checker',
      'subtitle': 'Verify items before dispatch',
      'icon': Icons.fact_check_outlined,
      'color': AppTheme.accentGreen,
      'gradient': AppTheme.accentGradient,
      'isNew': false,
    },
    {
      'title': 'Packer',
      'subtitle': 'Pack orders securely & efficiently',
      'icon': Icons.backpack,
      'color': const Color(0xFF199A8E),
      'gradient': AppTheme.primaryGradient,
      'isNew': false,
    },
    {
      'title': 'Merger',
      'subtitle': 'Combine multiple orders into one',
      'icon': Icons.merge_type_rounded,
      'color': Colors.deepPurple,
      'gradient': AppTheme.lavenderGradient,
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
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
              colorText: AppTheme.primaryTeal,
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

  Future<void> fetchLsn() async {
    try {
      isLoadingLocations(true);

      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();
      if (loginData?.response?.empId == null) {
        Get.snackbar(
          'Error',
          'Invalid user. Please login again.',
          backgroundColor: Colors.red.withOpacity(0.2),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}lsn'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': loginData!.response!.empId.toString(),
          'empid': loginData.response!.empId.toString(),
          'companyid': LoginController.selectedCompanyId.toString(),
          'branchid': LoginController.selectedBranchId.toString(),
          'appversion': 'V1',
        },
      );

      print("🌍 [FETCH LSN] Status => ${response.statusCode}");
      print("🌍 [FETCH LSN] Body => ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final lsnModel = LSNModel.fromJson(jsonData);

        if (lsnModel.status == '200') {
          final data = lsnModel.response ?? [];

          // Create "All LSN" entry
          final allLsn = LSNList(lsn: "All LSN");

          // Add it as the first item
          lsns.assignAll([allLsn, ...data]);
        } else {
          Get.snackbar(
            'Error',
            lsnModel.message ?? 'Failed to fetch LSN data',
            backgroundColor: Colors.red.withOpacity(0.2),
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          backgroundColor: Colors.red.withOpacity(0.2),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e, stack) {
      print("🔥 [FETCH LSN] Exception => $e");
      print("🔥 [FETCH LSN] Stacktrace => $stack");
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
    }else if (service['title'] == 'Picker Manager') {
      // Show location selection bottom sheet
      showLsnBottomSheet();
    } else if (service['title'] == 'Packer') {
      Get.to(() => PackerScreen());
    }else if (service['title'] == 'Checker') {
      _showPrinterSelection(Get.context!);
    }else if (service['title'] == 'Merger') {
      Get.to(() => MergerScreen());
    } else {
      Get.snackbar(
        service['title'],
        'Opening ${service['title']}...',
        backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
        colorText: AppTheme.primaryTeal,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void showLsnBottomSheet() {

    selectedLsn.value = LSNList(lsn: 'All LSN');


    // Fetch locations first, then show bottom sheet
    fetchLsn().then((_) {
      if (lsns.isNotEmpty) {
        Get.bottomSheet(
          LsnSelectionBottomSheet(),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      }
    });
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


  void _showPrinterSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrinterSelectionBottomSheet(),
    ).then((result) {
      if (result != null) {
        // Handle the result
        final position = result['position'];
        final camera = result['camera'];

        selectPrinter = position;
        selectCamera = camera;

        Get.to(CheckerScreen());

      }
    });
  }

  // Handle next button tap

  void managerButtonTap(){
    if (selectedLsn.value != null) {
      // Save selected location to static variable
      selectLsn = selectedLsn.value!.lsn;
      if(selectLsn == "All LSN"){
        selectLsn = '999999';
      }

      // Close bottom sheet

      Get.back();


      Get.to(() => PickerManager());
    }else {
      Get.snackbar(
        'Warning',
        'Please select a location first',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
    }
  }

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


      Get.to(() => PickerScreen());
    }  else {
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
