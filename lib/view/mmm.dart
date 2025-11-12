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

                // Chart Statistics Row
                _buildStatsRow(controller.DataItemList),
                const SizedBox(height: AppTheme.paddingLarge),

                // Main Chart with improved height
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
                      maxY: _getMaxYValue(controller.DataItemList) * 1.1, // Add 10% padding
                      barTouchData: _buildEnhancedBarTouchData(),
                      titlesData: _buildEnhancedBarTitles(controller.DataItemList),
                      borderData: FlBorderData(show: false),
                      gridData: _buildEnhancedGridData(),
                      barGroups: _buildEnhancedBarGroups(controller.DataItemList),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _getAverageValue(controller.DataItemList),
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
                _buildSmartInsights(controller.DataItemList),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

// Enhanced Chart Header with better visual hierarchy
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

// Statistics Row showing key metrics
Widget _buildStatsRow(List<DataItem> dataItems) {
  final totalCompleted = dataItems.fold<double>(0, (sum, item) => sum + item.done!);
  final totalPending = dataItems.fold<double>(0, (sum, item) => sum + item.pend!);
  final completionRate = totalCompleted / (totalCompleted + totalPending) * 100;

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
            totalCompleted.toInt().toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Pending',
            totalPending.toInt().toString(),
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
            fontSize: 18,
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

// Enhanced bar titles with rotation and better spacing
FlTitlesData _buildEnhancedBarTitles(List<DataItem> dataItems) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 60, // Increased space for rotated labels
        getTitlesWidget: (double value, TitleMeta meta) {
          final index = value.toInt();
          if (index >= 0 && index < dataItems.length) {
            return Container(
              padding: const EdgeInsets.only(top: 8),
              child: Transform.rotate(
                angle: -0.5, // Slight rotation to prevent overlap
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

// Enhanced grid with better visual hierarchy
FlGridData _buildEnhancedGridData() {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: null, // Auto-calculate
    getDrawingHorizontalLine: (value) {
      return FlLine(
        color: AppTheme.primaryTeal.withOpacity(0.1),
        strokeWidth: 1,
        dashArray: [3, 3],
      );
    },
  );
}

// Enhanced bar groups with gradients and animations
List<BarChartGroupData> _buildEnhancedBarGroups(List<DataItem> dataItems) {
  return dataItems.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;

    return BarChartGroupData(
      x: index,
      barRods: [
        // Completed bar
        BarChartRodData(
          toY: item.done!.toDouble(),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.green.withOpacity(0.7),
              Colors.green,
              Colors.green.shade600,
            ],
          ),
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxYValue(dataItems),
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        // Pending bar
        BarChartRodData(
          toY: item.pend!.toDouble(),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.orange.withOpacity(0.7),
              Colors.orange,
              Colors.orange.shade600,
            ],
          ),
          width: 16,
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

// Enhanced touch interaction
BarTouchData _buildEnhancedBarTouchData() {
  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.black87,
      tooltipRoundedRadius: 8,
      tooltipPadding: const EdgeInsets.all(8),
      tooltipMargin: 8,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final String statusName = 'Status ${groupIndex + 1}';
        final String label = rodIndex == 0 ? 'Completed' : 'Pending';
        return BarTooltipItem(
          '$statusName\n$label: ${rod.toY.toInt()}',
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

// Enhanced legend with better visual design
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

// Smart insights with actionable recommendations
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

double _getAverageValue(List<DataItem> dataItems) {
  if (dataItems.isEmpty) return 0;
  final total = dataItems.fold<double>(0, (sum, item) => sum + item.done! + item.pend!);
  return total / (dataItems.length * 2);
}

List<String> _generateSmartInsights(List<DataItem> dataItems) {
  List<String> insights = [];

  if (dataItems.isEmpty) return insights;

  // Calculate metrics
  final totalCompleted = dataItems.fold<double>(0, (sum, item) => sum + item.done!);
  final totalPending = dataItems.fold<double>(0, (sum, item) => sum + item.pend!);
  final completionRate = totalCompleted / (totalCompleted + totalPending) * 100;

  // Generate insights based on data
  if (completionRate >= 80) {
    insights.add("Excellent progress! ${completionRate.toStringAsFixed(1)}% completion rate indicates strong workflow efficiency.");
  } else if (completionRate >= 60) {
    insights.add("Good progress with ${completionRate.toStringAsFixed(1)}% completion rate. Consider optimizing bottleneck areas.");
  } else {
    insights.add("Completion rate at ${completionRate.toStringAsFixed(1)}% suggests need for process improvement and resource allocation.");
  }

  // Find best and worst performing status
  if (dataItems.length > 1) {
    final bestStatus = dataItems.reduce((a, b) =>
    (a.done! / (a.done! + a.pend!)) > (b.done! / (b.done! + b.pend!)) ? a : b);
    insights.add("${bestStatus.status} shows highest efficiency - consider replicating this approach across other stages.");
  }

  return insights;
}

Widget _buildDetailedStatusCards(StatusDashboardController controller) {
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

Widget _buildStatusCard(DataItem data, int index,
    StatusDashboardController controller) {
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

Widget _buildChartHeader(String title, String subtitle, IconData icon,
    Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppTheme.createGradient([color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      const SizedBox(width: AppTheme.paddingMedium),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
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

// Chart helper methods with enhanced details
double _getMaxYValue(List<DataItem> data) {
  if (data.isEmpty) return 100;
  return data.map((e) => e.noInvoice!.toDouble()).reduce((a, b) =>
  a > b
      ? a
      : b) * 1.2;
}