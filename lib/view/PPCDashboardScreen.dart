import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/PPCDashboardController.dart';
import '../model/UserPerformanceData.dart';

import '../theme/AppTheme.dart';
import 'Performance3DChart.dart';

class PPCDashboardScreen extends StatefulWidget {
  final controller = Get.put(PPCDashboardController());

  PPCDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PPCDashboardScreen> createState() => _PPCDashboardScreenState();
}

class _PPCDashboardScreenState extends State<PPCDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: false,
            snap: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildFlexibleHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() => widget.controller.isLoading.value
                ? _buildLoadingState()
                : widget.controller.filteredDataList.isEmpty
                ? _buildEmptyState()
                : _buildContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexibleHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2563EB), // Deep Blue
            Color(0xFF06B6D4), // Cyan
          ], // Clean modern gradient
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterControls(),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.controller.selectedDashboardType.value,
                isExpanded: true,
                dropdownColor: Color(0xFF06B6D4),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                items: widget.controller.dashboardTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.selectedDashboardType.value = value;
                    widget.controller.fetchDashboardData();
                  }
                },
              ),
            ),
          )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: widget.controller.selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Obx(() => Text(
                      '${DateFormat('MMM dd').format(widget.controller.fromDate.value)} - ${DateFormat('MMM dd').format(widget.controller.toDate.value)}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 12),
            Text(
              'Loading Performance Data...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Performance Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'There\'s no data available for the selected period.\nTry adjusting your filters or date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced vertical padding
      child: Column(
        children: [
          _buildStatisticsCards(),
          const SizedBox(height: 16),
          _buildTopPerformersChart(),
          // Spectacular 3D bars
          const SizedBox(height: 16),
          _buildDistributionChart(),
          const SizedBox(height: 16),
          _buildProductivityChart(),    // Interactive 3D scatter
          // Mathematical surface
          const SizedBox(height: 16),
          _buildPerformanceCards(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          _buildStatCard(
              'T.Users',
              widget.controller.totalUsers.value.toString(),
              Icons.people_outline,
              Colors.blue),
          const SizedBox(width: 8),
          _buildStatCard(
              'T.Products',
              widget.controller.totalProducts.value.toString(),
              Icons.inventory_2_outlined,
              Colors.green),
          const SizedBox(width: 8),
          _buildStatCard(
              'T.Quantity',
              widget.controller.totalQuantity.value.toString(),
              Icons.widgets_outlined,
              Colors.orange),
          const SizedBox(width: 8),
          _buildStatCard(
              'Picked',
              widget.controller.totalLineItems.value.toString(),
              Icons.list_alt,
              Colors.purple),
        ],
      ),
    ));
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 110, // smaller width
      height: 100, // smaller height
      padding: const EdgeInsets.all(8), // reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(1, 2),
          )
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5), // smaller padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18), // smaller icon
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // reduced font
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(

            title,
            style: TextStyle(
              fontSize: 11, // reduced font
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }




  Widget _buildTopPerformersChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xFF3B82F6), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Top 5 Performers by Quantity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Obx(() {
              final topPerformers = widget.controller.filteredDataList.take(5).toList();
              if (topPerformers.isEmpty) return _buildChartEmptyState();

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topPerformers.map((e) => e.tQty!.toDouble()).reduce(math.max) * 1.15,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color(0xFF1E293B),
                      tooltipRoundedRadius: 6,
                      tooltipPadding: const EdgeInsets.all(6),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${topPerformers[group.x].name?.split(' ').first}\n${_formatNumber(rod.toY.round())} items',
                          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatNumber(value.toInt()),
                            style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topPerformers.length) {
                            final name = topPerformers[value.toInt()].name?.split(' ').first ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                name.length > 6 ? '${name.substring(0, 6)}...' : name,
                                style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: topPerformers.map((e) => e.tQty!.toDouble()).reduce(math.max) / 4,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFF1F5F9),
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topPerformers.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.tQty!.toDouble(),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF3B82F6),
                              const Color(0xFF3B82F6).withOpacity(0.7),
                            ],
                          ),
                          width: 28,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget build3DBarChart() {
    return Performance3DChart(
      data: widget.controller.filteredDataList,
      chartType: 'bar',
      title: '3D Performance Bars',
      icon: Icons.bar_chart,
      primaryColor: const Color(0xFF3B82F6),
      secondaryColor: const Color(0xFF2563EB),
    );
  }

  Widget build3DScatterChart() {
    return Performance3DChart(
      data: widget.controller.filteredDataList,
      chartType: 'scatter',
      title: '3D Performance Scatter',
      icon: Icons.scatter_plot,
      primaryColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF059669),
    );
  }

  Widget build3DSurfaceChart() {
    return Performance3DChart(
      data: widget.controller.filteredDataList,
      chartType: 'surface',
      title: '3D Performance Surface',
      icon: Icons.terrain,
      primaryColor: const Color(0xFFF59E0B),
      secondaryColor: const Color(0xFFD97706),
    );
  }

  Widget _buildDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.pie_chart_outline, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Product Distribution (Top 5)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              final topData = widget.controller.filteredDataList.take(5).toList();
              if (topData.isEmpty) return _buildChartEmptyState();

              final colors = [
                const Color(0xFF3B82F6),
                const Color(0xFF10B981),
                const Color(0xFFF59E0B),
                const Color(0xFFEF4444),
                const Color(0xFF8B5CF6),
              ];

              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: topData.asMap().entries.map((entry) {
                          final percentage = (entry.value.lineItem! / widget.controller.totalLineItems.value * 100);
                          return PieChartSectionData(
                            value: entry.value.lineItem!.toDouble(),
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: colors[entry.key % colors.length],
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 180, // 👈 give fixed height so ListView can scroll inside
                      child: ListView.builder(
                        itemCount: topData.length,
                        itemBuilder: (context, index) {
                          final entry = topData[index];
                          final name = entry.name?.split(' ').first ?? '';

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.length > 12 ? '${name.substring(0, 12)}...' : name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${_formatNumber(entry.lineItem!)} items',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),


                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Productivity Trends (Items per 5 min)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              final topProductive = widget.controller.filteredDataList.take(5).toList();
              if (topProductive.isEmpty) return _buildChartEmptyState();

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFF1F5F9),
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topProductive.length) {
                            final name = topProductive[value.toInt()].name?.split(' ').first ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                name.length > 6 ? '${name.substring(0, 5)}.' : name,
                                style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Color(0xFFF1F5F9), width: 0.8),
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.8),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: topProductive.asMap().entries.map((entry) {
                        double itemsPer5Min = (entry.value.getProductivityScore() * 5);
                        return FlSpot(entry.key.toDouble(), itemsPer5Min);
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF10B981),
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.15),
                            const Color(0xFF10B981).withOpacity(0.03),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: const Color(0xFF1E293B),
                      tooltipRoundedRadius: 6,
                      tooltipPadding: const EdgeInsets.all(6),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final name = topProductive[spot.x.toInt()].name?.split(' ').first ?? '';
                          return LineTooltipItem(
                            '$name\n${spot.y.toStringAsFixed(1)} items/5min',
                            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> exportToExcel(List<UserPerformanceData> dataList, BuildContext context, String title) async {
    // Check permissions for Android versions < Q (API 29)
    if (Platform.isAndroid) {
      if (await _shouldRequestStoragePermission()) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
          return;
        }
      }
    }

    if (dataList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    // Create Excel workbook
    var excel = ex.Excel.createExcel();
    ex.Sheet sheet = excel['Performance Report'];
    excel.delete('Sheet1'); // Remove default sheet

    // Create styles
    ex.CellStyle titleStyle = _createTitleStyle();
    ex.CellStyle headerStyle = _createHeaderStyle();
    ex.CellStyle dataStyle = _createDataStyle();
    ex.CellStyle goldStyle   = _createRankStyle(ex.ExcelColor.fromHexString("#FFD700")); // Gold
    ex.CellStyle silverStyle = _createRankStyle(ex.ExcelColor.fromHexString("#C0C0C0")); // Silver
    ex.CellStyle bronzeStyle = _createRankStyle(ex.ExcelColor.fromHexString("#CD7F32")); // Bronze


    // Add title row with date
    String formattedDate = DateFormat("MMMM dd, yyyy").format(DateTime.now());
    var titleCell = sheet.cell(ex.CellIndex.indexByString('A1'));
    titleCell.value = ex.TextCellValue("Performance Report - $formattedDate");
    titleCell.cellStyle = titleStyle;

    // Merge title cells (A1 to G1)
    sheet.merge(ex.CellIndex.indexByString('A1'), ex.CellIndex.indexByString('G1'));

    // Add header row
    List<String> headers = [
      "Rank",
      "Name",
      "Invoices",
      "Products",
      "Quantity",
      title,
      "Duration",
      "Avg QTY/Min",
      "Avg Prod/Min"
    ];

    for (int i = 0; i < headers.length; i++) {
      var headerCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
      headerCell.value = ex.TextCellValue(headers[i]);
      headerCell.cellStyle = headerStyle;

      // Set column width (approximately 15 characters, except name column)
      if (i == 1) {
        // Name column wider (30 characters)
        sheet.setColumnWidth(i, 30.0);
      } else {
        sheet.setColumnWidth(i, 15.0);
      }
    }

    // Add data rows
    for (int i = 0; i < dataList.length; i++) {
      UserPerformanceData data = dataList[i];
      int rowIndex = i + 2; // Starting from row 2 (0-indexed)

      // Select style based on rank
      ex.CellStyle rowStyle = dataStyle;
      if (i == 0) rowStyle = goldStyle;        // 1st place - Gold
      else if (i == 1) rowStyle = silverStyle; // 2nd place - Silver
      else if (i == 2) rowStyle = bronzeStyle; // 3rd place - Bronze

      // Rank
      var rankCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      rankCell.value = ex.IntCellValue(i + 1);
      rankCell.cellStyle = rowStyle;

      // Name
      var nameCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
      nameCell.value = ex.TextCellValue(data.name ?? "Unknown");
      nameCell.cellStyle = rowStyle;

      // Invoices
      var invoicesCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
      invoicesCell.value = ex.IntCellValue(data.noInvoice ?? 0);
      invoicesCell.cellStyle = rowStyle;

      // Products
      var productsCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
      productsCell.value = ex.IntCellValue(data.noProd ?? 0);
      productsCell.cellStyle = rowStyle;

      // Quantity
      var qtyCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
      qtyCell.value = ex.IntCellValue(data.tQty ?? 0);
      qtyCell.cellStyle = rowStyle;

      // Line Item
      var lineItemCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
      lineItemCell.value = ex.IntCellValue(data.lineItem ?? 0);
      lineItemCell.cellStyle = rowStyle;

      // Duration
      var durationCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex));
      durationCell.value = ex.TextCellValue(data.getWorkDuration() ?? "0:00");
      durationCell.cellStyle = rowStyle;

      // Average Quantity per minute
      var avgQtyCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex));
      int avgPerMinute = calculateAvgPerMinute(data.tQty ?? 0, data.getWorkDuration() ?? "0:00");
      avgQtyCell.value = ex.IntCellValue(avgPerMinute);
      avgQtyCell.cellStyle = rowStyle;

      // Average Products per minute
      var avgProdCell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex));
      int avgProdPerMinute = calculateLineProductAvgPerMinute(data.lineItem ?? 0, data.getWorkDuration() ?? "0:00");
      avgProdCell.value = ex.IntCellValue(avgProdPerMinute);
      avgProdCell.cellStyle = rowStyle;
    }

    // Save file
    try {
      // Create directory if it doesn't exist
      String downloadsPath;
      if (Platform.isAndroid) {
        downloadsPath = "/storage/emulated/0/Download";
      } else {
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      final reportsDir = Directory("$downloadsPath/PerformanceReports");
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      // Create file with timestamp
      String timeStamp = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
      String filePath = "${reportsDir.path}/Performance_Report_$timeStamp.xlsx";

      File file = File(filePath);
      await file.writeAsBytes(excel.save()!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report exported successfully to Downloads/PerformanceReports folder"),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("Error exporting to Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting report: $e")),
      );
    }
  }

