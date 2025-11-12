import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:onepicker/main.dart';
import 'package:onepicker/model/LoginModel.dart';
import 'package:onepicker/view/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async'; // for TimeoutException

import '../bottomsheets/CompanySelectionBottomSheet.dart';
import '../model/BranchData.dart';
import '../model/CompanyData.dart';
import '../model/FloorData.dart';
import '../model/ServerConnectModel.dart';
import '../services/services.dart';
import '../theme/AppTheme.dart';

// Login Controller using GetX
class LoginController extends GetxController with GetTickerProviderStateMixin {
  // Observables
  var isLoading = false.obs;
  var isSettingsMode = false.obs;
  var rememberMe = false.obs;
  var isPasswordVisible = false.obs;

  // Selection Loading States
  var isCompanyLoading = false.obs;
  var isBranchLoading = false.obs;
  var isFloorLoading = false.obs;

  // Static Selection Variables
  static int? selectedCompanyId = 0;
  static int? selectedBranchId = 0;
  static int? selectedFloorId = 0;

  // Selection Data
  var companyList = <CompanyData>[].obs;
  var branchList = <BranchData>[].obs;
  var floorList = <FloorData>[].obs;

  // Selected Items for Display
  var selectedCompany = Rx<CompanyData?>(null);
  var selectedBranch = Rx<BranchData?>(null);
  var selectedFloor = Rx<FloorData?>(null);

  // Text Controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final ipController = TextEditingController();
  final portController = TextEditingController();

  // Animation Controllers
  late AnimationController backgroundController;
  late AnimationController slideController;
  late AnimationController fadeController;

