import 'package:flutter/material.dart';
import 'package:onepicker/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDetailsDialog {
  // Equivalent of MyHelper.getSYN() function
 

  static Future<void> showCustomerDialog({
    required BuildContext context,
    required String name,
    required String address,
    required String city,
    required String area,
  }) async {
    // Check preference (equivalent to getSYN check)
    final showCust = await ApiConfig.getSyn('ShowCust');

    if (showCust == 1) {
      // Debug log equivalent
      debugPrint('26579*84125');

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CustomerDetailsDialogWidget(
            name: name,
            address: address,
            city: city,
            area: area,
          );
        },
      );
    }
  }
}

class CustomerDetailsDialogWidget extends StatelessWidget {
  final String name;
  final String address;
  final String city;
  final String area;

  const CustomerDetailsDialogWidget({
    Key? key,
    required this.name,
    required this.address,
    required this.city,
    required this.area,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Customer Information
            _buildInfoCard(
              icon: Icons.person_outline,
              label: 'Customer Name',
              value: name,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: address,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.location_city_outlined,
              label: 'City',
              value: city,
              color: Colors.purple,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.map_outlined,
              label: 'Area',
              value: area,
              color: Colors.teal,
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                    fontSize: 14,
                    color: value.isNotEmpty ? const Color(0xFF2C3E50) : Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}