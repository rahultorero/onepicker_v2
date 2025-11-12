import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../controllers/AdminController.dart';
import '../model/UserListModel.dart';
import '../theme/AppTheme.dart';
import '../widget/AppLoader.dart';

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGradient[0],
                      AppTheme.primaryGradient[1],
                      AppTheme.primaryTeal.withOpacity(0.8),
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
                        indicatorColor: AppTheme.primaryTeal,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: AppTheme.primaryTeal,
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
                                    color: AppTheme.warmAccent,
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
                                    color: AppTheme.lightTeal,
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
                AppTheme.lightTeal.withOpacity(0.05),
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // container background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchUsers,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        textAlignVertical: TextAlignVertical.center,
        cursorColor: Colors.white70,
        decoration: InputDecoration(
          hintText: 'Search users by name...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
            size: 18,
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
            padding: EdgeInsets.zero,
            onPressed: controller.clearSearch,
            icon: Icon(
              Icons.clear,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
          )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,  // 👈 disable internal borders
          focusedBorder: InputBorder.none,  // 👈 disable teal/primary highlight
          filled: false,                    // 👈 disable InputDecoration bg
          isCollapsed: true,                // 👈 keeps it tight
          contentPadding: EdgeInsets.zero,  // 👈 no weird spacing
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
            child:  Padding(
              padding: EdgeInsets.all(15),
              child: LoadingIndicator(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? (screenWidth >= 900 ? 3 : 2) : 1;

    return Obx(() => users.isEmpty
        ? _EmptyState(
        isNewUser: isNewUser,
        hasSearchQuery: controller.searchQuery.isNotEmpty)
        : RefreshIndicator(
      onRefresh: controller.fetchUserLists,
      color: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      child: isTablet
          ? _buildGridView(context, crossAxisCount)
          : _buildListView(),
    ));
  }

  Widget _buildListView() {
    return ListView.builder(
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
    );
  }

  Widget _buildGridView(BuildContext context, int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Dynamic spacing
        const spacing = 16.0;

        // ⭐ KEY SOLUTION: Fixed height for cards
        // Adjust this value based on your _UserCard content
        final cardHeight = 150.0;  // Set appropriate height for your card design

        // Calculate available width per card
        const horizontalPadding = 40.0; // 20 * 2
        final totalSpacing = spacing * (crossAxisCount - 1);
        final availableWidth = screenWidth - horizontalPadding - totalSpacing;
        final cardWidth = availableWidth / crossAxisCount;

        // Calculate aspect ratio dynamically based on actual dimensions
        final childAspectRatio = cardWidth / cardHeight;

        print("User Grid - Columns: $crossAxisCount, CardWidth: $cardWidth, CardHeight: $cardHeight, AspectRatio: $childAspectRatio");

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
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
        );
      },
    );
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
                colors: AppTheme.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              hasSearchQuery ? Icons.search_off : Icons.people_outline,
              size: 60,
              color: AppTheme.primaryTeal.withOpacity(0.4),
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
            color: AppTheme.primaryTeal.withOpacity(0.04),
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
                                      colors: AppTheme.accentGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(10), // Reduced from 12
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGreen.withOpacity(0.2),
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
                          color: AppTheme.primaryTeal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8), // Reduced from 10
                          border: Border.all(
                            color: AppTheme.primaryTeal.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 90, // adjust as needed
                      child: _ModernActionButton(
                        onPressed: () => controller.showEditDialog(user),
                        text: 'Edit',
                        icon: Icons.edit_outlined,
                        gradient: [
                          AppTheme.lightTeal,
                          AppTheme.lightTeal.withOpacity(0.8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 90,
                      child: _ModernActionButton(
                        onPressed: () => controller.showRoleAssignmentDialog(user),
                        text: 'Roles',
                        icon: Icons.assignment_outlined,
                        gradient: [
                          AppTheme.primaryTeal,
                          AppTheme.primaryTeal.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getAvatarColors(int index) {
    final colorSets = [
      AppTheme.primaryGradient,
      AppTheme.bronzeGradient,
      AppTheme.accentGradient,
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
        height: 480, // Fixed height for better control
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
            // Fixed Header
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
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit User',
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
                      controller: controller.nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      hint: 'Enter full name',
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: controller.usernameController,
                      label: 'Username',
                      icon: Icons.account_circle_outlined,
                      hint: 'Enter username',
                      allowSpaces: false,
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: controller.passwordController,
                      label: 'New Password',
                      icon: Icons.lock_outline,
                      hint: 'Enter new password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_clock_outlined,
                      hint: 'Confirm password',
                      isPassword: true,
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
                      onPressed: controller.updateUser,
                      text: 'Update User',
                      gradient: [AppTheme.primaryTeal, AppTheme.lightTeal],
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


class RoleAssignmentDialog extends StatelessWidget {
  final AdminController controller;

  const RoleAssignmentDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        height: 700, // Increased height to accommodate dropdowns
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
            // Fixed Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
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
                    child: const Icon(
                        Icons.assignment, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign Roles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'For ${controller.currentEditingUser?.eName ??
                              'User'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                        Icons.close, color: Colors.white, size: 18),
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

            // Info Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryTeal,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select multiple roles and assign company/branch access',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Roles Section
                    Text(
                      'User Roles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() =>
                        Column(
                          children: controller.selectedRoles.keys.map((role) {
                            final isSelected = controller.selectedRoles[role]!;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryTeal.withOpacity(0.08)
                                    : Colors.grey.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryTeal
                                      : Colors.grey.withOpacity(0.2),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    controller.selectedRoles[role] =
                                    !isSelected;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.primaryTeal
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                                4),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppTheme.primaryTeal
                                                  : Colors.grey.withOpacity(
                                                  0.4),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                role,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppTheme.primaryTeal
                                                      : AppTheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _getRoleDescription(role),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.onSurface
                                                      .withOpacity(0.6),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius
                                                  .circular(6),
                                            ),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: AppTheme.primaryTeal,
                                              size: 16,
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

                    const SizedBox(height: 24),

                    // Company & Branch Section
                    Text(
                      'Company & Branch Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Company Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Obx(() =>
                                DropdownButton<int>(
                                  value:  controller.selectedCompanyId.value,
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: Text(
                                    'Select Company',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.onSurface.withOpacity(
                                          0.5),
                                    ),
                                  ),
                                  items: controller.companyList.map((company) {
                                    return DropdownMenuItem<int>(
                                      value: company['id'],
                                      child: Text(
                                        company['name'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedCompanyId.value =
                                        value ?? 0;
                                    controller.onCompanySelected(value ?? 0);
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Branch Dropdown
                    Obx(() =>
                        Visibility(
                          visible: controller.showBranchDropdown.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Branch',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurface.withOpacity(
                                          0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  DropdownButton<int>(
                                    value: controller.selectedBranchId.value,
                                    isExpanded: true,
                                    underline: Container(),
                                    hint: Text(
                                      'Select Branch',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.onSurface.withOpacity(
                                            0.5),
                                      ),
                                    ),
                                    items: controller.branchList.map((branch) {
                                      return DropdownMenuItem<int>(
                                        value: branch['id'],
                                        child: Text(
                                          branch['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.onSurface,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      controller.selectedBranchId.value =
                                          value ?? 0;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),

                    const SizedBox(height: 16),
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
                      onPressed: controller.assignRoles,
                      text: 'Assign Roles',
                      gradient: [AppTheme.primaryTeal, AppTheme.lightTeal],
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

String _getRoleDescription(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return 'Full system access and user management';

    case 'tray assigner':
      return 'Assign and manage tray operations';
    case 'picker':
      return 'Item picking and selection';
    case 'picker manager':
      return 'Manage picking operations and staff';
    case 'checker':
      return 'Quality control and verification';
    case 'packer':
      return 'Package and prepare items for dispatch';
    case 'merger':
      return 'Tray merger and operations';
    case 'solver':
      return 'Problem resolution and troubleshooting';
    default:
      return 'Standard user permissions';
  }
}



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
        height: 520, // Fixed height
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
            // Fixed Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.lightTeal, AppTheme.primaryTeal],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'user_avatar_${user.eCode}',
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.eName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                      valueColor: AppTheme.lightTeal,
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
                      onPressed: () {
                        Get.back();
                        controller.showEditDialog(user);
                      },
                      text: 'Edit User',
                      gradient: [AppTheme.lightTeal, AppTheme.lightTeal.withOpacity(0.8)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModernDialogButton(
                      onPressed: () {
                        Get.back();
                        controller.showRoleAssignmentDialog(user);
                      },
                      text: 'Assign Roles',
                      gradient: [AppTheme.primaryTeal, AppTheme.primaryTeal.withOpacity(0.8)],
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

// Helper Widget for Detail Items
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryTeal,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
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

// Improved Modern Dialog Button
class _ModernDialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final List<Color>? gradient;

  const _ModernDialogButton({
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : (gradient != null ? LinearGradient(colors: gradient!) : null),
        border: isOutlined ? Border.all(color: Colors.grey.withOpacity(0.3)) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: isOutlined ? Colors.transparent : (gradient == null ? AppTheme.primaryTeal : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isOutlined ? AppTheme.onSurface : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Improved Modern Text Field (assumed structure)
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isReadOnly;
  final bool allowSpaces; // 👈 NEW: control space input

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isReadOnly = false,
    this.allowSpaces = true, // 👈 default allows spaces
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
            color: Colors.grey.withOpacity(0.05),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            readOnly: isReadOnly,
            inputFormatters: allowSpaces
                ? null
                : [
              FilteringTextInputFormatter.deny(RegExp(r'\s')), // 👈 Block spaces
            ],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.6),
              ),
              prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryTeal),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
// Detail Item Widget

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