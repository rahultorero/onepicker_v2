import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onepicker/controllers/CheckerController.dart';
import 'package:onepicker/controllers/HomeScreenController.dart';

import '../model/PickerDataModel.dart';
import '../theme/AppTheme.dart';

class CheckerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckerController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(child: _buildBody(controller)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CheckerController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryTeal,
              AppTheme.lightTeal,
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
      leading:Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withOpacity(0.98),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppTheme.onSurface,
          onPressed: () => Get.back(),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Checker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                  '${controller.filteredPackerList.length} items • Ready to check',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${HomeScreenController.selectCamera}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(CheckerController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 16,right: 16,top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Search by Invoice, Tray No, or Type...',
                hintStyle: TextStyle(
                  color: AppTheme.onSurface.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryTeal,
                    size: 18,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: AppTheme.primaryTeal,
                size: 18,
              ),
              onPressed: controller.clearSearch,
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBody(CheckerController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      child: Obx(() {
        if (controller.isLoadingPackerList.value && controller.packerList.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.filteredPackerList.isEmpty) {
          return _buildEmptyState(controller.searchQuery.value.isNotEmpty);
        }

        return _buildPackerGrid(controller);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal.withOpacity(0.1),
                  AppTheme.lightTeal.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryTeal,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading checker list...',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch the data',
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal.withOpacity(0.1),
                  AppTheme.lightTeal.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              size: 56,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No matching results' : 'No items to check',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'Try adjusting your search terms'
                : 'Pull down to refresh and check for new items',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackerGrid(CheckerController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        print("check widthh ------> $screenWidth");

        final isTablet = screenWidth >= 600;

        // Calculate columns based on screen size
        final crossAxisCount = isTablet
            ? (screenWidth >= 900 ? 4 : 3)  // 4 columns for large tablets, 3 for small tablets
            : 2;  // 2 columns for mobile

        // Dynamic spacing
        final spacing = isTablet ? 12.0 : 10.0;

        // ⭐ KEY SOLUTION: Fixed height for cards
        // Adjust this value based on your EnhancedPackerItemCard content
        final cardHeight = isTablet ? 200.0 : 200.0;

        // Calculate available width per card
        final horizontalPadding = 32.0; // 16 * 2
        final totalSpacing = spacing * (crossAxisCount - 1);
        final availableWidth = screenWidth - horizontalPadding - totalSpacing;
        final cardWidth = availableWidth / crossAxisCount;

        // Calculate aspect ratio dynamically based on actual dimensions
        final childAspectRatio = cardWidth / cardHeight;

        print("Columns: $crossAxisCount, CardWidth: $cardWidth, CardHeight: $cardHeight, AspectRatio: $childAspectRatio");

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: controller.filteredPackerList.length,
            itemBuilder: (context, index) {
              final packerData = controller.filteredPackerList[index];
              return EnhancedPackerItemCard(
                packerData: packerData,
                index: index,
                onTap: () => controller.onPackerItemTap(packerData),
              );
            },
          ),
        );
      },
    );
  }

}

class EnhancedPackerItemCard extends StatelessWidget {
  final PickerData packerData;
  final int index;
  final VoidCallback onTap;

