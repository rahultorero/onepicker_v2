import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;


import '../model/LoginModel.dart';
import '../services/services.dart'; // Import your login model

class MainScreenController extends GetxController with GetTickerProviderStateMixin {
  var currentIndex = 0.obs;

  // User data
  Rx<LoginModel?> userData = Rx<LoginModel?>(null);
  var isLoading = true.obs;

  // Animation controllers
  late AnimationController backgroundController;
  late AnimationController fabController;
  late List<AnimationController> navControllers;

  // Animations
  late Animation<double> backgroundAnimation;
  late Animation<double> fabScaleAnimation;
  late List<Animation<double>> navAnimations;

  final List<String> titles = ['Home', 'Performance', 'Status', 'Info'];
  final List<IconData> icons = [
    Icons.home_filled,
    Icons.analytics,
    Icons.dashboard,
    Icons.network_check_rounded,
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    setupAnimations();
  }

  // Load user data from API
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final data = await ApiConfig.getLoginData();
      userData.value = data;
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper getters for easy access
  bool get isAdmin => userData.value?.response?.admin ?? false;
  bool get isTray => userData.value?.response?.tray ?? false;
  bool get isPicker => userData.value?.response?.picker ?? false;
  bool get isChecker => userData.value?.response?.checker ?? false;
  bool get isPacker => userData.value?.response?.packer ?? false;
  bool get isTrayPick => userData.value?.response?.trayPick ?? false;
  bool get isPickMan => userData.value?.response?.pickMan ?? false;
  String get userName => userData.value?.response?.eName ?? 'User';

  void setupAnimations() {
    backgroundController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    navControllers = List.generate(
      4,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(backgroundController);

    fabScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: fabController,
      curve: Curves.elasticOut,
    ));

    navAnimations = navControllers.map((controller) =>
        Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
    ).toList();

    backgroundController.repeat();
    fabController.forward();

    // Stagger nav animations
    for (int i = 0; i < navControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        navControllers[i].forward();
      });
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;

    // Animate selected tab
    for (int i = 0; i < navControllers.length; i++) {
      if (i == index) {
        navControllers[i].forward();
      } else {
        navControllers[i].reverse();
      }
    }

    // Fab pulse
    fabController.reset();
    fabController.forward();
  }

  @override
  void onClose() {
    backgroundController.dispose();
    fabController.dispose();
    for (var controller in navControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}