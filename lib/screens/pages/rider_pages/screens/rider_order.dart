import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/order_controller.dart';
import '../../../../model/order_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/rider_order_card.dart';
import '../../../../widgets/snackbars.dart';


class RiderOrderPage extends StatefulWidget {
  const RiderOrderPage({super.key});

  @override
  State<RiderOrderPage> createState() => _RiderOrderPageState();
}

class _RiderOrderPageState extends State<RiderOrderPage> {
  int _selectedTab = 0;

  OrderController orderController = Get.find<OrderController>();

  // --- DUMMY DATA FOR SKELETONIZER ---
  // Generates 3 fake orders to build the shimmer layout
  final List<OrderModel> _dummyOrders = List.generate(
    3,
        (index) => OrderModel(
      id: "dummy_id_$index",
      orderNumber: "ORD999999999",
      packageDescription: "Loading Package Description...",
      status: "in_transit",
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height100,
          Dimensions.width20,
          Dimensions.height10 * 13.5,
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
                      Text(
                        'Orders',
                        style: TextStyle(
                          fontSize: Dimensions.font22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Check Ongoing and Completed orders here',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.notification),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- TAB BAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton("Active", 0),
                _buildTabButton("Completed", 1),
                _buildTabButton("Rejected", 2),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- ORDERS LIST ---
            Expanded(
              // ✅ Used Obx to listen to loading state reactively
              child: Obx(() {
                List<OrderModel> ordersToShow;
                if (_selectedTab == 0) {
                  ordersToShow = orderController.confirmedOrders;
                } else if (_selectedTab == 1) {
                  ordersToShow = orderController.deliveredOrders;
                } else {
                  ordersToShow = orderController.cancelledOrders;
                }

                final bool isOrdersLoading = orderController.isFetchingOrders.value && orderController.pendingOrders.isEmpty;
                // Use dummy data if loading, otherwise use actual data
                final List<OrderModel> displayOrders = isOrdersLoading ? _dummyOrders : ordersToShow;

                if (!isOrdersLoading && displayOrders.isEmpty) {
                  return Center(
                    child: EmptyState(
                      message: 'No Orders Found',
                      imageAsset: 'empty-archive',
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isOrdersLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: displayOrders.length,
                    itemBuilder: (context, index) {
                      var order = displayOrders[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.height15),
                        child: RiderOrderCard(
                          orderId: order.orderNumber ?? "N/A",
                          itemCount: order.packageDescription ?? "Package",
                          status: order.status ?? '',
                          customerName: order.customer?.name ?? 'Customer Yet to Verify Data',
                          customerLocationLabel: order.customerLocationLabel ?? 'Customer Yet to Verify Data',
                          customerLocationPrecise: order.customerLocationPrecise ?? 'Customer Yet to Verify Data',
                          businessName: order.organization?.name ?? 'Loading...',
                          pickupLocation: order.organization?.address ?? 'Loading...',

                          onStartDeliveryTap: () {
                            if (!isOrdersLoading) orderController.acceptOrder(order.id!);
                          },
                          onCancelDeliveryTap: () {
                            if (!isOrdersLoading) orderController.cancelOrder(order.id!);
                          },
                          onTrackOrderTap: () {
                            if (!isOrdersLoading) {
                              Get.toNamed(
                                AppRoutes.riderTrackingScreen,
                                arguments: order,
                              );
                            }
                          },
                          onCallCustomerTap: () async {
                            if (isOrdersLoading) return;
                            String? phone = order.rider?.phoneNumber;

                            if (phone != null && phone.isNotEmpty) {
                              String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                              final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);

                              try {
                                if (!await launchUrl(launchUri, mode: LaunchMode.platformDefault)) {
                                  throw 'Could not launch $launchUri';
                                }
                              } catch (e) {
                                print("Error making call: $e");
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

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          color: isSelected ? AppColors.accentColor : AppColors.white,
          border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
