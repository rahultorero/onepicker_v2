import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:convert';
import 'dart:math' as math;

import '../model/UserPerformanceData.dart';

class Performance3DChart extends StatefulWidget {
  final List<UserPerformanceData> data;
  final String chartType;
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const Performance3DChart({
    Key? key,
    required this.data,
    required this.chartType,
    required this.title,
    required this.icon,
    this.primaryColor = const Color(0xFF3B82F6),
    this.secondaryColor = const Color(0xFF2563EB),
  }) : super(key: key);

  @override
  State<Performance3DChart> createState() => _Performance3DChartState();
}

class _Performance3DChartState extends State<Performance3DChart>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool autoRotate = true;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _generate3DBarChart() {
    final topData = widget.data.take(5).toList();
    if (topData.isEmpty) return '{}';

    final names = topData.map((e) => e.name?.split(' ').first ?? 'User').toList();
    final quantities = topData.map((e) => e.tQty ?? 0).toList();
    final products = topData.map((e) => e.noProd ?? 0).toList();
    final lineItems = topData.map((e) => e.lineItem ?? 0).toList();

    return jsonEncode({
      'backgroundColor': 'transparent',
      'tooltip': {
        'trigger': 'axis3D',
        'backgroundColor': 'rgba(30, 41, 59, 0.95)',
        'borderColor': 'transparent',
        'textStyle': {'color': '#ffffff', 'fontSize': 12},
        'formatter': '''function(params) {
          return params.seriesName + '<br/>' +
                 params.name + ': ' + params.value[3] + '<br/>' +
                 'Products: ' + params.value[4] + '<br/>' +
                 'Items: ' + params.value[5];
        }'''
      },
      'xAxis3D': {
        'type': 'category',
        'data': names,
        'name': 'Performers',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
      },
      'yAxis3D': {
        'type': 'value',
        'name': 'Quantity',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
        'splitLine': {'lineStyle': {'color': '#F1F5F9'}},
      },
      'zAxis3D': {
        'type': 'value',
        'name': 'Products',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
        'splitLine': {'lineStyle': {'color': '#F1F5F9'}},
      },
      'grid3D': {
        'boxWidth': 200,
        'boxHeight': 100,
        'boxDepth': 120,
        'viewControl': {
          'autoRotate': autoRotate,
          'autoRotateSpeed': 8,
          'rotateSensitivity': 1,
          'zoomSensitivity': 1,
          'panSensitivity': 1,
          'alpha': 25,
          'beta': 40,
          'distance': 200,
        },
        'light': {
          'main': {
            'intensity': 1.2,
            'shadow': true,
            'shadowQuality': 'high',
            'alpha': 30,
            'beta': 40,
          },
          'ambient': {
            'intensity': 0.3,
          }
        },
        'environment': '#F8FAFC',
        'postEffect': {
          'enable': true,
          'bloom': {'enable': true, 'intensity': 0.1},
          'SSAO': {'enable': true, 'intensity': 1.2, 'radius': 5},
        }
      },
      'series': [
        {
          'name': 'Performance Data',
          'type': 'bar3D',
          'data': List.generate(topData.length, (i) => [
            i, quantities[i], products[i], quantities[i], products[i], lineItems[i]
          ]),
          'itemStyle': {
            'color': '''function(params) {
              const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];
              return {
                type: 'linear',
                x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [
                  {offset: 0, color: colors[params.dataIndex % colors.length]},
                  {offset: 1, color: colors[params.dataIndex % colors.length] + '80'}
                ]
              };
            }''',
            'opacity': 0.9,
          },
          'emphasis': {
            'itemStyle': {
              'color': '#${widget.primaryColor.value.toRadixString(16).substring(2)}',
              'opacity': 1,
            }
          },
          'shading': 'realistic',
          'realisticMaterial': {
            'roughness': 0.2,
            'metalness': 0.1,
            'textureTiling': [1, 1],
          }
        }
      ]
    });
  }

  String _generate3DScatterChart() {
    final topData = widget.data.take(10).toList();
    if (topData.isEmpty) return '{}';

    return jsonEncode({
      'backgroundColor': 'transparent',
      'tooltip': {
        'trigger': 'item',
        'backgroundColor': 'rgba(30, 41, 59, 0.95)',
        'borderColor': 'transparent',
        'textStyle': {'color': '#ffffff', 'fontSize': 12},
        'formatter': '''function(params) {
          return params.data[6] + '<br/>' +
                 'Quantity: ' + params.data[0] + '<br/>' +
                 'Products: ' + params.data[1] + '<br/>' +
                 'Line Items: ' + params.data[2];
        }'''
      },
      'xAxis3D': {
        'name': 'Quantity',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
        'splitLine': {'lineStyle': {'color': '#F1F5F9'}},
      },
      'yAxis3D': {
        'name': 'Products',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
        'splitLine': {'lineStyle': {'color': '#F1F5F9'}},
      },
      'zAxis3D': {
        'name': 'Line Items',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
        'splitLine': {'lineStyle': {'color': '#F1F5F9'}},
      },
      'grid3D': {
        'boxWidth': 200,
        'boxHeight': 120,
        'boxDepth': 150,
        'viewControl': {
          'autoRotate': autoRotate,
          'autoRotateSpeed': 6,
          'rotateSensitivity': 1,
          'zoomSensitivity': 1,
          'panSensitivity': 1,
          'alpha': 20,
          'beta': 30,
          'distance': 250,
        },
        'light': {
          'main': {
            'intensity': 1.5,
            'shadow': true,
            'shadowQuality': 'high',
            'alpha': 40,
            'beta': 20,
          },
          'ambient': {'intensity': 0.4}
        },
        'environment': '#F8FAFC',
        'postEffect': {
          'enable': true,
          'bloom': {'enable': true, 'intensity': 0.15},
          'SSAO': {'enable': true, 'intensity': 1.5, 'radius': 8},
        }
      },
      'series': [
        {
          'name': 'Performance Scatter',
          'type': 'scatter3D',
          'data': topData.map((e) => [
            e.tQty ?? 0,
            e.noProd ?? 0,
            e.lineItem ?? 0,
            (e.tQty ?? 0) * 0.1 + 8, // symbolSize
            e.name?.split(' ').first ?? 'User', // label
            '#${widget.primaryColor.value.toRadixString(16).substring(2)}', // color
            e.name ?? 'Unknown User' // full name for tooltip
          ]).toList(),
          'symbolSize': '''function(data) { return data[3]; }''',
          'itemStyle': {
            'color': '''function(params) {
              const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4', '#8B5CF6', '#F97316', '#EC4899', '#84CC16'];
              return {
                type: 'radial',
                x: 0.5, y: 0.3,
                r: 0.8,
                colorStops: [
                  {offset: 0, color: '#ffffff'},
                  {offset: 0.3, color: colors[params.dataIndex % colors.length]},
                  {offset: 1, color: colors[params.dataIndex % colors.length] + '60'}
                ]
              };
            }''',
            'opacity': 0.85,
            'borderWidth': 2,
            'borderColor': '#ffffff'
          },
          'emphasis': {
            'itemStyle': {
              'opacity': 1,
              'borderWidth': 3,
            }
          },
          'label': {
            'show': true,
            'position': 'top',
            'color': '#374151',
            'fontSize': 10,
            'fontWeight': 500,
            'formatter': '''function(params) { return params.data[4]; }'''
          }
        }
      ]
    });
  }

  String _generate3DSurfaceChart() {
    final topData = widget.data.take(5).toList();
    if (topData.isEmpty) return '{}';

    // Create surface data based on performance metrics
    List<List<double>> surfaceData = [];
    for (int i = 0; i < 20; i++) {
      List<double> row = [];
      for (int j = 0; j < 20; j++) {
        // Create a smooth surface representing performance efficiency
        double x = i / 19.0 * 10;
        double y = j / 19.0 * 10;
        double z = 0;

        // Add peaks for each top performer
        for (int k = 0; k < topData.length; k++) {
          double centerX = (k + 1) * 2.0;
          double centerY = 5.0;
          double intensity = (topData[k].tQty ?? 0) / 100.0;
          double distance = ((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
          z += intensity * math.exp(-distance / 3.0);
        }
        row.add(z);
      }
      surfaceData.add(row);
    }

    return jsonEncode({
      'backgroundColor': 'transparent',
      'tooltip': {
        'trigger': 'item',
        'backgroundColor': 'rgba(30, 41, 59, 0.95)',
        'borderColor': 'transparent',
        'textStyle': {'color': '#ffffff', 'fontSize': 12},
      },
      'xAxis3D': {
        'type': 'value',
        'name': 'Performance Index',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
      },
      'yAxis3D': {
        'type': 'value',
        'name': 'Efficiency',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
      },
      'zAxis3D': {
        'type': 'value',
        'name': 'Output',
        'nameTextStyle': {'color': '#64748B', 'fontSize': 11},
        'axisLabel': {'color': '#64748B', 'fontSize': 10},
        'axisLine': {'lineStyle': {'color': '#E2E8F0'}},
      },
      'grid3D': {
        'boxWidth': 180,
        'boxHeight': 120,
        'boxDepth': 140,
        'viewControl': {
          'autoRotate': autoRotate,
          'autoRotateSpeed': 4,
          'rotateSensitivity': 1,
          'zoomSensitivity': 1,
          'panSensitivity': 1,
          'alpha': 35,
          'beta': 30,
          'distance': 280,
        },
        'light': {
          'main': {
            'intensity': 1.8,
            'shadow': true,
            'shadowQuality': 'ultra',
            'alpha': 30,
            'beta': 60,
          },
          'ambient': {'intensity': 0.5}
        },
        'environment': '#F8FAFC',
        'postEffect': {
          'enable': true,
          'bloom': {'enable': true, 'intensity': 0.2},
          'SSAO': {'enable': true, 'intensity': 2.0, 'radius': 10},
          'colorCorrection': {
            'enable': true,
            'brightness': 0.1,
            'contrast': 1.1,
            'saturation': 1.2,
          }
        }
      },
      'series': [
        {
          'name': 'Performance Surface',
          'type': 'surface',
          'wireframe': {'show': false},
          'data': surfaceData,
          'itemStyle': {
            'color': '''function(params) {
              return {
                type: 'linear',
                x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [
                  {offset: 0, color: '#3B82F6'},
                  {offset: 0.3, color: '#10B981'},
                  {offset: 0.6, color: '#F59E0B'},
                  {offset: 1, color: '#EF4444'}
                ]
              };
            }''',
            'opacity': 0.8,
          },
          'shading': 'realistic',
          'realisticMaterial': {
            'roughness': 0.1,
            'metalness': 0.2,
            'textureTiling': [2, 2],
          }
        }
      ]
    });
  }

  String _getChartOption() {
    switch (widget.chartType) {
      case 'bar':
        return _generate3DBarChart();
      case 'scatter':
        return _generate3DScatterChart();
      case 'surface':
        return _generate3DSurfaceChart();
      default:
        return _generate3DBarChart();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Header with controls
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, color: widget.primaryColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              // Rotation toggle
              Container(
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: Icon(
                    autoRotate ? Icons.pause : Icons.play_arrow,
                    color: widget.primaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      autoRotate = !autoRotate;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Chart Area
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF8FAFC),
                        widget.primaryColor.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Echarts(
                      option: _getChartOption(),
                      extraScript: '''
                        chart.on('click', function(params) {
                          console.log('Clicked:', params);
                        });
                      ''',
                    ),
                  ),
                ),
              );
            },
          ),

          // Legend
          const SizedBox(height: 12),
          if (widget.data.isNotEmpty) _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final topData = widget.data.take(5).toList();
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chartType == 'surface' ? 'Performance Peaks' : 'Top Performers',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: topData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final color = colors[index % colors.length];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.name?.split(' ').first ?? 'User',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}