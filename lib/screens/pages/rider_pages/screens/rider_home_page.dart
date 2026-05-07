import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:otonav/routes/routes.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:otonav/controllers/order_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/model/user_model.dart';
import 'package:otonav/model/order_model.dart'; // Ensure OrderModel is imported
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';

import '../../../../widgets/rider_order_card.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  UserController userController = Get.find<UserController>();
  OrderController orderController = Get.find<OrderController>();

  final User _dummyUser = User(
    name: "Loading Name",
    isActive: true,
    isOtonavRecommended: true,
  )..jobAnalytics = JobAnalytics.fromJson({
    'performanceScore': 10,
    'summary': {'completedOrders': 000}
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // 1. Check if user data is still loading
        final bool isUserLoading = userController.userModel.value == null;

        // 2. Feed dummy data if loading, otherwise use real data
        final User user = isUserLoading ? _dummyUser : userController.userModel.value!;

        final bool isOnline = user.isActive ?? true;
        final score = user.jobAnalytics?.performanceScore.toString() ?? "N/A";
        final totalDeliveries = user.jobAnalytics?.summary['completedOrders']?.toString() ?? "0";

        return Skeletonizer(
          enabled: isUserLoading, // ✅ Skeletonizer activates here
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height100,
              Dimensions.width20,
              Dimensions.height10 * 13.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey5,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Hello ${user.name?.split(" ")[0] ?? "Rider"},',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Dimensions.font22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (user.isOtonavRecommended == true) ...[
                                SizedBox(width: Dimensions.width5),
                                const Icon(Icons.verified, color: AppColors.primaryColor, size: 20),
                              ]
                            ],
                          ),
                        ],
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

                  // --- QUICK STATS ROW ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.height15),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radius15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Iconsax.trend_up, color: AppColors.primaryColor),
                              SizedBox(height: Dimensions.height10),
                              Text("$score of 100", style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.bold, color: AppColors.accentColor)),
                              const Text("Performance", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.height15),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radius15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Iconsax.box_tick, color: AppColors.success),
                              SizedBox(height: Dimensions.height10),
                              Text(totalDeliveries, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                              const Text("Total Deliveries", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),

                  // --- ONLINE TOGGLE ---
                  Container(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height15, horizontal: Dimensions.width20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      border: Border.all(color: AppColors.grey2),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset(isOnline ? 'online' : 'profile-icon'),
                          height: Dimensions.height40,
                          width: Dimensions.width40,
                        ),
                        SizedBox(width: Dimensions.width15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOnline ? 'You are online' : 'You are offline',
                                style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                isOnline ? 'Waiting on new orders' : 'Go online to receive orders',
                                style: TextStyle(fontSize: Dimensions.font13, color: AppColors.grey5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: isOnline,
                          onChanged: (val) {
                            if (!isUserLoading) userController.toggleRiderActivity();
                          },
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height30),

                  // --- ORDERS LIST HEADER ---
                  Text('Pending Orders', style: TextStyle(fontSize: Dimensions.font18, fontWeight: FontWeight.w600)),
                  Text('These orders need your attention!', style: TextStyle(fontSize: Dimensions.font14, color: AppColors.grey5)),
                  SizedBox(height: Dimensions.height15),

                  // --- ORDERS LIST (Nested Reactivity) ---
                  // ✅ Obx specifically for orders so only this list rebuilds when orders arrive
                  Obx(() {
                    final bool isOrdersLoading = orderController.loader.isLoading.value && orderController.pendingOrders.isEmpty;

                    if (!isOnline && !isUserLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: Dimensions.height40),
                        child: Center(child: Text("Go online to view orders.", style: TextStyle(color: AppColors.grey5))),
                      );
                    }

                    // Feed dummy order array to Skeletonizer if loading
                    final List<OrderModel> displayOrders = isOrdersLoading
                        ? [OrderModel(orderNumber: "ORDXXXXX", packageDescription: "Loading Package...")]
                        : orderController.pendingOrders;

                    if (displayOrders.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Dimensions.height40),
                        child: const Center(child: Text("No pending orders at the moment.")),
                      );
                    }

                    return Skeletonizer(
                      enabled: isOrdersLoading, // ✅ Order-specific skeleton
                      child: Column(
                        children: displayOrders.map((order) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: Dimensions.height15),
                            child: RiderOrderCard(
                              orderId: order.orderNumber ?? "N/A",
                              itemCount: order.packageDescription ?? "Package",
                              status: order.status ?? 'pending',
                              businessName: order.organization?.name ?? 'Loading...',
                              customerName: order.customer?.name ?? 'Awaiting Info',
                              customerLocationPrecise: order.customerLocationLabel ?? 'Awaiting Location',
                              customerLocationLabel: order.customerLocationLabel ?? '',
                              pickupLocation: order.organization?.address ?? 'Loading...',

                              onStartDeliveryTap: () => orderController.acceptOrder(order.id!),
                              onCancelDeliveryTap: () => showDeclineDialog(onConfirm: () => orderController.cancelOrder(order.id!)),
                              onCallCustomerTap: () async {
                                String? phone = order.rider?.phoneNumber;
                                if (phone != null && phone.isNotEmpty) {
                                  String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                                  final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
                                  if (await canLaunchUrl(launchUri)) await launchUrl(launchUri, mode: LaunchMode.platformDefault);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void showDeclineDialog({required VoidCallback onConfirm}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Warning Icon with Red Glow
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.warning_2, // Or CupertinoIcons.exclamationmark_circle
                  size: 40,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: Dimensions.height20),

              // 2. Title
              Text(
                "Decline Order?",
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height10),

              // 3. Message
              Text(
                "Are you sure you want to decline this order? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  color: AppColors.grey5, // or Colors.grey[600]
                ),
              ),
              SizedBox(height: Dimensions.height30),

              // 4. Buttons Row
              Row(
                children: [
                  // CANCEL (Go Back) BUTTON
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(), // Close dialog
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            "No, Keep it",
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),

                  // CONFIRM (Decline) BUTTON
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back(); // Close dialog first
                        onConfirm(); // Trigger actual API call
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Yes, Decline",
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User must click a button
    );
  }
}
