import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onepicker/controllers/HomeScreenController.dart';
import 'package:onepicker/model/PickerListDetailModel.dart';

import '../controllers/CheckerController.dart';
import '../model/PickerDataModel.dart';
import '../theme/AppTheme.dart';

class CheckerDetailScreen extends StatefulWidget {
  final PickerData pickerData;

  const CheckerDetailScreen({
    Key? key,
    required this.pickerData,
  }) : super(key: key);

  @override
  _CheckerDetailScreenState createState() => _CheckerDetailScreenState();
}

class _CheckerDetailScreenState extends State<CheckerDetailScreen> with TickerProviderStateMixin {
  final CheckerController controller = Get.find<CheckerController>();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  // Map to store quantity controllers and focus nodes for each item
  Map<int, TextEditingController> quantityControllers = {};
  Map<int, FocusNode> quantityFocusNodes = {};

  // Filtered and sorted list based on search and status
  RxList<PickerMenuDetail> filteredItems = <PickerMenuDetail>[].obs;
  RxList<PickerMenuDetail> selectedItems = <PickerMenuDetail>[].obs;

  // Validation settings
  bool validateBatch = true;
  String? validateChar;
  bool searchType = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize filtered items and check for already selected items
    _initializeItems();

    // Initialize quantity controllers and focus nodes for each item
    for (int i = 0; i < controller.packerDetails.length; i++) {
      quantityControllers[i] = TextEditingController(
          text: controller.packerDetails[i].tQty?.toString() ?? ''
      );
      quantityFocusNodes[i] = FocusNode();
    }

    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  void _initializeItems() {
    // Check for already completed items
    for (var item in controller.packerDetails) {
      if (item.isChk == "YES" && !selectedItems.contains(item)) {
        selectedItems.add(item);
      }
    }
    _sortAndFilterItems();
  }

  void _sortAndFilterItems() {
    List<PickerMenuDetail> allItems = List.from(controller.packerDetails);

    // Apply search filter if any
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase().trim();
      validateChar = query;
      searchType = query.length >= 2;

      allItems = allItems.where((item) {
        final batch = item.batchNo?.toLowerCase() ?? '';
        final mrp = item.mrp?.toString() ?? '';
        return batch.contains(query) || mrp.contains(query);
      }).toList();
    } else {
      validateChar = null;
      searchType = false;
    }

    // Sort items: incomplete first, then completed
    allItems.sort((a, b) {
      if (a.isChk == "YES" && b.isChk != "YES") return 1;
      if (a.isChk != "YES" && b.isChk == "YES") return -1;
      return 0;
    });

