import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onepicker/services.dart';
import 'package:onepicker/view/AdminScreen.dart';
import 'dart:math' as math;

import '../controllers/HomeScreenController.dart';
import '../theme/AppTheme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final controller = Get.put(HomeScreenController());
    final loginData = await ApiConfig.getLoginData();

    controller.userName.value = loginData!.response!.eName ?? '';
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeTransition(
              opacity: controller.headerAnimation,
              child: _buildHeader(controller),
            ),

            const SizedBox(height: 20),

            // New Launch Banner
            FadeTransition(
              opacity: controller.headerAnimation,
              child: _buildNewLaunchBanner(),
            ),

            const SizedBox(height: 24),

            // Quick Services
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.quickServices.length,
                      itemBuilder: (context, index) {
                        return  _buildServiceCard(
                            controller.quickServices[index],
                            index,
                          );
                      },
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

  Widget _buildHeader(HomeScreenController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Obx(() => Text(
              controller.userName.value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
                letterSpacing: 0.5,
              ),
            )),
          ],
        ),
        Row(
          children: [
            // Notification bell
            // Stack(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.all(10),
            //       decoration: BoxDecoration(
            //         color: AppTheme.surface,
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: AppTheme.shadowColor.withOpacity(0.08),
            //             blurRadius: 8,
            //             spreadRadius: 1,
            //           ),
            //         ],
            //       ),
            //       child: Icon(
            //         Icons.notifications_outlined,
            //         color: AppTheme.primaryBlue,
            //         size: 20,
            //       ),
            //     ),
            //     Obx(() => controller.notificationCount.value > 0
            //         ? Positioned(
            //       right: 2,
            //       top: 2,
            //       child: Container(
            //         width: 16,
            //         height: 16,
            //         decoration: const BoxDecoration(
            //           color: Colors.red,
            //           shape: BoxShape.circle,
            //         ),
            //         child: Center(
            //           child: Text(
            //             controller.notificationCount.value.toString(),
            //             style: const TextStyle(
            //               color: Colors.white,
            //               fontSize: 9,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     )
            //         : const SizedBox(),
            //     ),
            //   ],
            // ),
            const SizedBox(width: 10),
            // Search button
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewLaunchBanner() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW LAUNCH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nurtura - AI Co-Pilot for\nLabor, Birthing & Postpartum\nMonitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),

              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pregnant_woman,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 76,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // Get.snackbar(
            //   service['title'],
            //   'Opening ${service['title']}...',
            //   backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            //   colorText: AppTheme.primaryBlue,
            //   duration: const Duration(seconds: 2),
            // );

            Get.to(AdminScreen());

          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: service['gradient']),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: service['color'].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    service['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          if (service['isNew'])
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        service['subtitle'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: service['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: service['color'],
                    size: 14,
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
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Reports Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Devices Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
