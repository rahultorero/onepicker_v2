import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../controllers/LoginController.dart';
import '../theme/AppTheme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: controller.backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.lightTeal.withOpacity(0.3),
                  AppTheme.background,
                  AppTheme.primaryTeal.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background elements
                CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: MedicalBackgroundPainter(controller.backgroundAnimation.value),
                ),

                // Floating medical icons
                ...List.generate(8, (index) => _buildFloatingIcon(index, controller,context)),

                // Main content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(controller),

                        const SizedBox(height: 40),

                        // Main card with forms
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: _buildMainCard(controller),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(LoginController controller) {
    return FadeTransition(
      opacity: controller.fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              key: ValueKey(controller.isSettingsMode.value),
              onPressed: controller.toggleSettingsMode,
              icon: Icon(
                controller.isSettingsMode.value ? Icons.arrow_back : Icons.settings,
                color: AppTheme.primaryTeal,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMainCard(LoginController controller) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: controller.isSettingsMode.value
              ? _buildSettingsForm(controller)
              : _buildLoginForm(controller),
        )),
      ),
    );
  }

  Widget _buildLoginForm(LoginController controller) {
    return Column(
      key: const ValueKey('login'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 32),

        // Username field
        _buildTextField(
          controller: controller.usernameController,
          label: 'Username',
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 16),

        // Password field
        Obx(() => _buildTextField(
          controller: controller.passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: controller.isPasswordVisible.value,
          onVisibilityToggle: controller.togglePasswordVisibility,
        )),

        const SizedBox(height: 16),

        // Remember me checkbox
        Obx(() => Row(
          children: [
            Checkbox(
              value: controller.rememberMe.value,
              onChanged: (_) => controller.toggleRememberMe(),
              activeColor: AppTheme.lightTeal,
            ),
            Text(
              'Remember me',
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        )),

        const SizedBox(height: 32),

        // Login button
        Obx(() => _buildActionButton(
          onPressed: controller.login,
          text: 'Login',
          isLoading: controller.isLoading.value,
        )),
      ],
    );
  }

  Widget _buildSettingsForm(LoginController controller) {
    return Column(
      key: const ValueKey('settings'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Settings icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.lightTeal, AppTheme.accentGreen],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.dns_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Connect to Server',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),

        const SizedBox(height: 32),

        // IP Address field
        _buildTextField(
          controller: controller.ipController,
          label: 'IP Address',
          icon: Icons.computer,
          hintText: '192.168.1.100',
        ),

        const SizedBox(height: 16),

        // Port field
        _buildTextField(
          controller: controller.portController,
          label: 'Port',
          icon: Icons.settings_ethernet,
          hintText: '8080',
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 32),

        // Connect button
        Obx(() => _buildActionButton(
          onPressed: controller.connectToServer,
          text: 'Connect',
          isLoading: controller.isLoading.value,
        )),

        const SizedBox(height: 16),

        // Back button
        TextButton(
          onPressed: controller.toggleSettingsMode,
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !(isPasswordVisible ?? false),
        keyboardType: keyboardType,
        style: TextStyle(color: AppTheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppTheme.primaryTeal),
          suffixIcon: isPassword
              ? IconButton(
            onPressed: onVisibilityToggle,
            icon: Icon(
              isPasswordVisible ?? false ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.primaryTeal,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: AppTheme.primaryTeal),
          hintStyle: TextStyle(color: AppTheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(int index, LoginController controller,BuildContext context) {
    final icons = [
      Icons.medication,
      Icons.favorite,
      Icons.health_and_safety,
      Icons.medical_services,
      Icons.healing,
      Icons.vaccines,
      Icons.monitor_heart,
      Icons.local_pharmacy,
    ];

    final random = math.Random(index + 42);
    final size = 16.0 + random.nextDouble() * 8;
    final initialX = random.nextDouble();
    final initialY = random.nextDouble();

    return Positioned(
      left: MediaQuery.of(context).size.width * initialX,
      top: MediaQuery.of(context).size.height * initialY,
      child: Transform.translate(
        offset: Offset(
          math.sin(controller.backgroundAnimation.value * 2 * math.pi + index * 0.8) * 15,
          math.cos(controller.backgroundAnimation.value * math.pi + index * 0.4) * 10,
        ),
        child: Opacity(
          opacity: 0.3 + 0.2 * math.sin(controller.backgroundAnimation.value * math.pi + index),
          child: Icon(
            icons[index % icons.length],
            size: size,
            color: [
              AppTheme.primaryTeal,
              AppTheme.lightTeal,
              AppTheme.accentGreen,
              AppTheme.warmAccent,
            ][index % 4].withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

// Custom painter for medical background
class MedicalBackgroundPainter extends CustomPainter {
  final double animationValue;

  MedicalBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw animated medical crosses
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * (0.3 + math.sin(animationValue + i) * 0.1);
      final crossSize = 20.0 + math.sin(animationValue * 2 + i) * 5;

      // Horizontal line
      canvas.drawLine(
        Offset(x - crossSize, y),
        Offset(x + crossSize, y),
        paint,
      );

      // Vertical line
      canvas.drawLine(
        Offset(x, y - crossSize * 0.7),
        Offset(x, y + crossSize * 0.7),
        paint,
      );
    }

    // Draw animated circles
    for (int i = 0; i < 4; i++) {
      final x = size.width * (0.15 + i * 0.25);
      final y = size.height * (0.7 + math.cos(animationValue + i * 1.5) * 0.1);
      final radius = 15.0 + math.cos(animationValue * 1.5 + i) * 8;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}