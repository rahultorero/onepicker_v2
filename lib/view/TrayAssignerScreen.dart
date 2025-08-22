import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onepicker/services/services.dart';

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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppTheme.onSurface,
          onPressed: () => Get.back(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tray Assignment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          Obx(() => Text(
            '${controller.filteredTrayList.length} pending deliveries',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          )),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent,
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
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.08)),
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
                      selectedColor: AppTheme.primaryBlue,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.onSurface.withOpacity(0.2),
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
                            ? AppTheme.primaryBlue
                            : AppTheme.onSurface.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFilterIcon(controller.selectedFilterType.value),
                          color: AppTheme.primaryBlue,
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
                              color: AppTheme.primaryBlue,
                            ),
                          )
                        else
                          Icon(
                            controller.showFilterDropdown.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppTheme.primaryBlue,
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
                        final item = controller.searchFilterList[index];
                        final displayText = _getDisplayText(item, controller.selectedFilterType.value);

                        return InkWell(
                          onTap: () => controller.onFilterValueSelected(item),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                color: AppTheme.primaryBlue,
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
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppTheme.primaryBlue.withOpacity(0.6),
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

      return RefreshIndicator(
        onRefresh: controller.fetchTrayAssignerList,
        color: AppTheme.primaryBlue,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredTrayList.length,
          itemBuilder: (context, index) {
            final item = controller.filteredTrayList[index];
            return _buildTrayCard(item, controller, index);
          },
        ),
      );
    });
  }

  Widget _buildTrayCard(TrayAssignerData item, TrayAssignerController controller, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.onSurface.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${(index + 1).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.invNo ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      ApiConfig.dateConvert(item.invDate) ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Party Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.party ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.openQRScannerForItem(item),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          size: 16,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.location_on_outlined,
                        'Location',
                        '${item.area ?? ''} ${item.city ?? ''}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.person_outline,
                        'Sales Rep',
                        item.sman ?? '',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Action Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Items Count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.lItem ?? 21}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'items',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryBlue.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Tray Input
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                            ),
                          ),
                          alignment: Alignment.center, // Ensures content is centered vertically
                          child: TextField(
                            controller: controller.getTrayController(item.sIId ?? 0),
                            textAlign: TextAlign.center, // Center text horizontally
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tray No',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true, // Removes default padding
                              contentPadding: EdgeInsets.zero, // Perfect vertical center
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Delivery Type Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDeliveryTypeColor(item.delType ?? ''),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.delType ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Action Button
                      GestureDetector(
                        onTap: () => controller.handleDelivery(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
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
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
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

  Color _getDeliveryTypeColor(String deliveryType) {
    switch (deliveryType.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'express':
        return Colors.orange;
      case 'priority':
        return AppTheme.accent;
      default:
        return AppTheme.primaryBlue;
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