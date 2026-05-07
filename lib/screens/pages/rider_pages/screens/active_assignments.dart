import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:otonav/controllers/order_controller.dart';
import 'package:otonav/model/order_model.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/rider_order_card.dart';

import '../../../../routes/routes.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/snackbars.dart';

class ActiveAssignments extends StatefulWidget {
  const ActiveAssignments({super.key});

  @override
  State<ActiveAssignments> createState() => _ActiveAssignmentsState();
}

class _ActiveAssignmentsState extends State<ActiveAssignments> {
  final OrderController _waitlistController = Get.find<OrderController>();
  final OrderController _orderController = Get.find<OrderController>();

  // --- DUMMY DATA FOR SKELETONIZER ---
  final List<OrderModel> _dummyData = List.generate(
    3,
        (index) => OrderModel(
      orderNumber: "ORDXXXXXX",
      packageDescription: "Loading assignment details...",
      status: "in_transit",
      organization: null,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitlistController.fetchActiveAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height100,
          Dimensions.width20,
          Dimensions.height10 * 13.5, // Padding for bottom nav bar
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Active Assignments', style: TextStyle(fontSize: Dimensions.font22, fontWeight: FontWeight.bold)),
                          SizedBox(width: Dimensions.width5),
                          const Icon(Icons.verified, color: Colors.blue, size: 22),
                        ],
                      ),
                      Text(
                        'Manage your ongoing verified deliveries',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w400, color: AppColors.grey5),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: const BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.notification),
                  ),
                ),

              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- ORDER LIST ---
            Expanded(
              child: Obx(() {
                final bool isLoading = _waitlistController.isFetchingOrders.value && _waitlistController.activeAssignments.isEmpty;
                final List<OrderModel> displayData = isLoading ? _dummyData : _waitlistController.activeAssignments;

                if (!isLoading && displayData.isEmpty) {
                  return Center(
                    child: EmptyState(
                      message: "You have no active assignments right now.",
                      imageAsset: "empty-archive",
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      final order = displayData[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.height15),
                        child: RiderOrderCard(
                          orderId: order.orderNumber ?? "N/A",
                          itemCount: order.packageDescription ?? "Package",
                          status: order.status ?? 'pending',
                          businessName: order.organization?.name ?? 'Loading...',
                          customerName: order.customer?.name ?? 'Loading Customer...',
                          customerLocationPrecise: order.customerLocationLabel ?? 'Loading Location...',
                          customerLocationLabel: order.customerLocationLabel ?? '',
                          pickupLocation: order.organization?.address ?? 'Loading...',

                          // --- ACTIONS ---
                          onStartDeliveryTap: () {
                            if (!isLoading && order.id != null) {
                              _orderController.acceptOrder(order.id!);
                            }
                          },
                          onCancelDeliveryTap: () {
                            if (!isLoading && order.id != null) {
                              _orderController.cancelOrder(order.id!);
                            }
                          },
                          onTrackOrderTap: () {
                            if (!isLoading) {
                              // Navigate to tracking screen for this assignment
                              // Get.toNamed(AppRoutes.riderTrackingScreen, arguments: order);
                            }
                          },
                          onCallCustomerTap: () async {
                            if (isLoading) return;
                            String? phone = order.customer?.phoneNumber ?? order.rider?.phoneNumber; // Fallbacks depending on your data
                            if (phone != null && phone.isNotEmpty) {
                              String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                              final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
                              try {
                                if (!await launchUrl(launchUri, mode: LaunchMode.platformDefault)) throw 'Could not launch $launchUri';
                              } catch (e) {
                                CustomSnackBar.failure(message: "Unable to make call on this device.");
                              }
                            } else {
                              CustomSnackBar.failure(message: "Phone number not available.");
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
