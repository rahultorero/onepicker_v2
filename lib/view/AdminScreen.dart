import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controllers/AdminController.dart';
import '../model/UserListModel.dart';
import '../theme/AppTheme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 230,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back, color: Colors.white),
              //   onPressed: () => Navigator.pop(context),
              // ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGradient[0],
                      AppTheme.primaryGradient[1],
                      AppTheme.medicalTeal.withOpacity(0.8),
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                    child: const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Floating particles animation background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ParticlePainter(),
                        ),
                      ),
                      // Main header content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  const Text(
                                    'Admin Panel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 25,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage users and permissions',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Search Bar
                              const SizedBox(height: 12),

                              _SearchBar(controller: controller),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      TabBar(
                        controller: controller.tabController,
                        indicatorColor: AppTheme.primaryBlue,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 8),
                                const Text('New Users'),
                                Obx(() => controller.newUsers.isNotEmpty
                                    ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 20),
                                  child: Text(
                                    '${controller.newUsers.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                    : const SizedBox()),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people, size: 20),
                                const SizedBox(width: 8),
                                const Text('Existing'),
                                Obx(() => controller.existingUsers.isNotEmpty
                                    ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.medicalTeal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 20),
                                  child: Text(
                                    '${controller.existingUsers.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                    : const SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 2.0,
              colors: [
                AppTheme.lightBlue.withOpacity(0.05),
                AppTheme.background,
                AppTheme.background,
              ],
            ),
          ),
          child: Obx(() => controller.isLoading.value
              ? const _LoadingWidget()
              : TabBarView(
            controller: controller.tabController,
            children: [
              _UserListView(
                users: controller.filteredNewUsers,
                isNewUser: true,
                controller: controller,
              ),
              _UserListView(
                users: controller.filteredExistingUsers,
                isNewUser: false,
                controller: controller,
              ),
            ],
          )),
        ),
      ),
    );
  }


}

// Enhanced Search Bar
class _SearchBar extends StatelessWidget {
  final AdminController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38, // Reduced from 42
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18), // Reduced from 21
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: controller.searchUsers,
        style: const TextStyle(color: Colors.white, fontSize: 12), // Reduced from 14
        decoration: InputDecoration(
          hintText: 'Search users by name...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14, // Reduced from 14
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.8),
            size: 16, // Reduced from 18
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: Icon(
              Icons.clear,
              color: Colors.white.withOpacity(0.8),
              size: 14, // Reduced from 16
            ),
          )
              : const SizedBox()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced from 16,12
        ),
      ),
    );
  }
}
// Custom Loading Widget
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.primaryGradient),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading users...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced User List View Widget
class _UserListView extends StatelessWidget {
  final RxList<UserData> users;
  final bool isNewUser;
  final AdminController controller;

  const _UserListView({
    required this.users,
    required this.isNewUser,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => users.isEmpty
        ? _EmptyState(isNewUser: isNewUser, hasSearchQuery: controller.searchQuery.isNotEmpty)
        : RefreshIndicator(
      onRefresh: controller.fetchUserLists,
      color: AppTheme.primaryBlue,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _UserCard(
              user: users[index],
              isNewUser: isNewUser,
              controller: controller,
              index: index,
            ),
          );
        },
      ),
    ));
  }
}

// Enhanced Empty State
class _EmptyState extends StatelessWidget {
  final bool isNewUser;
  final bool hasSearchQuery;

