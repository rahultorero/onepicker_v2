import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onepicker/services/services.dart';
import 'package:onepicker/view/AdminScreen.dart';
import 'package:onepicker/view/TrayAssignerScreen.dart';
import 'dart:math' as math;

import '../controllers/HomeScreenController.dart';
import '../controllers/LoginController.dart';
import '../theme/AppTheme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final controller = Get.put(HomeScreenController());
    final loginData = await ApiConfig.getLoginData();

    controller.userName.value = loginData!.response!.eName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    DateTime? _lastPressedAt;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;

          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Press back again to exit',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.amberGold,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          return false; // Don't exit
        }

        // Call logout API before exiting
        await controller.logout();

        return true; // Exit app
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
      
               _buildHeader(controller),
      
      
              const SizedBox(height: 20),
      
              // New Launch Banner
               _buildNewLaunchBanner(),
      
      
              const SizedBox(height: 24),
      
              // Quick Services
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Obx((){
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: controller.quickServices.length,
                          itemBuilder: (context, index) {
                            return  _buildServiceCard(
                                controller.quickServices[index],
                                index,
                              );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HomeScreenController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Obx(() => Container(
              width: 150,
              child: Text(
                controller.userName.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal,
                  letterSpacing: 0.5,
                  overflow: TextOverflow.ellipsis
                ),
              ),
            )),
          ],
        ),
        Row(
          children: [
            // Notification bell
            // Stack(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.all(10),
            //       decoration: BoxDecoration(
            //         color: AppTheme.surface,
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: AppTheme.shadowColor.withOpacity(0.08),
            //             blurRadius: 8,
            //             spreadRadius: 1,
            //           ),
            //         ],
            //       ),
            //       child: Icon(
            //         Icons.notifications_outlined,
            //         color: AppTheme.primaryTeal,
            //         size: 20,
            //       ),
            //     ),
            //     Obx(() => controller.notificationCount.value > 0
            //         ? Positioned(
            //       right: 2,
            //       top: 2,
            //       child: Container(
            //         width: 16,
            //         height: 16,
            //         decoration: const BoxDecoration(
            //           color: Colors.red,
            //           shape: BoxShape.circle,
            //         ),
            //         child: Center(
            //           child: Text(
            //             controller.notificationCount.value.toString(),
            //             style: const TextStyle(
            //               color: Colors.white,
            //               fontSize: 9,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     )
            //         : const SizedBox(),
            //     ),
            //   ],
            // ),
            const SizedBox(width: 10),
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),

                child: GestureDetector(
                  onTap: () {
                    final loginController = Get.find<LoginController>();
                    loginController.showSelectionBottomSheet();
                  },
                  child: const Icon(
                    Icons.compare_arrows,
                    color: Colors.white,
                    size: 20,
                  ),
                )
            ),
            const SizedBox(width: 10),

            // Search button
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),

                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ResetPasswordDialog(controller: controller),
                    );
                  },
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                )
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildNewLaunchBanner() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW LAUNCH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nurtura - AI Co-Pilot for\nLabor, Birthing & Postpartum\nMonitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),

              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pregnant_woman,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final controller = Get.find<HomeScreenController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 76,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {

            controller.onServiceTap(service);


          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: service['gradient']),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: service['color'].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    service['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          if (service['isNew'])
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        service['subtitle'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: service['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: service['color'],
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordDialog extends StatefulWidget {
  final HomeScreenController controller;

  const ResetPasswordDialog({required this.controller});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  bool isSubmitEnabled = false;
  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isPasswordValidated = false; // 👈 NEW: Track validation status

  @override
  void initState() {
    super.initState();
    widget.controller.newPasswordController.addListener(_checkPasswordField);
  }

  @override
  void dispose() {
    widget.controller.newPasswordController.removeListener(_checkPasswordField);
    widget.controller.newPasswordController.clear();
    widget.controller.currentPasswordController.clear();
    super.dispose();
  }

  void _checkPasswordField() {
    setState(() {
      isSubmitEnabled = widget.controller.newPasswordController.text.isNotEmpty && isPasswordValidated;
    });
  }

  // 👈 NEW: Method to handle validation
  Future<void> _handleValidatePassword() async {
    // Call your validation API
    await widget.controller.validatePassword();

    // Check the result from controller's observable
    setState(() {
      isPasswordValidated = widget.controller.isPasswordValidated.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        height: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Fixed Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGradient[0], AppTheme.primaryGradient[1]],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ModernTextField(
                      controller: widget.controller.usernameController,
                      label: 'Username',
                      icon: Icons.account_circle_outlined,
                      hint: 'Username',
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: widget.controller.currentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      hint: 'Enter current password',
                      isPassword: true,
                      isPasswordVisible: isCurrentPasswordVisible,
                      isReadOnly: isPasswordValidated, // 👈 Lock after validation
                      onToggleVisibility: () {
                        setState(() {
                          isCurrentPasswordVisible = !isCurrentPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Validate Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isPasswordValidated
                              ? LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          )
                              : LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isPasswordValidated ? null : _handleValidatePassword, // 👈 Disable after validation
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isPasswordValidated)
                                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                                  if (isPasswordValidated) SizedBox(width: 8),
                                  Text(
                                    isPasswordValidated ? 'Validated' : 'Validate Password',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: widget.controller.newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_clock_outlined,
                      hint: isPasswordValidated ? 'Enter new password' : 'Validate current password first',
                      isPassword: true,
                      helperText: isPasswordValidated ? 'Minimum 6 characters, alphanumeric...' : null,
                      isPasswordVisible: isNewPasswordVisible,
                      isReadOnly: !isPasswordValidated, // 👈 Disable until validated
                      onToggleVisibility: () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModernDialogButton(
                      onPressed: () => Get.back(),
                      text: 'Cancel',
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModernDialogButton(
                      onPressed: isSubmitEnabled ? widget.controller.updateUser : () {},
                      text: 'Submit',
                      gradient: isSubmitEnabled ? [AppTheme.primaryTeal, AppTheme.lightTeal] : null,
                      isDisabled: !isSubmitEnabled,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Dialog Button
class _ModernDialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final List<Color>? gradient;
  final bool isDisabled;

  const _ModernDialogButton({
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.gradient,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : (isOutlined ? null : (gradient != null ? LinearGradient(colors: gradient!) : null)),
        border: isOutlined ? Border.all(color: Colors.grey.withOpacity(0.3)) : null,
        color: isDisabled ? Colors.grey.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: isDisabled
            ? Colors.transparent
            : (isOutlined ? Colors.transparent : (gradient == null ? AppTheme.primaryTeal : Colors.transparent)),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDisabled ? null : onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? Colors.grey.withOpacity(0.6)
                    : (isOutlined ? AppTheme.onSurface : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Text Field with Helper Text Support and Password Toggle
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isReadOnly;
  final String? helperText;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isReadOnly = false,
    this.helperText,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            color: isReadOnly ? Colors.grey.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            readOnly: isReadOnly,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isReadOnly ? AppTheme.onSurface.withOpacity(0.6) : AppTheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.6),
              ),
              prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryTeal),
              suffixIcon: isPassword && !isReadOnly // 👈 Hide toggle when readonly
                  ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: Colors.grey.withOpacity(0.6),
                ),
                onPressed: onToggleVisibility,
              )
                  : (isReadOnly && isPassword
                  ? Icon(Icons.lock, size: 18, color: Colors.grey.withOpacity(0.4))
                  : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}