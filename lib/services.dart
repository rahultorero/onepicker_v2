
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'model/LoginModel.dart';
import 'model/ServerConnectModel.dart';
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
}