import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/controllers/order_controller.dart';
import 'package:otonav/widgets/empty_state_widget.dart';
import 'package:otonav/widgets/order_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../model/order_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/snackbars.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedTab = 0;

  OrderController orderController = Get.find<OrderController>();

  // --- DUMMY DATA FOR SKELETONIZER ---
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
                InkWell(
                  onTap: (){
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: const BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.notification,
                    ),
                  ),
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
              // ✅ Replaced GetBuilder with Obx for reactivity
              child: Obx(() {
                List<OrderModel> ordersToShow;
                if (_selectedTab == 0) {
                  ordersToShow = orderController.confirmedOrders;
                } else if (_selectedTab == 1) {
                  ordersToShow = orderController.deliveredOrders;
                } else {
                  ordersToShow = orderController.cancelledOrders;
                }

                // Check if currently fetching data and the list is empty
                final bool isLoading = orderController.isFetchingOrders.value && ordersToShow.isEmpty;

                // Use dummy data if loading, otherwise use actual data
                final List<OrderModel> displayOrders = isLoading ? _dummyOrders : ordersToShow;

                if (!isLoading && displayOrders.isEmpty) {
                  return Center(
                    child: EmptyState(
                      message: 'No Orders Found',
                      imageAsset: 'empty-archive',
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: displayOrders.length,
                    itemBuilder: (context, index) {
                      var order = displayOrders[index];
                      bool locationIsSet = order.status == 'customer_location_set' ||
                          (order.customerLocationLabel != null && order.customerLocationLabel!.isNotEmpty);

                      return Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.height15),
                        child: OrderCard(
                          status: order.status ?? '',
                          orderId: order.orderNumber ?? "N/A",
                          itemCount: order.packageDescription ?? "Items",
                          vendorName: order.rider?.name ?? 'Assigning rider...',
                          customerLocationPrecise: locationIsSet ? order.customerLocationLabel : null,
                          deliveryPin: order.deliveryPin,
                          onFetchPin: () async {
                            final res = await orderController.orderRepo.getOrderDetails(order.id!);
                            if (res.statusCode == 200 && res.body['success'] == true) {
                              return res.body['data']['deliveryPin']?.toString();
                            } else {
                              CustomSnackBar.failure(message: "Failed to fetch PIN. Please try again.");
                              return null;
                            }
                          },

                          // Click Protections: Ignore taps if skeleton is loading
                          onSetLocationTap: () {
                            // if (!isLoading) Get.toNamed(AppRoutes.locationScreen);
                          },
                          onTrackOrderTap: () {
                            if (!isLoading) {
                              Get.toNamed(
                                AppRoutes.customerTrackingScreen,
                                arguments: order.id!,
                              );
                            }
                          },
                            onCallVendorTap: () async {
                              String? phone = order.rider?.phoneNumber;
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

                          onRateDeliveryTap: () {
                            if (!isLoading) _showRatingModal(context, order.id!);
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

  void _showRatingModal(BuildContext context, String orderId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Rate your Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("How was the delivery experience?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Star Rating Row (Simple visual placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Icon(Iconsax.star1, color: Colors.amber, size: 36)),
            ),

            const SizedBox(height: 30),
            CustomButton(
              text: "Submit Feedback",
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                // TODO: Call API to rate order
                Get.back();
                CustomSnackBar.success(message: "Thanks for your feedback!");
              },
            )
          ],
        ),
      ),
    );
  }
}
