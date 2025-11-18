import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/PickerController.dart';
import '../model/StockDetailModel.dart';
import '../theme/AppTheme.dart';

class StockListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PickerController>();

    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Fields in Row
              Row(
                children: [
                  // Item Name Search
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller.itemNameSearchController,
                      onChanged: (value) {
                        controller.itemNameSearch.value = value;
                        controller.filterStockList();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search item...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF718096),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF4A90E2),
                          size: 20,
                        ),
                        suffixIcon: Obx(() => controller.itemNameSearch.value.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF718096),
                            size: 18,
                          ),
                          onPressed: () {
                            controller.itemNameSearchController.clear();
                            controller.itemNameSearch.value = '';
                            controller.filterStockList();
                          },
                        )
                            : const SizedBox.shrink()),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF4A90E2).withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF4A90E2).withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A90E2),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Location Search
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller.locationSearchController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.locationSearch.value = value;
                        controller.filterStockList();
                      },
                      decoration: InputDecoration(
                        hintText: 'Location...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF718096),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFF7B68EE),
                          size: 20,
                        ),
                        suffixIcon: Obx(() => controller.locationSearch.value.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF718096),
                            size: 18,
                          ),
                          onPressed: () {
                            controller.locationSearchController.clear();
                            controller.locationSearch.value = '';
                            controller.filterStockList();
                          },
                        )
                            : const SizedBox.shrink()),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF7B68EE).withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF7B68EE).withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF7B68EE),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Active filters indicator
              Obx(() {
                final hasFilters = controller.itemNameSearch.value.isNotEmpty ||
                    controller.locationSearch.value.isNotEmpty;

                if (!hasFilters) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: const Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.filteredStockList.length} of ${controller.stockList.length} items',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          controller.itemNameSearchController.clear();
                          controller.locationSearchController.clear();
                          controller.itemNameSearch.value = '';
                          controller.locationSearch.value = '';
                          controller.filterStockList();
                        },
                        icon: const Icon(
                          Icons.clear_all,
                          size: 16,
                        ),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE53E3E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Stock List
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshStockData,
            color: AppTheme.primaryTeal,
            child: Obx(() {
              if (controller.isLoadingStockList.value && controller.stockList.isEmpty) {
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
                        'Loading stock data...',
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

              final displayList = controller.filteredStockList.isEmpty &&
                  (controller.itemNameSearchController.text.isNotEmpty ||
                      controller.locationSearchController.text.isNotEmpty)
                  ? <StockDetail>[]
                  : controller.filteredStockList;

              if (displayList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppTheme.lightTeal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.stockList.isEmpty
                            ? 'No stock data available'
                            : 'No items found',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.stockList.isEmpty
                            ? 'Pull down to refresh'
                            : 'Try adjusting your search filters',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth >= 600;

                  return isTablet
                      ? _buildStockGrid(displayList, constraints.maxWidth)
                      : _buildStockList(displayList);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  // Stock List for Mobile
  Widget _buildStockList(List<StockDetail> displayList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final stockDetail = displayList[index];
        return StockItemCard(stockDetail: stockDetail, index: index);
      },
    );
  }

  // Stock Grid for Tablet
  Widget _buildStockGrid(List<StockDetail> displayList, double availableWidth) {
    final crossAxisCount = availableWidth >= 900 ? 3 : 2;

    // Dynamic spacing
    const spacing = 12.0;

    // ⭐ KEY SOLUTION: Fixed height for cards
    // Adjust this value based on your StockItemCard content
    final cardHeight = 250.0;  // Set appropriate height for your card design

    // Calculate available width per card
    const horizontalPadding = 32.0; // 16 * 2
    final totalSpacing = spacing * (crossAxisCount - 1);
    final cardAvailableWidth = availableWidth - horizontalPadding - totalSpacing;
    final cardWidth = cardAvailableWidth / crossAxisCount;

    // Calculate aspect ratio dynamically based on actual dimensions
    final childAspectRatio = cardWidth / cardHeight;

    print("Stock - Columns: $crossAxisCount, CardWidth: $cardWidth, CardHeight: $cardHeight, AspectRatio: $childAspectRatio");

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final stockDetail = displayList[index];
        return StockItemCard(stockDetail: stockDetail, index: index);
      },
    );

  }

}

class StockItemCard extends StatefulWidget {
  final StockDetail stockDetail;
  final int index;

  const StockItemCard({
    Key? key,
    required this.stockDetail,
    required this.index,
  }) : super(key: key);

  @override
  State<StockItemCard> createState() => _StockItemCardState();
}

