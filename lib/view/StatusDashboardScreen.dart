import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:onepicker/model/StatusApiResponse.dart';
import 'dart:math' as math;

import '../controllers/StatusDashboardController.dart';
import '../theme/AppTheme.dart';

class StatusDashboardScreen extends StatelessWidget {
  const StatusDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatusDashboardController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(controller),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildMetricCards(controller),
          _buildStatusBarChart(controller),
          _buildPendingPieChart(controller),
          _buildDetailedStatusCards(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(StatusDashboardController controller) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.createGradient(
            [AppTheme.primaryTeal, AppTheme.lightTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Top row with title and actions
                Row(
                  children: [
                    // Dashboard icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title with subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Dashboard',
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Analytics & Performance',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Row(
                      children: [
                        // Refresh button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Obx(() => AnimatedRotation(
                              turns: controller.isLoading.value ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 1000),
                              child: Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            )),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.fetchDashboardData,
                            tooltip: 'Refresh Data',
                          ),
                        ),
                        const SizedBox(width: 8),

                        // More options button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => _showOptionsMenu(Get.context!),
                            tooltip: 'More Options',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date range selector row
                Obx(() => InkWell(
                  onTap: () => _showDateRangePicker(Get.context!, controller),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Calendar icon with background
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Date range text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date Range',
                                style: AppTheme.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${controller.fromDate.value} - ${controller.toDate.value}',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Generate report button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: controller.isLoading.value
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : GestureDetector(
                            onTap: controller.fetchDashboardData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.createGradient([
                                  AppTheme.coralPink,
                                  AppTheme.amberGold,
                                ]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.coralPink.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.analytics_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Generate',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Dropdown indicator
                        const SizedBox(width: 8),
                        Icon(
                          Icons.expand_more_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context, StatusDashboardController controller) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Safely parse the current dates with fallback
    DateTime startDate;
    DateTime endDate;

    try {
      startDate = dateFormat.parse(controller.fromDate.value);
    } catch (e) {
      startDate = DateTime.now().subtract(const Duration(days: 30));
    }

    try {
      endDate = dateFormat.parse(controller.toDate.value);
    } catch (e) {
      endDate = DateTime.now();
    }

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate,
        end: endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format dates consistently using the controller's date format
      controller.fromDate.value = dateFormat.format(picked.start);
      controller.toDate.value = dateFormat.format(picked.end);
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.download_rounded, color: AppTheme.primaryTeal),
                title: const Text('Export Data'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle export
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_rounded, color: AppTheme.primaryTeal),
                title: const Text('Dashboard Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle settings
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline_rounded, color: AppTheme.primaryTeal),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle help
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCards(StatusDashboardController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (!controller.hasData.value && !controller.isLoading.value) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(left: 16,right: 16,top: 10),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Invoices',
                  controller.totalInvoices.value.toString(),
                  Icons.receipt_long_rounded,
                  AppTheme.primaryGradient,
                  '100%',
                ),
              ),
              Expanded(
                child: _buildMetricCard(
                  'Completed',
                  controller.totalDeliveryDone.value.toString(),
                  Icons.check_circle_rounded,
                  AppTheme.performanceGradient,
                  '${((controller.totalDeliveryDone.value /
                      (controller.totalInvoices.value == 0 ? 1 : controller
                          .totalInvoices.value)) * 100).toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _buildMetricCard(
                  'Pending',
                  controller.totalDeliveryPending.value.toString(),
                  Icons.schedule_rounded,
                  AppTheme.warmGradient,
                  '${((controller.totalDeliveryPending.value /
                      (controller.totalInvoices.value == 0 ? 1 : controller
                          .totalInvoices.value)) * 100).toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      List<Color> gradientColors, String percentage) {
    return SizedBox(
      height: 100, // Much smaller height
      child: Card(
        elevation: 3,
        shadowColor: gradientColors.first.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.createGradient(gradientColors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row with icon and percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white, size: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        percentage,
                        style: AppTheme.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                // Value
                Text(
                  value,
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),

                // Title
                Text(
                  title,
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart(String message) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryTeal,
                strokeWidth: 3,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStatusCards(StatusDashboardController controller)
  {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (!controller.hasData.value) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.sage.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.list_alt_rounded,
                        color: AppTheme.sage,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Text(
                      'Detailed Status Breakdown',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.sage,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ...controller.DataItemList
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                    _buildStatusCard(entry.value, entry.key, controller),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(DataItem data, int index, StatusDashboardController controller) {
    // ✅ Skip Picker Manager card
    if (!controller.showPickerManager.value &&
        data.status?.toLowerCase().contains('picker manager') == true) {
      return const SizedBox.shrink();
    }

    final completion = data.completionPercentage;
    final stageValue = controller.getStageValue(index);
    final cardColor = AppTheme.chartColors[index % AppTheme.chartColors.length];

    return Card(
      elevation: 6,
      shadowColor: cardColor.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          gradient: AppTheme.createGradient([
            AppTheme.surface,
            cardColor.withOpacity(0.05),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.createGradient(
                        [cardColor, cardColor.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(data.status!),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.status!,
                        style: AppTheme.titleSmall.copyWith(
                          color: cardColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Status Stage ${index + 1}',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.createGradient([
                      cardColor.withOpacity(0.1),
                      cardColor.withOpacity(0.05),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${completion.toStringAsFixed(1)}%',
                    style: AppTheme.labelMedium.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricChip(
                    'Total',
                    data.noInvoice.toString(),
                    Icons.receipt_rounded,
                    AppTheme.info,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  _buildMetricChip(
                    'Done',
                    data.done.toString(),
                    Icons.check_circle_rounded,
                    AppTheme.success,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  _buildMetricChip(
                    'Pending',
                    data.pend.toString(),
                    Icons.schedule_rounded,
                    AppTheme.warning,
                  ),
                  if (index > 0) ...[
                    const SizedBox(width: AppTheme.paddingSmall),
                    _buildMetricChip(
                      'Stage',
                      stageValue.toString(),
                      Icons.trending_up_rounded,
                      AppTheme.lavender,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${data.done}/${data.noInvoice} completed',
                      style: AppTheme.labelSmall.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    backgroundColor: cardColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, IconData icon,
      Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyChart(String title, String subtitle) {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppTheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBarChart(StatusDashboardController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingChart('Loading Status Analysis...');
        }

        if (!controller.hasData.value) {
          return _buildEmptyChart(
              'No Status Data', 'Apply date filter to view status breakdown');
        }

        // ✅ Filter data HERE
        final filteredData = controller.getFilteredDataItems();

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Card(
            elevation: 12,
            shadowColor: AppTheme.primaryTeal.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surface,
                    AppTheme.surfaceVariant.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedChartHeader(controller),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Use filteredData instead of controller.DataItemList
                  _buildStatsRow(filteredData),
                  const SizedBox(height: AppTheme.paddingLarge),

                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: _getMaxYValue(filteredData) * 1.1,
                        barTouchData: _buildEnhancedBarTouchData(filteredData),
                        titlesData: _buildEnhancedBarTitles(filteredData),
                        borderData: FlBorderData(show: false),
                        gridData: _buildEnhancedGridData(),
                        barGroups: _buildEnhancedBarGroups(filteredData),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _getAverageValue(filteredData),
                              color: AppTheme.primaryTeal.withOpacity(0.3),
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                labelResolver: (line) => 'Avg: ${line.y.toInt()}',
                                style: TextStyle(
                                  color: AppTheme.primaryTeal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildEnhancedLegend(),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildSmartInsights(filteredData),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

// FIXED Statistics Row - now shows actual totals correctly
  Widget _buildStatsRow(List<DataItem> dataItems) {
    // Get the actual totals from the data
    // Assuming the last item contains the final totals or sum all unique items
    double actualTotalCompleted = 0;
    double actualTotalPending = 0;
    double actualTotal = 0;

    // Method 1: If you want individual status totals
    for (var item in dataItems) {
      actualTotalCompleted = item.done?.toDouble() ?? 0.0;
      actualTotalPending = item.pend?.toDouble() ?? 0.0;
      actualTotal = item.noInvoice?.toDouble() ?? 0.0;
    }



    final completionRate = actualTotal > 0
        ? (actualTotalCompleted / actualTotal) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Done',
              actualTotalCompleted.toInt().toString(),
              Icons.check_circle_outline,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Pending',
              actualTotalPending.toInt().toString(),
              Icons.pending_outlined,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Completion Rate',
              '${completionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              completionRate >= 70 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Enhanced Chart Header
  Widget _buildEnhancedChartHeader(StatusDashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryTeal,
                  AppTheme.primaryTeal.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Progress Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time completion tracking across all workflow stages',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Live',
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Enhanced bar titles
  FlTitlesData _buildEnhancedBarTitles(List<DataItem> dataItems) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 60,
          getTitlesWidget: (double value, TitleMeta meta) {
            final index = value.toInt();
            if (index >= 0 && index < dataItems.length) {
              return Container(
                padding: const EdgeInsets.only(top: 8),
                child: Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    _truncateLabel(dataItems[index].status!, 12),
                    style: TextStyle(
                      color: AppTheme.onSurface.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _calculateInterval(_getMaxYValue(dataItems)),
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              _formatNumber(value),
              style: TextStyle(
                color: AppTheme.onSurface.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

// Enhanced grid
  FlGridData _buildEnhancedGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: null,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppTheme.primaryTeal.withOpacity(0.1),
          strokeWidth: 1,
          dashArray: [3, 3],
        );
      },
    );
  }

// FIXED Bar groups - now shows individual status data correctly
  List<BarChartGroupData> _buildEnhancedBarGroups(List<DataItem> dataItems) {
    return dataItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barsSpace: 4, // Increased space between bars
        barRods: [
          // ✅ Completed bar (left position)
          BarChartRodData(

            toY: (item.done ?? 0).toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.green.withOpacity(0.7),
                Colors.green,
                Colors.green.shade600,
              ],
            ),
            width: 14, // Reduced width
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            // ❌ Removed backDrawRodData - this was causing overlap
          ),

          // ✅ Pending bar (right position)
          BarChartRodData(

            toY: (item.pend ?? 0).toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.orange.withOpacity(0.7),
                Colors.orange,
                Colors.orange.shade600,
              ],
            ),
            width: 11, // Reduced width
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
// Enhanced touch interaction - FIXED
  BarTouchData _buildEnhancedBarTouchData(List<DataItem> dataItems) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.black87,
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex < dataItems.length) {
            final statusName = dataItems[groupIndex].status ?? 'Status ${groupIndex + 1}';
            final String label = rodIndex == 0 ? 'Completed' : 'Pending';
            return BarTooltipItem(
              '$statusName\n$label: ${rod.toY.toInt()}',
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
// Enhanced legend
  Widget _buildEnhancedLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            'Done Tasks',
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(width: 20),
          _buildLegendItem(
            'Pending Tasks',
            Colors.orange,
            Icons.pending,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.onSurface.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

// FIXED Smart insights
  Widget _buildSmartInsights(List<DataItem> dataItems) {
    final insights = _generateSmartInsights(dataItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      color: AppTheme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

// Helper methods
  String _truncateLabel(String label, int maxLength) {
    if (label.length <= maxLength) return label;
    return '${label.substring(0, maxLength - 3)}...';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 50;
    return (maxValue / 5).roundToDouble();
  }

// FIXED average calculation
  double _getAverageValue(List<DataItem> dataItems) {
    if (dataItems.isEmpty) return 0;

    // Calculate average of total items per status
    final totalItems = dataItems.fold<double>(0, (sum, item) => sum + (item.noInvoice ?? 0));
    return totalItems / dataItems.length;
  }

// FIXED insights generation
  List<String> _generateSmartInsights(List<DataItem> dataItems) {
    List<String> insights = [];

    if (dataItems.isEmpty) return insights;

    // Get actual totals (you might want to get these from your controller)
    double totalCompleted = 0;
    double totalPending = 0;
    double totalItems = 0;

    for (var item in dataItems) {
      totalCompleted += item.done ?? 0;
      totalPending += item.pend ?? 0;
      totalItems += item.noInvoice ?? 0;
    }

    final completionRate = totalItems > 0 ? (totalCompleted / totalItems) * 100 : 0;

    // Generate insights based on actual data
    if (completionRate >= 80) {
      insights.add("Excellent progress! ${completionRate.toStringAsFixed(1)}% completion rate indicates strong workflow efficiency.");
    } else if (completionRate >= 60) {
      insights.add("Good progress with ${completionRate.toStringAsFixed(1)}% completion rate. Consider optimizing bottleneck areas.");
    } else {
      insights.add("Completion rate at ${completionRate.toStringAsFixed(1)}% suggests need for process improvement and resource allocation.");
    }

    // Find best performing status
    if (dataItems.length > 1) {
      var bestStatus = dataItems[0];
      double bestRate = 0;

      for (var item in dataItems) {
        final itemTotal = (item.noInvoice ?? 0);
        if (itemTotal > 0) {
          final itemRate = (item.done ?? 0) / itemTotal;
          if (itemRate > bestRate) {
            bestRate = itemRate;
            bestStatus = item;
          }
        }
      }

      if (bestRate > 0) {
        insights.add("${bestStatus.status} shows highest efficiency with ${(bestRate * 100).toStringAsFixed(1)}% completion rate.");
      }
    }

    return insights;
  }

// FIXED max Y value calculation
  double _getMaxYValue(List<DataItem> data) {
    if (data.isEmpty) return 100;

    double maxValue = 0;
    for (var item in data) {
      final maxForItem = math.max((item.done ?? 0).toDouble(), (item.pend ?? 0).toDouble());
      maxValue = math.max(maxValue, maxForItem);
    }

    return maxValue > 0 ? maxValue * 1.2 : 100;
  }

  BarTouchData _buildDetailedBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: AppTheme.onSurface.withOpacity(0.9),
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String label = rodIndex == 0 ? 'Completed' : 'Pending';
          return BarTooltipItem(
            '$label: ${rod.toY.round()}\nTotal: ${(rod.toY +
                (rodIndex == 0 ? 0 : 0)).round()}',
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildDetailedBarTitles(List<DataItem> data) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  data[value.toInt()].status!,
                  style: AppTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const Text('');
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            );
          },
          reservedSize: 35,
        ),
      ),
    );
  }

  FlGridData _buildDetailedGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 20,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppTheme.onSurfaceVariant.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  List<BarChartGroupData> _buildDetailedBarGroups(List<DataItem> data) {
    return data
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final statusData = entry.value;
      final color = AppTheme.chartColors[index % AppTheme.chartColors.length];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: statusData.done!.toDouble(),
            color: color,
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: statusData.pend!.toDouble(),
            color: color.withOpacity(0.4),
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }



  Widget _buildPendingPieChart(StatusDashboardController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingChart('Loading Pending Analysis...');
        }

        if (!controller.hasData.value) {
          return _buildEmptyChart('No Pending Data',
              'Apply date filter to view pending distribution');
        }

        final pendingData = controller.DataItemList.where((item) =>
        item.pend! > 0).toList();

        if (pendingData.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.paddingXLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                      Colors.green.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'All Tasks Completed!',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No pending items in selected date range',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Card(
            elevation: 12,
            shadowColor: AppTheme.coralPink.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surface,
                    AppTheme.surfaceVariant.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.coralPink.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedPieHeader(pendingData),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Summary Statistics
                  _buildPendingSummaryStats(pendingData),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Main Chart Section with proper proportions
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.coralPink.withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Pie Chart - Reduced size
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: _buildEnhancedPieSections(pendingData,controller),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 25, // Reduced from 70
                                    startDegreeOffset: -80,
                                    pieTouchData: _buildEnhancedPieTouchData(),
                                  ),
                                ),
                                // Center content
                                _buildCenterContent(pendingData),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Enhanced Legend - More space
                        Expanded(
                          flex: 2,
                          child: _buildEnhancedPieChartLegend(pendingData,controller),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildEnhancedPieChartInsights(pendingData),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

// Enhanced header for pie chart
  Widget _buildEnhancedPieHeader(List<DataItem> pendingData) {
    final totalPending = pendingData.fold<int>(0, (sum, item) => sum + item.pend!);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.coralPink,
                  AppTheme.coralPink.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.coralPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.donut_large_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Work Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Breakdown analysis of $totalPending pending items across ${pendingData.length} categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

// Summary statistics row
  Widget _buildPendingSummaryStats(List<DataItem> pendingData) {
    // final totalPending = pendingData.fold<int>(0, (sum, item) => sum + item.pend!);
    // final avgPending = (totalPending / pendingData.length).round();
    // final highestCategory = pendingData.reduce((a, b) => a.pend! > b.pend! ? a : b);

    int totalPending = 0;
    int? avgPending = 0;


    // Method 1: If you want individual status totals
    for (var item in pendingData) {
      totalPending = item.pend ?? 0;
      avgPending = pendingData.isNotEmpty
          ? (totalPending / pendingData.length).round()
          : 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.coralPink.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.coralPink.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPendingStatCard(
              'T Pending',
              totalPending.toString(),
              Icons.pending_actions,
              AppTheme.coralPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPendingStatCard(
              'Categories',
              pendingData.length.toString(),
              Icons.category_outlined,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPendingStatCard(
              'Avg/Cat',
              avgPending.toString(),
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

// Center content for the pie chart
  Widget _buildCenterContent(List<DataItem> pendingData) {
    var totalPending = 0;
    for (var item in pendingData) {
      totalPending = item.pend ?? 0;

    }


    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppTheme.coralPink.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            totalPending.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.coralPink,
            ),
          ),
          Text(
            'Total',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// Enhanced pie sections
  List<PieChartSectionData> _buildEnhancedPieSections(List<DataItem> pendingData, StatusDashboardController controller) {
    // ✅ Filter data first
    final filteredData = pendingData.where((item) {
      if (!controller.showPickerManager.value) {
        return !(item.status?.toLowerCase().contains('picker manager') ?? false);
      }
      return true;
    }).toList();

    // ✅ Calculate total from filtered data
    final total = filteredData.fold<double>(0, (sum, item) => sum + item.pend!);

    return filteredData.asMap().entries.map((entry) {
      final index = entry.key;
      final statusData = entry.value;
      final color = AppTheme.chartColors[index % AppTheme.chartColors.length];
      final percentage = (statusData.pend! / total * 100);

      return PieChartSectionData(
        color: color,
        value: statusData.pend!.toDouble(),
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 60,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Enhanced legend with better layout
  Widget _buildEnhancedPieChartLegend(List<DataItem> pendingData, StatusDashboardController controller) {
    final total = pendingData.fold<double>(0, (sum, item) => sum + item.pend!);

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pendingData.length,
              itemBuilder: (context, index) {
                final statusData = pendingData[index];

                // ✅ Skip Picker Manager
                if (!controller.showPickerManager.value &&
                    statusData.status?.toLowerCase().contains('picker manager') == true) {
                  return const SizedBox.shrink();
                }

                final color = AppTheme.chartColors[index % AppTheme.chartColors.length];
                final percentage = (statusData.pend! / total * 100);

                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withOpacity(0.8), color],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusData.status!,
                              style: TextStyle(
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
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${statusData.pend!} items',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
// Enhanced touch data
  PieTouchData _buildEnhancedPieTouchData() {
    return PieTouchData(
      enabled: true,
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        // Enhanced touch handling for pie chart
        if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
          // Handle tap events if needed
        }
      },
    );
  }

// Enhanced insights
  Widget _buildEnhancedPieChartInsights(List<DataItem> pendingData) {
    final highestPending = pendingData.reduce((a, b) => a.pend! > b.pend! ? a : b);
    final totalPending = pendingData.fold<int>(0, (sum, item) => sum + item.pend!);
    final avgPending = (totalPending / pendingData.length).round();

    // Find items above average
    final aboveAverage = pendingData.where((item) => item.pend! > avgPending).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.coralPink.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.coralPink.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: AppTheme.coralPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Insights & Recommendations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Priority Focus',
            '"${highestPending.status}" requires immediate attention with ${highestPending.pend} pending items (${((highestPending.pend! / totalPending) * 100).toStringAsFixed(1)}% of total workload)',
            Icons.priority_high,
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildInsightItem(
            'Workload Distribution',
            '$aboveAverage out of ${pendingData.length} categories are above average ($avgPending items), indicating potential resource reallocation needs',
            Icons.balance,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildInsightItem(
            'Action Plan',
            'Consider redistributing resources from lighter categories to optimize overall completion time',
            Icons.trending_up,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurface.withOpacity(0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'tray assigner':
        return Icons.inventory_2_rounded;
      case 'picker':
        return Icons.inbox_rounded;
      case 'delivery':
        return Icons.local_shipping_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'picker manager':
        return Icons.manage_accounts_rounded;
      case 'checker':
        return Icons.check_box;
      case 'packer':
        return Icons.backpack;
      case 'del-confirm':
        return Icons.confirmation_num_outlined;
      default:
        return Icons.help_rounded;
    }
  }


}