import 'dart:async';

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
import 'package:shared_preferences/shared_preferences.dart';
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
import '../widget/AppLoader.dart';

class HomeScreenController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController cardController;
  late AnimationController headerController;

  // Edit form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

// Variable to track if current password is validated
  var isPasswordValidated = false.obs;


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



  var quickServices = <Map<String, dynamic>>[].obs; // RxList

  @override
  void onInit() {
    super.onInit();
    _loadServices(); // call here
  }

  Future<void> _loadServices() async {
    await _setQuickServices();   // fetch and build list

    final userData = await ApiConfig.getLoginData();
    usernameController.text = userData!.response!.eCode!;
  }

  Future<void> _setQuickServices() async {
    quickServices.clear();

    final userData = await ApiConfig.getLoginData();
    final user = userData!.response!;

    // Admin
    if (user.admin == true) {
      quickServices.add({
        'title': 'Admin',
        'subtitle': 'Manage users, roles & settings',
        'icon': Icons.computer_sharp,
        'color': AppTheme.primaryTeal,
        'gradient': AppTheme.primaryGradient,
        'isNew': false,
      });

    }

    // Tray Assigner
    if (user.trayPick == true) {
      quickServices.add({
        'title': 'Tray Assigner',
        'subtitle': 'Assign trays for seamless order flow',
        'icon': Icons.assignment_turned_in_outlined,
        'color': AppTheme.lavender,
        'gradient': AppTheme.lavenderGradient,
        'isNew': false,
      });
    }

    // Picker
    if (user.picker == true) {
      quickServices.add({
        'title': 'Picker',
        'subtitle': 'Pick items quickly & accurately',
        'icon': Icons.delivery_dining_outlined,
        'color': AppTheme.amberGold,
        'gradient': AppTheme.bronzeGradient,
        'isNew': false,
      });
    }

    // Merger
    final ETrayMerger = await ApiConfig.getSyn('ETrayMerger');
    if (ETrayMerger != 0) {
      if (user.tray == true) {
        quickServices.add({
          'title': 'Merger',
          'subtitle': 'Combine multiple orders into one',
          'icon': Icons.merge_type_rounded,
          'color': Colors.deepPurple,
          'gradient': AppTheme.lavenderGradient,
          'isNew': false,
        });
      }
    }

    // Picker Manager
    if (user.pickMan == true) {
      final workingWithPickupManager = await ApiConfig.getSyn('WorkingWithPickupManager');
      if (workingWithPickupManager != 0) {
        quickServices.add({
          'title': 'Picker Manager',
          'subtitle': 'Monitor and manage picking process',
          'icon': Icons.manage_accounts_rounded,
          'color': AppTheme.primaryTeal,
          'gradient': AppTheme.coolGradient,
          'isNew': false,
        });
      }
    }



    // Checker & Packer
    final EPCSeprate = await ApiConfig.getSyn('EPCSeprate');
    if (EPCSeprate == 0) {
      // Only Checker
      if (user.checker == true) {
        quickServices.add({
          'title': 'Checker',
          'subtitle': 'Verify items before dispatch',
          'icon': Icons.fact_check_outlined,
          'color': AppTheme.accentGreen,
          'gradient': AppTheme.accentGradient,
          'isNew': false,
        });
      }
    } else {
      // Both Checker and Packer
      if (user.checker == true) {
        quickServices.add({
          'title': 'Checker',
          'subtitle': 'Verify items before dispatch',
          'icon': Icons.fact_check_outlined,
          'color': AppTheme.accentGreen,
          'gradient': AppTheme.accentGradient,
          'isNew': false,
        });
      }

      if (user.packer == true) {
        quickServices.add({
          'title': 'Packer',
          'subtitle': 'Pack orders securely & efficiently',
          'icon': Icons.backpack,
          'color': const Color(0xFF199A8E),
          'gradient': AppTheme.primaryGradient,
          'isNew': false,
        });
      }
    }

    print("✅ Quick services loaded: ${quickServices.length}");
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

  Future<void> logout() async {
    try {
      final apiConfig = await ApiConfig.load();
      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('session_id');

      if (sessionId == null) {
        print("Session ID not found");
        return;
      }

      final response = await http
          .post(
        Uri.parse('${apiConfig.baseUrl}logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'SessionId': sessionId,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out after 10 seconds");
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Logout response: $responseData");
        print("session Id $sessionId");

        // Clear session data from SharedPreferences
        await prefs.remove('session_id');

        // Optionally clear other login data
        // await prefs.remove('username');
        // await prefs.remove('password');
        // await prefs.setBool('remember_me', false);

        print("Logout successful");
      } else {
        print("Logout failed with status: ${response.statusCode}");
      }
    } on TimeoutException {
      print("Logout request timed out");
    } catch (e) {
      print("Logout error: $e");
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

  Future<void> validatePassword() async {
    // Check if current password field is empty
    if (currentPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your current password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Get stored password
      final storedPassword = prefs.getString('password');
      final storedUsername = prefs.getString('username');

      // Check if password exists in SharedPreferences
      if (storedPassword == null || storedUsername == null) {
        Get.snackbar(
          'Error',
          'No stored credentials found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Validate password
      if (currentPasswordController.text == storedPassword) {
        // Password is correct
        isPasswordValidated.value = true;

        Get.snackbar(
          'Success',
          'Password validated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Password is incorrect
        isPasswordValidated.value = false;

        Get.snackbar(
          'Error',
          'Current password is incorrect',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to validate password: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
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

  // Helper methods for better UX
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  Future<void> updateUser() async {
    // Validation
    if (usernameController.text.trim().isEmpty) {
      _showErrorSnackbar('Username is required');
      return;
    }

    if (newPasswordController.text.isNotEmpty && newPasswordController.text.length < 2) {
      _showErrorSnackbar('Password must be at least 2 characters');
      return;
    }

    try {
      final apiConfig = await ApiConfig.load();
      final userId = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}user_update'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': userId?.response?.empId.toString() ?? '',
          'empid': userId?.response?.empId?.toString() ?? '',
          'empcode': usernameController.text.trim(),
          'pwd': newPasswordController.text.isNotEmpty ? newPasswordController.text : '',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // Update password in SharedPreferences
        await prefs.setString('password', newPasswordController.text);

        // Clear password fields after successful update
        currentPasswordController.clear();
        newPasswordController.clear();

        Get.back(); // Close edit dialog
        _showSuccessSnackbar(responseData['message'] ?? 'User updated successfully');
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        _showErrorSnackbar(responseData['message'] ?? 'Unauthorized access');
      } else {
        _showErrorSnackbar('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Network error: ${e.toString()}');
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
