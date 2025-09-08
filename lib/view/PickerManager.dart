import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onepicker/widget/AppLoader.dart';

import '../controllers/PickerManagerController.dart';
import '../model/PickerDataModel.dart';
import '../model/PickerMenuDetailModel.dart';
import '../model/StockDetailDataModel.dart';
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
                                          onFetchStockDetail: controller.fetchStockDetail,
                                          stockDetailList: controller.stockDetailList,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_getBackgroundColor().withOpacity(0.05), _getBackgroundColor().withOpacity(0.15)],
          ),
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

class CompactDetailCard extends StatefulWidget {
  final PickerMenuDetail detail;
  final int index;
  final Function(String detailId, bool isSelected) onSelectionChanged;
  final bool isSelected;
  final Function(int itemDetailId, String itemName)? onTap;
  final Function(PickerMenuDetail detail)? onRemarkSubmitted;
  final Function(int itemDetailId, String itemName, bool show)? onFetchStockDetail;
  final List<StockDetailData> stockDetailList;

  bool get isDisabled => detail.pLedId == 0;

  const CompactDetailCard({
    Key? key,
    required this.detail,
    required this.index,
    required this.onSelectionChanged,
    required this.isSelected,
    required this.onTap,
    this.onRemarkSubmitted,
    this.onFetchStockDetail,
    required this.stockDetailList,
  }) : super(key: key);

  @override
  State<CompactDetailCard> createState() => _CompactDetailCardState();
}

