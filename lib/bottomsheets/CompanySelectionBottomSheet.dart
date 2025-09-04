import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/LoginController.dart';
import '../model/BranchData.dart';
import '../model/CompanyData.dart';
import '../model/FloorData.dart';
import '../theme/AppTheme.dart';

class CompanySelectionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

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

                  SizedBox(height: 16),

                  // Branch Selection
                  _buildSelectionCard(
                    controller: controller,
                    title: 'Select Branch',
                    icon: Icons.location_on,
                    child: Obx(() => _buildBranchDropdown(controller)),
                  ),

                  SizedBox(height: 16),

                  // Floor Selection
                  _buildSelectionCard(
                    controller: controller,
                    title: 'Select Floor',
                    icon: Icons.layers,
                    child: Obx(() => _buildFloorDropdown(controller)),
                  ),

                  Spacer(),

                  // Continue Button
                  Obx(() => _buildContinueButton(controller)),

                  SizedBox(height: 20),
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          value: controller.selectedCompany.value,
          items: controller.companyList.map((company) {
            return DropdownMenuItem<CompanyData>(
              value: company,
              child: Text(
                company.companyname ?? 'Unknown Company',
                style: TextStyle(
                  color: AppTheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (CompanyData? value) {
            if (value != null) {
              controller.selectCompany(value);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppTheme.primaryTeal,
          ),
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          value: controller.selectedBranch.value,
          items: controller.branchList.map((branch) {
            return DropdownMenuItem<BranchData>(
              value: branch,
              child: Text(
                branch.brchname ?? 'Unknown Branch',
                style: TextStyle(
                  color: AppTheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (BranchData? value) {
            if (value != null) {
              controller.selectBranch(value);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppTheme.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildFloorDropdown(LoginController controller) {
    if (controller.selectedBranch.value == null) {
      return _buildDisabledDropdown('Select branch first');
    }

    if (controller.isFloorLoading.value) {
      return _buildLoadingDropdown();
    }

    if (controller.floorList.isEmpty) {
      return _buildEmptyDropdown('No floors available');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          value: controller.selectedFloor.value,
          items: controller.floorList.map((floor) {
            return DropdownMenuItem<FloorData>(
              value: floor,
              child: Text(
                'Floor ${floor.brk}',
                style: TextStyle(
                  color: AppTheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (FloorData? value) {
            if (value != null) {
              controller.selectFloor(value);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppTheme.primaryTeal,
          ),
        ),
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
        // &&
        // controller.selectedBranch.value != null;
        // &&
        // controller.selectedFloor.value != null;

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
        boxShadow: canProceed ? [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
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