  // Animations
  late Animation<double> backgroundAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    setupAnimations();
    loadSavedCredentials();
  }

  void setupAnimations() {
    backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(backgroundController);

    slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(fadeController);

    backgroundController.repeat();
    fadeController.forward();
  }

  void loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved IP and port
    ipController.text = prefs.getString('ip') ?? '';
    portController.text = prefs.getString('port') ?? '';

    // Load saved login credentials
    final savedRememberMe = prefs.getBool('remember_me') ?? false;
    rememberMe.value = savedRememberMe;

    if (savedRememberMe) {
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  void toggleSettingsMode() {
    isSettingsMode.value = !isSettingsMode.value;
    if (isSettingsMode.value) {
      slideController.forward();
    } else {
      slideController.reverse();
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<String> getDeviceImei() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'unknown';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    return 'unknown_device';
  }

  // Login API Call - Modified to show selection bottomsheet
  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter username and password',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      String imei = await getDeviceImei();
      final apiConfig = await ApiConfig.load();

      final response = await http
          .post(
        Uri.parse('${apiConfig.baseUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imei': imei,
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out after 10 seconds");
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginModel.fromJson(responseData);

        if (loginResponse.status == '200') {
          await ApiConfig.setLoginData(loginResponse);

          if (rememberMe.value) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('remember_me', true);
            await prefs.setString('username', usernameController.text);
            await prefs.setString('password', passwordController.text);
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('remember_me', false);
            await prefs.remove('username');
            await prefs.remove('password');
          }

          print("login responssee   ${loginResponse.toJson()}");

          await saveSession();


          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: AppTheme.success.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );



          // Show selection bottomsheet instead of navigating directly
          await Future.delayed(const Duration(milliseconds: 500));
          showSelectionBottomSheet();
        } else {
          Get.snackbar(
            'Error',
            'Login failed. Access Denied...',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Login failed. Please check your credentials.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on TimeoutException {
      Get.snackbar(
        'Error',
        'Request timed out. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print("e --> $e");
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSession() async {
    try {
      String imei = await getDeviceImei();
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      if (loginData == null) {
        print("Login data not found");
        return;
      }

      final now = DateTime.now();
      final sessionId = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';


      final response = await http
          .post(
        Uri.parse('${apiConfig.baseUrl}save_session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'imei': imei,
          'mobilenum':'', // Adjust based on your LoginModel
          'empid': loginData.response?.empId ?? 0,
          'companyid': loginData.response?.coId ?? 0,
          'brchid': loginData.response?.brchId ?? 0,
          'locationid':'',
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out after 10 seconds");
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Save session response: $responseData");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);
        print("SessionId saved: $sessionId");
      } else {
        print("Save session failed with status: ${response.statusCode}");
      }
    } on TimeoutException {
      print("Save session request timed out");
    } catch (e) {
      print("Save session error: $e");
    }
  }

  // Company List API
  Future<void> getCompanyList() async {
    isCompanyLoading.value = true;
    try {
      final apiConfig = await ApiConfig.load();
      final loginData = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}company'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': loginData?.response?.empId?.toString() ?? '0',
          'useas': '1',
          'companyid': loginData?.response?.coId?.toString() ?? '0',
          'branchid': loginData?.response?.brchId?.toString() ?? '0',
        },
      ).timeout(const Duration(seconds: 10));

      print("📩 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("📦 Decoded JSON: $data");

        final companyResponse = CompanyListModel.fromJson(data);

        print("✅ Parsed Company Response: ${companyResponse.toJson()}");

        if (companyResponse.status == '200' && companyResponse.response != null) {
          companyList.value = companyResponse.response!;
          print("🏢 Loaded Companies: ${companyList.length}");
        } else {
          print('⚠️ Response status: ${companyResponse.status}');
          Get.snackbar('Error', 'Failed to load companies');
        }
      } else {
        print("❌ API returned status: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      print('🔥 Company API Error: $e');
      print('📌 Stacktrace: $stacktrace');
      Get.snackbar('Error', 'Failed to load companies');
    } finally {
      isCompanyLoading.value = false;
    }
  }

  // Branch List API
  Future<void> getBranchList(int companyId) async {
    isBranchLoading.value = true;
    branchList.clear();
    selectedBranch.value = null;
    floorList.clear();
    selectedFloor.value = null;

    try {
      final apiConfig = await ApiConfig.load();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}branch'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': companyId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branchResponse = BranchListModel.fromJson(data);

        if (branchResponse.status == '200' && branchResponse.response != null) {
          branchList.value = branchResponse.response!;
        } else {
          Get.snackbar('Error', 'Failed to load branches');
        }
      }
    } catch (e) {
      print('Branch API Error: $e');
      Get.snackbar('Error', 'Failed to load branches');
    } finally {
      isBranchLoading.value = false;
    }
  }

  // Floor List API
  Future<void> getFloorList(int companyId, int branchId) async {
    isFloorLoading.value = true;
    floorList.clear();
    selectedFloor.value = null;

    try {
      final apiConfig = await ApiConfig.load();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}break'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'companyid': companyId.toString(),
          'branchid': branchId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final floorResponse = FloorListModel.fromJson(data);

        if (floorResponse.status == '200' && floorResponse.response != null) {
          floorList.value = floorResponse.response!;
        } else {
          Get.snackbar('Error', 'Failed to load floors');
        }
      }
    } catch (e) {
      print('Floor API Error: $e');
      Get.snackbar('Error', 'Failed to load floors');
    } finally {
      isFloorLoading.value = false;
    }
  }

  // Selection Methods
  void selectCompany(CompanyData company) {
    print("u");
    selectedCompany.value = company;
    selectedCompanyId = company.companyid;
    getBranchList(company.companyid!);
    getFloorList(selectedCompanyId!, 0);
  }

  void selectBranch(BranchData branch) {
    selectedBranch.value = branch;
    selectedBranchId = branch.brchid;
    getFloorList(selectedCompanyId!, branch.brchid!);
  }

  void selectFloor(FloorData floor) {
    selectedFloor.value = floor;
    selectedFloorId = floor.brk;
  }

  // Show Selection Bottom Sheet
  void showSelectionBottomSheet() {  // Removed underscore
    getCompanyList();
    Get.bottomSheet(
      CompanySelectionBottomSheet(),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }
  // Proceed to Main Screen
  void proceedToMainScreen() {
    // if (selectedCompanyId != null && selectedBranchId != null && selectedFloorId != null) {
      if (selectedCompanyId != null && selectedBranchId != null ) {

        Get.back(); // Close bottom sheet
      Get.offAll(() => MainScreen());
    } else {
      Get.snackbar('Error', 'Please complete all selections');
    }
  }

  // Settings API Call (unchanged)
  Future<void> connectToServer() async {
    if (ipController.text.isEmpty || portController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter IP address and port',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!_isValidIP(ipController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid IP address',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http
          .post(
        Uri.parse(
            'http://${ipController.text}:${portController.text}/medipick/api/settings'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Connection timed out after 10 seconds");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverConnect = ServerConnectModel.fromJson(data);

        if (serverConnect.settingData != null) {
          await ApiConfig.setAppSettings(serverConnect.settingData!);
        }
        print("server valuess ${serverConnect.toJson()}");
        Get.snackbar(
          'Success',
          'Connected to server successfully!',
          backgroundColor: AppTheme.success.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await saveSettings(ipController.text, portController.text);
        toggleSettingsMode();
      } else {
        Get.snackbar(
          'Error',
          'Failed to connect to server.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on TimeoutException {
      Get.snackbar(
        'Error',
        'Connection timed out. Please check server or try again.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed. Please check IP and port.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    String baseUrl = 'http://$ip:$port/medipick/api/';

    Map<String, String> settings = {
      'ip': ip,
      'port': port,
      'base_url': baseUrl,
    };

    settings.forEach((key, value) {
      prefs.setString(key, value);
    });
  }

  bool _isValidIP(String ip) {
    return RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')
        .hasMatch(ip);
  }

  @override
  void onClose() {
    backgroundController.dispose();
    slideController.dispose();
    fadeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    ipController.dispose();
    portController.dispose();
    super.onClose();
  }
}