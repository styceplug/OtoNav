import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/controllers/order_controller.dart';
import 'package:otonav/widgets/empty_state_widget.dart';
import 'package:otonav/widgets/order_card.dart';

import '../../../../model/order_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
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
                        child: OrderCard(
                          isLocationSet: locationIsSet,
                          status: order.status ?? '',
                          orderId: order.orderNumber ?? "N/A",
                          itemCount: order.packageDescription ?? "Items",
                          vendorName: order.rider?.name ?? '',
                          onSetLocationTap: () =>
                              Get.toNamed(AppRoutes.locationScreen),
                          onTrackOrderTap: () =>
                              Get.toNamed(AppRoutes.trackingScreen),
                          onCallVendorTap: () {},
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
