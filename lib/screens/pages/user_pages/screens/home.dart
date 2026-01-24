import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:otonav/controllers/app_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/empty_state_widget.dart';
import 'package:otonav/widgets/order_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/order_controller.dart';
import '../../../../model/user_model.dart';
import '../../../../widgets/snackbars.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  UserController userController = Get.find<UserController>();
  AppController appController = Get.find<AppController>();
  OrderController orderController = Get.find<OrderController>();

  bool _isBannerVisible = true;

  IconData _getLocationIcon(String label) {
    final List<Map<String, dynamic>> locationTypes = [
      {'name': 'Home', 'icon': Icons.home_rounded},
      {'name': 'Office', 'icon': Icons.work_rounded},
      {'name': "Partner's Place", 'icon': Icons.favorite_rounded},
      {'name': "Parents' House", 'icon': Icons.family_restroom_rounded},
      {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
      {'name': 'Church', 'icon': Icons.church_rounded},
      {'name': 'School', 'icon': Icons.school_rounded},
      {'name': 'Market', 'icon': Icons.shopping_cart_rounded},
      {'name': 'Chill Spot', 'icon': Icons.local_cafe_rounded},
    ];

    var match = locationTypes.firstWhere(
      (element) =>
          element['name'].toString().toLowerCase() == label.toLowerCase(),
      orElse: () => {'icon': Icons.location_on_rounded},
    );

    return match['icon'] as IconData;
  }

  void _showLocationPicker(String orderId) async {
    // 1. Get User Locations
    User? user = userController.userModel.value;

    // Safety Check
    if (user == null || user.locations == null || user.locations!.isEmpty) {
      CustomSnackBar.failure(
        message: "You have no saved locations. Please add one first.",
      );
      await Get.toNamed(AppRoutes.locationScreen);
      await userController.getUserProfile();
      return;
    }

    // Local variable to track selection inside the sheet
    int? selectedIndex;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.radius20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                Text(
                  "Select Delivery Location",
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  "Where should the rider deliver this order?",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: Dimensions.height20),

                // LIST OF LOCATIONS
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: user.locations!.length,
                    separatorBuilder: (c, i) =>
                        SizedBox(height: Dimensions.height15),
                    itemBuilder: (context, index) {
                      var location = user.locations![index];
                      bool isSelected = selectedIndex == index;

                      return InkWell(
                        onTap: () {
                          // Update the local state of the modal
                          setModalState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.width15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getLocationIcon(location.label ?? ""),
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: Dimensions.width15),

                              // Text Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.label ?? "Unknown",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: Dimensions.font16,
                                      ),
                                    ),
                                    Text(
                                      location.preciseLocation ?? "No address",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: Dimensions.font13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Selection Radio
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: Dimensions.height30),

                // CONFIRM BUTTON
                CustomButton(
                  text: "Confirm Location",
                  backgroundColor: selectedIndex == null
                      ? Colors.grey
                      : AppColors.accentColor,
                  onPressed: () {
                    if (selectedIndex == null) {
                      CustomSnackBar.failure(
                        message: "Please select a location first.",
                      );
                      return;
                    }

                    // Retrieve selected object
                    var selectedLoc = user.locations![selectedIndex!];

                    // Call Controller
                    Get.find<OrderController>().setOrderLocation(
                      orderId,
                      selectedLoc.label!,
                      selectedLoc.preciseLocation!,
                    );
                  },
                ),
                SizedBox(height: Dimensions.height10),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrders();
      userController.getUserProfile();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx((){
        if (userController.userModel.value == null) {
          return Center(child: Text("Loading..."));
        }

        User user = userController.userModel.value!;
        var status = userController.getProfileStatus();

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
                    Expanded(
                      child: Column(
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
                //widget for profile completeness
                if (status.progress < 1.0 && _isBannerVisible)
                  InkWell(
                    onTap: () {
                      if (status.route.isNotEmpty) {
                        Get.toNamed(status.route);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(Dimensions.height20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Complete your Profile',
                                style: TextStyle(
                                  fontSize: Dimensions.font17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Close button to dismiss temporarily
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBannerVisible = false;
                                  });
                                },
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  size: Dimensions.iconSize20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height10),
                          Text(
                            status.message,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(status.progress * 100).toInt()}%',
                                // Dynamic %
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: status.progress,
                              // Dynamic Value (0.0 to 1.0)
                              color: AppColors.accentColor,
                              backgroundColor: AppColors.accentColor
                                  .withOpacity(0.1),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (status.progress < 1.0)
                  SizedBox(height: Dimensions.height20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Locations',
                      style: TextStyle(
                        fontSize: Dimensions.font17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (user.locations != null)
                        ...user.locations!.map((location) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: Dimensions.width20,
                            ),
                            child: Container(
                              height: Dimensions.height10 * 8,
                              width: Dimensions.width10 * 8,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: Dimensions.height10),

                                  Expanded(
                                    child: Icon(
                                      _getLocationIcon(location.label ?? ""),
                                      color: AppColors.primaryColor,
                                      size: Dimensions.iconSize24,
                                    ),
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Dimensions.width10,
                                      ),
                                      child: Text(
                                        location.label ?? 'Loc',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: Dimensions.font13,
                                          color: AppColors.primaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                      InkWell(
                        onTap: () async {
                          await Get.toNamed(AppRoutes.locationScreen);
                          await userController.getUserProfile();
                        },
                        child: Container(
                          height: Dimensions.height10 * 8,
                          width: Dimensions.width10 * 8,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(height: Dimensions.height5),
                              Icon(
                                CupertinoIcons.add,
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                'Add New',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: Dimensions.font13,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: Dimensions.height5),
                            ],
                          ),
                        ),
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
                        bool locationIsSet =
                            order.status == 'customer_location_set' ||
                                (order.customerLocationLabel != null &&
                                    order.customerLocationLabel!.isNotEmpty);

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: Dimensions.height15,
                          ),
                          child: OrderCard(
                            orderId: order.orderNumber ?? "N/A",
                            isLocationSet: locationIsSet,
                            itemCount: order.packageDescription ?? "Package",
                            vendorName:
                            order.rider?.name ?? 'Waiting for rider...',
                            onSetLocationTap: () {
                              _showLocationPicker(order.id ?? '');
                            },
                            onTrackOrderTap: () {
                              Get.toNamed(
                                AppRoutes.customerTrackingScreen,
                                arguments: order.id!,
                              );
                            },
                            onCallVendorTap: () async {
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
      }),
    );
  }
}
