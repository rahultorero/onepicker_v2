import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onepicker/services/services.dart';

import '../controllers/LoginController.dart';
import '../model/BranchData.dart';
import '../model/CompanyData.dart';
import '../model/FloorData.dart';
import '../theme/AppTheme.dart';

class CompanySelectionBottomSheet extends StatefulWidget {
  @override
  _CompanySelectionBottomSheetState createState() => _CompanySelectionBottomSheetState();
}

class _CompanySelectionBottomSheetState extends State<CompanySelectionBottomSheet> {
  bool showBranch = false;
  bool showFloor = false;
  bool isLoadingConfig = true;
  int companyId = 0;
  int brchId = 0;
  int brk = 0;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {

    try {
      final workingWithBrchValue = await ApiConfig.getSyn("WorkingWithBrch");
      final eBreakeValue = await ApiConfig.getSyn("EBreake");
      final userData = await ApiConfig.getLoginData();

      setState(() {
        showBranch = workingWithBrchValue != 0;
        showFloor = eBreakeValue != 0;

        companyId = userData?.response!.selectedCompanyID ?? 0;
        brchId = userData?.response!.selectedBranchID ?? 0;
        brk = userData?.response!.brk ?? 0;
        isLoadingConfig = false;
      });

      print("WorkingWithBrch value: $workingWithBrchValue");
      print("EBreake value: $eBreakeValue");
      print("Show Branch: $showBranch");
      print("Show Floor: $showFloor");
    } catch (e) {
      print("Error loading configuration: $e");
      setState(() {
        showBranch = true;
        showFloor = true;
        isLoadingConfig = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    if (isLoadingConfig) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryTeal,
              ),
              SizedBox(height: 16),
              Text(
                'Loading configuration...',
                style: TextStyle(
                  color: AppTheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Your Workspace',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      Text(
                        'Select company, branch and floor',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Company Selection
                  _buildSelectionCard(
                    controller: controller,
                    title: 'Select Company',
                    icon: Icons.business,
                    child: Obx(() => _buildCompanyDropdown(controller)),
                  ),

                  // Branch Selection
                  if (showBranch) ...[
                    SizedBox(height: 16),
                    _buildSelectionCard(
                      controller: controller,
                      title: 'Select Branch',
                      icon: Icons.location_on,
                      child: Obx(() => _buildBranchDropdown(controller)),
                    ),
                  ],

                  // Floor Selection
                  if (showFloor) ...[
                    SizedBox(height: 16),
                    _buildSelectionCard(
                      controller: controller,
                      title: 'Select Floor',
                      icon: Icons.layers,
                      child: Obx(() => _buildFloorDropdown(controller)),
                    ),
                  ],

                  Spacer(),

                  // Continue Button
                  Obx(() => _buildContinueButton(controller)),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required LoginController controller,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
                icon,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCompanyDropdown(LoginController controller) {
    if (controller.isCompanyLoading.value) {
      return _buildLoadingDropdown();
    }

    if (controller.companyList.isEmpty) {
      return _buildEmptyDropdown('No companies available');
    }

    // Use int IDs instead of objects for dropdown values
    final companyMap = <int, CompanyData>{};
    for (var company in controller.companyList) {
      if (company.companyid != null && !companyMap.containsKey(company.companyid)) {
        companyMap[company.companyid!] = company;
      }
    }

    final uniqueCompanyList = companyMap.values.toList();

    // Debug print
    print("Company list size: ${controller.companyList.length}");
    print("Unique company list size: ${uniqueCompanyList.length}");
    print("Company IDs: ${uniqueCompanyList.map((c) => c.companyid).toList()}");

    if (uniqueCompanyList.isEmpty) {
      return _buildEmptyDropdown('No companies available');
    }

    // Auto-select logic
    if (companyId != 0 && controller.selectedCompany.value == null) {
      final matchedCompany = uniqueCompanyList.cast<CompanyData?>().firstWhere(
            (company) => company?.companyid == companyId,
        orElse: () => null,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (matchedCompany != null) {
          controller.selectCompany(matchedCompany);
        } else if (uniqueCompanyList.isNotEmpty) {
          controller.selectCompany(uniqueCompanyList.first);
        }
      });
    }

    // Auto-select if only one company
    if (uniqueCompanyList.length == 1 && controller.selectedCompany.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectCompany(uniqueCompanyList.first);
      });
    }

    // If selected and should be locked, show as selected item
    if (controller.selectedCompany.value != null &&
        (uniqueCompanyList.length == 1 || companyId != 0)) {
      // Schedule the state change for after the current build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectCompany(controller.selectedCompany.value!);
      });

      return _buildSelectedItem(
        text: controller.selectedCompany.value?.companyname ?? 'Unknown Company',
        icon: Icons.business,
      );
    }

    // Get the selected company ID
    final selectedCompanyId = controller.selectedCompany.value?.companyid;

    // Find the actual company object from our unique list that matches the ID
    final dropdownValue = selectedCompanyId != null && companyMap.containsKey(selectedCompanyId)
        ? companyMap[selectedCompanyId]
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CompanyData>(
          isExpanded: true,
          hint: Text(
            'Choose Company',
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
          value: dropdownValue,
          items: uniqueCompanyList.map((company) {
            return DropdownMenuItem<CompanyData>(
              value: company,
              child: Text(
                company.companyname ?? 'Unknown Company',
                style: TextStyle(color: AppTheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (CompanyData? value) {
            if (value != null) controller.selectCompany(value);
          },
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown(LoginController controller) {
    if (controller.selectedCompany.value == null) {
      return _buildDisabledDropdown('Select company first');
    }

    if (controller.isBranchLoading.value) {
      return _buildLoadingDropdown();
    }

    if (controller.branchList.isEmpty) {
      return _buildEmptyDropdown('No branches available');
    }

    // Use int IDs instead of objects for dropdown values
    final branchMap = <int, BranchData>{};
    for (var branch in controller.branchList) {
      if (branch.brchid != null && !branchMap.containsKey(branch.brchid)) {
        branchMap[branch.brchid!] = branch;
      }
    }

    final uniqueBranchList = branchMap.values.toList();

    // Debug print
    print("Branch list size: ${controller.branchList.length}");
    print("Unique branch list size: ${uniqueBranchList.length}");
    print("Branch IDs: ${uniqueBranchList.map((b) => b.brchid).toList()}");

    if (uniqueBranchList.isEmpty) {
      return _buildEmptyDropdown('No branches available');
    }

    // Auto-select logic
    if (brchId != 0 && controller.selectedBranch.value == null) {
      final matchedBranch = uniqueBranchList.cast<BranchData?>().firstWhere(
            (branch) => branch?.brchid == brchId,
        orElse: () => null,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (matchedBranch != null) {
          controller.selectBranch(matchedBranch);
        } else if (uniqueBranchList.isNotEmpty) {
          controller.selectBranch(uniqueBranchList.first);
        }
      });
    }

    // Auto-select if only one branch
    if (uniqueBranchList.length == 1 && controller.selectedBranch.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectBranch(uniqueBranchList.first);
      });
    }

    // If selected and should be locked, show as selected item
    if (controller.selectedBranch.value != null &&
        (uniqueBranchList.length == 1 || brchId != 0)) {
      return _buildSelectedItem(
        text: controller.selectedBranch.value?.brchname ?? 'Unknown Branch',
        icon: Icons.location_on,
      );
    }

    // Get the selected branch ID
    final selectedBranchId = controller.selectedBranch.value?.brchid;

    // Find the actual branch object from our unique list that matches the ID
    final dropdownValue = selectedBranchId != null && branchMap.containsKey(selectedBranchId)
        ? branchMap[selectedBranchId]
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BranchData>(
          isExpanded: true,
          hint: Text(
            'Choose Branch',
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
          value: dropdownValue,
          items: uniqueBranchList.map((branch) {
            return DropdownMenuItem<BranchData>(
              value: branch,
              child: Text(
                branch.brchname ?? 'Unknown Branch',
                style: TextStyle(color: AppTheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (BranchData? value) {
            if (value != null) controller.selectBranch(value);
          },
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildFloorDropdown(LoginController controller) {
    if (controller.selectedBranch.value == null && showBranch) {
      return _buildDisabledDropdown('Select branch first');
    }

    if (controller.isFloorLoading.value) {
      return _buildLoadingDropdown();
    }

    if (controller.floorList.isEmpty) {
      return _buildEmptyDropdown('No floors available');
    }

    // Use int IDs instead of objects for dropdown values
    final floorMap = <int, FloorData>{};
    for (var floor in controller.floorList) {
      if (floor.brk != null && !floorMap.containsKey(floor.brk)) {
        floorMap[floor.brk!] = floor;
      }
    }

    final uniqueFloorList = floorMap.values.toList();

    // Debug print
    print("Floor list size: ${controller.floorList.length}");
    print("Unique floor list size: ${uniqueFloorList.length}");
    print("Floor IDs: ${uniqueFloorList.map((f) => f.brk).toList()}");

    if (uniqueFloorList.isEmpty) {
      return _buildEmptyDropdown('No floors available');
    }

    // Auto-select logic
    if (brk != 0 && controller.selectedFloor.value == null) {
      final matchedFloor = uniqueFloorList.cast<FloorData?>().firstWhere(
            (floor) => floor?.brk == brk,
        orElse: () => null,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (matchedFloor != null) {
          controller.selectFloor(matchedFloor);
        } else if (uniqueFloorList.isNotEmpty) {
          controller.selectFloor(uniqueFloorList.first);
        }
      });
    }

    // Auto-select if only one floor
    if (uniqueFloorList.length == 1 && controller.selectedFloor.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectFloor(uniqueFloorList.first);
      });
    }

    // If selected and should be locked, show as selected item
    if (controller.selectedFloor.value != null &&
        (uniqueFloorList.length == 1 || brk != 0)) {
      return _buildSelectedItem(
        text: 'Floor ${controller.selectedFloor.value?.brk ?? ''}',
        icon: Icons.layers,
      );
    }

    // Get the selected floor ID
    final selectedFloorId = controller.selectedFloor.value?.brk;

    // Find the actual floor object from our unique list that matches the ID
    final dropdownValue = selectedFloorId != null && floorMap.containsKey(selectedFloorId)
        ? floorMap[selectedFloorId]
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FloorData>(
          isExpanded: true,
          hint: Text(
            'Choose Floor',
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
          value: dropdownValue,
          items: uniqueFloorList.map((floor) {
            return DropdownMenuItem<FloorData>(
              value: floor,
              child: Text(
                'Floor ${floor.brk}',
                style: TextStyle(color: AppTheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (FloorData? value) {
            if (value != null) controller.selectFloor(value);
          },
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildSelectedItem({
    required String text,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryTeal,
            size: 16,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryTeal,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.block,
            color: AppTheme.onSurface.withOpacity(0.4),
            size: 16,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.onSurface.withOpacity(0.6),
            size: 16,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(LoginController controller) {
    bool canProceed = controller.selectedCompany.value != null;

    if (showBranch) {
      canProceed = canProceed && (controller.selectedBranch.value != null || controller.branchList.isEmpty);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoginController.selectedBranchId = 0;
        controller.selectedBranch.value = null;
      });
    }

    if (showFloor) {
      canProceed = canProceed && (controller.selectedFloor.value != null || controller.floorList.isEmpty);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoginController.selectedFloorId = 0;
        controller.selectedFloor.value = null;
      });
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canProceed
            ? LinearGradient(
          colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
        )
            : LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: canProceed
            ? [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canProceed ? controller.proceedToMainScreen : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to App',
                  style: TextStyle(
                    color: canProceed ? Colors.white : Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                AnimatedRotation(
                  turns: canProceed ? 0 : -0.25,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.arrow_forward,
                    color: canProceed ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}