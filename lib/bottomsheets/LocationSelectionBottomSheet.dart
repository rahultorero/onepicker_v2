import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/HomeScreenController.dart';
import '../model/LocationModel.dart';
import '../theme/AppTheme.dart';

import 'dart:ui';

import 'dart:ui';

class LocationSelectionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeScreenController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 6),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Location icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.amberGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.coralPink,
                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            'Choose your pickup location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Thin divider
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey[200],
              ),

              const SizedBox(height: 16),

              // Content - Scrollable area
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Location spinner section - Fixed height
                        SizedBox(
                          height: 240,
                          child: Obx(() {
                            if (controller.isLoadingLocations.value) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.amberGold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Loading locations...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (controller.locations.isEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off_rounded,
                                        size: 36,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No locations available',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[200]!, width: 1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Selection background
                                    Positioned(
                                      top: (240 - 44) / 2,
                                      left: 1,
                                      right: 1,
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.amberGold.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppTheme.amberGold.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Main spinner
                                    ListWheelScrollView.useDelegate(
                                      controller: FixedExtentScrollController(
                                        initialItem: controller.locations.indexWhere(
                                              (location) => location == controller.selectedLocation.value,
                                        ) == -1 ? 0 : controller.locations.indexWhere(
                                              (location) => location == controller.selectedLocation.value,
                                        ),
                                      ),
                                      itemExtent: 44,
                                      physics: const FixedExtentScrollPhysics(),
                                      diameterRatio: 2.5,
                                      squeeze: 0.9,
                                      useMagnifier: true,
                                      magnification: 1.1,
                                      onSelectedItemChanged: (index) {
                                        controller.selectedLocation.value = controller.locations[index];
                                      },
                                      childDelegate: ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          if (index >= controller.locations.length) return null;

                                          final location = controller.locations[index];
                                          final isSelected = controller.selectedLocation.value == location;

                                          return Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppTheme.amberGold.withOpacity(0.15)
                                                        : Colors.grey.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on_rounded,
                                                    size: 14,
                                                    color: isSelected
                                                        ? AppTheme.amberGold
                                                        : Colors.grey[500],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    location.loca ?? 'Unknown Location',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                      color: isSelected
                                                          ? AppTheme.onSurface
                                                          : Colors.grey[700],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 16,
                                                    color: AppTheme.amberGold,
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                        childCount: controller.locations.length,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 80), // Space for the fixed button
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed Button at Bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.selectedLocation.value != null
                        ? controller.onNextButtonTap
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedLocation.value != null
                          ? AppTheme.amberGold
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: controller.selectedLocation.value != null ? 2 : 0,
                      shadowColor: AppTheme.amberGold.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: controller.selectedLocation.value != null
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                        if (controller.selectedLocation.value != null) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}