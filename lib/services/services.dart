
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/LoginModel.dart';
import '../model/ServerConnectModel.dart';
class ApiConfig {
  final String? baseUrl;
  static const String _keyAppSetting = 'KEY_SETTING';
  static const String _keyLoginData = 'login_data';


  ApiConfig._(this.baseUrl);


  static Future<void> setAppSettings(List<SettingData> settings) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(settings.map((e) => e.toJson()).toList());
    await prefs.setString(_keyAppSetting, jsonString);
  }

  static Future<List<SettingData>> getAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyAppSetting);

    if (jsonString == null || jsonString.isEmpty) return [];

    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => SettingData.fromJson(e)).toList();
  }

  static Future<void> setLoginData(LoginModel data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data.toJson());
    await prefs.setString(_keyLoginData, jsonString);
  }

  static Future<LoginModel?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyLoginData);

    if (jsonString == null || jsonString.isEmpty) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return LoginModel.fromJson(jsonMap);
  }

  static Future<ApiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('base_url');
    return ApiConfig._(baseUrl);
  }

  static Future<int> getSyn(String chkValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyAppSetting);

      if (jsonString == null || jsonString.isEmpty) return 0;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (var item in jsonList) {
        final obj = SettingData.fromJson(item);
        if (obj.sName == chkValue) {
          return obj.syn ?? 0;
        }
      }
    } catch (e) {
      debugPrint("getSyn error: $e");
    }
    return 0;
  }

  /// Get SSub (int) by SName
  static Future<String> getSsub(String chkValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyAppSetting);

      if (jsonString == null || jsonString.isEmpty) return '';

      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (var item in jsonList) {
        final obj = SettingData.fromJson(item);
        if (obj.sName == chkValue) {
          return obj.sSub ?? '';
        }
      }
    } catch (e) {
      debugPrint("getSsub error: $e");
    }
    return '';
  }

  /// Get SSub (String) by SName
  static Future<String> getSsubStr(String chkValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyAppSetting);

      if (jsonString == null || jsonString.isEmpty) return "";

      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (var item in jsonList) {
        final obj = SettingData.fromJson(item);
        if (obj.sName == chkValue) {
          return obj.sSub?.toString() ?? "";
        }
      }
    } catch (e) {
      debugPrint("getSsubStr error: $e");
    }
    return "";
  }

  static String dateConvert(String? inputDate) {
    try {
      if (inputDate != null && inputDate.isNotEmpty) {
        // Parse the input date string (ISO 8601 format)
        DateTime date = DateTime.parse(inputDate);

        // Format to desired output
        return DateFormat("dd-MM-yyyy").format(date);
      } else {
        return "";
      }
    } catch (e) {
      print("Date parsing error: $e");
      return "";
    }
  }
}