// Helper function to check if storage permission is needed
  Future<bool> _shouldRequestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt < 29; // API level 29 is Android 10 (Q)
    }
    return false;
  }

  /// Create title cell style
  ex.CellStyle _createTitleStyle() {
    return ex.CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: ex.HorizontalAlign.Center,
      verticalAlign: ex.VerticalAlign.Center,
      backgroundColorHex: ex.ExcelColor.lightBlue,
    );
  }

  /// Create header cell style
  ex.CellStyle _createHeaderStyle() {
    return ex.CellStyle(
      bold: true,
      horizontalAlign: ex.HorizontalAlign.Center,
      backgroundColorHex: ex.ExcelColor.grey100,
      bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
    );
  }

  /// Create data cell style
  ex.CellStyle _createDataStyle() {
    return ex.CellStyle(
      horizontalAlign: ex.HorizontalAlign.Center,
      bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
    );
  }

  /// Create rank specific cell style
  ex.CellStyle _createRankStyle(ex.ExcelColor backgroundColor) {
    return ex.CellStyle(
      horizontalAlign: ex.HorizontalAlign.Center,
      bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      backgroundColorHex: backgroundColor,
    );
  }
  Widget _buildPerformanceCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.leaderboard, color: Color(0xFFF59E0B), size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Performance Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF0F172A)),
              onPressed: () {
                exportToExcel(widget.controller.filteredDataList, context,'Performance Report');
              },
            ),
          ],
        ),
        const SizedBox(height: 8), // 👈 control spacing manually
        Obx(() => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero, // 👈 removes unwanted space
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.controller.filteredDataList.length,
          itemBuilder: (context, index) {
            final data = widget.controller.filteredDataList[index];
            return _buildPerformanceCard(data, index);
          },
        )),
      ],
    );
  }

  Widget _buildPerformanceCard(UserPerformanceData data, int index) {
    final isTopThree = index < 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree ? _getRankColor(index).withOpacity(0.2) : const Color(0xFFF1F5F9),
          width: isTopThree ? 1 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTopThree ? _getRankColor(index) : Colors.black).withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTopThree
                    ? [_getRankColor(index), _getRankColor(index).withOpacity(0.8)]
                    : [const Color(0xFF64748B), const Color(0xFF475569)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isTopThree)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index == 0 ? Icons.stars : Icons.star,
                        size: 8,
                        color: _getRankColor(index),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isTopThree ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Duration: ${data.getWorkDuration()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // Stats Row
                Row(
                  children: [
                    _buildStatChip('Invoices', data.noInvoice.toString(), Icons.receipt_outlined, const Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    _buildStatChip('Products', data.noProd.toString(), Icons.inventory_2_outlined, const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStatChip('Quantity', _formatNumber(data.tQty!), Icons.widgets_outlined, const Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    _buildStatChip('Items', data.lineItem.toString(), Icons.checklist_outlined, const Color(0xFF8B5CF6)),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // 👈 centers horizontally

                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed, size: 16, color: Color(0xFF059669)), // 👈 small icon
                          const SizedBox(width: 4),
                          const Text(
                            "Avg per min:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${calculateAvgPerMinute(data.tQty!, data.getWorkDuration())} QTY / "
                                "${calculateLineProductAvgPerMinute(data.lineItem!, data.getWorkDuration())} Prod",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  int calculateAvgPerMinute(int quantity, String durationStr) {
    try {
      double totalMinutes = 0.0;

      // Check if format is "X hrs Y mins"
      if (durationStr.contains("hrs") || durationStr.contains("mins")) {
        // Parse "8 hrs 27 mins" format
        final parts = durationStr.split(" ");
        for (int i = 0; i < parts.length; i += 2) {
          final value = int.tryParse(parts[i]) ?? 0;
          final unit = parts[i + 1];

          if (unit.startsWith("hr")) {
            totalMinutes += value * 60.0;
          } else if (unit.startsWith("min")) {
            totalMinutes += value;
          }
        }
      } else {
        // Parse "HH:MM:SS" format
        final parts = durationStr.split(":");
        if (parts.length == 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = int.tryParse(parts[2]) ?? 0;

          totalMinutes = hours * 60.0 + minutes + seconds / 60.0;
        }
      }

      if (totalMinutes <= 0) {
        return 0;
      }

      return (quantity / totalMinutes).round(); // Rounded to nearest int
    } catch (e) {
      print("Error calculating average: $e");
      return 0;
    }
  }

  int calculateLineProductAvgPerMinute(int quantity, String durationStr) {
    try {
      double totalMinutes = 0.0;

      // Check if format is "X hrs Y mins"
      if (durationStr.contains("hrs") || durationStr.contains("mins")) {
        // Parse "8 hrs 27 mins" format
        final parts = durationStr.split(" ");
        for (int i = 0; i < parts.length; i += 2) {
          final value = int.tryParse(parts[i]) ?? 0;
          final unit = parts[i + 1];

          if (unit.startsWith("hr")) {
            totalMinutes += value * 60.0;
          } else if (unit.startsWith("min")) {
            totalMinutes += value;
          }
        }
      } else {
        // Parse "HH:MM:SS" format
        final parts = durationStr.split(":");
        if (parts.length == 3) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = int.tryParse(parts[2]) ?? 0;

          totalMinutes = hours * 60.0 + minutes + seconds / 60.0;
        }
      }

      if (totalMinutes <= 0) {
        return 0;
      }

      return (quantity / totalMinutes).round(); // Rounded to nearest int
    } catch (e) {
      print("Error calculating average: $e");
      return 0;
    }
  }


  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.bar_chart_outlined,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFF59E0B); // Gold
      case 1:
        return const Color(0xFF6B7280); // Silver
      case 2:
        return const Color(0xFFEA580C); // Bronze
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

}



// Replace your existing chart widgets with these 3D versions:

