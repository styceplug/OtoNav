import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/controllers/app_controller.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/model/user_model.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';

import '../../../in_app/riders/rider_analytics_page.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();
  AppController appController = Get.find<AppController>();

  void _showVerifiedDialog() {
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: Colors.blue, size: 60),
              SizedBox(height: Dimensions.height15),
              Text(
                "OtoNav Verified",
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                "This rider has been manually verified by our team and maintains a high standard of service, speed, and reliability.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("Got it"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<UserController>(
        builder: (userController) {
          if (userController.userModel.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          User user = userController.userModel.value!;

          // Quick Stats Only
          final summary = user.jobAnalytics?.summary;
          final completedOrders = summary?['completedOrders']?.toString() ?? "0";
          final completionRate = summary?['completionRate']?.toString() ?? "0";
          final averageRating = user.averageRating?.toStringAsFixed(1) ?? "0.0";

          return Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height100,
              Dimensions.width20,
              Dimensions.height10 * 13.5,
            ),
            child: SingleChildScrollView(
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
                            Text('Rider Profile', style: TextStyle(fontSize: Dimensions.font22, fontWeight: FontWeight.w500)),
                            Text('Manage your account and view performance', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(Dimensions.width15),
                        decoration: const BoxDecoration(color: AppColors.cardColor, shape: BoxShape.circle),
                        child: const Icon(Iconsax.notification),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height30),

                  // --- AVATAR & NAME ---
                  Container(
                    padding: EdgeInsets.all(Dimensions.width20),
                    decoration: BoxDecoration(color: AppColors.accentColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Image.asset(AppConstants.getPngAsset('delivery-bike-2'), height: Dimensions.height50, width: Dimensions.width50),
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${user.name?.capitalizeFirst}', style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.w600)),
                      if (user.isOtonavRecommended == true) ...[
                        SizedBox(width: Dimensions.width5),
                        GestureDetector(onTap: _showVerifiedDialog, child: const Icon(Icons.verified, color: Colors.blue, size: 22)),
                      ]
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.height5),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: Dimensions.height5),
                    decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radius20)),
                    child: Text(user.primaryOrgName, style: TextStyle(fontSize: Dimensions.font13, color: AppColors.primaryColor, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: Dimensions.height30),

                  // --- QUICK STATS ---
                  Row(
                    children: [
                      _buildStatCard(title: "Rating", value: averageRating, icon: Iconsax.star1, iconColor: AppColors.warning),
                      SizedBox(width: Dimensions.width10),
                      _buildStatCard(title: "Completed", value: completedOrders, icon: Iconsax.box_tick, iconColor: AppColors.success),
                      SizedBox(width: Dimensions.width10),
                      _buildStatCard(title: "Completion", value: "$completionRate%", icon: Iconsax.chart_success, iconColor: AppColors.primaryColor),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),

                  // --- VIEW FULL ANALYTICS BUTTON ---
                  InkWell(
                    onTap: () => Get.to(() => const RiderAnalyticsPage()),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.chart_21, color: AppColors.accentColor, size: Dimensions.iconSize20),
                          SizedBox(width: Dimensions.width10),
                          Text(
                            "View Full Analytics",
                            style: TextStyle(color: AppColors.accentColor, fontSize: Dimensions.font16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height30),

                  // --- SETTINGS MENU ---
                  Align(alignment: Alignment.centerLeft, child: Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w600, color: AppColors.grey5, letterSpacing: 1.2))),
                  SizedBox(height: Dimensions.height10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radius20), border: Border.all(color: AppColors.grey2), color: Colors.white),
                    child: Column(
                      children: [
                        OptionCard('edit-profile', 'Edit Profile'),
                        const Divider(color: AppColors.grey2),
                        OptionCard('bell-icon', 'Location & Navigation'),
                        const Divider(color: AppColors.grey2),
                        OptionCard('empty-archive', 'Delivery History'),
                        const Divider(color: AppColors.grey2),
                        OptionCard('help-icon', 'Rider Support', onTap: () {}),
                        const Divider(color: AppColors.grey2),
                        OptionCard('log-out', 'Log Out', onTap: () => appController.clearSharedData()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color iconColor}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10, horizontal: Dimensions.width5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: AppColors.grey2),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: Dimensions.iconSize20),
            SizedBox(height: Dimensions.height10),
            Text(value, style: TextStyle(fontSize: Dimensions.font15, fontWeight: FontWeight.bold)),
            SizedBox(height: Dimensions.height5),
            Text(title, style: TextStyle(fontSize: Dimensions.font12, color: AppColors.grey5)),
          ],
        ),
      ),
    );
  }

  Widget OptionCard(String image, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
        child: Row(
          children: [
            Image.asset(AppConstants.getPngAsset(image), height: Dimensions.height20, width: Dimensions.width20),
            SizedBox(width: Dimensions.width15),
            Text(title, style: TextStyle(fontSize: Dimensions.font15, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey5),
          ],
        ),
      ),
    );
  }
}