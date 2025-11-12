import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepicker/controllers/LoginController.dart';

import '../model/BranchData.dart';
import '../model/CompanyData.dart';
import '../model/UserListModel.dart';
import '../services/services.dart';
import '../view/AdminScreen.dart';
import '../widget/AppLoader.dart';

class AdminController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  var isLoading = false.obs;
  var newUsers = <UserData>[].obs;
  var existingUsers = <UserData>[].obs;
  var selectedTabIndex = 0.obs;

  // Search functionality
  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  var filteredNewUsers = <UserData>[].obs;
  var filteredExistingUsers = <UserData>[].obs;

  // Edit form controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var selectedRoles = <String, bool>{}.obs;
  UserData? currentEditingUser;

  // New properties for company and branch
  var selectedCompanyId = 0.obs;
  var selectedBranchId = 0.obs;
  var showBranchDropdown = false.obs;

  // Company and branch data lists
  var companyList = <Map<String, dynamic>>[].obs;
  var branchList = <Map<String, dynamic>>[].obs;


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
    loadCompanyList();
  }

  // Search functionality
  void searchUsers(String query) {
    searchQuery.value = query.toLowerCase();
    _updateFilteredLists();
  }

  void clearSearch() {
    searchController.clear();   // clears the TextField

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

  Future<void> showRoleAssignmentDialog(UserData user) async {
    currentEditingUser = user;

    // Set current roles - map all possible roles
    selectedRoles.value = {
      'Admin': user.admin ?? false,
      'Tray Assigner': user.trayPick ?? false,
      'Picker': user.picker ?? false,
      'Picker Manager': user.pickMan ?? false,
      'Checker': user.checker ?? false,
      'Packer': user.packer ?? false,
      'Merger':user.tray ?? false,
      'Solver': user.solver ?? false,
    };

    // Set current company and branch
    selectedCompanyId.value = int.tryParse(user.coId!) ?? 0;
    selectedBranchId.value = int.tryParse(user.brchId!) ?? 0;

    // Load branch list if company is selected
    if (selectedCompanyId.value != 0) {
      await loadBranchList(selectedCompanyId.value);
      showBranchDropdown.value = await shouldShowBranchDropdown();
      print("----------- >${showBranchDropdown.value}");

    } else {
      showBranchDropdown.value = false;
    }

    Get.dialog(
      RoleAssignmentDialog(controller: this),
      barrierDismissible: false,
    );
  }


  Future<void> loadCompanyList() async {

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
          companyList.value = [
            {'id': 0, 'name': 'ALL COMPANY'}, // Always at 0 index
          ];

          companyResponse.response?.forEach((company) {
            companyList.value.add({
              'id': company.companyid,
              'name': company.companyname,
            });
          });

          print("🏢 Loaded Companies: ${companyList.length}");
        } else {
          // print('⚠️ Response status: ${companyResponse.status}');
          Get.snackbar('Error', 'Failed to load companies');
        }
      } else {
        print("❌ API returned status: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      print('🔥 Company API Error: $e');
      print('📌 Stacktrace: $stacktrace');
      Get.snackbar('Error', 'Failed to load companies');
    }
  }

  Future<void> onCompanySelected(int companyId) async {
    selectedBranchId.value = 0; // Reset branch selection



    if (companyId != 0) {
      await loadBranchList(companyId);
      showBranchDropdown.value = await shouldShowBranchDropdown();
      print("----------- >${showBranchDropdown.value}");

    } else {
      showBranchDropdown.value = false;
      branchList.clear();
    }
  }

  Future<void> loadBranchList(int companyId) async {
    branchList.clear();

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
          branchList.value = [
            {'id': 0, 'name': 'ALL Branch'}, // Always at 0 index
          ];
          branchResponse.response?.forEach((brch) {
            branchList.value.add({
              'id': brch.brchid,
              'name': brch.brchname,
            });
          });
        } else {
          Get.snackbar('Error', 'Failed to load branches');
        }
      }
    } catch (e) {
      print('Branch API Error: $e');
      Get.snackbar('Error', 'Failed to load branches');
    }


  }

  Future<bool> shouldShowBranchDropdown() async {
    final workingBranch = await ApiConfig.getSyn("WorkingWithBrch");
    return workingBranch != 0 && branchList.isNotEmpty;
  }





  // Updated API implementation for user update
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

    if (passwordController.text.isNotEmpty && passwordController.text.length < 2) {
      _showErrorSnackbar('Password must be at least 2 characters');
      return;
    }

    try {
      // Show loading with custom indicator
      Get.dialog(
        LoadingIndicator(),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final userId = await ApiConfig.getLoginData();

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}user_update'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userid': userId?.response?.empId.toString() ?? '',
          'empid': currentEditingUser?.empId?.toString() ?? '',
          'empcode': usernameController.text.trim(),
          'pwd': passwordController.text.isNotEmpty ? passwordController.text : '',
        },
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Get.back(); // Close edit dialog
        _showSuccessSnackbar(responseData['message'] ?? 'User updated successfully');
        await fetchUserLists();
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

  // Updated API implementation for assign roles
  Future<void> assignRoles() async {
    try {
      // Show loading with custom indicator
      Get.dialog(
        LoadingIndicator(),
        barrierDismissible: false,
      );

      final apiConfig = await ApiConfig.load();
      final userId = await ApiConfig.getLoginData();

      // Helper function to convert boolean to int (like your Java get_chkCb_status method)
      int getCheckboxStatus(bool isChecked) {
        return isChecked ? 1 : 0;
      }

      // Create request body following your Java format
      final requestBody = {
        'userid': userId?.response?.empId?.toString() ?? '',
        'useas': '5',
        'empdetails': {
          'empid': currentEditingUser?.empId?.toString() ?? '',
          'admin': getCheckboxStatus(selectedRoles['Admin'] ?? false),
          'picker': getCheckboxStatus(selectedRoles['Picker'] ?? false),
          'checker': getCheckboxStatus(selectedRoles['Checker'] ?? false),
          'solver': getCheckboxStatus(selectedRoles['Solver'] ?? false),
          'tray': getCheckboxStatus(selectedRoles['Merger'] ?? false),
          'pickman': getCheckboxStatus(selectedRoles['Picker Manager'] ?? false),
          'packer': getCheckboxStatus(selectedRoles['Packer'] ?? false),
          'traypick': getCheckboxStatus(selectedRoles['Tray Assigner'] ?? false),
          'companyid': selectedCompanyId.value,
          'brchid': selectedBranchId.value,
        },
      };
      print('Assign Roles Request Body: ${jsonEncode(requestBody)}'); // Debug log

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}saveuserrole'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Get.back(); // Close role assignment dialog
        _showSuccessSnackbar(responseData['message'] ?? 'Roles assigned successfully');
        await fetchUserLists();
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        _showErrorSnackbar(responseData['message'] ?? 'Unauthorized access');
      } else {
        _showErrorSnackbar('Failed to assign roles: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Network error: ${e.toString()}');
      print('Network error: ${e.toString()}');
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
      if (passwordController.text.length < 2) {
        _showErrorSnackbar('Password must be at least 2 characters long');
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