class _StockItemCardState extends State<StockItemCard> {
  String? stockInput;
  String? gdwnInput;
  bool? stockCorrect;
  bool? gdwnCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFAFBFC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4A90E2).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.stockDetail.itemName ?? 'Unknown Item',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A202C),
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (widget.stockDetail.packing != null)
                              Text(
                                widget.stockDetail.packing!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF718096),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8A65).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'L: ${widget.stockDetail.locn ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [

                      Expanded(
                        flex: 3,
                        child: _buildModernInfoCard(
                          'B: ${_formatExpiry(widget.stockDetail.batchNo)}',
                          Icons.backpack,
                          const Color(0xFFFFA726), // Light orange
                          const Color(0xFFF7FAFC),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: _buildModernInfoCard(
                          'E: ${_formatExpiry(widget.stockDetail.expDate)}',
                          Icons.access_time_rounded,
                          const Color(0xFF9F7AEA),
                          const Color(0xFFF7FAFC),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: _buildModernInfoCard(
                          'M: ${widget.stockDetail.mrp?.toStringAsFixed(0) ?? 'N/A'}',
                          Icons.currency_rupee_rounded,
                          const Color(0xFF48BB78),
                          const Color(0xFFF0FFF4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF4A90E2).withOpacity(0.08),
                          const Color(0xFF7B68EE).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4A90E2).withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildVerifiableValue(
                          'Stock',
                          widget.stockDetail.stock ?? 0,
                          Icons.inventory_2_rounded,
                          const Color(0xFF4A90E2),
                          stockInput,
                          stockCorrect,
                              (value) {
                            setState(() {
                              stockInput = value;
                              final actualStock = widget.stockDetail.stock ?? 0;
                              final expectedDigits = actualStock.toString().length;
                              final currentDigits = value.length;

                              // Only validate when user has typed the expected number of digits
                              if (currentDigits >= expectedDigits) {
                                stockCorrect = value == '$actualStock';

                                // Show snackbar when value is wrong
                                if (value.isNotEmpty && !stockCorrect!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Correct Stock is $actualStock',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(milliseconds: 500),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // User is still typing, reset the correct flag
                                stockCorrect = null;
                              }
                            });
                          },
                        ),

                        Container(
                          width: 2,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF4A90E2).withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        _buildVerifiableValue(
                          'Godown',
                          widget.stockDetail.gdwnQty ?? 0,
                          Icons.warehouse_rounded,
                          const Color(0xFF7B68EE),
                          gdwnInput,
                          gdwnCorrect,
                              (value) {
                            setState(() {
                              gdwnInput = value;
                              gdwnCorrect = value == '${widget.stockDetail.gdwnQty ?? 0}';
                            });
                          },
                          isRight: true,
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

  Widget _buildVerifiableValue(
      String label,
      int actualValue,
      IconData icon,
      Color color,
      String? inputValue,
      bool? isCorrect,
      Function(String) onValueChanged,
      {bool isRight = false}
      ) {
    final hint = _getHint(actualValue);

    Color? borderColor;
    Color? backgroundColor;
    if (isCorrect != null) {
      borderColor = isCorrect ? Colors.green : Colors.red;
      backgroundColor = isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
    }

    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isRight) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: 85,
          height: 38,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor ?? color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: borderColor ?? const Color(0xFF1A202C),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C).withOpacity(0.4),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              counterText: '',
            ),
            maxLength: 6,
            onChanged: (value) {
              onValueChanged(value);
            },
            controller: TextEditingController(text: inputValue)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: inputValue?.length ?? 0),
              ),
          ),
        ),
      ],
    );
  }
  String _getHint(int value) {
    if (value >= 10) {
      return '${value.toString()[0]}*';
    } else if (value >= 1) {
      return '*';
    } else {
      return value.toString();
    }
  }



  Widget _buildModernInfoCard(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 8,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(String? expDate) {
    if (expDate == null || expDate.isEmpty) return 'N/A';

    if (expDate.contains('/') && expDate.length <= 5) {
      return expDate;
    }

    try {
      List<String> parts;
      if (expDate.contains('-')) {
        parts = expDate.split('-');
      } else if (expDate.contains('/')) {
        parts = expDate.split('/');
      } else {
        return expDate;
      }

      if (parts.length >= 2) {
        String month, year;

        if (parts[0].length == 4) {
          year = parts[0].substring(2);
          month = parts[1].padLeft(2, '0');
        } else if (parts[2].length == 4) {
          year = parts[2].substring(2);
          month = parts[0].padLeft(2, '0');
        } else {
          month = parts[0].padLeft(2, '0');
          year = parts[1].padLeft(2, '0');
        }

        return '$month/$year';
      }
    } catch (e) {
      return expDate.length > 10 ? 'N/A' : expDate;
    }

    return expDate;
  }
}