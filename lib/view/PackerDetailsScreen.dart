import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onepicker/controllers/PickerController.dart';

import '../controllers/PackerController.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerListDetailModel.dart';
import '../theme/AppTheme.dart';

class PackerDetailsScreen extends StatelessWidget {
  final PickerData packerData;

  const PackerDetailsScreen({
    Key? key,
    required this.packerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PackerController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Packer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '${packerData.invNo} - ${packerData.trayNo}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() {
              final selectedCount = controller.selectedPackerDetails.length;
              final totalCount = controller.packerDetails.length;
              return Text(
                '$selectedCount/$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Select All Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryTeal.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor.withOpacity(0.06),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Obx(() {
                  final isAllSelected = controller.isAllSelected.value;
                  return GestureDetector(
                    onTap: () => controller.toggleSelectAll(),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isAllSelected ? AppTheme.primaryTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryTeal,
                          width: 2,
                        ),
                      ),
                      child: isAllSelected
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                          : null,
                    ),
                  );
                }),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select All Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.lightTeal, AppTheme.accentGreen],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Text(
                    '${controller.packerDetails.length} items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingPackerDetails.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryTeal,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading details...',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.packerDetails.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppTheme.primaryTeal,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No details available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.packerDetails.length,
                itemBuilder: (context, index) {
                  final detail = controller.packerDetails[index];
                  return PackerDetailCard(
                    detail: detail,
                    index: index,
                    onTap: () => controller.togglePackerDetailSelection(detail),
                  );
                },
              );
            }),
          ),

          // Submit Button - ONLY show when ALL items are selected
          Obx(() {
            // Show button only when ALL items are selected (not just some)
            final allSelected = controller.isAllSelected.value;
            final hasItems = controller.packerDetails.isNotEmpty;
            final selectedCount = controller.selectedPackerDetails.length;
            final totalCount = controller.packerDetails.length;

            // Only show if we have items AND all items are selected
            if (!hasItems || !allSelected || selectedCount != totalCount) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.submitSelectedItems(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Submit All ${totalCount} Items',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Updated Packer Detail Card with selection functionality
class PackerDetailCard extends StatelessWidget {
  final PickerMenuDetail detail;
  final int index;
  final VoidCallback? onTap;

  const PackerDetailCard({
    Key? key,
    required this.detail,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PackerController>();
    final pickerController = Get.put(PickerController());

    return Obx(() {
      final isSelected = controller.selectedPackerDetails.contains(detail);

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryTeal
                  : AppTheme.primaryTeal.withOpacity(0.15),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.primaryTeal.withOpacity(0.2)
                    : AppTheme.shadowColor.withOpacity(0.06),
                blurRadius: isSelected ? 12 : 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Selection overlay
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Checkbox, Location, Item Name, Quantity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2, right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.primaryTeal,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                              : null,
                        ),

                        // Location badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.lightTeal, AppTheme.accentGreen],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${detail.loca ?? 'N/A'}-${detail.locn ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Item name and packing
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                child: Text(
                                  detail.itemName ?? 'Unknown Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppTheme.primaryTeal
                                        : AppTheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => pickerController.showItemStockDetail(
                                  detail.itemDetailId ?? 0,
                                  detail.itemName.toString(),
                                ),
                              ),
                              if (detail.packing != null)
                                Text(
                                  detail.packing!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Quantity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppTheme.goldGradient,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${detail.tQty ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Bottom row: Compact details in a single row
                    Row(
                      children: [
                        // Batch
                        Expanded(
                          flex: 2,
                          child: _buildCompactDetail(
                            Icons.batch_prediction,
                            detail.batchNo ?? 'N/A',
                            AppTheme.lavender,
                            isSelected,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Expiry
                        Expanded(
                          flex: 2,
                          child: _buildCompactDetail(
                            Icons.schedule,
                            detail.sExpDate ?? 'N/A',
                            AppTheme.coralPink,
                            isSelected,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // MRP
                        Expanded(
                          flex: 2,
                          child: _buildCompactDetail(
                            Icons.currency_rupee,
                            detail.mrp != null ? '₹${detail.mrp}' : 'N/A',
                            AppTheme.accentGreen,
                            isSelected,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCompactDetail(IconData icon, String value, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.15)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? color.withOpacity(0.4)
              : color.withOpacity(0.2),
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}