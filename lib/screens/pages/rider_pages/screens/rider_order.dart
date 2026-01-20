import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrders();
    });
    super.initState();
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
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.notification),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton("Active", 0),
                _buildTabButton("Completed", 1),
                _buildTabButton("Rejected", 2),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: GetBuilder<OrderController>(
                builder: (controller) {
                  List<OrderModel> ordersToShow;
                  if (_selectedTab == 0)
                    ordersToShow = controller.confirmedOrders;
                  else if (_selectedTab == 1)
                    ordersToShow = controller.deliveredOrders;
                  else
                    ordersToShow = controller.cancelledOrders;

                  if (ordersToShow.isEmpty) {
                    return Center(
                      child: EmptyState(
                        message: 'No Orders Found',
                        imageAsset: 'empty-archive',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: ordersToShow.length,
                    itemBuilder: (context, index) {
                      var order = ordersToShow[index];
                      bool locationIsSet =
                          order.status == 'customer_location_set' ||
                              (order.customerLocationLabel != null &&
                                  order.customerLocationLabel!.isNotEmpty);

                      return Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.height15),
                        child: RiderOrderCard(
                            orderId: order.orderNumber ?? "N/A",
                            itemCount: order.packageDescription ?? "Package",
                            onCallCustomerTap: () async {
                              String? phone = order.rider?.phoneNumber;

                              if (phone != null && phone.isNotEmpty) {
                                // 1. Sanitize the number (Remove spaces, brackets, dashes)
                                String cleanPhone = phone.replaceAll(
                                  RegExp(r'[^\d+]'),
                                  '',
                                ); // Keeps only digits and +

                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: cleanPhone,
                                );

                                // 2. Attempt to launch
                                try {
                                  // mode: LaunchMode.platformDefault is usually better for dialers
                                  if (!await launchUrl(
                                    launchUri,
                                    mode: LaunchMode.platformDefault,
                                  )) {
                                    throw 'Could not launch $launchUri';
                                  }
                                } catch (e) {
                                  print("Error making call: $e");
                                  // On Simulator, this will often trigger because there is no dialer
                                  CustomSnackBar.failure(
                                    message:
                                    "Unable to make call on this device.",
                                  );
                                }
                              } else {
                                CustomSnackBar.failure(
                                  message: "Phone number not available.",
                                );
                              }
                            },
                            status: order.status ?? '',
                            customerName:
                            order.customer?.name ??
                                'Customer Yet to Verify Data',
                            customerLocationLabel: order.customerLocationLabel ??
                                'Customer Yet to Verify Data',
                            customerLocationPrecise: order.customerLocationPrecise ??
                                'Customer Yet to Verify Data',
                            pickupLocation: 'Yet to Setup',
                            onStartDeliveryTap: () {
                              orderController.acceptOrder(order.id!);
                            },
                            onCancelDeliveryTap: () {
                              orderController.cancelOrder(order.id!);
                            }
                        ),
                      );
                    },
                  );
                },
              ),
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
          // Active color logic
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.3)),
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
