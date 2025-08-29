import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/PickerController.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerMenuDetailModel.dart';
import '../theme/AppTheme.dart';

class PickerListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PickerController>();

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppTheme.primaryBlue,
      child: Obx(() {
        if (controller.isLoadingPickerList.value && controller.pickerList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading picker list...',
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

        if (controller.pickerList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No picker data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        // Split Screen Layout
        return Row(
          children: [
            // Left Side - Picker List (40% of screen)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [AppTheme.primaryBlue.withOpacity(0.1), Colors.white],
                  //     ),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //         Icons.list_alt,
                  //         color: AppTheme.primaryBlue,
                  //         size: 15,
                  //       ),
                  //       const SizedBox(width: 8),
                  //       Text(
                  //         'Picker List (${controller.pickerList.length})',
                  //         style: const TextStyle(
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.w700,
                  //           color: AppTheme.onSurface,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemCount: controller.pickerList.length,
                      itemBuilder: (context, index) {
                        final pickerData = controller.pickerList[index];
                        return CompactPickerCard(
                          pickerData: pickerData,
                          index: index,
                          isSelected: controller.selectedPickerIndex.value == index,
                          onTap: () => controller.onPickerItemSelect(index, pickerData),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              color: AppTheme.primaryBlue.withOpacity(0.2),
            ),

            // Right Side - Details (60% of screen)
            Expanded(
              flex: 6,
              child: Container(
                color: AppTheme.surface.withOpacity(0.3),
                child: Obx(() {
                  if (controller.selectedPickerIndex.value == -1) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 48,
                            color: AppTheme.primaryBlue,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Select a picker item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap any item from the left\nto view its details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.isLoadingPickerDetails.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
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

                  if (controller.pickerDetails.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppTheme.primaryBlue,
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

                  final selectedPicker = controller.pickerList[controller.selectedPickerIndex.value];

                  return Column(
                    children: [
                      // Details Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invoice: ${selectedPicker.invNo ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Items: ${controller.pickerDetails.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: controller.pickerDetails.length,
                          itemBuilder: (context, index) {
                            final detail = controller.pickerDetails[index];
                            return CompactDetailCard(detail: detail, index: index);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CompactPickerCard extends StatelessWidget {
  final PickerData pickerData;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const CompactPickerCard({
    Key? key,
    required this.pickerData,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.shadowColor.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Number
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'INV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pickerData.invNo ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Tray & Time
                Row(
                  children: [
                    // Tray
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 12,
                            color: AppTheme.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pickerData.trayNo ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppTheme.medicalTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pickerData.iTime ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurface,
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
}

class CompactDetailCard extends StatelessWidget {
  final PickerMenuDetail detail;
  final int index;

  const CompactDetailCard({
    Key? key,
    required this.detail,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with item name and quantity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.itemName ?? 'Unknown Item',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail.packing != null)
                        Text(
                          detail.packing!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.orange, AppTheme.gold],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${detail.tQty ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Location and key details in grid
            Row(
              children: [
                Expanded(
                  child: _buildCompactInfo(
                    '${detail.loca ?? 'N/A'}-${detail.locn ?? 'N/A'}',
                    Icons.location_on,
                    AppTheme.medicalTeal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactInfo(
                    detail.batchNo ?? 'N/A',
                    Icons.batch_prediction,
                    AppTheme.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _buildCompactInfo(
                    detail.sExpDate ?? 'N/A',
                    Icons.schedule,
                    AppTheme.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactInfo(
                    detail.mrp != null ? '₹${detail.mrp!.toStringAsFixed(2)}' : 'N/A',
                    Icons.currency_rupee,
                    AppTheme.mintGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfo(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
