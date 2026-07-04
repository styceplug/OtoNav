import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/controllers/app_controller.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/helpers/push_notification.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/dimensions.dart';

import '../../../../model/user_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/colors.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();
  AppController appController = Get.find<AppController>();

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
                            'Profile',
                            style: TextStyle(
                              fontSize: Dimensions.font22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Keep track of account and personal data',
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
                SizedBox(height: Dimensions.height50),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    AppConstants.getPngAsset('profile-icon'),
                    color: AppColors.accentColor,
                  ),
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  '${user.name?.capitalize}',
                  style: TextStyle(
                    fontSize: Dimensions.font17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.star1,
                      color: AppColors.warning,
                      size: Dimensions.iconSize20,
                    ),
                    Icon(
                      Iconsax.star1,
                      color: AppColors.warning,
                      size: Dimensions.iconSize20,
                    ),
                    Icon(
                      Iconsax.star1,
                      color: AppColors.warning,
                      size: Dimensions.iconSize20,
                    ),
                    Icon(
                      Iconsax.star1,
                      color: AppColors.warning,
                      size: Dimensions.iconSize20,
                    ),
                    Icon(
                      Iconsax.star1,
                      color: AppColors.warning,
                      size: Dimensions.iconSize20,
                    ),
                    SizedBox(width: Dimensions.width5),
                    Text(
                      '5.0',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Dimensions.font15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    border: Border.all(color: AppColors.grey1),
                  ),
                  child: Column(
                    children: [
                      // OptionCard('edit-profile', 'Edit Profile'),
                      // Divider(color: AppColors.grey2),
                      OptionCard(
                        'delete-2',
                        'Delete Account',
                        onTap: () {
                          // 1. Show a warning bottom sheet first to prevent accidental deletion
                          Get.bottomSheet(
                            Container(
                              padding: EdgeInsets.all(Dimensions.width20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(Dimensions.radius20),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Little drag handle
                                  Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height20),

                                  // Warning Icon
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Iconsax.trash,
                                      color: Colors.redAccent,
                                      size: 35,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height15),

                                  // Text Prompts
                                  Text(
                                    "Delete Account?",
                                    style: TextStyle(
                                      fontSize: Dimensions.font20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height10),
                                  Text(
                                    "This action is permanent and cannot be undone. All your data, orders, and history will be permanently erased.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.grey5,
                                      fontSize: Dimensions.font14,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height30),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => Get.back(),
                                          // Safely close the sheet
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.height15,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radius10,
                                                  ),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: Dimensions.font15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.width15),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Get.back(); // Close the bottom sheet

                                            // 2. ONLY call the actual delete method if they click "Yes, Delete"
                                            Get.find<AuthController>()
                                                .deleteProfile();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.height15,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radius10,
                                                  ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Yes, Delete",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: Dimensions.font15,
                                                  fontWeight: FontWeight.bold,
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
                          );
                        },
                      ),
                      Divider(color: AppColors.grey2),
                      OptionCard('bell-icon', 'Location Services',onTap: (){
                        NotificationService notificationService = NotificationService();
                        notificationService.requestNotificationPermission();
                      }),
                      // Divider(color: AppColors.grey2),
                      // OptionCard('help-icon', 'Help Center', onTap: () {}),
                      // Divider(color: AppColors.grey2),
                      // OptionCard('terms', 'Terms and condition'),
                      Divider(color: AppColors.grey2),
                      OptionCard(
                        'log-out',
                        'Log Out',
                        onTap: () {
                          appController.clearSharedData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget OptionCard(String image, String title, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Dimensions.height5,
        top: Dimensions.height5,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
          child: Row(
            children: [
              Image.asset(
                AppConstants.getPngAsset(image),
                height: Dimensions.height10 * 2,
                width: Dimensions.width10 * 2,
              ),
              SizedBox(width: Dimensions.width10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
