import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onepicker/services/services.dart';
import 'package:flutter/services.dart';

import '../controllers/TrayAssignerController.dart';
import '../model/SearchFilterListModel.dart';
import '../model/TrayAssignerModel.dart';
import '../theme/AppTheme.dart';

class TrayAssignerScreen extends StatelessWidget {
  const TrayAssignerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrayAssignerController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          _buildSearchAndFilters(controller),
          Expanded(
            child: _buildTrayGrid(controller),
          ),
        ],
      ),
    );
  }



  PreferredSizeWidget _buildAppBar(TrayAssignerController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.createGradient(
            AppTheme.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.15),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(AppTheme.marginMedium),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tray Assignment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 2),
          Obx(() => Text(
            '${controller.filteredTrayList.length} pending deliveries',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
            ),
          )),
        ],
      ),
      actions: [
        // Live Status Indicator
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated pulsing dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildSearchAndFilters(TrayAssignerController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.08)),
            ),
            child: TextField(
              onChanged: (query) => controller.filterSearch(query),
              decoration: const InputDecoration(
                hintText: 'Search invoice, party, or location...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: controller.filterTypes.map((filterType) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() {
                    final isSelected = controller.selectedFilterType.value == filterType;
                    return FilterChip(
                      label: Text(
                        filterType,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => controller.onFilterTypeChanged(filterType),
                      backgroundColor: Colors.transparent,
                      selectedColor: AppTheme.primaryTeal,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.onSurface.withOpacity(0.2),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      showCheckmark: false,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }),
                );
              }).toList(),
            ),
          ),

          // Dropdown Filter
          Obx(() {
            if (controller.selectedFilterType.value == 'ALL') {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    if (controller.searchFilterList.isNotEmpty) {
                      controller.showFilterDropdown.value = !controller.showFilterDropdown.value;
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: controller.showFilterDropdown.value
                            ? AppTheme.primaryTeal
                            : AppTheme.onSurface.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFilterIcon(controller.selectedFilterType.value),
                          color: AppTheme.primaryTeal,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.selectedFilterValue.value.isEmpty
                                ? 'Select ${controller.selectedFilterType.value.toLowerCase()}'
                                : controller.selectedFilterValue.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: controller.selectedFilterValue.value.isEmpty
                                  ? Colors.grey.shade600
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ),
                        if (controller.isSearchLoading.value)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryTeal,
                            ),
                          )
                        else
                          Icon(
                            controller.showFilterDropdown.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),

                if (controller.showFilterDropdown.value)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 160),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.onSurface.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: controller.searchFilterList.length,
                      itemBuilder: (context, index) {
                        // Sort the list by Pending in descending order
                        final sortedList = List.from(controller.searchFilterList)
                          ..sort((a, b) => (b.Pending ?? 0).compareTo(a.Pending ?? 0));

                        final item = sortedList[index];
                        final displayText = _getDisplayText(item, controller.selectedFilterType.value);

                        return InkWell(
                          onTap: () => controller.onFilterValueSelected(item),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  displayText,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  item.Pending?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrayGrid(TrayAssignerController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryTeal,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16),
              Text(
                'Loading deliveries...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.filteredTrayList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppTheme.primaryTeal.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No deliveries found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth >= 600;
          final crossAxisCount = isTablet ? (screenWidth >= 900 ? 3 : 2) : 1;

          return RefreshIndicator(
            onRefresh: () => controller.fetchSearchFilterList(
                controller.selectedFilterType.value),
            color: AppTheme.primaryTeal,
            child: isTablet
                ? _buildGridLayout(controller, crossAxisCount)
                : _buildListLayout(controller),
          );
        },
      );
    });
  }

  Widget _buildListLayout(TrayAssignerController controller) {
    return ListView.builder(
      controller: controller.scrollController, // ADD THIS
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredTrayList.length,
      itemBuilder: (context, index) {
        final item = controller.filteredTrayList[index];
        return _buildTrayCard(item, controller, index);
      },
    );
  }

  Widget _buildGridLayout(TrayAssignerController controller, int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Dynamic spacing
        const spacing = 16.0;

        // ⭐ KEY SOLUTION: Fixed height for cards
        // Adjust this value based on your tray card content
        final cardHeight = 290.0;  // Set appropriate height for your card design

        // Calculate available width per card
        const horizontalPadding = 32.0; // 16 * 2
        final totalSpacing = spacing * (crossAxisCount - 1);
        final availableWidth = screenWidth - horizontalPadding - totalSpacing;
        final cardWidth = availableWidth / crossAxisCount;

        // Calculate aspect ratio dynamically based on actual dimensions
        final childAspectRatio = cardWidth / cardHeight;

        print("Tray - Columns: $crossAxisCount, CardWidth: $cardWidth, CardHeight: $cardHeight, AspectRatio: $childAspectRatio");

        return GridView.builder(
          controller: controller.scrollController, // ADD THIS
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: controller.filteredTrayList.length,
          itemBuilder: (context, index) {
            final item = controller.filteredTrayList[index];
            return _buildTrayCard(item, controller, index);
          },
        );
      },
    );
  }


  Widget _buildTrayCard(TrayAssignerData item, TrayAssignerController controller, int index) {
    final deliveryType = item.delType ?? '';
    final cardColors = _getDeliveryTypeColors(deliveryType);
    final itemId = item.sIId ?? 0;
    final isOnHold = item.hold ?? false; // Add this line to check hold status

    return Container(
      key: controller.getItemKey(item.sIId ?? 0), // ADD THIS KEY
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.onSurfaceVariant.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColors['primary']!.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Opacity(
        opacity: isOnHold ? 0.6 : 1.0, // Reduce opacity when on hold
        child: Column(
          children: [
            // Enhanced Header with subtle gradient
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOnHold
                      ? [
                    AppTheme.onSurfaceVariant.withOpacity(0.3),
                    AppTheme.onSurfaceVariant.withOpacity(0.1),
                  ]
                      : [
                    AppTheme.surfaceVariant.withOpacity(0.3),
                    AppTheme.background,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  left: BorderSide(
                    color: isOnHold ? AppTheme.onSurfaceVariant : cardColors['primary']!,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Refined index badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cardColors['primary']!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cardColors['primary']!.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#${(index + 1).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cardColors['primary'],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Enhanced delivery type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cardColors['primary'],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: cardColors['primary']!.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      deliveryType,
                      style: TextStyle(
                        color: cardColors['primaryText'],
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  // Add ON HOLD badge
                  if (isOnHold) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warning.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_circle_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ON HOLD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Elegant invoice container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.invNo ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          ApiConfig.dateConvert(item.invDate) ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Refined Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Enhanced Party Info Row
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Refined business icon
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.party ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Enhanced QR scanner button - DISABLED when on hold
                        GestureDetector(
                          onTap: isOnHold ? null : () => controller.openQRScannerForItem(item),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isOnHold
                                    ? [
                                  AppTheme.onSurfaceVariant.withOpacity(0.3),
                                  AppTheme.onSurfaceVariant.withOpacity(0.3),
                                ]
                                    : [
                                  AppTheme.warmAccent,
                                  AppTheme.warmAccent.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isOnHold
                                  ? []
                                  : [
                                BoxShadow(
                                  color: AppTheme.warmAccent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 16,
                              color: isOnHold ? AppTheme.onSurfaceVariant : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Refined Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildRefinedDetailItem(
                          Icons.location_on_rounded,
                          'Location',
                          '${item.area ?? ''} ${item.city ?? ''}',
                          AppTheme.coralPink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRefinedDetailItem(
                          Icons.person_rounded,
                          'Sales Rep',
                          item.sman ?? '',
                          AppTheme.sage,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Refined Error Message
                  GetBuilder<TrayAssignerController>(
                    id: 'error_$itemId',
                    builder: (controller) {
                      final errorMessage = controller.getErrorMessage(itemId);
                      return errorMessage.isNotEmpty
                          ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.error.withOpacity(0.08),
                              AppTheme.error.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.error.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : const SizedBox.shrink();
                    },
                  ),

                  // Refined Tray Numbers
                  GetBuilder<TrayAssignerController>(
                    id: 'trays_$itemId',
                    builder: (controller) {
                      final trayNumbers = controller.getTrayNumbers(itemId);
                      return trayNumbers.isNotEmpty
                          ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cardColors['primary']!.withOpacity(0.06),
                              cardColors['primary']!.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cardColors['primary']!.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: cardColors['primary']!.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    size: 12,
                                    color: cardColors['primary'],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tray Numbers',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cardColors['primary'],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: trayNumbers.map((trayNumber) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.onSurfaceVariant.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        trayNumber,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: isOnHold
                                            ? null
                                            : () {
                                          controller.removeTrayNumber(itemId, trayNumber);
                                          controller.update(['trays_$itemId']);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.error.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 10,
                                            color: isOnHold ? AppTheme.onSurfaceVariant : AppTheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      )
                          : const SizedBox.shrink();
                    },
                  ),

                  // Enhanced Action Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.surfaceVariant.withOpacity(0.4),
                          AppTheme.surfaceVariant.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Refined items count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.info.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.info.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_outlined,
                                size: 12,
                                color: AppTheme.info,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.lItem ?? 21}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.info,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'items',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.info.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Refined tray input - DISABLED when on hold
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: isOnHold ? AppTheme.surfaceVariant.withOpacity(0.3) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isOnHold
                                  ? []
                                  : [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child:TextField(
                              key: ValueKey('tray_input_$itemId'),
                              controller: controller.getTrayController(itemId),
                              focusNode: controller.getTrayFocusNode(itemId),
                              enabled: !isOnHold,
                              textAlign: TextAlign.center,
                              cursorColor: cardColors['primary']!.withOpacity(0.8),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next, // Keeps keyboard open
                              enableInteractiveSelection: true, // ADD THIS - prevents keyboard flicker
                              showCursor: true, // ADD THIS - ensures cursor stays visible
                              autocorrect: false, // ADD THIS - prevents keyboard changing
                              enableSuggestions: false, // ADD THIS - prevents suggestion bar changes
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              onSubmitted: (value) => controller.onTrayNumberSubmitted(item, value),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOnHold ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
                                letterSpacing: 0.3,
                              ),
                              decoration: InputDecoration(
                                hintText: isOnHold ? 'On Hold' : 'Enter Tray Number',
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.onSurfaceVariant.withOpacity(0.3), // Light color when not focused
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: cardColors['primary']!.withOpacity(0.8), // Same as cursor - amber/gold rectangle when focused
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.onSurfaceVariant.withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),

                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Enhanced submit button - DISABLED when on hold
                        GetBuilder<TrayAssignerController>(
                          id: 'submit_$itemId',
                          builder: (controller) {
                            final hasTrays = controller.getTrayNumbers(itemId).isNotEmpty;
                            return hasTrays && !isOnHold
                                ? GestureDetector(
                              onTap: () => controller.handleManualSubmit(item),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.success,
                                      AppTheme.success.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.success.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            )
                                : const SizedBox.shrink();
                          },
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


  Widget _buildRefinedDetailItem(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.06),
            accentColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              size: 11,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    color: accentColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDeliveryTypeColors(String deliveryType) {
    switch (deliveryType.toUpperCase()) {
      case 'URGENT':
        return {
          'primary': AppTheme.error,
          'primaryText': Colors.white,
        };
      case 'PICK-UP':
        return {
          'primary': AppTheme.success,
          'primaryText': Colors.white,
        };
      case 'DELIVERY':
        return {
          'primary': AppTheme.amberGold,
          'primaryText': Colors.white,
        };
      case 'MEDREP':
        return {
          'primary': AppTheme.warning,
          'primaryText': Colors.white,
        };
      case 'COD':
        return {
          'primary': AppTheme.lavender,
          'primaryText': Colors.white,
        };
      case 'OUTSTATION':
        return {
          'primary': AppTheme.info,
          'primaryText': Colors.white,
        };
      default:
        return {
          'primary': AppTheme.primaryTeal,
          'primaryText': Colors.white,
        };
    }
  }

  IconData _getFilterIcon(String filterType) {
    switch (filterType) {
      case 'CITY':
        return Icons.location_city;
      case 'AREA':
        return Icons.place;
      case 'SMAN':
        return Icons.person;
      case 'ROUTE':
        return Icons.route;
      default:
        return Icons.filter_list;
    }
  }

  String _getDisplayText(SearchData item, String filterType) {
    switch (filterType) {
      case 'CITY':
        return item.city ?? '';
      case 'AREA':
        return item.area ?? '';
      case 'SMAN':
        return item.sman ?? '';
      case 'ROUTE':
        return item.deliveryRoute ?? '';
      default:
        return '';
    }
  }
}