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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/order_controller.dart';
import '../../../../model/order_model.dart';
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

  // --- DUMMY DATA FOR SKELETONIZER ---
  final User _dummyUser = User(
    name: "Loading Name",
    locations: [
      LocationModel(label: "Home", lat: 0.00, lng: 0.00),
      LocationModel(label: "Office", lat: 0.00, lng: 0.00),
    ],
  );

  final List<OrderModel> _dummyOrders = List.generate(
    2,
        (index) => OrderModel(
      orderNumber: "ORDXXXXX",
      packageDescription: "Loading Package...",
      status: "pending",
      organization: null, // Dummy org
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrders();
      userController.getUserProfile();
    });
  }

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
          (element) => element['name'].toString().toLowerCase() == label.toLowerCase(),
      orElse: () => {'icon': Icons.location_on_rounded},
    );

    return match['icon'] as IconData;
  }

  void _showLocationPicker(String orderId) {
    // Get the current user's locations
    final user = userController.userModel.value;
    final locations = user?.locations ?? [];

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          left: Dimensions.width20,
          right: Dimensions.width20,
          top: Dimensions.height20,
          bottom: Dimensions.height20,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Location',
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- VERTICAL LOCATIONS LIST ---
            if (locations.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.height30),
                child: Center(
                  child: Text(
                    "You have no saved locations.",
                    style: TextStyle(color: AppColors.grey5, fontSize: 14),
                  ),
                ),
              )
            else
              Flexible(
                // Flexible ensures it scrolls if there are too many locations to fit on screen
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: locations.map((location) {
                      return InkWell(
                        onTap: () {
                          orderController.setOrderLocation(
                            orderId,
                            location.label ?? '',
                            location.lat ?? 0.0,
                            location.lng ?? 0.0,
                          );

                          print('Selected: ${location.label} for Order: $orderId');
                          Get.back(); // Close the bottom sheet after selection
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: Dimensions.height15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                    _getLocationIcon(location.label ?? ""),
                                    color: AppColors.accentColor,
                                    size: 24
                                ),
                              ),
                              SizedBox(width: Dimensions.width15),
                              Expanded(
                                child: Text(
                                  location.label ?? 'Location',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            SizedBox(height: Dimensions.height10),

            // --- ADD NEW LOCATION BUTTON ---
            CustomButton(
              text: 'Add New Location',
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              onPressed: () {
                Get.back(); // Close bottom sheet
                Get.toNamed(AppRoutes.locationScreen); // Navigate to your location creation screen
              },
            ),
            SizedBox(height: Dimensions.height50),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // 1. Check User Loading State
        final bool isUserLoading = userController.userModel.value == null;

        // 2. Feed dummy data if loading
        final User user = isUserLoading ? _dummyUser : userController.userModel.value!;

        // We only get profile status if the user is fully loaded to prevent null errors
        var status = isUserLoading ? null : userController.getProfileStatus();

        return Skeletonizer(
          enabled: isUserLoading,
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
                  // --- 1. HEADER ---
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
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey5,
                              ),
                            ),
                            Text(
                              'Hello ${user.name?.split(" ")[0] ?? "Customer"},',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (!isUserLoading) Get.toNamed(AppRoutes.notificationScreen);
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

                  // --- 2. PROFILE COMPLETENESS BANNER ---
                  if (!isUserLoading && status != null && status.progress < 1.0 && _isBannerVisible)
                    InkWell(
                      onTap: () {
                        if (status.route.isNotEmpty) Get.toNamed(status.route);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: Dimensions.height20),
                        padding: EdgeInsets.all(Dimensions.width20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.white, AppColors.primaryColor.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(Dimensions.radius20),
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: AppColors.accentColor.withOpacity(0.1), shape: BoxShape.circle),
                                      child: const Icon(Iconsax.shield_tick, color: AppColors.accentColor, size: 16),
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Text('Complete Profile', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => setState(() => _isBannerVisible = false),
                                  child: const Icon(CupertinoIcons.xmark, size: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(status.message, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            SizedBox(height: Dimensions.height15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Progress', style: TextStyle(fontSize: Dimensions.font13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                Text('${(status.progress * 100).toInt()}%', style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.bold, color: AppColors.accentColor)),
                              ],
                            ),
                            SizedBox(height: Dimensions.height10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: status.progress,
                                color: AppColors.accentColor,
                                backgroundColor: AppColors.accentColor.withOpacity(0.1),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- 3. LOCATIONS SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Locations', style: TextStyle(fontSize: Dimensions.font18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        // PROMINENT MANAGE BUTTON (First in list)
                        InkWell(
                          onTap: () async {
                            if (isUserLoading) return;
                            await Get.toNamed(AppRoutes.locationScreen);
                            await userController.getUserProfile();
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(right: Dimensions.width15),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(Dimensions.radius15),
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Iconsax.add, color: AppColors.primaryColor, size: 20),
                                ),
                                SizedBox(height: Dimensions.height10),
                                const Text('Add New', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryColor)),
                              ],
                            ),
                          ),
                        ),

                        // SAVED LOCATIONS CARDS
                        if (user.locations != null)
                          ...user.locations!.map((location) {
                            return Container(
                              height: 100,
                              width: 110,
                              margin: EdgeInsets.only(right: Dimensions.width15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radius15),
                                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_getLocationIcon(location.label ?? ""), color: AppColors.accentColor, size: 24),
                                  const Spacer(),
                                  Text(
                                    location.label ?? 'Location',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height30),

                  // --- 4. ORDERS SECTION ---
                  Text('Active Orders', style: TextStyle(fontSize: Dimensions.font18, fontWeight: FontWeight.bold)),
                  Text('Track your incoming deliveries', style: TextStyle(fontSize: Dimensions.font13, color: AppColors.grey5)),
                  SizedBox(height: Dimensions.height20),

                  // Nested Obx for Orders Reactivity
                  Obx(() {
                    // Assuming you have 'isFetchingOrders' logic implemented in OrderController
                    // If not, fallback to orderController.loader.isLoading.value
                    final bool isOrdersLoading = orderController.isFetchingOrders.value && orderController.pendingOrders.isEmpty;

                    final List<OrderModel> displayOrders = isOrdersLoading ? _dummyOrders : orderController.pendingOrders;

                    if (!isOrdersLoading && displayOrders.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Dimensions.height40),
                        child: Center(
                          child: EmptyState(message: 'No Active Orders', imageAsset: 'empty-archive'),
                        ),
                      );
                    }

                    return Skeletonizer(
                      enabled: isOrdersLoading, // Order specific skeleton
                      child: Column(
                        children: displayOrders.map((order) {
                          bool locationIsSet = order.status == 'customer_location_set' ||
                              (order.customerLocationLabel != null && order.customerLocationLabel!.isNotEmpty);

                          return Padding(
                            padding: EdgeInsets.only(bottom: Dimensions.height15),
                            child: OrderCard(
                              orderId: order.orderNumber ?? "N/A",
                              itemCount: order.packageDescription ?? "Package",
                              vendorName: order.rider?.name ?? 'Attach Your Location',
                              status: order.status ?? '',
                              customerLocationPrecise: locationIsSet ? order.customerLocationLabel : null,
                              deliveryPin: order.deliveryPin,


                              onSetLocationTap: () {
                                if (!isOrdersLoading) _showLocationPicker(order.id ?? '');
                              },
                              onTrackOrderTap: () {
                                if (!isOrdersLoading) Get.toNamed(AppRoutes.customerTrackingScreen, arguments: order.id!);
                              },
                              onCallVendorTap: () async {
                                if (isOrdersLoading) return;
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
}