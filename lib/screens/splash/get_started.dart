import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:otonav/widgets/custom_button.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  // 1. Initialize as empty string
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        // Fixed EdgeInsetsGeometry to EdgeInsets
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Stack(
          children: [
            // TOP SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: Dimensions.height100),
                Text(
                  'Let\'s Get Started',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Dimensions.font10 * 3.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentColor,
                  ),
                ),
                Text(
                  'How do you intend to use this app?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.accentColor,
                  ),
                ),
                // Ensure image fits within available space
                Expanded(
                  child: Center(
                    child: Image.asset(AppConstants.getPngAsset('onboard3')),
                  ),
                ),
                // Add space for the bottom container to prevent overlap
                SizedBox(height: Dimensions.height100 * 3.6),
              ],
            ),

            // BOTTOM SELECTION SECTION
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // Removed hardcoded height to let content dictate size,
                // preventing overflow on small screens
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  // Optional: Add top border radius or shadow for better separation
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important for Positioned widgets
                  children: [
                    Text(
                      'I want to use the app as:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height15),

                    // --- OPTION 1: RIDER ---
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedOption = "rider");
                      },
                      child: Container(
                        width: Dimensions.screenWidth,
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height20,
                          horizontal: Dimensions.width20,
                        ),
                        decoration: BoxDecoration(
                          color: selectedOption == "rider"
                              ? AppColors.accentColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          border: Border.all(
                            color: selectedOption == "rider"
                                ? Colors.transparent
                                : AppColors.primaryColor,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              AppConstants.getPngAsset('delivery'),
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              color: selectedOption == "rider" ? null : null,
                            ),
                            SizedBox(width: Dimensions.width20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A Rider',
                                    style: TextStyle(
                                      fontSize: Dimensions.font20 * 0.95,
                                      fontWeight: FontWeight.w600,
                                      color: selectedOption == "rider"
                                          ? AppColors.white
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Join our fleet, accept delivery requests, and earn money on your own schedule.',
                                    style: TextStyle(
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                      // FIXED: Was checking "find", changed to "rider"
                                      color: selectedOption == "rider"
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: Dimensions.height15),

                    // --- OPTION 2: CUSTOMER ---
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedOption = "customer");
                      },
                      child: Container(
                        width: Dimensions.screenWidth,
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height20,
                          horizontal: Dimensions.width20,
                        ),
                        decoration: BoxDecoration(
                          color: selectedOption == "customer"
                              ? AppColors.accentColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          border: Border.all(
                            color: selectedOption == "customer"
                                ? Colors.transparent
                                : AppColors.accentColor,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              AppConstants.getPngAsset('customer-icon'),
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                              color: selectedOption == "customer" ? null : null,
                            ),
                            SizedBox(width: Dimensions.width20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer',
                                    style: TextStyle(
                                      fontSize: Dimensions.font20 * 0.95,
                                      fontWeight: FontWeight.w600,
                                      color: selectedOption == "customer"
                                          ? AppColors.white
                                          : AppColors.accentColor,
                                    ),
                                  ),
                                  Text(
                                    'Get pickups, track deliveries in real-time, and manage your shipments easily',
                                    style: TextStyle(
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w400,
                                      color: selectedOption == "customer"
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: Dimensions.height10),

                    // Disclaimer Box
                    Container(
                      width: Dimensions.screenWidth,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.height5,
                      ),
                      // Ensure AppColors.grey1 exists or use Colors.grey[100]
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppConstants.getPngAsset('info-icon'),height: Dimensions.height15),
                          SizedBox(width: Dimensions.width5),
                          Text(
                            'User Experience vary depending on option selected',
                            style: TextStyle(color: Colors.grey[600], fontSize: Dimensions.font12),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.height20),

                    // --- CONTINUE BUTTON ---
                    CustomButton(
                      text: "Continue",
                      isDisabled: selectedOption.isEmpty,
                      onPressed: () {
                        if (selectedOption == 'rider') {
                          Get.toNamed(AppRoutes.riderLoginScreen);
                          print("Go to Rider flow");
                        } else if (selectedOption == 'customer') {
                          Get.toNamed(AppRoutes.customerLoginScreen);
                          print("Go to Customer flow");
                        }
                      },
                    ),
                    SizedBox(height: Dimensions.height10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}