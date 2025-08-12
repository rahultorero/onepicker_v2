import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/UserListModel.dart';
import '../services.dart';
import '../view/AdminScreen.dart';

class AdminController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  var isLoading = false.obs;
  var newUsers = <UserData>[].obs;
  var existingUsers = <UserData>[].obs;
  var selectedTabIndex = 0.obs;

  // Search functionality
  var searchQuery = ''.obs;
  var filteredNewUsers = <UserData>[].obs;
  var filteredExistingUsers = <UserData>[].obs;

  // Edit form controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Role assignment
  var selectedRoles = <String, bool>{
    'Admin': false,
    'Doctor': false,
    'Nurse': false,
    'Receptionist': false,
    'Manager': false,
    'Tray': false,
    'Tray Assigner': false,
    'Picker': false,
    'Picker Manager': false,
    'Checker': false,
    'Packer': false,
    'Solver': false,
  }.obs;

  UserData? currentEditingUser;
  var apiConfig;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });

    // Initialize filtered lists
    filteredNewUsers.value = newUsers;
    filteredExistingUsers.value = existingUsers;

    // Listen to changes in original lists to update filtered lists
    ever(newUsers, (_) => _updateFilteredLists());
    ever(existingUsers, (_) => _updateFilteredLists());

    fetchUserLists();
  }

  // Search functionality
  void searchUsers(String query) {
    searchQuery.value = query.toLowerCase();
    _updateFilteredLists();
  }

  void clearSearch() {
    searchQuery.value = '';
    _updateFilteredLists();
  }

  void _updateFilteredLists() {
    if (searchQuery.value.isEmpty) {
      filteredNewUsers.value = List.from(newUsers);
      filteredExistingUsers.value = List.from(existingUsers);
    } else {
      filteredNewUsers.value = newUsers.where((user) {
        final name = (user.eName ?? '').toLowerCase();
        final code = (user.eCode ?? '').toLowerCase();
        return name.contains(searchQuery.value) || code.contains(searchQuery.value);
      }).toList();

      filteredExistingUsers.value = existingUsers.where((user) {
        final name = (user.eName ?? '').toLowerCase();
        final code = (user.eCode ?? '').toLowerCase();
        return name.contains(searchQuery.value) || code.contains(searchQuery.value);
      }).toList();
    }
  }

  Future<void> fetchUserLists() async {
    isLoading.value = true;
    try {
      // Fetch new users
      await fetchNewUsers();
      // Fetch existing users
      await fetchExistingUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user lists: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNewUsers() async {
    final apiConfig = await ApiConfig.load();
    final userId = await ApiConfig.getLoginData();

    try {
      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}userlistnew'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'companyid': '1',
          'userid': userId?.response?.empId.toString(),
          'useas': '5',
        }),
      );

      if (response.statusCode == 200) {
        final userListModel = UserListModel.fromJson(jsonDecode(response.body));
        newUsers.value = userListModel.userData ?? [];
      } else {
        throw Exception('Failed to fetch new users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching new users: $e');
      throw e;
    }
  }

  Future<void> fetchExistingUsers() async {
    try {
      final apiConfig = await ApiConfig.load();
      final userId = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}userlistexists'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'companyid': '1',
          'userid': userId?.response?.empId.toString(),
          'useas': '5',
        }),
      );

      if (response.statusCode == 200) {
        final userListModel = UserListModel.fromJson(jsonDecode(response.body));
        existingUsers.value = userListModel.userData ?? [];
      } else {
        throw Exception('Failed to fetch existing users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching existing users: $e');
      throw e;
    }
  }

  // Show user details dialog
  void showUserDetailsDialog(UserData user) {
    currentEditingUser = user;
    Get.dialog(
      UserDetailsDialog(controller: this, user: user),
      barrierDismissible: true,
    );
  }

  void showEditDialog(UserData user) {
    currentEditingUser = user;
    nameController.text = user.eName ?? '';
    usernameController.text = user.eCode ?? '';
    passwordController.clear();
    confirmPasswordController.clear();

    Get.dialog(
      EditUserDialog(controller: this),
      barrierDismissible: false,
    );
  }

  void showRoleAssignmentDialog(UserData user) {
    currentEditingUser = user;

    // Set current roles - map all possible roles
    selectedRoles.value = {
      'Admin': user.admin ?? false,
      'Tray': user.tray ?? false,
      'Tray Assigner': user.trayPick ?? false,
      'Picker': user.picker ?? false,
      'Picker Manager': user.pickMan ?? false,
      'Checker': user.checker ?? false,
      'Packer': user.packer ?? false,
      'Solver': user.solver ?? false,
    };

    Get.dialog(
      RoleAssignmentDialog(controller: this),
      barrierDismissible: false,
    );
  }

  Future<void> updateUser() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Name is required');
      return;
    }

    if (usernameController.text.trim().isEmpty) {
      _showErrorSnackbar('Username is required');
      return;
    }

    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    if (passwordController.text.isNotEmpty && passwordController.text.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final response = await http.put(
        Uri.parse('${apiConfig.baseUrl}update-user'), // Replace with your actual endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empId': currentEditingUser?.empId,
          'name': nameController.text.trim(),
          'username': usernameController.text.trim(),
          if (passwordController.text.isNotEmpty) 'password': passwordController.text,
        }),
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        Get.back(); // Close edit dialog
        _showSuccessSnackbar('User updated successfully');
        await fetchUserLists();
      } else {
        _showErrorSnackbar('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Network error: ${e.toString()}');
    }
  }

  Future<void> assignRoles() async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final response = await http.put(
        Uri.parse('${apiConfig.baseUrl}assign-roles'), // Replace with your actual endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empId': currentEditingUser?.empId,
          'roles': {
            'admin': selectedRoles['Admin'],
            'doctor': selectedRoles['Doctor'],
            'nurse': selectedRoles['Nurse'],
            'receptionist': selectedRoles['Receptionist'],
            'manager': selectedRoles['Manager'],
            'tray': selectedRoles['Tray'],
            'trayPick': selectedRoles['Tray Assigner'],
            'picker': selectedRoles['Picker'],
            'pickMan': selectedRoles['Picker Manager'],
            'checker': selectedRoles['Checker'],
            'packer': selectedRoles['Packer'],
            'solver': selectedRoles['Solver'],
          },
        }),
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        Get.back(); // Close role assignment dialog
        _showSuccessSnackbar('Roles assigned successfully');
        await fetchUserLists();
      } else {
        _showErrorSnackbar('Failed to assign roles: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Network error: ${e.toString()}');
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

  // Method to get user role summary
  String getUserRoleSummary(UserData user) {
    List<String> roles = [];

    if (user.admin ?? false) roles.add('Admin');
    if (user.tray ?? false) roles.add('Tray');
    if (user.trayPick ?? false) roles.add('Tray Assigner');
    if (user.picker ?? false) roles.add('Picker');
    if (user.pickMan ?? false) roles.add('Picker Manager');
    if (user.checker ?? false) roles.add('Checker');
    if (user.packer ?? false) roles.add('Packer');
    if (user.solver ?? false) roles.add('Solver');

    return roles.isEmpty ? 'No roles assigned' : roles.join(', ');
  }

  // Method to get assigned roles list for user
  List<String> getAssignedRoles(UserData user) {
    List<String> roles = [];

    if (user.admin ?? false) roles.add('Admin');
    if (user.tray ?? false) roles.add('Tray');
    if (user.trayPick ?? false) roles.add('Tray Assigner');
    if (user.picker ?? false) roles.add('Picker');
    if (user.pickMan ?? false) roles.add('Picker Manager');
    if (user.checker ?? false) roles.add('Checker');
    if (user.packer ?? false) roles.add('Packer');
    if (user.solver ?? false) roles.add('Solver');

    return roles;
  }

  // Method to refresh data with pull-to-refresh
  Future<void> refreshData() async {
    await fetchUserLists();
  }

  // Method to validate form data
  bool validateEditForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Name cannot be empty');
      return false;
    }

    if (usernameController.text.trim().isEmpty) {
      _showErrorSnackbar('Username cannot be empty');
      return false;
    }

    if (passwordController.text.isNotEmpty) {
      if (passwordController.text.length < 6) {
        _showErrorSnackbar('Password must be at least 6 characters long');
        return false;
      }

      if (passwordController.text != confirmPasswordController.text) {
        _showErrorSnackbar('Passwords do not match');
        return false;
      }
    }

    return true;
  }

  // Method to clear form data
  void clearFormData() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    currentEditingUser = null;

    // Reset role selection
    selectedRoles.updateAll((key, value) => false);
  }

  // Method to check if any roles are selected
  bool hasSelectedRoles() {
    return selectedRoles.values.any((selected) => selected);
  }

  // Method to get selected roles count
  int getSelectedRolesCount() {
    return selectedRoles.values.where((selected) => selected).length;
  }

  @override
  void onClose() {
    tabController.dispose();
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}