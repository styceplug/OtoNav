import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/order_controller.dart';
import '../../../../model/user_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/rider_order_card.dart';
import '../../../../widgets/snackbars.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  bool online = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<UserController>(
        builder: (userController) {
          if (userController.userModel.value == null) {
            return Center(child: Text("Loading..."));
          }

          User user = userController.userModel.value!;

          return Container(
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
                            ),
                          ),
                          Text(
                            'Hello ${user.name}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height20,
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppConstants.getPngAsset('online'),
                          height: Dimensions.height50,
                          width: Dimensions.width50,
                        ),
                        SizedBox(width: Dimensions.width20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are online',
                              style: TextStyle(
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'Waiting on new orders',
                              style: TextStyle(
                                fontSize: Dimensions.font15,
                                fontWeight: FontWeight.w300,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        CupertinoSwitch(
                          value: online,
                          onChanged: (online) {},
                          activeColor: AppColors.accentColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders',
                        style: TextStyle(
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'These Orders need your attention!',
                        style: TextStyle(
                          fontSize: Dimensions.font15,
                          fontWeight: FontWeight.w300,
                          color: AppColors.grey5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  GetBuilder<OrderController>(
                    init: Get.find<OrderController>(),
                    builder: (orderController) {
                      var pendingList = orderController.pendingOrders;

                      if (pendingList.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: Dimensions.height70),
                          child: Center(
                            child: EmptyState(
                              message: 'No Pending Order',
                              imageAsset: 'empty-archive',
                            ),
                          ),
                        );
                      }

                      // List of Pending Orders
                      return Column(
                        children: pendingList.map((order) {

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: Dimensions.height15,
                            ),
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
                              customerLocationPrecise: order.customerLocationPrecise ??
                                  'Customer Yet to Verify Data',
                                customerLocationLabel: order.customerLocationLabel ?? '',
                              pickupLocation: 'Yet to Setup',
                              onStartDeliveryTap: () {
                                orderController.acceptOrder(order.id!);
                              },
                              onCancelDeliveryTap: () {
                                showDeclineDialog(
                                  onConfirm: () {
                                    orderController.cancelOrder(order.id!);
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
