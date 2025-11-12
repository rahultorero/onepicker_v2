import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../controllers/DashboardController.dart';
import '../model/DashBoardDataModel.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math' as math;

import '../theme/AppTheme.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../controllers/DashboardController.dart';
import '../model/DashBoardDataModel.dart';
import '../theme/AppTheme.dart';
import 'dart:math' as math;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(controller),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsOverview(controller),
                _buildFilterSection(controller),
                _buildPaginationControls(controller),
              ],
            ),
          ),
          _buildOrdersSliverList(controller),
          // REMOVED: The problematic detail view - we'll use bottom sheet instead
        ],
      ),
    );
  }

  void _showDetailBottomSheet(DBStateData item, int index) {
    // Set the selected index for UI feedback
    Get.find<DashboardController>().selectedItemIndex.value = index;

    // Load detail data first, then show sheet
    Get.find<DashboardController>().getDbStateDtlForBottomSheet(item.sIId!, () {
      Get.bottomSheet(
        _buildDetailBottomSheet(item),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    });
  }


  Widget _buildDetailBottomSheet(DBStateData selectedItem) {
    final controller = Get.find<DashboardController>();

    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invoice Details: ${selectedItem.invNo ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                    controller.selectedItemIndex.value = -1;
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Party', selectedItem.party ?? 'N/A', Icons.business),
                  const SizedBox(height: 8),
                  _buildInfoRow('Area', selectedItem.area ?? 'N/A', Icons.location_on),
                  const SizedBox(height: 8),
                  _buildInfoRow('Delivery Type', selectedItem.delType ?? 'N/A', Icons.local_shipping),
                  const SizedBox(height: 16),

                  // Print buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (selectedItem.sIId != null) {
                              controller.triggerPrint(selectedItem.sIId!, 'printinv');
                            }
                          },
                          icon: const Icon(Icons.receipt, size: 16),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Sales Invoice', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                (selectedItem.printed ?? 0) > 0 ? 'Printed' : 'Not Printed',
                                style: const TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (selectedItem.printed ?? 0) > 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (selectedItem.sIId != null) {
                              controller.triggerPrint(selectedItem.sIId!, 'printpp');
                            }
                          },
                          icon: const Icon(Icons.inventory, size: 16),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Packing Slip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                (selectedItem.plprn ?? 0) > 0 ? 'Printed' : 'Not Printed',
                                style: const TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (selectedItem.plprn ?? 0) > 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Detail list
                  Expanded(
                    child: Obx(() {
                      final detailList = controller.dbStateDtlList.value;
                      final workingWithPickupManager = controller.workingWithPickupManager.value;

                      if (detailList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No detail data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Item Details:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: detailList.length,
                              itemBuilder: (context, index) {
                                final detail = detailList[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF404040),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'LOCA: ${detail.loca ?? 'N/A'}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                      _buildStatusIcon('Pick', (detail.pick ?? 0) == 1),
                                      const SizedBox(width: 12),
                                      if (workingWithPickupManager) ...[
                                        _buildStatusIcon('LSN', (detail.lsn ?? 0) == 1),
                                        const SizedBox(width: 12),
                                        _buildStatusIcon('PickM', (detail.pickM ?? 0) == 1),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String label, bool isActive) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 8)),
      ],
    );
  }

  Widget _buildDetailViewNonReactive(DashboardController controller) {
    // Get data once - no reactive listening
    final selectedIndex = controller.selectedItemIndex.value;
    final filteredList = controller.filteredStateList.toList(); // Convert to static list
    final detailList = controller.dbStateDtlList.value.toList(); // Convert to static list
    final workingWithPickupManager = controller.workingWithPickupManager.value;

    print('Building detail view FINAL - selectedIndex: $selectedIndex');

    if (selectedIndex == -1 || selectedIndex >= filteredList.length) {
      return const SizedBox.shrink();
    }

    final selectedItem = filteredList[selectedIndex];

    return Container( // Use Container instead of AnimatedContainer
      height: 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailHeaderFinal(selectedItem, controller),
          Expanded(
            child: _buildDetailContentFinal(selectedItem, controller, detailList, workingWithPickupManager),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeaderFinal(DBStateData selectedItem, DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Invoice Details: ${selectedItem.invNo ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.closeDetailViewFinal(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContentFinal(DBStateData selectedItem, DashboardController controller,
      List<DbStateDtlData> detailList, bool workingWithPickupManager) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        ],
      ),
    );
  }

  Widget _buildPrintButtonsFinal(DBStateData selectedItem, DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildPrintButton(
            'Sales Invoice',
            (selectedItem.printed ?? 0) > 0,
            Icons.receipt,
                () {
              if (selectedItem.sIId != null) {
                controller.triggerPrint(selectedItem.sIId!, 'printinv');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPrintButton(
            'Packing Slip',
            (selectedItem.plprn ?? 0) > 0,
            Icons.inventory,
                () {
              if (selectedItem.sIId != null) {
                controller.triggerPrint(selectedItem.sIId!, 'printpp');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailListFinal(List<DbStateDtlData> detailList, bool workingWithPickupManager) {
    if (detailList.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No detail data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Item Details:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: detailList.length,
              itemBuilder: (context, index) {
                final detail = detailList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF404040),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'LOCA: ${detail.loca ?? 'N/A'}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      _buildDetailStatusIcon('Pick', (detail.pick ?? 0) == 1),
                      const SizedBox(width: 12),
                      if (workingWithPickupManager) ...[
                        _buildDetailStatusIcon('LSN', (detail.lsn ?? 0) == 1),
                        const SizedBox(width: 12),
                        _buildDetailStatusIcon('PickM', (detail.pickM ?? 0) ==
                            1),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSliverAppBar(DashboardController controller) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryTeal,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double percent = ((constraints.maxHeight - kToolbarHeight) /
              (140 - kToolbarHeight)).clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryTeal,
                    AppTheme.primaryTeal.withOpacity(0.8),
                    const Color(0xFF1A5F5F),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                // Add subtle pattern overlay
                image: const DecorationImage(
                  image: AssetImage('assets/images/merger_2.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Stack(
                children: [
                  // Animated background elements
                  Positioned(
                    top: -20,
                    right: -30,
                    child: Opacity(
                      opacity: percent * 0.1,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 60,
                    child: Opacity(
                      opacity: percent * 0.05,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingLarge,
                        vertical: AppTheme.paddingMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Animated title with scale effect
                                    Transform.scale(
                                      scale: 1.0 + (percent * 0.1),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Main DashBoard',
                                        style: AppTheme.titleLarge.copyWith(
                                          color: Colors.white,
                                          fontSize: 16 + (percent * 4),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 6 * percent),

                                    // Animated subtitle
                                    AnimatedOpacity(
                                      duration: const Duration(milliseconds: 200),
                                      opacity: percent,
                                      child: Obx(() => Text(
                                        controller.formattedDate,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                    ),

                                    // Optional: Add a welcome message
                                    if (percent > 0.5)
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: (percent - 0.5) * 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Welcome back!',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Action buttons with improved styling
                              AnimatedScale(
                                scale: 0.9 + (percent * 0.1),
                                duration: const Duration(milliseconds: 200),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildDateSelector(controller, percent),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Optional: Add a progress indicator or stats preview
                          if (percent > 0.7)
                            AnimatedSlide(
                              offset: Offset(0, 1 - percent),
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'All systems running smoothly',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Enhanced date selector button
  Widget _buildDateSelector(DashboardController controller, [double percent = 1.0]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>  _selectDate(controller),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Select Date',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(DashboardController controller) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.loadInitialData();
    }
  }


// Enhanced refresh button
  // Widget _buildDateSelector(DashboardController controller) {
  //   return GestureDetector(
  //     onTap: () => _selectDate(controller),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(
  //         horizontal: AppTheme.paddingMedium,
  //         vertical: AppTheme.paddingSmall,
  //       ),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.2),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.white.withOpacity(0.3)),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(Icons.calendar_today, color: Colors.white, size: 16),
  //           const SizedBox(width: 8),
  //           Text(
  //             'Change',
  //             style: AppTheme.labelMedium.copyWith(color: Colors.white),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildRefreshButton(DashboardController controller) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.2),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.white.withOpacity(0.3)),
  //     ),
  //     child: IconButton(
  //       onPressed: controller.loadInitialData,
  //       icon: const Icon(Icons.refresh, color: Colors.white),
  //       iconSize: 20,
  //     ),
  //   );
  // }


  Widget _buildStatsOverview(DashboardController controller) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.marginLarge),
      child: Obx(() {
        final data = controller.dbCountData.value;
        if (data == null) {
          return _buildLoadingStats();
        }
        return _buildStatsGrid(data, controller);
      }),
    );
  }

  Widget _buildLoadingStats() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DBcountData data, DashboardController controller) {
    final total = data.total ?? 0;
    final stats = [
      _StatItem('Total', total, total, AppTheme.primaryTeal, Icons.inventory),
      _StatItem('Tray', data.tray ?? 0, total, AppTheme.lightTeal, Icons.inventory_2),
      _StatItem('Picked', data.picked ?? 0, total, AppTheme.coralPink, Icons.shopping_cart),
      if (controller.workingWithPickupManager.value)
        _StatItem('Pick Mgr', data.mPicked ?? 0, total, AppTheme.amberGold, Icons.person),
      _StatItem('Checked', data.checked ?? 0, total, AppTheme.lavender, Icons.check_circle),
      _StatItem('Packed', data.packed ?? 0, total, AppTheme.accentGreen, Icons.backpack),
      _StatItem('Delivered', data.delivered ?? 0, total, AppTheme.sage, Icons.local_shipping),
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.marginMedium),
            child: Text(
              'Overview',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(stat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    final percentage = stat.total > 0 ? (stat.current / stat.total) : 0.0;

    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withOpacity(0.08),
            stat.color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stat.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat.current.toString(),
                style: AppTheme.titleSmall.copyWith(
                  color: stat.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.label,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 3,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: stat.color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashboardController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.marginLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Search',
            style: AppTheme.titleSmall.copyWith(
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSearchField(controller),
              ),
              const SizedBox(width: AppTheme.marginMedium),
              Expanded(
                child: _buildCategoryDropdown(controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(DashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller.searchController,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search orders...',
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingLarge,
            vertical: AppTheme.paddingMedium,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
              ? IconButton(
            onPressed: () {
              controller.searchController.clear();
              controller.searchText.value = '';
              controller.filterData();
            },
            icon: Icon(
              Icons.clear,
              color: AppTheme.onSurfaceVariant,
              size: 18,
            ),
          )
              : const SizedBox()),
        ),
        onChanged: (value) => controller.searchText.value = value,
      ),
    );
  }

  Widget _buildCategoryDropdown(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedCategory.value,
        dropdownColor: AppTheme.surface,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurface),
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.onSurfaceVariant),
        isExpanded: true,
        items: controller.categories.map((category) {
          String displayName = _getCategoryDisplayName(category);
          return DropdownMenuItem(
            value: category,
            child: Text(displayName),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedCategory.value = value;
            controller.filterData();
          }
        },
      )),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'InvNo':
        return 'Invoice';
      case 'TrayNo':
        return 'Tray';
      case 'PName':
        return 'Party';
      case 'Area':
        return 'Area';
      default:
        return category;
    }
  }

  Widget _buildPaginationControls(DashboardController controller) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.marginLarge),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final totalItems = controller.filteredStateList.length;
        final totalPages = controller.totalPages;
        final currentPage = controller.currentPage.value;

        if (totalItems == 0) return const SizedBox();

        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Items per page:',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: controller.itemsPerPage.value,
                    underline: const SizedBox(),
                    items: [10, 20, 50, 100].map((value) =>
                        DropdownMenuItem(value: value, child: Text('$value'))
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeItemsPerPage(value);
                      }
                    },
                  ),
                ),
                const Spacer(),
                Text(
                  'Showing ${controller.startIndex + 1}-${controller.endIndex} of $totalItems',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: currentPage > 1 ? () => controller.goToPage(1) : null,
                    icon: const Icon(Icons.first_page),
                    color: AppTheme.primaryTeal,
                  ),
                  IconButton(
                    onPressed: currentPage > 1 ? () => controller.previousPage() : null,
                    icon: const Icon(Icons.chevron_left),
                    color: AppTheme.primaryTeal,
                  ),
                  ...List.generate(3, (index) {
                    int start = (currentPage - 2).clamp(1, (totalPages - 4).clamp(1, totalPages));
                    int pageNumber = start + index;

                    if (pageNumber > totalPages) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: TextButton(
                        onPressed: () => controller.goToPage(pageNumber),
                        style: TextButton.styleFrom(
                          backgroundColor: pageNumber == currentPage
                              ? AppTheme.primaryTeal
                              : Colors.transparent,
                          foregroundColor: pageNumber == currentPage
                              ? Colors.white
                              : AppTheme.primaryTeal,
                          minimumSize: const Size(40, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('$pageNumber'),
                      ),
                    );
                  }),
                  IconButton(
                    onPressed: currentPage < totalPages ? () => controller.nextPage() : null,
                    icon: const Icon(Icons.chevron_right),
                    color: AppTheme.primaryTeal,
                  ),
                  IconButton(
                    onPressed: currentPage < totalPages
                        ? () => controller.goToPage(totalPages)
                        : null,
                    icon: const Icon(Icons.last_page),
                    color: AppTheme.primaryTeal,
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _buildOrdersSliverList(DashboardController controller) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.marginLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: Row(
                children: [
                  Text(
                    'Orders',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    '${controller.paginatedList.length} of ${controller.filteredStateList.length} items',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  )),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingList();
              }

              if (controller.filteredStateList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.paginatedList.length,
                itemBuilder: (context, paginatedIndex) {
                  final item = controller.paginatedList[paginatedIndex];
                  final originalIndex = controller.filteredStateList.indexOf(item);
                  return _buildOrderCard(item, paginatedIndex, originalIndex, controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(3, (index) => _buildSkeletonCard()),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.marginMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingXLarge),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // keeps it compact
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppTheme.primaryTeal.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Text(
              'No orders found',
              style: AppTheme.titleSmall.copyWith(
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Try adjusting your search criteria or date selection',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildOrderCard(DBStateData item, int paginatedIndex, int originalIndex, DashboardController controller) {
    final isSelected = controller.selectedItemIndex.value == originalIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryTeal.withOpacity(0.15)
                : AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: isSelected ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetailBottomSheet(item, originalIndex), // Direct call
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(item),
                const SizedBox(height: 12),
                _buildOrderInfo(item),
                const SizedBox(height: 16),
                _buildProgressIndicator(item, controller),
                const SizedBox(height: 12),
                _buildOrderFooter(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(DBStateData item) {
    return Column(
      children: [
        _buildInfoDRow(Icons.business, 'Party', item.party ?? 'N/A'),
        if (item.area != null && item.area!.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildInfoDRow(Icons.location_on, 'Area', item.area!),
        ],
      ],
    );
  }

  Widget _buildInfoDRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(DBStateData item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice #${item.invNo ?? 'N/A'}',
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.trayNo != null && item.trayNo!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Tray: ${item.trayNo}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            _buildStatusBadge(
              'Print',
              (item.printed ?? 0) > 0,
              Icons.print,
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(
              'Slip',
              (item.plprn ?? 0) > 0,
              Icons.receipt,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isActive ? AppTheme.success : AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Done' : 'Pending',
            style: AppTheme.labelSmall.copyWith(
              color: isActive ? AppTheme.success : AppTheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressIndicator(DBStateData item, DashboardController controller) {
    final steps = <String>['Picked', 'Checked', 'Packed', 'Delivered'];
    if (controller.workingWithPickupManager.value) {
      steps.insert(1, 'Pick Mgr');
    }

    final currentStep = controller.calculateStepProgress(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline,
              size: 16,
              color: AppTheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Progress',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${currentStep}/${steps.length}',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.success
                                : isCurrent
                                ? AppTheme.primaryTeal
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCompleted || isCurrent
                                  ? Colors.transparent
                                  : AppTheme.onSurfaceVariant.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : isCurrent
                                ? Icons.radio_button_unchecked
                                : Icons.circle,
                            size: 12,
                            color: isCompleted || isCurrent
                                ? Colors.white
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: AppTheme.labelSmall.copyWith(
                            color: isCompleted || isCurrent
                                ? AppTheme.onSurface
                                : AppTheme.onSurfaceVariant,
                            fontWeight: isCompleted || isCurrent
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 20,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.success
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderFooter(DBStateData item) {
    final bgColor = getDeliveryTypeStyle(item.delType);

    return Row(
      children: [
        if (item.iTime != null) ...[
          Icon(
            Icons.access_time,
            size: 14,
            color: AppTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            item.iTime!,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: bgColor['gradientColors'],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.delType ?? 'N/A',
            style: AppTheme.labelSmall.copyWith(
              color:  bgColor['textColor'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // FIXED: Completely rewritten detail view without nested Obx


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


  Widget _buildPrintButton(String label, bool isPrinted, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            isPrinted ? 'Printed' : 'Not Printed',
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrinted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // FIXED: Static version without Obx

  Widget _buildDetailStatusIcon(String label, bool isActive) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 8),
        ),
      ],
    );
  }
}

// Helper class for statistics
class _StatItem {
  final String label;
  final int current;
  final int total;
  final Color color;
  final IconData icon;

  _StatItem(this.label, this.current, this.total, this.color, this.icon);
}