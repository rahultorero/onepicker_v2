import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../controllers/DashboardController.dart';
import '../model/DashBoardDataModel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(controller),
      body: _buildBody(controller),
      floatingActionButton: _buildFloatingActionButtons(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(DashboardController controller) {
    return AppBar(
      title: const Text('Dashboard'),
      backgroundColor: const Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: controller.loadInitialData,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildBody(DashboardController controller) {
    return Row(
      children: [
        _buildStatisticsPanel(controller),
        Expanded(
          child: Column(
            children: [
              _buildSearchSection(controller),
              _buildMainContent(controller),
              Obx(() => controller.isDetailViewVisible.value
                  ? _buildDetailView(controller)
                  : const SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsPanel(DashboardController controller) {
    return Container(
      width: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        border: Border(right: BorderSide(color: Color(0xFF404040))),
      ),
      child: Column(
        children: [
          _buildDateSelector(controller),
          Expanded(
            child: Obx(() {
              final data = controller.dbCountData.value;
              if (data == null) {
                return const Center(
                  child: Text(
                    'No data',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return _buildStatistics(data, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(DashboardController controller) {
    return GestureDetector(
      onTap: () => _selectDate(controller),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF404040),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4CAF50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => Text(
                controller.formattedDate,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(DashboardController controller) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.loadInitialData();
    }
  }

  Widget _buildStatistics(DBcountData data, DashboardController controller) {
    final total = data.total ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildStatCard('Total', total, total, const Color(0xFF4CAF50), Icons.inventory),
          const SizedBox(height: 16),
          _buildStatCard('Tray', data.tray ?? 0, total, const Color(0xFF2196F3), Icons.inventory_2),
          const SizedBox(height: 16),
          _buildStatCard('Picked', data.picked ?? 0, total, const Color(0xFFE91E63), Icons.shopping_cart),
          const SizedBox(height: 16),
          if (controller.workingWithPickupManager.value) ...[
            _buildStatCard('Pick Mgr', data.mPicked ?? 0, total, const Color(0xFFFFC107), Icons.person),
            const SizedBox(height: 16),
          ],
          _buildStatCard('Checked', data.checked ?? 0, total, const Color(0xFF9C27B0), Icons.check_circle),
          const SizedBox(height: 16),
          _buildStatCard('Packed', data.packed ?? 0, total, const Color(0xFFFF5722), Icons.backpack),
          const SizedBox(height: 16),
          _buildStatCard('Delivered', data.delivered ?? 0, total, const Color(0xFF795548), Icons.local_shipping),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int current, int total, Color color, IconData icon) {
    final percentage = total > 0 ? (current / total) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF404040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            current.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFF555555),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF555555)),
            ),
            child: Obx(() => DropdownButton<String>(
              value: controller.selectedCategory.value,
              dropdownColor: const Color(0xFF404040),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: controller.categories.map((category) {
                String displayName = _getCategoryDisplayName(category);
                return DropdownMenuItem(
                  value: category,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategory.value = value;
                  controller.filterData();
                }
              },
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF404040),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF555555)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      controller.searchText.value = '';
                      controller.filterData();
                    },
                    icon: const Icon(Icons.clear, color: Colors.grey),
                  )
                      : const Icon(Icons.search, color: Colors.grey)),
                ),
                onChanged: (value) => controller.searchText.value = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'InvNo':
        return 'Invoice';
      case 'TrayNo':
        return 'Tray';
      case 'PName':
        return 'Party';
      case 'Area':
        return 'Area';
      default:
        return category;
    }
  }

  Widget _buildMainContent(DashboardController controller) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        if (controller.filteredStateList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No data found',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.filteredStateList.length,
          itemBuilder: (context, index) {
            final item = controller.filteredStateList[index];
            final isSelected = controller.selectedItemIndex.value == index;

            return _buildItemCard(item, index, controller, isSelected);
          },
        );
      }),
    );
  }

  Widget _buildItemCard(DBStateData item, int index, DashboardController controller, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 2,
      color: isSelected ? const Color(0xFF404040) : const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.onItemTap(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemHeader(item),
              const SizedBox(height: 12),
              _buildItemInfo(item),
              const SizedBox(height: 16),
              _buildProgressSteps(item, controller),
              const SizedBox(height: 12),
              _buildItemFooter(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader(DBStateData item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice: ${item.invNo ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (item.trayNo != null && item.trayNo!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Tray: ${item.trayNo}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusChip('Print', (item.printed ?? 0) > 0, Icons.print),
            const SizedBox(height: 4),
            _buildStatusChip('Slip', (item.plprn ?? 0) > 0, Icons.receipt),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Yes' : 'No',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo(DBStateData item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business, color: Colors.grey, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.party ?? 'N/A',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (item.area != null && item.area!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Area: ${item.area}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSteps(DBStateData item, DashboardController controller) {
    final steps = <String>['Picked', 'Checked', 'Packed', 'Del.out'];
    if (controller.workingWithPickupManager.value) {
      steps.insert(1, 'Pick Mgr');
    }

    final currentStep = controller.calculateStepProgress(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress:',
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isActive = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : isCurrent
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF404040),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isActive ? Icons.check : isCurrent ? Icons.radio_button_unchecked : Icons.circle,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive || isCurrent ? Colors.white : Colors.grey,
                        fontSize: 8,
                        fontWeight: isActive || isCurrent ? FontWeight.w500 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemFooter(DBStateData item) {
    return Row(
      children: [
        if (item.iTime != null) ...[
          const Icon(Icons.access_time, color: Colors.grey, size: 14),
          const SizedBox(width: 4),
          Text(
            item.iTime!,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF404040),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.delType ?? 'N/A',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(DashboardController controller) {
    if (controller.selectedItemIndex.value == -1) return const SizedBox();

    final selectedItem = controller.filteredStateList[controller.selectedItemIndex.value];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailHeader(selectedItem, controller),
          Expanded(
            child: _buildDetailContent(selectedItem, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(DBStateData selectedItem, DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Invoice Details: ${selectedItem.invNo ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.closeDetailView,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(DBStateData selectedItem, DashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Party', selectedItem.party ?? 'N/A', Icons.business),
          const SizedBox(height: 8),
          _buildInfoRow('Area', selectedItem.area ?? 'N/A', Icons.location_on),
          const SizedBox(height: 8),
          _buildInfoRow('Delivery Type', selectedItem.delType ?? 'N/A', Icons.local_shipping),
          const SizedBox(height: 16),
          _buildPrintButtons(selectedItem, controller),
          const SizedBox(height: 16),
          _buildDetailList(controller),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPrintButtons(DBStateData selectedItem, DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildPrintButton(
            'Sales Invoice',
            (selectedItem.printed ?? 0) > 0,
            Icons.receipt,
                () {
              if (selectedItem.sIId != null) {
                controller.triggerPrint(selectedItem.sIId!, 'printinv');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPrintButton(
            'Packing Slip',
            (selectedItem.plprn ?? 0) > 0,
            Icons.inventory,
                () {
              if (selectedItem.sIId != null) {
                controller.triggerPrint(selectedItem.sIId!, 'printpp');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrintButton(String label, bool isPrinted, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            isPrinted ? 'Printed' : 'Not Printed',
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrinted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDetailList(DashboardController controller) {
    return Obx(() {
      if (controller.dbStateDtlList.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text(
              'No detail data available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Item Details:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: controller.dbStateDtlList.length,
                itemBuilder: (context, index) {
                  final detail = controller.dbStateDtlList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF404040),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'LOCA: ${detail.loca ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        _buildDetailStatusIcon('Pick', (detail.pick ?? 0) == 1),
                        const SizedBox(width: 12),
                        if (controller.workingWithPickupManager.value) ...[
                          _buildDetailStatusIcon('LSN', (detail.lsn ?? 0) == 1),
                          const SizedBox(width: 12),
                          _buildDetailStatusIcon('PickM', (detail.pickM ?? 0) == 1),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailStatusIcon(String label, bool isActive) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(DashboardController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "refresh",
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: controller.loadInitialData,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "search",
          backgroundColor: Colors.white,
          onPressed: () {
            Get.snackbar(
              'Search',
              'Use the search bar above to filter results',
              backgroundColor: const Color(0xFF404040),
              colorText: Colors.white,
            );
          },
          child: const Icon(Icons.search, color: Colors.black),
        ),
      ],
    );
  }
}