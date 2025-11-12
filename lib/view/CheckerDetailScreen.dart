import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:onepicker/controllers/HomeScreenController.dart';
import 'package:onepicker/model/PickerListDetailModel.dart';
import 'package:onepicker/services/services.dart';

import '../controllers/CheckerController.dart';
import '../controllers/PickerController.dart';
import '../model/PickerDataModel.dart';
import '../theme/AppTheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'CustomerDetailsDialog.dart';
import 'PickerListTab.dart';

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
  bool isNumberKeyboard = true; // Start with number keyboard

  String searchQuery = '';
  bool isSearching = false;
  bool showExpandedTrayNo = false;
  List<PickerMenuDetail> filteredDetails = [];
  List<PickerMenuDetail> checkedItems = [];
  // Changed: Use unique item identifier instead of index
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, FocusNode> qtyFocusNodes = {};
  int batchNo = 0;
  bool isLoadingBatchNo = true;


  @override
  void initState() {
    super.initState();
    ever(controller.packerDetails, (_) {
      _initializeData();
    });
    _initializeData();
    _setupSearch();
    _loadBatchNo(); // Add this

  }

  Future<void> _loadBatchNo() async {
    try {
      batchNo = await ApiConfig.getSyn('BatchCheck');
      setState(() {
        isLoadingBatchNo = false;
      });
    } catch (e) {
      print("Error loading batch check: $e");
      setState(() {
        isLoadingBatchNo = false;
        batchNo = 0; // default value on error
      });
    }
  }

  String _getUniqueItemKey(PickerMenuDetail item) {
    // These items differ by tQty, so include it in the key
    return '${item.itemDetailId}_${item.loca}_${item.locn}_${item.batchNo}_${item.mrp}_${item.tQty}';
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
      print('📝 Init controller - Key: $key, isChk: ${item.isChk}, tQty: ${item.tQty}');

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

  Future<void> _updateCheckedItems() async {
    checkedItems = controller.packerDetails.where((item) => item.isChk == "YES").toList();
    batchNo = await ApiConfig.getSyn('BatchCheck');
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

    if (value == targetQty) {
      // Update the model directly
      item.isChk = "YES";
      if (item.tQty == null) {
        item.tQty = int.tryParse(value);
      }

      if (!checkedItems.contains(item)) {
        checkedItems.add(item);
      }

      // Keep the value in the controller
      qtyControllers[itemKey]?.text = value;

      // Show success feedback BEFORE setState
      _showSuccessMessage(item.itemName ?? 'Item');
      searchController.clear();


      // Delay the setState to give user time to see the feedback
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            // State update happens here after delay
          });
        }
      });
    } else {
      // Immediate update for incorrect quantity
      setState(() {
        item.isChk = "NO";
        checkedItems.remove(item);

        if (value.isNotEmpty && value != targetQty) {
          _showCorrectQtyMessage(targetQty);
        }
      });
    }
  }

  void _showSuccessMessage(String itemName) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Quantity Verified ✓',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    itemName,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
    return WillPopScope(
      onWillPop: () async {
        // Check if there are any checked items (unsaved changes)
        if (checkedItems.isNotEmpty) {
          final shouldSave = await _showExitDialog();
          if (shouldSave) {
            // Save changes before going back
            if (checkedItems.length == controller.packerDetails.length) {
              _showTrayManagementDialog();
            } else {
              await controller.submitCheckedItems(widget.pickerData, checkedItems);
              Get.back();
            }
          } else {
            // Discard changes and go back
            Get.back();
          }
        } else {
          // No changes, go back directly
          Get.back();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(
              child: _buildItemsList(),
            ),
            // if (checkedItems.isNotEmpty)
              _buildSubmitButton(),
          ],
        ),
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
        onPressed: () async {
          // Check if there are any checked items (unsaved changes)
          if (checkedItems.isNotEmpty) {
            final shouldSave = await _showExitDialog();
            if (shouldSave) {
              // Save changes before going back
              if (checkedItems.length == controller.packerDetails.length) {
                _showTrayManagementDialog();
              } else {
                await controller.submitCheckedItems(widget.pickerData, checkedItems);
                Get.back();
              }
            } else {
              // Discard changes and go back
              Get.back();
            }
          } else {
            // No changes, go back directly
            Get.back();
          }
        },
      ),
      // ... rest of your AppBar code remains the same
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
  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    size: 40,
                    color: Colors.orange.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Save Changes?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 8),

                // Message
                Text(
                  'You have unsaved changes. Do you want to save your progress before leaving?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Discard Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Don't save, just exit
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Discard',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Save Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Save and exit
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Yes, Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? false; // Return false if dialog is dismissed
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

      if (trayNumbers.isEmpty) {
        trayNumbers.add('N/A'); // or throw an error if this shouldn't happen
      }


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
                            "${trayNumbers.first}",
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
                    child: GestureDetector(
                        onTap: () {
                          // Example usage - replace with your actual data
                          CustomerDetailsDialog.showCustomerDialog(
                            context: context,
                            name: widget.pickerData.party!,
                            address: widget.pickerData.lMark!,
                            city: widget.pickerData.city!,
                            area: widget.pickerData.area!,
                          );
                        },
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
      margin: const EdgeInsets.only(left: 16, right: 16),
      height: 45,
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        keyboardType: isNumberKeyboard ? TextInputType.number : TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by Batch No or MRP...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ABC/123 Switch Button
              IconButton(
                icon: Icon(
                  isNumberKeyboard ? Icons.abc : Icons.dialpad,
                  color: Colors.teal.shade600,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isNumberKeyboard = !isNumberKeyboard;
                    // Refocus to update keyboard
                    searchFocusNode.unfocus();
                    Future.delayed(Duration(milliseconds: 100), () {
                      searchFocusNode.requestFocus();
                    });
                  });
                },
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    searchController.clear();
                    searchFocusNode.unfocus();
                  },
                ),
            ],
          ),
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
    return Obx(() {
      if (controller.isLoadingPackerDetails.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        );
      }

      // Sort items inside Obx so it recalculates on every rebuild
      final sortedItems = [...filteredDetails];
      sortedItems.sort((a, b) {
        if (a.isChk == "YES" && b.isChk != "YES") return 1;
        if (a.isChk != "YES" && b.isChk == "YES") return -1;
        return 0;
      });

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth >= 600;

          // Calculate columns based on screen size
          final crossAxisCount = isTablet
              ? (screenWidth >= 900 ? 4 : 3)  // 4 columns for large tablets, 3 for small tablets
              : 2;  // 2 columns for mobile

          // Dynamic spacing
          final spacing = isTablet ? 8.0 : 2.0;

          // ⭐ KEY SOLUTION: Fixed height for cards
          // Adjust this value based on your item card content
          final cardHeight = isTablet ? 285.0 : 285.0;

          // Calculate available width per card
          final horizontalPadding = 16.0; // 8 * 2
          final totalSpacing = spacing * (crossAxisCount - 1);
          final availableWidth = screenWidth - horizontalPadding - totalSpacing;
          final cardWidth = availableWidth / crossAxisCount;

          // Calculate aspect ratio dynamically based on actual dimensions
          final childAspectRatio = cardWidth / cardHeight;

          print("Items - Columns: $crossAxisCount, CardWidth: $cardWidth, CardHeight: $cardHeight, AspectRatio: $childAspectRatio");

          return GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return _buildItemCard(item, isTablet, index); // Pass index
            },
          );
        },
      );
    });
  }

  Widget _buildItemCard(PickerMenuDetail item, bool isTablet, int index) {
    if (isLoadingBatchNo) {
      return const Card(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final showUnmasked = batchNo != 1 || _shouldShowUnmasked(item);
    final isChecked = item.isChk == "YES";
    final canEditQty = showUnmasked || searchQuery.length >= 2;
    final itemKey = '${item.itemDetailId}_${item.loca}_${item.locn}_${item.batchNo}_${item.tQty}';
    print('🔑 Card Key: $itemKey');
    print('   isChk: ${item.isChk}');
    print('   tQty: ${item.tQty}');
    print('   Name: ${item.itemName}');
    print('---');

        return Card(
          key: ValueKey(itemKey),
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
                      child: Container(
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
                            const Icon(Icons.location_on, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${item.loca}-${item.locn}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),

                            Spacer(),
                      GestureDetector(
                  onTap: () {
                    String? selectedRemark = item.pNote; // Store currently selected remark

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setDialogState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    color: AppTheme.primaryTeal,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Select Remark',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Choose a remark:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Predefined options
                                  _buildRemarkOption(
                                    'Shortage in Quantity Received',
                                    selectedRemark,
                                        (value) {
                                      setDialogState(() {
                                        selectedRemark = value;
                                      });
                                    },
                                  ),
                                  _buildRemarkOption(
                                    'Excess Quantity Received',
                                    selectedRemark,
                                        (value) {
                                      setDialogState(() {
                                        selectedRemark = value;
                                      });
                                    },
                                  ),
                                  _buildRemarkOption(
                                    'Incorrect Batch Received',
                                    selectedRemark,
                                        (value) {
                                      setDialogState(() {
                                        selectedRemark = value;
                                      });
                                    },
                                  ),
                                  _buildRemarkOption(
                                    'Incorrect Product Received',
                                    selectedRemark,
                                        (value) {
                                      setDialogState(() {
                                        selectedRemark = value;
                                      });
                                    },
                                  ),
                                  _buildRemarkOption(
                                    'Product Not Picked',
                                    selectedRemark,
                                        (value) {
                                      setDialogState(() {
                                        selectedRemark = value;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Display selected remark
                                  const Text(
                                    'Selected Remark:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.primaryTeal.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[50],
                                    ),
                                    child: Text(
                                      selectedRemark ?? 'No remark selected',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedRemark != null ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                // Clear Button
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Show confirmation dialog for clearing
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: const Row(
                                            children: [
                                              Icon(
                                                Icons.warning,
                                                color: Colors.orange,
                                                size: 24,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Clear Remark',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: const Text(
                                            'Are you sure you want to clear this remark?',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  item.pNote = null;
                                                });

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Remark cleared successfully!'),
                                                    backgroundColor: Colors.orange,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Clear',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // Cancel Button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // Save Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    setState(() {
                                      item.pNote = selectedRemark;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          selectedRemark != null ? 'Remark saved successfully!' : 'Remark cleared!',
                                        ),
                                        backgroundColor: AppTheme.primaryTeal,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.save,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryTeal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.info, size: 16, color: Colors.white),
                ),

                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isChecked)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
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
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 14 : 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 3),
                Text(
                  item.packing ?? '',
                  style:  TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Manufacture and Batch details
                if(item.ccp == 1)
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.amberGold,
                          AppTheme.amberGold.withOpacity(0.8),
                          AppTheme.amberGold,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.amberGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          // Icon on the left
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.comment_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),

                          // Marquee text
                          Expanded(
                            child: _MarqueeText(
                              text: 'Checked with coolant.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 3),
                if (item.pNote != null && item.pNote!.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      TextEditingController remarkController = TextEditingController();

                      // Pre-fill with existing note
                      remarkController.text = item.pNote ?? '';

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  color: AppTheme.primaryTeal,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Review Remark',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryTeal.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: remarkController,
                                    enabled: false, // Makes the TextField non-editable
                                    maxLines: 4,
                                    minLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your remark here...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(12),
                                      hintStyle: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              // Clear Button
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Show confirmation dialog for clearing
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        title: const Row(
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.orange,
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Clear Remark',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          'Are you sure you want to clear this remark?',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                item.pNote = '';
                                              });

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Remark cleared successfully!'),
                                                  backgroundColor: Colors.orange,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Clear',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Cancel Button
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Save Button
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.pNote!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: AppTheme.primaryTeal.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Item Details
                Column(
                  children: [
                    _buildDetailRow(
                      'B',
                      _getMaskedText(item.batchNo, showUnmasked),
                      (item.bCount ?? 0) > 1
                          ? Colors.pinkAccent // when bCount > 1
                          : Colors.black87,
                      isTablet
                    ),
                    const SizedBox(height: 3),
                    _buildDetailRow(
                      'E',
                      item.sExpDate ?? '',
                      Colors.black87,
                      isTablet
                    ),
                    const SizedBox(height: 3),
                    _buildDetailRow(
                      'M',
                      _getMaskedText(item.mrp?.toString(), showUnmasked, isMrp: true),
                      (item.mCount ?? 0) > 1
                          ? Colors.pinkAccent // when bCount > 1
                          : Colors.black87,
                      isTablet
                    ),
                  ],
                ),

                const Spacer(),

                // Quantity Field
                _buildQuantityField(item, canEditQty,isTablet),
              ],
            ),
          ),
        );
  }

  Widget _buildRemarkOption(String value, String? selectedRemark, Function(String?) onChanged) {
    bool isSelected = selectedRemark == value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.primaryTeal : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? AppTheme.primaryTeal : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor,bool isTablet) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 15 : 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: labelColor,
              fontSize: isTablet ? 15 : 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField(PickerMenuDetail item, bool canEdit,bool isTablet) {
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
          fontSize: isTablet ? 14 : 12,
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
      onChanged: (value) {
        // Don't call setState immediately, just update the logic
        _onQtyChanged(item, value);
      },
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
            if(checkedItems.length == controller.packerDetails.length){
              _showTrayManagementDialog();
            }else{
              controller.submitCheckedItems(widget.pickerData, checkedItems);
              searchController.clear();
            }
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


  void _showTrayManagementDialog() {
    final controller = Get.find<CheckerController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TrayManagementDialog(        // <-- This is where TrayManagementDialog is called
          pickerData: widget.pickerData,
          onTrayUpdated: () {
            controller.submitCheckedAllItems(widget.pickerData, checkedItems);
            Get.back();
          },
          checkedItems: checkedItems,
        );
      },
    );
  }


}


class TrayManagementDialog extends StatefulWidget {
  final PickerData pickerData;
  final VoidCallback onTrayUpdated;
  final List<PickerMenuDetail> checkedItems;

   TrayManagementDialog({
    Key? key,
    required this.pickerData,
    required this.onTrayUpdated,
    required this.checkedItems
  }) : super(key: key);

  @override
  State<TrayManagementDialog> createState() => _TrayManagementDialogState();
}

class _TrayManagementDialogState extends State<TrayManagementDialog> {
  final TextEditingController _trayController = TextEditingController();
  final FocusNode _trayFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<String> oldTrays = [];
  List<String> newTrays = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeTrays();

    // Listen to focus changes to scroll to input when focused
    _trayFocusNode.addListener(() {
      if (_trayFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _trayController.dispose();
    _trayFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _initializeTrays() {
    final trayNo = widget.pickerData.trayNo ?? '';
    if (trayNo.isNotEmpty && trayNo != 'N/A') {
      oldTrays = trayNo
          .split(',')
          .map((tray) => tray.trim())
          .where((tray) => tray.isNotEmpty)
          .toList();
    }
  }

  String _formatTrayNumber(String input) {
    final length = input.length;
    switch (length) {
      case 1:
        return "9000$input";
      case 2:
        return "900$input";
      case 3:
        return "90$input";
      case 4:
        return "9$input";
      case 5:
        return input;
      default:
        return "";
    }
  }

  void _addTrayNumber() {
    final input = _trayController.text.trim();
    if (input.isEmpty) {
      setState(() {
        errorMessage = "Please enter a tray number";
      });
      return;
    }

    final formattedTray = _formatTrayNumber(input);
    if (formattedTray.isEmpty) {
      setState(() {
        errorMessage = "Invalid tray number format (1-5 digits only)";
      });
      return;
    }

    if (oldTrays.contains(formattedTray)) {
      setState(() {
        errorMessage = "Tray already exists in current list";
      });
      return;
    }

    if (newTrays.contains(formattedTray)) {
      setState(() {
        errorMessage = "Tray already added to new list";
      });
      return;
    }

    setState(() {
      newTrays.add(formattedTray);
      _trayController.clear();
      errorMessage = null;
    });
  }

  void _removeTrayNumber(String trayNumber) {
    setState(() {
      newTrays.remove(trayNumber);
      if (newTrays.isEmpty) {
        errorMessage = null;
      }
    });
  }

  Future<void> _submitSkip() async{
    final controller = Get.find<CheckerController>();
    Navigator.of(context).pop();

    controller.submitCheckedAllItems(widget.pickerData, widget.checkedItems);
    Get.back();
  }

  Future<void> _submitTrays() async {
    if (newTrays.isEmpty) {
      setState(() {
        errorMessage = "Please add at least one tray number";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final controller = Get.find<CheckerController>();

      // Only use newTrays
      final newTrayString = newTrays.join(',');

      await controller.assignTray(
        siId: widget.pickerData.sIId ?? 0,
        trayNumbers: newTrayString,
        trayCount: newTrays.length,
      );

      Navigator.of(context).pop();
      widget.onTrayUpdated();

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  Widget _buildTrayChip(String tray, {bool isRemovable = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isRemovable
            ? AppTheme.accentGreen.withOpacity(0.15)
            : AppTheme.lightTeal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRemovable
              ? AppTheme.accentGreen.withOpacity(0.4)
              : AppTheme.lightTeal.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tray,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          if (isRemovable) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _removeTrayNumber(tray),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: keyboardHeight > 0 ? 20 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: mediaQuery.size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Trays',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.pickerData.invNo ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Existing Trays - Compact
                    if (oldTrays.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.inventory_2,
                              size: 16,
                              color: AppTheme.lightTeal),
                          const SizedBox(width: 6),
                          Text(
                            'Current (${oldTrays.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: oldTrays.map((tray) => _buildTrayChip(tray)).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New Trays - Compact
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 16,
                            color: AppTheme.accentGreen),
                        const SizedBox(width: 6),
                        Text(
                          'New (${newTrays.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // New trays or placeholder
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 50),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGreen.withOpacity(0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: newTrays.isEmpty
                          ? Center(
                        child: Text(
                          'No new trays added yet',
                          style: TextStyle(
                            color: AppTheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      )
                          : Wrap(
                        children: newTrays.map((tray) =>
                            _buildTrayChip(tray, isRemovable: true)
                        ).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input Section - More prominent
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Tray Number',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _trayController,
                                  focusNode: _trayFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter 1-5 digits',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryTeal.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryTeal,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _addTrayNumber(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _addTrayNumber,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Error Message - Improved
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded,
                                color: Colors.red.shade600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Add some bottom padding for keyboard
                    SizedBox(height: keyboardHeight > 0 ? 20 : 0),
                  ],
                ),
              ),
            ),

            // Action Buttons - Always visible
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => {
                        _submitSkip()
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryTeal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isLoading || newTrays.isEmpty) ? null : _submitTrays,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'Submit${newTrays.isNotEmpty ? ' (${newTrays.length})' : ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
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
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed; // pixels per second

  const _MarqueeText({
    required this.text,
    required this.style,
    this.speed = 30.0,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  void _checkIfScrollNeeded() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = textPainter.width;
    _containerWidth = context.size?.width ?? 0;

    if (_textWidth > _containerWidth) {
      setState(() {
        _shouldScroll = true;
      });
      _startScrolling();
    }
  }

  void _startScrolling() {
    if (!_shouldScroll) return;

    final duration = Duration(
      milliseconds: ((_textWidth + _containerWidth) / widget.speed * 1000).round(),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _scrollController
            .animateTo(
          _textWidth + _containerWidth,
          duration: duration,
          curve: Curves.linear,
        )
            .then((_) {
          if (mounted) {
            _scrollController.jumpTo(0);
            _startScrolling();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldScroll) {
      return Text(
        widget.text,
        style: widget.style,
        overflow: TextOverflow.ellipsis,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          Text(widget.text, style: widget.style),
          SizedBox(width: _containerWidth),
          Text(widget.text, style: widget.style),
        ],
      ),
    );
  }
}