  const _EmptyState({required this.isNewUser, required this.hasSearchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.medicalTeal.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              hasSearchQuery ? Icons.search_off : Icons.people_outline,
              size: 60,
              color: AppTheme.primaryBlue.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasSearchQuery
                ? 'No users found'
                : isNewUser
                ? 'No new users found'
                : 'No existing users found',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try adjusting your search terms'
                : 'Users will appear here when available',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced User Card Widget
class _UserCard extends StatelessWidget {
  final UserData user;
  final bool isNewUser;
  final AdminController controller;
  final int index;

  const _UserCard({
    required this.user,
    required this.isNewUser,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // Reduced from 18
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.06),
            blurRadius: 12, // Reduced from 16
            offset: const Offset(0, 4), // Reduced from 6
          ),
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.04),
            blurRadius: 24, // Reduced from 32
            offset: const Offset(0, 8), // Reduced from 12
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => controller.showUserDetailsDialog(user),
          child: Padding(
            padding: const EdgeInsets.all(10), // Reduced from 14
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'user_avatar_${user.eCode}',
                      child: Container(
                        width: 36, // Reduced from 44
                        height: 36, // Reduced from 44
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getAvatarColors(index),
                          ),
                          borderRadius: BorderRadius.circular(10), // Reduced from 14
                          boxShadow: [
                            BoxShadow(
                              color: _getAvatarColors(index)[0].withOpacity(0.2),
                              blurRadius: 6, // Reduced from 8
                              offset: const Offset(0, 2), // Reduced from 3
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user.eName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Reduced from 18
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced from 12
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.eName ?? 'Unknown User',
                                  style: TextStyle(
                                    fontSize: 14, // Reduced from 15
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isNewUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced from 8,3
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(10), // Reduced from 12
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accent.withOpacity(0.2),
                                        blurRadius: 4, // Reduced from 6
                                        offset: const Offset(0, 1), // Reduced from 2
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8, // Reduced from 9
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (user.eCode != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 10, // Reduced from 12
                                  color: AppTheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.eCode!,
                                  style: TextStyle(
                                    fontSize: 11, // Reduced from 12
                                    color: AppTheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isNewUser && user.assignedRoles.isNotEmpty) ...[
                  const SizedBox(height: 8), // Reduced from 10
                  Wrap(
                    spacing: 4, // Reduced from 6
                    runSpacing: 3, // Reduced from 4
                    children: user.assignedRoles.take(3).map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced from 8,4
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8), // Reduced from 10
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 9, // Reduced from 10
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList()
                      ..addAll(user.assignedRoles.length > 3
                          ? [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced
                          decoration: BoxDecoration(
                            color: AppTheme.onSurface.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8), // Reduced
                          ),
                          child: Text(
                            '+${user.assignedRoles.length - 3}',
                            style: TextStyle(
                              color: AppTheme.onSurface.withOpacity(0.6),
                              fontSize: 9, // Reduced from 10
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ]
                          : []),
                  ),
                ],
                const SizedBox(height: 10), // Reduced from 14
                Row(
                  children: [
                    Expanded(
                      child: _ModernActionButton(
                        onPressed: () => controller.showEditDialog(user),
                        text: 'Edit',
                        icon: Icons.edit_outlined,
                        gradient: [AppTheme.medicalTeal, AppTheme.medicalTeal.withOpacity(0.8)],
                      ),
                    ),
                    const SizedBox(width: 6), // Reduced from 8
                    Expanded(
                      child: _ModernActionButton(
                        onPressed: () => controller.showRoleAssignmentDialog(user),
                        text: 'Roles',
                        icon: Icons.assignment_outlined,
                        gradient: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getAvatarColors(int index) {
    final colorSets = [
      [AppTheme.primaryBlue, AppTheme.medicalTeal],
      [AppTheme.medicalTeal, AppTheme.accent],
      [AppTheme.accent, AppTheme.primaryBlue],
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF59E0B)],
    ];
    return colorSets[index % colorSets.length];
  }
}
// Modern Action Button Widget
class _ModernActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final List<Color> gradient;

  const _ModernActionButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, // Reduced from 44
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(12), // Reduced from 16
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8, // Reduced from 12
            offset: const Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16), // Reduced from 18
              const SizedBox(width: 6), // Reduced from 8
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Reduced from 14
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Enhanced Edit User Dialog
class EditUserDialog extends StatelessWidget {
  final AdminController controller;

  const EditUserDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500), // Reduced from 600
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Reduced from 28
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20, // Reduced from 30
              spreadRadius: 0,
              offset: const Offset(0, 12), // Reduced from 20
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16), // Reduced from 24
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGradient[0], AppTheme.primaryGradient[1]],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), // Reduced from 28
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12), // Reduced from 16
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20), // Reduced from 24
                  ),
                  const SizedBox(width: 12), // Reduced from 16
                  const Expanded(
                    child: Text(
                      'Edit User',
                      style: TextStyle(
                        fontSize: 20, // Reduced from 24
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20), // Reduced from 24
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Reduced from 12
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Reduced from 24
                child: Column(
                  children: [
                    _ModernTextField(
                      controller: controller.nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      hint: 'Enter full name',
                    ),
                    const SizedBox(height: 16), // Reduced from 20
                    _ModernTextField(
                      controller: controller.usernameController,
                      label: 'Username',
                      icon: Icons.account_circle_outlined,
                      hint: 'Enter username',
                    ),
                    const SizedBox(height: 16), // Reduced from 20
                    _ModernTextField(
                      controller: controller.passwordController,
                      label: 'New Password',
                      icon: Icons.lock_outline,
                      hint: 'Enter new password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 16), // Reduced from 20
                    _ModernTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_clock_outlined,
                      hint: 'Confirm password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 24), // Reduced from 32
                    Row(
                      children: [
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: () => Get.back(),
                            text: 'Cancel',
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12), // Reduced from 16
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: controller.updateUser,
                            text: 'Update User',
                            gradient: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Enhanced Role Assignment Dialog
class RoleAssignmentDialog extends StatelessWidget {
  final AdminController controller;

  const RoleAssignmentDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.assignment, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign Roles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For ${controller.currentEditingUser?.eName ?? 'User'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select multiple roles to assign to this user',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(() => Column(
                        children: controller.selectedRoles.keys.map((role) {
                          final isSelected = controller.selectedRoles[role]!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBlue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  controller.selectedRoles[role] = !isSelected;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.primaryBlue
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primaryBlue
                                                : Colors.grey.withOpacity(0.4),
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              role,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? AppTheme.primaryBlue
                                                    : AppTheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getRoleDescription(role),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.onSurface.withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppTheme.primaryBlue,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: () => Get.back(),
                            text: 'Cancel',
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: controller.assignRoles,
                            text: 'Assign Roles',
                            gradient: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                          ),
                        ),
                      ],
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

  String _getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Full system access and user management';
      case 'doctor':
        return 'Medical consultation and patient care';
      case 'nurse':
        return 'Patient care and medical assistance';
      case 'receptionist':
        return 'Front desk operations and scheduling';
      case 'manager':
        return 'Department management and oversight';
      default:
        return 'Standard user permissions';
    }
  }
}

// User Details Dialog
class UserDetailsDialog extends StatelessWidget {
  final AdminController controller;
  final UserData user;

  const UserDetailsDialog({required this.controller, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.medicalTeal, AppTheme.primaryBlue],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'user_avatar_${user.eCode}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (user.eName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.eName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItem(
                      icon: Icons.badge_outlined,
                      title: 'User Code',
                      value: user.eCode ?? 'Not assigned',
                    ),

                    const SizedBox(height: 16),

                    _DetailItem(
                      icon: Icons.assignment_ind_outlined,
                      title: 'Assigned Roles',
                      value: user.assignedRoles.isEmpty
                          ? 'No roles assigned'
                          : user.assignedRoles.join(', '),
                    ),

                    const SizedBox(height: 16),

                    _DetailItem(
                      icon: Icons.access_time_outlined,
                      title: 'Account Status',
                      value: 'Active',
                      valueColor: AppTheme.medicalTeal,
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: () {
                              Get.back();
                              controller.showEditDialog(user);
                            },
                            text: 'Edit User',
                            gradient: [AppTheme.medicalTeal, AppTheme.medicalTeal.withOpacity(0.8)],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ModernDialogButton(
                            onPressed: () {
                              Get.back();
                              controller.showRoleAssignmentDialog(user);
                            },
                            text: 'Assign Roles',
                            gradient: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detail Item Widget
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Dialog Button Widget
class _ModernDialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final List<Color>? gradient;
  final bool isOutlined;

  const _ModernDialogButton({
    required this.onPressed,
    required this.text,
    this.gradient,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.onSurface.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: AppTheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient ?? [AppTheme.primaryBlue, AppTheme.primaryBlue]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient?[0] ?? AppTheme.primaryBlue).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Text Field Widget
class _ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12, // Reduced from 14
            color: AppTheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Container(
          decoration: BoxDecoration(
            color: _isFocused
                ? AppTheme.primaryBlue.withOpacity(0.05)
                : AppTheme.lightBlue.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12), // Reduced from 16
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primaryBlue
                  : AppTheme.primaryBlue.withOpacity(0.2),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) => setState(() {}),
            onTap: () => setState(() => _isFocused = true),
            onTapOutside: (_) => setState(() => _isFocused = false),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.4),
                fontSize: 14, // Reduced from 16
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10), // Reduced from 12
                child: Icon(
                  widget.icon,
                  color: _isFocused
                      ? AppTheme.primaryBlue
                      : AppTheme.primaryBlue.withOpacity(0.6),
                  size: 20, // Reduced from 22
                ),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                onPressed: () => setState(() => _obscureText = !_obscureText),
                icon: Icon(
                  _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.primaryBlue.withOpacity(0.6),
                  size: 20, // Reduced from 22
                ),
              )
                  : widget.controller.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
                icon: Icon(
                  Icons.clear,
                  color: AppTheme.onSurface.withOpacity(0.6),
                  size: 18, // Reduced from 20
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced from 16,16
            ),
          ),
        ),
      ],
    );
  }
}
// Particle Painter for animated background
class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating circles
    final circles = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.3),
    ];

    final radii = [30.0, 20.0, 40.0, 25.0, 15.0];

    for (int i = 0; i < circles.length; i++) {
      canvas.drawCircle(circles[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}