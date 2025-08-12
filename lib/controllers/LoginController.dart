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

import '../model/ServerConnectModel.dart';
import '../services.dart';
import '../theme/AppTheme.dart';

// Login Controller using GetX
class LoginController extends GetxController with GetTickerProviderStateMixin {
  // Observables
  var isLoading = false.obs;
  var isSettingsMode = false.obs;
  var rememberMe = false.obs;
  var isPasswordVisible = false.obs;

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

  // Get device IMEI (simplified - you'll need proper implementation)
  Future<String> getDeviceImei() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'unknown'; // Use Android ID as fallback
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    return 'unknown_device';
  }

  // Login API Call
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

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}login'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imei': imei,
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);


        // 🔁 Convert to model
        final loginResponse = LoginModel.fromJson(responseData);

        if(loginResponse.status == '200'){
          await ApiConfig.setLoginData(loginResponse);

          // ✅ Access values
          print('Status: ${loginResponse.status}');
          print('Message: ${loginResponse.message}');


          // 🔄 Print entire JSON for debugging
          print('Raw JSON: ${jsonEncode(responseData)}');

          if (rememberMe.value) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('remember_me', true);
            await prefs.setString('username', usernameController.text);
            await prefs.setString('password', passwordController.text);
          } else {
            // Clear saved login if rememberMe is off
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('remember_me', false);
            await prefs.remove('username');
            await prefs.remove('password');
          }


          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: AppTheme.mintGreen.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );


          // Navigate to main screen
          await Future.delayed(const Duration(seconds: 2));
          Get.offAll(() => MainScreen());
        }else{

          print('Status: ${loginResponse.status}');
          print('Message: ${loginResponse.message}');

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
    } catch (e) {
      print("e -->$e");
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

  // Settings API Call
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

    // Validate IP address format
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
      final response = await http.post(
        Uri.parse('http://${ipController.text}:${portController.text}/medipick/api/settings'), // Dynamic endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        final serverConnect = ServerConnectModel.fromJson(data);

        if (serverConnect.settingData != null) {
          await ApiConfig.setAppSettings(serverConnect.settingData!); // 🔥 save like Java
        }

        Get.snackbar(
          'Success',
          'Connected to server successfully!',
          backgroundColor: AppTheme.mintGreen.withOpacity(0.8),
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
    } catch (e) {
      print(e.toString());
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