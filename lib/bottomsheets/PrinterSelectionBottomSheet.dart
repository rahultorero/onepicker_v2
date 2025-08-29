import 'package:flutter/material.dart';
import 'package:onepicker/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrinterSelectionBottomSheet extends StatefulWidget {
  const PrinterSelectionBottomSheet({super.key});

  @override
  _PrinterSelectionBottomSheetState createState() => _PrinterSelectionBottomSheetState();
}

class _PrinterSelectionBottomSheetState extends State<PrinterSelectionBottomSheet> {
  String? selectedPosition;
  String? selectedCamera;
  List<String> positionList = ['1', '2', '3', '4', '5'];
  List<String> cameraList = ['Select Camera/table'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCameraData();
  }



  Future<void> _loadCameraData() async {
    try {
      debugPrint("Fetching camera data for PCamera...");
      String arrSSUB = await ApiConfig.getSsubStr("PCamera");
      debugPrint("Response from getSsub: $arrSSUB");

      if (arrSSUB.isNotEmpty) {
        List<String> cameras = arrSSUB.split(",");
        debugPrint("Parsed cameras: $cameras");

        setState(() {
          cameraList = ['Select Camera/table'];
          cameraList.addAll(cameras);
          isLoading = false;
        });

        debugPrint("Updated cameraList: $cameraList");
      } else {
        debugPrint("No camera data found.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, s) {
      debugPrint("Error loading camera data: $e");
      debugPrint("StackTrace: $s");
      setState(() {
        isLoading = false;
      });
    }

  }

  bool get isNextButtonEnabled {
    return selectedPosition != null &&
        selectedCamera != null &&
        selectedCamera != 'Select Camera/table';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Heading
          Row(
            children: [
              Icon(Icons.print, color: Colors.blue[600], size: 24),
              SizedBox(width: 8),
              Text(
                'Select Printer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            )
          else ...[
            // Position Dropdown
            _buildDropdownSection(
              title: 'Position',
              icon: Icons.format_list_numbered,
              value: selectedPosition,
              items: positionList,
              hint: 'Default',
              onChanged: (value) {
                setState(() {
                  selectedPosition = value;
                });
              },
            ),

            SizedBox(height: 20),

            // Camera/Table Dropdown
            _buildDropdownSection(
              title: 'Camera/Table',
              icon: Icons.camera_alt,
              value: selectedCamera,
              items: cameraList,
              hint: 'Select Camera/Table',
              onChanged: (value) {
                setState(() {
                  selectedCamera = value;
                });
              },
            ),
          ],

          SizedBox(height: 32),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isNextButtonEnabled ? _onNextPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Safe area padding for bottom
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey[500]),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: items.map((String item) {
                bool isPlaceholder = item == 'Select Camera/table';
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isPlaceholder ? Colors.grey[500] : Colors.grey[800],
                      fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _onNextPressed() {
    // Handle next button press
    Navigator.pop(context, {
      'position': selectedPosition,
      'camera': selectedCamera,
    });

    // You can also add navigation logic here
    debugPrint('Selected Position: $selectedPosition');
    debugPrint('Selected Camera: $selectedCamera');
  }
}

