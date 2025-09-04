import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onepicker/controllers/HomeScreenController.dart';
import 'package:onepicker/controllers/PickerController.dart';
import 'package:onepicker/model/PickerListDetailModel.dart';

import '../controllers/CheckerController.dart';
import '../model/PickerDataModel.dart';
import '../theme/AppTheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CheckerDetailScreen extends StatefulWidget {
  final PickerData pickerData;

  const CheckerDetailScreen({
    Key? key,
    required this.pickerData,
  }) : super(key: key);

  @override
  State<CheckerDetailScreen> createState() => _CheckerDetailScreenState();
}

class _CheckerDetailScreenState extends State<CheckerDetailScreen>
    with TickerProviderStateMixin {
  final CheckerController controller = Get.find<CheckerController>();
  final PickerController pController = Get.put(PickerController());

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  String searchQuery = '';
  bool isSearching = false;
  bool showExpandedTrayNo = false;
  List<PickerMenuDetail> filteredDetails = [];
  List<PickerMenuDetail> checkedItems = [];
  // Changed: Use unique item identifier instead of index
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, FocusNode> qtyFocusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupSearch();
  }

  String _getUniqueItemKey(PickerMenuDetail item) {
    // Create unique key using item properties that don't change
    return '${item.itemDetailId}_${item.batchNo}_${item.loca}_${item.locn}';
  }

  void _initializeData() {
    filteredDetails = List.from(controller.packerDetails);
    _updateCheckedItems();

    // Initialize controllers and focus nodes with unique keys
    for (var item in controller.packerDetails) {
      final key = _getUniqueItemKey(item);
      qtyControllers[key] = TextEditingController();
      qtyFocusNodes[key] = FocusNode();

      // Set initial values for checked items
      if (item.isChk == "YES") {
        qtyControllers[key]?.text = item.tQty?.toString() ?? '';
      }
    }
  }

  void _setupSearch() {
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
        _filterDetails();
      });
    });
  }

  void _filterDetails() {
    if (searchQuery.isEmpty) {
      filteredDetails = List.from(controller.packerDetails);
    } else {
      filteredDetails = controller.packerDetails.where((item) {
        final batchNo = item.batchNo?.toLowerCase() ?? '';
        final mrp = item.mrp?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return batchNo.contains(query) || mrp.contains(query);
      }).toList();
    }
    _updateCheckedItems();
  }

  void _updateCheckedItems() {
    checkedItems = filteredDetails.where((item) => item.isChk == "YES").toList();
  }

  bool _shouldShowUnmasked(PickerMenuDetail item) {
    if (searchQuery.length < 2) return false;

    final batchNo = item.batchNo?.toLowerCase() ?? '';
    final mrp = item.mrp?.toString().toLowerCase() ?? '';
    final query = searchQuery.toLowerCase();

    return batchNo.contains(query) || mrp.contains(query);
  }

  String _getMaskedText(String? text, bool showUnmasked, {bool isMrp = false}) {
    if (text == null || text.isEmpty) return '***';
    if (showUnmasked) return text;

    if (isMrp) {
      // Show only 1 character for MRP
      return text.length > 1 ? '${text.substring(0, 1)}***' : '***';
    } else {
      // Show 3 characters for batch number
      return text.length > 3 ? '${text.substring(0, 3)}***' : '***';
    }
  }

  void _onQtyChanged(PickerMenuDetail item, String value) {
    final targetQty = item.tQty?.toString() ?? '';
    final itemKey = _getUniqueItemKey(item);

    setState(() {
      if (value == targetQty) {
        // Update the model directly
        item.isChk = "YES";
        // Set the tQty in the model to maintain consistency
        if (item.tQty == null) {
          item.tQty = int.tryParse(value);
        }

        if (!checkedItems.contains(item)) {
          checkedItems.add(item);
        }

        // Clear the controller since item is now checked
        qtyControllers[itemKey]?.text = value;

        _showSuccessMessage();

        // Unfocus the field
        qtyFocusNodes[itemKey]?.unfocus();
      } else {
        // Update the model directly
        item.isChk = "NO";
        checkedItems.remove(item);

        if (value.isNotEmpty && value != targetQty) {
          _showCorrectQtyMessage(targetQty);
        }
      }
    });
  }

  void _showCorrectQtyMessage(String correctQty) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correct QTY is: $correctQty'),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessMessage() {
    HapticFeedback.lightImpact();
  }

  Color _getCardColor(PickerMenuDetail item) {
    if (item.isChk == "YES") {
      return Colors.green.shade50;
    }
    return Colors.white;
  }

  Color _getCardBorderColor(PickerMenuDetail item) {
    if (item.isChk == "YES") {
      return Colors.green.shade400;
    }
    return Colors.grey.shade300;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    qtyControllers.values.forEach((controller) => controller.dispose());
    qtyFocusNodes.values.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          Expanded(
            child: _buildItemsList(),
          ),
          if (checkedItems.isNotEmpty) _buildSubmitButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryTeal,
      elevation: 3,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Quality Check',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                '${HomeScreenController.selectCamera}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final showAllTrays = false.obs;

    return Obx(() {
      final totalItems = controller.packerDetails.length;
      final completedItems = checkedItems.length;

      final trayNumbers = (widget.pickerData.trayNo ?? "")
          .toString()
          .split(",")
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  // Tray Badge
                  GestureDetector(
                    onTap: () {
                      if (trayNumbers.length > 1) {
                        showAllTrays.value = !showAllTrays.value;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.coralPink, AppTheme.amberGold],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.coralPink.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            trayNumbers.first,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (trayNumbers.length > 1 && !showAllTrays.value) ...[
                            SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "+${trayNumbers.length - 1}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Invoice Badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${widget.pickerData.invNo}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Progress Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: completedItems == totalItems
                            ? [AppTheme.success, AppTheme.sage]
                            : [AppTheme.lavender, AppTheme.warmAccent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (completedItems == totalItems ? AppTheme.success : AppTheme.lavender)
                              .withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "$completedItems/$totalItems",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Expanded Tray List
              if (showAllTrays.value && trayNumbers.length > 1) ...[
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: trayNumbers.skip(1).map((tray) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.coralPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.coralPink.withOpacity(0.3)),
                      ),
                      child: Text(
                        tray,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.coralPink,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.only(left: 16,right: 16),
      height: 45,
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by Batch No or MRP...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey, size: 20),
            onPressed: () {
              searchController.clear();
              searchFocusNode.unfocus();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    // Sort items: unchecked first, then checked
    final sortedItems = [...filteredDetails];
    sortedItems.sort((a, b) {
      if (a.isChk == "YES" && b.isChk != "YES") return 1;
      if (a.isChk != "YES" && b.isChk == "YES") return -1;
      return 0;
    });

    return Obx(() {
      if (controller.isLoadingPackerDetails.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        );
      }

      return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 0.72,
        ),
        itemCount: sortedItems.length,
        itemBuilder: (context, index) {
          final item = sortedItems[index];
          return _buildItemCard(item);
        },
      );
    });
  }

  Widget _buildItemCard(PickerMenuDetail item) {
    final showUnmasked = _shouldShowUnmasked(item);
    final isChecked = item.isChk == "YES";
    final canEditQty = showUnmasked || searchQuery.length >= 2;
    final itemKey = _getUniqueItemKey(item);

    return Card(
      elevation: 3,
      color: _getCardColor(item),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getCardBorderColor(item),
          width: isChecked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.purple.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.loca}-${item.locn}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                const SizedBox(width: 6),
                if (isChecked)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Item Name
            GestureDetector(
              onTap: () => pController.showItemStockDetail(
                item.itemDetailId ?? 0,
                item.itemName.toString(),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.red.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.itemName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.packing ?? '',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),

            const SizedBox(height: 6),

            // Item Details
            Expanded(
              child: Column(
                children: [
                  _buildDetailRow(
                    'B',
                    _getMaskedText(item.batchNo, showUnmasked),
                    Colors.pink,
                  ),
                  const SizedBox(height: 3),
                  _buildDetailRow(
                    'E',
                    item.sExpDate ?? '',
                    Colors.black87,
                  ),
                  const SizedBox(height: 3),
                  _buildDetailRow(
                    'M',
                    _getMaskedText(item.mrp?.toString(), showUnmasked, isMrp: true),
                    Colors.black87,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Quantity Field
            _buildQuantityField(item, canEditQty),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField(PickerMenuDetail item, bool canEdit) {
    final itemKey = _getUniqueItemKey(item);

    return TextField(
      controller: qtyControllers[itemKey],
      focusNode: qtyFocusNodes[itemKey],
      enabled: canEdit,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: canEdit ? Colors.black : Colors.grey,
      ),
      decoration: InputDecoration(
        hintText: 'Qty' ,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        filled: true,
        fillColor: canEdit ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: canEdit ? Colors.orange : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: canEdit ? Colors.orange : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      onChanged: (value) => _onQtyChanged(item, value),
      onEditingComplete: () {
        qtyFocusNodes[itemKey]?.unfocus();
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: Obx(() => ElevatedButton(
          onPressed: controller.isSubmittingData.value
              ? null
              : () {
            controller.submitCheckedItems(widget.pickerData, checkedItems);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.isSubmittingData.value
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text('Submitting...'),
            ],
          )
              : Text(
            'Submit (${checkedItems.length}/${controller.packerDetails.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
      ),
    );
  }
}