import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onepicker/widget/AppLoader.dart';

import '../controllers/PickerManagerController.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerMenuDetailModel.dart';
import '../theme/AppTheme.dart';

class PickerManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PickerManagercontroller());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PickerManager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        shadowColor: AppTheme.lavender.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Add camera functionality here
            },
          ),
        ],

        // 🌈 Gradient background here
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppTheme.primaryTeal,
        child: Obx(() {
          if (controller.isLoadingPickerList.value && controller.pickerList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  const SizedBox(height: 16),
                  const Text(
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
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppTheme.primaryTeal,
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

          // Split Screen Layout - Changed to 70/30
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Left Side - Picker List (30% of screen)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              itemCount: controller.pickerList.length,
                              itemBuilder: (context, index) {
                                final pickerData = controller.pickerList[index];
                                return Obx(() => CompactPickerCard(
                                  pickerData: pickerData,
                                  index: index,
                                  isSelected: controller.selectedPickerIndex.value == index,
                                  onTap: () => controller.onPickerItemSelect(index, pickerData),
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      color: AppTheme.primaryTeal.withOpacity(0.2),
                    ),

                    // Right Side - Details (70% of screen)
                    Expanded(
                      flex: 7,
                      child: Stack( // Changed from Container to Stack
                        children: [
                          Container(
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
                                        color: AppTheme.primaryTeal,
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

                              if (controller.pickerDetails.isEmpty) {
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

                              final selectedPicker = controller.pickerList[controller.selectedPickerIndex.value];

                              return Column(
                                children: [
                                  // Details Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                    color: Colors.blueGrey.withOpacity(0.5),
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
                                                'Tray NO: ${selectedPicker.trayNo ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Items: ${controller.pickerDetails.length}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text(
                                                    'Selected: ${controller.selectedDetailIds.length}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
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
                                  // Details List
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: controller.pickerDetails.length,
                                      itemBuilder: (context, index) {
                                        final detail = controller.pickerDetails[index];
                                        return Obx(() => CompactDetailCard(
                                          detail: detail,
                                          index: index,
                                          onSelectionChanged: controller.onDetailSelectionChanged,
                                          isSelected: controller.selectedDetailIds.contains(detail.itemDetailId.toString()),
                                          onTap: controller.showItemStockDetail,
                                        ));
                                      },
                                    ),
                                  ),
                                  // Removed FloatingSubmitButton from here
                                ],
                              );
                            }),
                          ),
                          FloatingSubmitButton(controller: controller), // Now properly positioned in Stack
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}



class CompactPickerCard extends StatefulWidget {
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
  State<CompactPickerCard> createState() => _CompactPickerCardState();
}

class _CompactPickerCardState extends State<CompactPickerCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    final delType = widget.pickerData.delType?.toUpperCase() ?? '';

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
        return Colors.white; // Default white
    }
  }

  Color _getTextColor() {
    final delType = widget.pickerData.delType?.toUpperCase() ?? '';
    return delType == 'URGENT' ? Colors.white : Colors.black;
  }

  List<String> _getTrayNumbers() {
    final trayNo = widget.pickerData.trayNo ?? '';
    if (trayNo.isEmpty || trayNo == 'N/A') return [];

    // Split by comma and clean up each tray number
    return trayNo
        .split(',')
        .map((tray) => tray.trim())
        .where((tray) => tray.isNotEmpty)
        .toList();
  }

  void _toggleExpansion() {
    final trayNumbers = _getTrayNumbers();
    if (trayNumbers.length <= 1) return; // Don't expand if only one or no trays

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildTraySection() {
    final trayNumbers = _getTrayNumbers();

    if (trayNumbers.isEmpty) {
      return _buildSingleTrayRow('N/A', false);
    }

    if (trayNumbers.length == 1) {
      return _buildSingleTrayRow(trayNumbers.first, false);
    }

    // Multiple trays - show first one and expand button
    return Column(
      children: [
        _buildSingleTrayRow(
          '${trayNumbers.first} ${trayNumbers.length > 1 ? '(+${trayNumbers.length - 1})' : ''}',
          true,
        ),
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _expandAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.amberGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.amberGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: trayNumbers.map((trayNo) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.amberGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.amberGold.withOpacity(0.5),
                      width: 0.5,
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
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTrayRow(String displayText, bool canExpand) {
    return GestureDetector(
      onTap: canExpand ? _toggleExpansion : null,
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
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.amberGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTrayManagementDialog() {
    final controller = Get.find<PickerManagercontroller>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TrayManagementDialog(        // <-- This is where TrayManagementDialog is called
          pickerData: widget.pickerData,
          onTrayUpdated: () {
            // Refresh the picker list to show updated tray numbers
            controller.fetchPickerList();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showTrayManagementDialog(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected
                ? AppTheme.primaryTeal
                : AppTheme.shadowColor.withOpacity(0.1),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ]
              : [
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
                children: [
                  // Selection indicator and Invoice Number with DelType Color
                  Row(
                    children: [
                      // Selection indicator
                      if (widget.isSelected)
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (widget.isSelected) const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBackgroundColor(),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: widget.isSelected
                                ? [
                              BoxShadow(
                                color: _getBackgroundColor().withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                                : [],
                          ),
                          child: Text(
                            widget.pickerData.invNo ?? 'N/A',
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tray section with expand/collapse functionality
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
                        widget.pickerData.dTime ?? 'N/A',
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
      ),
    );
  }
}

class CompactDetailCard extends StatelessWidget {
  final PickerMenuDetail detail;
  final int index;
  final Function(String detailId, bool isSelected) onSelectionChanged;
  final bool isSelected;
  bool get isDisabled => detail.pLedId == 0;
  final Function(int itemDetailId, String itemName)? onTap;


  const CompactDetailCard({
    Key? key,
    required this.detail,
    required this.index,
    required this.onSelectionChanged,
    required this.isSelected,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.blueGrey.withOpacity(0.2)
            : (isSelected
            ? AppTheme.primaryTeal.withOpacity(0.01)
            : AppTheme.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryTeal
              : AppTheme.primaryTeal.withOpacity(0.05),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryTeal.withOpacity(0.05)
                : AppTheme.shadowColor.withOpacity(0.04),
            blurRadius: isSelected ? 8 : 4,
            spreadRadius: isSelected ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDisabled
              ? null
              : () => onSelectionChanged(detail.itemDetailId.toString(), !isSelected),
          splashColor: AppTheme.primaryTeal.withOpacity(0.1),
          highlightColor: AppTheme.primaryTeal.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Header with Info Icon
                // 🔹 Header with gradient highlight (like your screenshot)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.chartGradient, // adjust to match your design
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${detail.loca ?? 'N/A'}-${detail.locn ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showItemInfo(context),
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Header with item name, selection checkbox and quantity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection Checkbox with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                        border: Border.all(
                          color: AppTheme.primaryTeal,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child: Text(
                              detail.itemName ?? 'Unknown Item',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                              onTap: () => onTap?.call(
                                  detail.itemDetailId ?? 0,
                                  detail.itemName ?? 'Unknown Item'
                              ),
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
                        color: AppTheme.amberGold,
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

                // Manufacture and Batch details
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfo(
                        detail.dNick ?? 'N/A',
                        Icons.factory,
                        AppTheme.lightTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        detail.batchNo ?? 'N/A',
                        Icons.batch_prediction,
                        AppTheme.lavender,
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
                        AppTheme.amberGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        detail.mrp != null ? '₹${detail.mrp!.toStringAsFixed(2)}' : 'N/A',
                        Icons.currency_rupee,
                        AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Case and Loose values
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfo(
                        'C: ${detail.caseQ?.toString().replaceAll('.0', '') ?? '0'}',
                        Icons.inventory,
                        AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        'L: ${detail.caseL?.toString().replaceAll('.0', '') ?? '0'}',
                        Icons.inventory_2,
                        AppTheme.lightTeal,
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

  void _showItemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Item Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${detail.itemName ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Location: ${detail.loca ?? 'N/A'}-${detail.locn ?? 'N/A'}'),
            Text('Manufacture: ${detail.dNick ?? 'N/A'}'),
            Text('Batch: ${detail.batchNo ?? 'N/A'}'),
            Text('Expiry: ${detail.sExpDate ?? 'N/A'}'),
            Text('MRP: ${detail.mrp != null ? '₹${detail.mrp!.toStringAsFixed(2)}' : 'N/A'}'),
            Text('Quantity: ${detail.tQty ?? 0}'),
            Text('Case: ${detail.caseQ?.toString().replaceAll('.0', '') ?? '0'}'),
            Text('Loose: ${detail.caseL?.toString().replaceAll('.0', '') ?? '0'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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

class TrayManagementDialog extends StatefulWidget {
  final PickerData pickerData;
  final VoidCallback onTrayUpdated;

  const TrayManagementDialog({
    Key? key,
    required this.pickerData,
    required this.onTrayUpdated,
  }) : super(key: key);

  @override
  State<TrayManagementDialog> createState() => _TrayManagementDialogState();
}

class _TrayManagementDialogState extends State<TrayManagementDialog> {
  final TextEditingController _trayController = TextEditingController();
  final FocusNode _trayFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<String> oldTrays = [];
  List<String> newTrays = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeTrays();

    // Listen to focus changes to scroll to input when focused
    _trayFocusNode.addListener(() {
      if (_trayFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _trayController.dispose();
    _trayFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _initializeTrays() {
    final trayNo = widget.pickerData.trayNo ?? '';
    if (trayNo.isNotEmpty && trayNo != 'N/A') {
      oldTrays = trayNo
          .split(',')
          .map((tray) => tray.trim())
          .where((tray) => tray.isNotEmpty)
          .toList();
    }
  }

  String _formatTrayNumber(String input) {
    final length = input.length;
    switch (length) {
      case 1:
        return "9000$input";
      case 2:
        return "900$input";
      case 3:
        return "90$input";
      case 4:
        return "9$input";
      case 5:
        return input;
      default:
        return "";
    }
  }

  void _addTrayNumber() {
    final input = _trayController.text.trim();
    if (input.isEmpty) {
      setState(() {
        errorMessage = "Please enter a tray number";
      });
      return;
    }

    final formattedTray = _formatTrayNumber(input);
    if (formattedTray.isEmpty) {
      setState(() {
        errorMessage = "Invalid tray number format (1-5 digits only)";
      });
      return;
    }

    if (oldTrays.contains(formattedTray)) {
      setState(() {
        errorMessage = "Tray already exists in current list";
      });
      return;
    }

    if (newTrays.contains(formattedTray)) {
      setState(() {
        errorMessage = "Tray already added to new list";
      });
      return;
    }

    setState(() {
      newTrays.add(formattedTray);
      _trayController.clear();
      errorMessage = null;
    });
  }

  void _removeTrayNumber(String trayNumber) {
    setState(() {
      newTrays.remove(trayNumber);
      if (newTrays.isEmpty) {
        errorMessage = null;
      }
    });
  }

  Future<void> _submitTrays() async {
    if (newTrays.isEmpty) {
      setState(() {
        errorMessage = "Please add at least one tray number";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final controller = Get.find<PickerManagercontroller>();
      final allTrays = [...oldTrays, ...newTrays];
      final combinedTrayString = allTrays.join(',');

      await controller.assignTray(
        siId: widget.pickerData.sIId ?? 0,
        trayNumbers: combinedTrayString,
        trayCount: newTrays.length,
      );

      Navigator.of(context).pop();
      widget.onTrayUpdated();

      Get.snackbar(
        'Success',
        '${newTrays.length} tray(s) added successfully!',
        backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
        colorText: AppTheme.accentGreen,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTrayChip(String tray, {bool isRemovable = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isRemovable
            ? AppTheme.accentGreen.withOpacity(0.15)
            : AppTheme.lightTeal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRemovable
              ? AppTheme.accentGreen.withOpacity(0.4)
              : AppTheme.lightTeal.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tray,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          if (isRemovable) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _removeTrayNumber(tray),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: keyboardHeight > 0 ? 20 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: mediaQuery.size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Trays',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.pickerData.invNo ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Existing Trays - Compact
                    if (oldTrays.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.inventory_2,
                              size: 16,
                              color: AppTheme.lightTeal),
                          const SizedBox(width: 6),
                          Text(
                            'Current (${oldTrays.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: oldTrays.map((tray) => _buildTrayChip(tray)).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New Trays - Compact
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 16,
                            color: AppTheme.accentGreen),
                        const SizedBox(width: 6),
                        Text(
                          'New (${newTrays.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // New trays or placeholder
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 50),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGreen.withOpacity(0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: newTrays.isEmpty
                          ? Center(
                        child: Text(
                          'No new trays added yet',
                          style: TextStyle(
                            color: AppTheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      )
                          : Wrap(
                        children: newTrays.map((tray) =>
                            _buildTrayChip(tray, isRemovable: true)
                        ).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input Section - More prominent
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Tray Number',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _trayController,
                                  focusNode: _trayFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter 1-5 digits',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryTeal.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryTeal,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _addTrayNumber(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _addTrayNumber,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Error Message - Improved
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded,
                                color: Colors.red.shade600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Add some bottom padding for keyboard
                    SizedBox(height: keyboardHeight > 0 ? 20 : 0),
                  ],
                ),
              ),
            ),

            // Action Buttons - Always visible
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryTeal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isLoading || newTrays.isEmpty) ? null : _submitTrays,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'Submit${newTrays.isNotEmpty ? ' (${newTrays.length})' : ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
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

// Add this widget to your picker screen

class FloatingSubmitButton extends StatelessWidget {
  final PickerManagercontroller controller;

  const FloatingSubmitButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only show the button when ALL items are selected
      if (!controller.shouldShowSubmitButton) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGreen, AppTheme.accentGreen.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: controller.isLoadingPickerDetails.value
                    ? null
                    : () => controller.showSubmitConfirmationDialog(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.isLoadingPickerDetails.value) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.done_all,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.submitButtonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

