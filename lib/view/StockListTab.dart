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

    return RefreshIndicator(
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

        if (controller.stockList.isEmpty) {
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
                const Text(
                  'No stock data available',
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

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.stockList.length,
          itemBuilder: (context, index) {
            final stockDetail = controller.stockList[index];
            return StockItemCard(stockDetail: stockDetail, index: index);
          },
        );
      }),
    );
  }
}

class StockItemCard extends StatelessWidget {
  final StockDetail stockDetail;
  final int index;

  const StockItemCard({
    Key? key,
    required this.stockDetail,
    required this.index,
  }) : super(key: key);

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
            // Subtle pattern overlay
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
                  // Header with medicine name and batch
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine icon
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

                      // Medicine name and batch
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stockDetail.itemName ?? 'Unknown Item',
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
                            if (stockDetail.packing != null)
                              Text(
                                stockDetail.packing!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF718096),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Batch badge
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
                          'B: ${stockDetail.batchNo ?? 'N/A'}',
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

                  // Info cards in a sleek row
                  Row(
                    children: [
                      // Expiry card
                      Expanded(
                        child: _buildModernInfoCard(
                          'E: ${_formatExpiry(stockDetail.expDate)}',
                          Icons.access_time_rounded,
                          const Color(0xFF9F7AEA),
                          const Color(0xFFF7FAFC),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // MRP card
                      Expanded(
                        child: _buildModernInfoCard(
                          'M: ${stockDetail.mrp?.toStringAsFixed(0) ?? 'N/A'}',
                          Icons.currency_rupee_rounded,
                          const Color(0xFF48BB78),
                          const Color(0xFFF0FFF4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Stock information bar
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
                        // Stock quantity
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Stock',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF4A90E2),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stockDetail.stock ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                          ],
                        ),

                        // Vertical divider
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

                        // Godown quantity
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Godown',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF7B68EE),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B68EE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.warehouse_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stockDetail.gdwnQty ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A202C),
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
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
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

    // If it's already in MM/YY format, return as is
    if (expDate.contains('/') && expDate.length <= 5) {
      return expDate;
    }

    // Try to parse different date formats and convert to MM/YY
    try {
      // Handle formats like "2023-02-15" or "15-02-2023" etc.
      List<String> parts;
      if (expDate.contains('-')) {
        parts = expDate.split('-');
      } else if (expDate.contains('/')) {
        parts = expDate.split('/');
      } else {
        return expDate; // Return as is if format is unknown
      }

      if (parts.length >= 2) {
        String month, year;

        // Determine which part is month and year
        if (parts[0].length == 4) {
          // Format: YYYY-MM-DD
          year = parts[0].substring(2); // Get last 2 digits
          month = parts[1].padLeft(2, '0');
        } else if (parts[2].length == 4) {
          // Format: MM-DD-YYYY or DD-MM-YYYY
          year = parts[2].substring(2); // Get last 2 digits
          month = parts[0].padLeft(2, '0'); // Assuming MM-DD-YYYY
        } else {
          // Format: MM-YY or similar
          month = parts[0].padLeft(2, '0');
          year = parts[1].padLeft(2, '0');
        }

        return '$month/$year';
      }
    } catch (e) {
      // If parsing fails, return original or N/A
      return expDate.length > 10 ? 'N/A' : expDate;
    }

    return expDate;
  }
}