    filteredItems.assignAll(allItems);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    quantityControllers.values.forEach((controller) => controller.dispose());
    quantityFocusNodes.values.forEach((focus) => focus.dispose());
    _fadeController.dispose();
    _slideController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _sortAndFilterItems();
  }

  void _handleFocusChange(FocusNode targetFocus) {
    if (targetFocus != searchFocus) {
      searchFocus.unfocus();
    }

    quantityFocusNodes.values.forEach((focus) {
      if (focus != targetFocus) {
        focus.unfocus();
      }
    });

    if (!targetFocus.hasFocus) {
      FocusScope.of(context).requestFocus(targetFocus);
    }
  }

  void _showQuantityMessage(String message) {
    _fadeController.forward();
    _messageTimer?.cancel();
    _messageTimer = Timer(Duration(milliseconds: 2000), () {
      _fadeController.reverse();
    });
  }

  String _getMaskedBatch(String batchNo) {
    if (!validateBatch) return batchNo;

    bool showUnmasked = false;
    if (validateChar != null && validateChar!.length >= 2) {
      if (batchNo.toLowerCase().contains(validateChar!.toLowerCase())) {
        showUnmasked = true;
      }
    }

    if (searchType || showUnmasked) {
      return batchNo;
    }

    return batchNo.length > 3 ? "${batchNo.substring(0, 3)}***" : "***";
  }

  String _getMaskedMRP(String mrp) {
    if (!validateBatch) return mrp;

    bool showUnmasked = false;
    if (validateChar != null && validateChar!.length >= 2) {
      if (mrp.toLowerCase().contains(validateChar!.toLowerCase())) {
        showUnmasked = true;
      }
    }

    if (searchType || showUnmasked) {
      return mrp;
    }

    return mrp.length > 3 ? "${mrp.substring(0, 1)}***" : "***";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingPackerDetails.value) {
                    return _buildLoadingState();
                  }

                  if (filteredItems.isEmpty && controller.packerDetails.isNotEmpty) {
                    return _buildNoResultsState();
                  }

                  if (controller.packerDetails.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildItemGrid();
                }),
              ),
            ],
          ),
          _buildQuantityMessage(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF334155),
            size: 16,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Quality Check',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                '${HomeScreenController.selectCamera}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final showAllTrays = false.obs; // reactive toggle with GetX

    return Obx(() {
      final totalItems = controller.packerDetails.length;
      final completedItems = selectedItems.length;

      final trayNumbers = (widget.pickerData.trayNo ?? "")
          .toString()
          .split(",")
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      return Container(
        margin: const EdgeInsets.only(left: 12,right:12,top: 12 ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Row with Tray + Invoice + Progress
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔶 Tray Box
                GestureDetector(
                  onTap: () {
                    if (trayNumbers.length > 1) {
                      showAllTrays.value = !showAllTrays.value;
                    }
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF97316).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_rounded,
                            size: 16, color: Color(0xFFEA580C)),
                        const SizedBox(width: 6),
                        Text(
                          trayNumbers.first,
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (trayNumbers.length > 1 && !showAllTrays.value) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "+${trayNumbers.length - 1}",
                              style: const TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // 🔵 Invoice Box
                Flexible(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 16, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${widget.pickerData.invNo}',
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12,),

                // ✅ Progress + Upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: completedItems == totalItems
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "$completedItems / $totalItems",
                            style: TextStyle(
                              color: completedItems == totalItems
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF1D4ED8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Color(0xFF7C3AED),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 🔽 Expanded Tray List (if badge clicked)
            if (showAllTrays.value && trayNumbers.length > 1) ...[
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: trayNumbers
                    .map((tray) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right,
                          size: 16, color: Color(0xFFEA580C)),
                      const SizedBox(width: 4),
                      Text(
                        tray,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 8), // removed vertical gap
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: searchFocus.hasFocus
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE2E8F0),
          width: searchFocus.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: searchFocus.hasFocus
                ? const Color(0xFF3B82F6).withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: searchFocus.hasFocus ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocus,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search by Batch or MRP...',
          hintStyle: TextStyle(
            color: const Color(0xFF64748B).withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: searchFocus.hasFocus
                ? const Color(0xFF3B82F6)
                : const Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
            onPressed: () {
              searchController.clear();
              // Trigger rebuild
              (searchController as TextEditingController).notifyListeners();
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onTap: () => _handleFocusChange(searchFocus),
      ),
    );
  }

  Widget _buildQuantityMessage() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Incorrect quantity! Check the correct amount.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final originalIndex = controller.packerDetails.indexOf(item);
          return _buildItemCard(item, originalIndex);
        },
      ),
    );
  }

  Widget _buildItemCard(PickerMenuDetail item, int index) {
    final isCompleted = item.isChk == "YES";
    final isError = item.isChk == "ERROR";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFF0FDF4)
            : isError
            ? const Color(0xFFFEF2F2)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF22C55E)
              : isError
              ? const Color(0xFFEF4444)
              : const Color(0xFFE2E8F0),
          width: isCompleted || isError ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF22C55E).withOpacity(0.1)
                : isError
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: isCompleted || isError ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and location row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.locn?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Status indicator
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Item name
            Text(
              item.itemName ?? 'Unknown Item',
              style: TextStyle(
                color: isCompleted ? const Color(0xFF166534) : const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Details with masking
            _buildDetailRow(
                'Batch',
                _getMaskedBatch(item.batchNo ?? 'N/A'),
                const Color(0xFF8B5CF6)
            ),
            _buildDetailRow(
                'Expiry',
                item.sExpDate ?? 'N/A',
                const Color(0xFF64748B)
            ),
            _buildDetailRow(
                'MRP',
                '₹${_getMaskedMRP(item.mrp?.toString() ?? '0')}',
                const Color(0xFF059669)
            ),

            const Spacer(),

            // Quantity input
            Container(
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF22C55E).withOpacity(0.1)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF22C55E)
                      : quantityFocusNodes[index]?.hasFocus == true
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE2E8F0),
                  width: quantityFocusNodes[index]?.hasFocus == true || isCompleted ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: quantityControllers[index],
                focusNode: quantityFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                enabled: !isCompleted,
                style: TextStyle(
                  color: isCompleted
                      ? const Color(0xFF166534)
                      : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: isCompleted ? 'Completed' : 'Enter Qty',
                  hintStyle: TextStyle(
                    color: isCompleted
                        ? const Color(0xFF22C55E).withOpacity(0.7)
                        : const Color(0xFF94A3B8).withOpacity(0.8),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: isCompleted
                      ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E),
                    size: 20,
                  )
                      : null,
                ),
                onChanged: (value) => _validateQuantity(index, value, item),
                onTap: () {
                  if (!isCompleted) {
                    _handleFocusChange(quantityFocusNodes[index]!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _validateQuantity(int index, String value, PickerMenuDetail item) {
    final enteredQty = int.tryParse(value) ?? 0;
    final expectedQty = item.tQty ?? 0;

    if (value.isEmpty) {
      // Reset state
      item.isChk = null;
      selectedItems.remove(item);
      _sortAndFilterItems();
      return;
    }

    if (enteredQty == expectedQty) {
      // Correct quantity
      item.isChk = "YES";
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
      }
      quantityFocusNodes[index]?.unfocus();

      // Auto-focus next incomplete item
      _focusNextIncompleteItem(index);

    } else {
      // Incorrect quantity
      item.isChk = "ERROR";
      selectedItems.remove(item);

      // Show error message
      _showQuantityMessage("Correct QTY is: $expectedQty");
    }

    _sortAndFilterItems();
    controller.packerDetails.refresh();
  }

  void _focusNextIncompleteItem(int currentIndex) {
    // Find next incomplete item to focus
    for (int i = 0; i < filteredItems.length; i++) {
      if (filteredItems[i].isChk != "YES") {
        final originalIndex = controller.packerDetails.indexOf(filteredItems[i]);
        if (quantityFocusNodes[originalIndex] != null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _handleFocusChange(quantityFocusNodes[originalIndex]!);
          });
        }
        break;
      }
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading details...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No details available',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching with different batch or MRP',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for your controller
extension CheckerControllerExtension on CheckerController {
  void updateItemQuantity(int index, int quantity) {
    if (index < packerDetails.length) {
      packerDetails[index].tQty = quantity;
      packerDetails.refresh();
    }
  }
}