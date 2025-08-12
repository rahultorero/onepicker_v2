import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../theme/AppTheme.dart';

class HomeScreenController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController cardController;
  late AnimationController headerController;
  late List<Animation<Offset>> cardAnimations;
  late Animation<double> headerAnimation;

  var userName = ''.obs;
  var notificationCount = 3.obs;

  final List<Map<String, dynamic>> quickServices = [
    {
      'title': 'Admin',
      'subtitle': 'Real Time Labour Monitoring',
      'icon': Icons.computer_sharp,
      'color': AppTheme.primaryBlue,
      'gradient': AppTheme.primaryGradient,
      'isNew': false,
    },
    {
      'title': 'Tray Assigner',
      'subtitle': 'Real Time NST Test Tracking',
      'icon': Icons.assignment_turned_in_outlined,
      'color': AppTheme.purple,
      'gradient': [AppTheme.purple, AppTheme.primaryBlue],
      'isNew': false,
    },
    {
      'title': 'Picker',
      'subtitle': 'Track your BabyBeat NST Test',
      'icon': Icons.delivery_dining_outlined,
      'color': AppTheme.orange,
      'gradient': [AppTheme.orange, AppTheme.gold],
      'isNew': false,
    },
    {
      'title': 'Picker Manager',
      'subtitle': 'Take UTI test and get report instantly',
      'icon': Icons.manage_accounts_rounded,
      'color': AppTheme.medicalTeal,
      'gradient': [AppTheme.medicalTeal, AppTheme.mintGreen],
      'isNew': false,
    },
    {
      'title': 'Checker',
      'subtitle': 'Live ApneBoot Device Monitoring',
      'icon': Icons.fact_check_outlined,
      'color': AppTheme.accent,
      'gradient': AppTheme.accentGradient,
      'isNew': false,
    },
    {
      'title': 'Packer',
      'subtitle': 'Live ApneBoot Device Monitoring',
      'icon': Icons.backpack,
      'color':  Color(0xFF199A8E),
      'gradient': AppTheme.primaryGradient,
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

  @override
  void onClose() {
    cardController.dispose();
    headerController.dispose();
    super.onClose();
  }
}