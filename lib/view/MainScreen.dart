import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onepicker/view/PPCDashboardScreen.dart';
import 'package:onepicker/view/StatusDashboardScreen.dart';
import 'dart:math' as math;

import '../controllers/MainScreenController.dart';
import '../theme/AppTheme.dart';
import '../theme/FloatingElementsPainter.dart';
import 'HomeScreen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainScreenController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: AnimatedBuilder(
        animation: controller.backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  AppTheme.lightTeal.withOpacity(0.2),
                  AppTheme.background,
                  AppTheme.primaryTeal.withOpacity(0.03),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background animation
                CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: FloatingElementsPainter(controller.backgroundAnimation.value),
                ),

                // Screen content
                Obx(() => IndexedStack(
                  index: controller.currentIndex.value,
                  children: [
                    const HomeScreen(),
                    PPCDashboardScreen(),
                    StatusDashboardScreen(),
                    const ProfileScreen(),
                  ],
                )),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: _buildFloatingBottomNav(controller),
    );
  }

  Widget _buildFloatingBottomNav(MainScreenController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          controller.titles.length,
              (index) => _buildNavItem(
            index: index,
            icon: controller.icons[index],
            title: controller.titles[index],
            isSelected: controller.currentIndex.value == index,
            animation: controller.navAnimations[index],
            onTap: () => controller.changeTab(index),
          ),
        ),
      )),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required Animation<double> animation,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.onSurface.withOpacity(0.6),
                    size: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
