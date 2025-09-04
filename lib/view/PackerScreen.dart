import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/PackerController.dart';
import '../model/PickerDataModel.dart';
import '../theme/AppTheme.dart';

class PackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PackerController());

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

  PreferredSizeWidget _buildAppBar(PackerController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.primaryGradient,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Packer List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(() => Text(
                '${controller.filteredPackerList.length} items available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              )),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() => Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${controller.filteredPackerList.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSearchBar(PackerController controller) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by Invoice No or Tray No...',
                hintStyle: TextStyle(
                  color: AppTheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: AppTheme.primaryTeal,
              size: 20,
            ),
            onPressed: controller.clearSearch,
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBody(PackerController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppTheme.primaryTeal,
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
            'Loading packer list...',
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal.withOpacity(0.1),
                  AppTheme.lightTeal.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.inventory_outlined,
              size: 48,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No packer data available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try searching with different keywords'
                : 'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackerGrid(PackerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.filteredPackerList.length,
        itemBuilder: (context, index) {
          final packerData = controller.filteredPackerList[index];
          return CompactPackerCard(
            packerData: packerData,
            index: index,
            onTap: () => controller.onPackerItemTap(packerData),
          );
        },
      ),
    );
  }
}
class CompactPackerCard extends StatefulWidget {
  final PickerData packerData;
  final int index;
  final VoidCallback onTap;

  const CompactPackerCard({
    Key? key,
    required this.packerData,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CompactPackerCard> createState() => _CompactPackerCardState();
}

class _CompactPackerCardState extends State<CompactPackerCard> {
  Color _getBackgroundColor() {
    final delType = widget.packerData.delType?.toUpperCase() ?? '';

    switch (delType) {
      case 'URGENT':
        return const Color(0xFFF50E0E); // Red
      case 'PICK-UP':
        return const Color(0xFF15EE81); // Green
      case 'DELIVERY':
        return const Color(0xFFFFB266); // Orange
      case 'MEDREP':
        return const Color(0xFFEAF207); // Yellow
      case 'COD':
        return const Color(0xFFFF99FF); // Pink
      case 'OUTSTATION':
        return const Color(0xFF99FFFF); // Sky Blue
      default:
        return AppTheme.primaryTeal; // Default teal for packer
    }
  }

  Color _getTextColor() {
    final delType = widget.packerData.delType?.toUpperCase() ?? '';
    return delType == 'URGENT' ? Colors.white : Colors.black;
  }

  List<String> _getTrayNumbers() {
    final trayNo = widget.packerData.trayNo ?? '';
    if (trayNo.isEmpty || trayNo == 'N/A') return [];

    // Split by comma and clean up each tray number
    return trayNo
        .split(',')
        .map((tray) => tray.trim())
        .where((tray) => tray.isNotEmpty)
        .toList();
  }

  void _showTrayModal() {
    final trayNumbers = _getTrayNumbers();
    if (trayNumbers.length <= 1) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Trays',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: AppTheme.onSurface,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trayNumbers.map((trayNo) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.amberGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.amberGold.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        trayNo,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTraySection() {
    final trayNumbers = _getTrayNumbers();

    if (trayNumbers.isEmpty) {
      return _buildSingleTrayRow('N/A', false);
    }

    if (trayNumbers.length == 1) {
      return _buildSingleTrayRow(trayNumbers.first, false);
    }

    // Multiple trays - show first one and count with tap to show modal
    return _buildSingleTrayRow(
      '${trayNumbers.first} (+${trayNumbers.length - 1} more)',
      true,
    );
  }

  Widget _buildSingleTrayRow(String displayText, bool canExpand) {
    return GestureDetector(
      onTap: canExpand ? _showTrayModal : null,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 13,
                  color: AppTheme.amberGold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canExpand) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: AppTheme.amberGold,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.shadowColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          splashColor: AppTheme.primaryTeal.withOpacity(0.1),
          highlightColor: AppTheme.primaryTeal.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Invoice Number with DelType Color Background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.packerData.invNo ?? 'N/A',
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Tray section with modal display for multiple trays
                _buildTraySection(),

                const SizedBox(height: 4),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppTheme.lightTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.packerData.iTime ?? 'N/A',
                      style: TextStyle(
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