class _CompactDetailCardState extends State<CompactDetailCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isDisabled
            ? Colors.blueGrey.withOpacity(0.2)
            : (widget.isSelected
            ? AppTheme.primaryTeal.withOpacity(0.01)
            : AppTheme.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.primaryTeal
              : AppTheme.primaryTeal.withOpacity(0.05),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? AppTheme.primaryTeal.withOpacity(0.05)
                : AppTheme.shadowColor.withOpacity(0.04),
            blurRadius: widget.isSelected ? 8 : 4,
            spreadRadius: widget.isSelected ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.isDisabled
              ? null
              : () {
            // If item is being unselected and has a remark, clear the remark
            if (widget.isSelected && (widget.detail.pNote != null &&
                widget.detail.pNote!.isNotEmpty)) {
              setState(() {
                widget.detail.pNote = '';
              });
            }
            widget.onSelectionChanged(
                widget.detail.itemDetailId.toString(), !widget.isSelected);
          },
          splashColor: AppTheme.primaryTeal.withOpacity(0.1),
          highlightColor: AppTheme.primaryTeal.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Header with Info Icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.chartGradient,
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
                          '${widget.detail.loca ?? 'N/A'}-${widget.detail
                              .locn ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Show info icon - opens review dialog
                      if (widget.detail.pNote == null ||
                          widget.detail.pNote!.isEmpty)
                        GestureDetector(
                          onTap: () => _showReviewDialog(context),
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
                        color: widget.isSelected ? AppTheme.primaryTeal : Colors
                            .transparent,
                        border: Border.all(
                          color: AppTheme.primaryTeal,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: widget.isSelected
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
                              widget.detail.itemName ?? 'Unknown Item',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () =>
                                widget.onTap?.call(
                                    widget.detail.itemDetailId ?? 0,
                                    widget.detail.itemName ?? 'Unknown Item'),
                          ),
                          if (widget.detail.packing != null)
                            Text(
                              widget.detail.packing!,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amberGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.detail.tQty ?? 0}',
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
                        widget.detail.dNick ?? 'N/A',
                        Icons.factory,
                        AppTheme.lightTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        widget.detail.batchNo ?? 'N/A',
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
                        widget.detail.sExpDate ?? 'N/A',
                        Icons.schedule,
                        AppTheme.amberGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        widget.detail.mrp != null ? '₹${widget.detail.mrp!
                            .toStringAsFixed(2)}' : 'N/A',
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
                        'C: ${widget.detail.caseQ?.toString().replaceAll(
                            '.0', '') ?? '0'}',
                        Icons.inventory,
                        AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactInfo(
                        'L: ${widget.detail.caseL?.toString().replaceAll(
                            '.0', '') ?? '0'}',
                        Icons.inventory_2,
                        AppTheme.lightTeal,
                      ),
                    ),
                  ],
                ),

                // Remark Section - Only show if pNote is not empty
                if (widget.detail.pNote != null &&
                    widget.detail.pNote!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_alt,
                              size: 14,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Remark',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.detail.pNote!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) async {
    String? selectedReason;
    String? selectedBatch;
    TextEditingController reviewController = TextEditingController();
    bool showBatchList = false;
    bool showReviewField = false;
    String reviewHint = '';
    bool isLoading = false;
    List<String> batchNumbers = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height * 0.85,
                  maxWidth: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.chartGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Item Review',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Select appropriate review reason',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Details Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryTeal.withOpacity(0.05),
                                    AppTheme.lightTeal.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryTeal.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryTeal.withOpacity(
                                        0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              8),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2,
                                          color: AppTheme.primaryTeal,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Item Information',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${widget.detail.itemName ??
                                        'Unknown Item'} ${widget.detail
                                        .packing ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'B: ${widget.detail.batchNo ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.onSurface.withOpacity(
                                          0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'E: ${widget.detail.sExpDate ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.onSurface.withOpacity(
                                          0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'M: ${widget.detail.mrp != null
                                        ? '₹${widget.detail.mrp!
                                        .toStringAsFixed(2)}'
                                        : 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.onSurface.withOpacity(
                                          0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Review Options Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withOpacity(
                                        0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.rate_review,
                                    color: AppTheme.primaryTeal,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Select Review Reason',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Radio Button Options
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryTeal.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildRadioOption(
                                    'Batch change',
                                    'batch_change',
                                    Icons.swap_horiz,
                                    selectedReason,
                                        (value) async {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = true;
                                        showReviewField = true;
                                        reviewHint = 'Enter Batch No';
                                        isLoading = true;
                                      });

                                      // Call the API to fetch stock details
                                      if (widget.onFetchStockDetail != null) {
                                        await widget.onFetchStockDetail!(
                                          widget.detail.itemDetailId ?? 0,
                                          widget.detail.itemName ?? '',
                                          false,
                                        );

                                        setState(() {
                                          batchNumbers = widget.stockDetailList
                                              .map((stock) => "${stock
                                              ?.batchNo} / ₹${stock?.mrp}")
                                              .toList();
                                          isLoading = false;
                                        });
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                  ),

                                  if (showBatchList &&
                                      selectedReason == 'batch_change')
                                    isLoading
                                        ? Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: AppTheme.primaryTeal,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Loading batch data...',
                                            style: TextStyle(
                                              color: AppTheme.onSurface
                                                  .withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        : _buildBatchList(
                                        batchNumbers,
                                        selectedBatch,
                                        setState,
                                        reviewController,
                                            (value) =>
                                            setState(() =>
                                            selectedBatch = value)),

                                  _buildDivider(),

                                  _buildRadioOption(
                                    'Short quantity supplied',
                                    'short_qty',
                                    Icons.remove_circle_outline,
                                    selectedReason,
                                        (value) {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = false;
                                        showReviewField = true;
                                        reviewHint = 'Enter Short Quantity';
                                        reviewController.clear();
                                      });
                                    },
                                  ),

                                  _buildDivider(),

                                  _buildRadioOption(
                                    'Not available',
                                    'not_available',
                                    Icons.cancel_outlined,
                                    selectedReason,
                                        (value) {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = false;
                                        showReviewField = false;
                                        reviewController.clear();
                                      });
                                    },
                                  ),

                                  _buildDivider(),

                                  _buildRadioOption(
                                    'Damage product',
                                    'damage_product',
                                    Icons.broken_image_outlined,
                                    selectedReason,
                                        (value) {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = false;
                                        showReviewField = true;
                                        reviewHint =
                                        'Enter Damage / Breakage Qty';
                                        reviewController.clear();
                                      });
                                    },
                                  ),

                                  _buildDivider(),

                                  _buildRadioOption(
                                    'Supplied multiple batch and quantity',
                                    'multiple',
                                    Icons.dynamic_feed,
                                    selectedReason,
                                        (value) {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = false;
                                        showReviewField = true;
                                        reviewHint =
                                        'Enter Batch and Quantity.\nFormat: batch no - qty, batch no - qty';
                                        reviewController.clear();
                                      });
                                    },
                                  ),

                                  _buildDivider(),

                                  _buildRadioOption(
                                    'None',
                                    'none',
                                    Icons.check_circle_outline,
                                    selectedReason,
                                        (value) {
                                      setState(() {
                                        selectedReason = value;
                                        showBatchList = false;
                                        showReviewField = false;
                                        reviewController.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Review Text Field
                            if (showReviewField) ...[
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryTeal.withOpacity(
                                        0.3),
                                  ),
                                ),
                                child: TextField(
                                  controller: reviewController,
                                  decoration: InputDecoration(
                                    hintText: reviewHint,
                                    hintStyle: TextStyle(
                                      color: AppTheme.onSurface.withOpacity(
                                          0.6),
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.primaryTeal.withOpacity(
                                        0.05),
                                    contentPadding: const EdgeInsets.all(16),
                                    prefixIcon: Icon(
                                      Icons.edit_note,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  maxLines: selectedReason == 'multiple'
                                      ? 3
                                      : 1,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppTheme.primaryTeal.withOpacity(
                                        0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppTheme.onSurface.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _submitReview(
                                    context,
                                    selectedReason,
                                    reviewController.text,
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppTheme.primaryTeal.withOpacity(
                                    0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Submit Review',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
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
          },
        );
      },
    );
  }

  Widget _buildRadioOption(String title,
      String value,
      IconData icon,
      String? selectedValue,
      Function(String?) onChanged,) {
    bool isSelected = selectedValue == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryTeal.withOpacity(0.05) : Colors
            .transparent,
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryTeal.withOpacity(0.1)
                    : AppTheme.primaryTeal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.onSurface
                    .withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryTeal : AppTheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        value: value,
        groupValue: selectedValue,
        onChanged: onChanged,
        dense: false,
        activeColor: AppTheme.primaryTeal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppTheme.primaryTeal.withOpacity(0.1),
    );
  }

  Widget _buildBatchList(List<String> batchNumbers, String? selectedBatch,
      Function setState, TextEditingController controller,
      Function(String?) onBatchSelected) {
    if (batchNumbers.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightTeal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTeal.withOpacity(0.3),
          ),
        ),
        child: Text(
          'No batch data available',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTeal.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 16,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                'Available Batches:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...batchNumbers.map((batch) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: selectedBatch == batch
                    ? AppTheme.primaryTeal.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedBatch == batch
                      ? AppTheme.primaryTeal
                      : AppTheme.primaryTeal.withOpacity(0.2),
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  batch,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selectedBatch == batch
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: selectedBatch == batch
                        ? AppTheme.primaryTeal
                        : AppTheme.onSurface,
                  ),
                ),
                value: batch,
                groupValue: selectedBatch,
                onChanged: (value) {
                  setState(() {
                    onBatchSelected(value);
                    selectedBatch = value;
                    controller.text = value ?? '';
                  });
                },
                dense: true,
                activeColor: AppTheme.primaryTeal,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _submitReview(BuildContext context, String? selectedReason,
      String reviewText) {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((selectedReason == 'batch_change' ||
        selectedReason == 'short_qty' ||
        selectedReason == 'damage_product' ||
        selectedReason == 'multiple') &&
        reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the required information.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create remark text
    String remarkText = '';
    switch (selectedReason) {
      case 'batch_change':
        remarkText = 'Batch change --> $reviewText';
        break;
      case 'short_qty':
        remarkText = 'Short quantity supplied --> $reviewText';
        break;
      case 'not_available':
        remarkText = 'Not available';
        break;
      case 'damage_product':
        remarkText = 'Damage product --> $reviewText';
        break;
      case 'multiple':
        remarkText = 'Supplied multiple batch and quantity --> $reviewText';
        break;
      case 'none':
        remarkText = '';
        break;
    }

    // Set the pNote in detail and trigger rebuild
    setState(() {
      widget.detail.pNote = remarkText;
    });

    // Auto-select the item after submitting review
    widget.onSelectionChanged(widget.detail.itemDetailId.toString(), true);

    // Call the callback if provided
    widget.onRemarkSubmitted?.call(widget.detail);

    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(selectedReason == 'none'
            ? 'Review submitted successfully.'
            : 'Review submitted: $remarkText'),
        backgroundColor: AppTheme.primaryTeal,
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