  const EnhancedPackerItemCard({
    Key? key,
    required this.packerData,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  // Enhanced delivery type color configuration with better visibility
  Map<String, Map<String, dynamic>> get deliveryTypeConfig => {
    'URGENT': {
      'backgroundColor': const Color(0xFFFF6B6B), // Coral Red - more visible
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      'cardGradientColors': [
        const Color(0xFFFF6B6B).withOpacity(0.03),
        const Color(0xFFFF6B6B).withOpacity(0.08),
        const Color(0xFFFF6B6B).withOpacity(0.12),
      ],
      'icon': Icons.priority_high,
      'label': 'URGENT',
    },
    'PICK-UP': {
      'backgroundColor': const Color(0xFF4ECDC4), // Turquoise Green - fresh
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFF4ECDC4), const Color(0xFF6DD5D0)],
      'cardGradientColors': [
        const Color(0xFF4ECDC4).withOpacity(0.03),
        const Color(0xFF4ECDC4).withOpacity(0.08),
        const Color(0xFF4ECDC4).withOpacity(0.12),
      ],
      'icon': Icons.local_shipping,
      'label': 'PICKUP',
    },
    'DELIVERY': {
      'backgroundColor': const Color(0xFFFFBE0B), // Vibrant Amber
      'textColor': Colors.black,
      'gradientColors': [const Color(0xFFFFBE0B), const Color(0xFFFFC83D)],
      'cardGradientColors': [
        const Color(0xFFFFBE0B).withOpacity(0.03),
        const Color(0xFFFFBE0B).withOpacity(0.08),
        const Color(0xFFFFBE0B).withOpacity(0.12),
      ],
      'icon': Icons.delivery_dining,
      'label': 'DELIVERY',
    },
    'MEDREP': {
      'backgroundColor': const Color(0xFFFB8500), // Burnt Orange
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFFFB8500), const Color(0xFFFC9A33)],
      'cardGradientColors': [
        const Color(0xFFFB8500).withOpacity(0.03),
        const Color(0xFFFB8500).withOpacity(0.08),
        const Color(0xFFFB8500).withOpacity(0.12),
      ],
      'icon': Icons.medical_services,
      'label': 'MEDREP',
    },
    'COD': {
      'backgroundColor': const Color(0xFF8367C7), // Lavender Purple
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFF8367C7), const Color(0xFF9B7ED1)],
      'cardGradientColors': [
        const Color(0xFF8367C7).withOpacity(0.03),
        const Color(0xFF8367C7).withOpacity(0.08),
        const Color(0xFF8367C7).withOpacity(0.12),
      ],
      'icon': Icons.payments,
      'label': 'COD',
    },
    'OUTSTATION': {
      'backgroundColor': const Color(0xFF219EBC), // Ocean Blue
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFF219EBC), const Color(0xFF4AADC7)],
      'cardGradientColors': [
        const Color(0xFF219EBC).withOpacity(0.03),
        const Color(0xFF219EBC).withOpacity(0.08),
        const Color(0xFF219EBC).withOpacity(0.12),
      ],
      'icon': Icons.flight_takeoff,
      'label': 'OUTSTATION',
    },
  };

  Map<String, dynamic> getDeliveryTypeStyle(String? delType) {
    final type = delType?.toUpperCase() ?? '';
    return deliveryTypeConfig[type] ?? {
      'backgroundColor': const Color(0xFF457B9D), // Steel Blue default
      'textColor': Colors.white,
      'gradientColors': [const Color(0xFF457B9D), const Color(0xFF5A8BA8)],
      'cardGradientColors': [
        const Color(0xFF457B9D).withOpacity(0.03),
        const Color(0xFF457B9D).withOpacity(0.08),
        const Color(0xFF457B9D).withOpacity(0.12),
      ],
      'icon': Icons.local_shipping,
      'label': 'STANDARD',
    };
  }

  @override
  Widget build(BuildContext context) {
    final deliveryStyle = getDeliveryTypeStyle(packerData.delType);
    final Color themeColor = deliveryStyle['backgroundColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: deliveryStyle['cardGradientColors'],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: themeColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Color.lerp(themeColor, Colors.white, 0.85)!,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: themeColor.withOpacity(0.1),
          highlightColor: themeColor.withOpacity(0.05),
          child: Column(
            children: [
              // Header with delivery type
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: deliveryStyle['gradientColors'],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        deliveryStyle['icon'],
                        color: deliveryStyle['textColor'],
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deliveryStyle['label'],
                        style: TextStyle(
                          color: deliveryStyle['textColor'],
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: deliveryStyle['textColor'],
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice number
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  themeColor.withOpacity(0.1),
                                  themeColor.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: themeColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'INV',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              packerData.invNo ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tray information
                      _buildInfoRow(
                        Icons.inventory_2_outlined,
                        'Tray',
                        packerData.trayNo ?? 'N/A',
                        themeColor,
                      ),

                      const SizedBox(height: 8),

                      // Time information
                      _buildInfoRow(
                        Icons.schedule_outlined,
                        'Time',
                        _formatTime(packerData.iTime),
                        themeColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 13,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String? time) {
    if (time == null || time == 'N/A') return 'N/A';
    // Add your time formatting logic here if needed
    return time;
  }
}