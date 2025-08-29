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
            colors: [
              AppTheme.primaryBlue,
              AppTheme.medicalTeal,
              AppTheme.mintGreen,
            ],
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
          color: AppTheme.primaryBlue.withOpacity(0.2),
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
                  color: AppTheme.primaryBlue,
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
              color: AppTheme.primaryBlue,
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
      color: AppTheme.primaryBlue,
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
            color: AppTheme.primaryBlue,
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
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.medicalTeal.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.inventory_outlined,
              size: 48,
              color: AppTheme.primaryBlue,
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
          childAspectRatio: 0.92,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.filteredPackerList.length,
        itemBuilder: (context, index) {
          final packerData = controller.filteredPackerList[index];
          return PackerItemCard(
            packerData: packerData,
            index: index,
            onTap: () => controller.onPackerItemTap(packerData),
          );
        },
      ),
    );
  }
}

class PackerItemCard extends StatelessWidget {
  final PickerData packerData;
  final int index;
  final VoidCallback onTap;

  const PackerItemCard({
    Key? key,
    required this.packerData,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primaryBlue.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.medicalTeal],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'INV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.orange,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  packerData.invNo ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.inventory_2,
                  packerData.trayNo ?? 'N/A',
                  AppTheme.orange,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.access_time,
                  packerData.iTime ?? 'N/A',
                  AppTheme.medicalTeal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 11,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}