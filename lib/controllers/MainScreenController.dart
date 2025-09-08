import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;


class MainScreenController extends GetxController with GetTickerProviderStateMixin {
  var currentIndex = 0.obs;

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
    setupAnimations();
  }

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