import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/user_controller.dart';

import '../controllers/app_controller.dart';
import '../model/user_model.dart';
import '../utils/dimensions.dart';
import 'bottom_bar_item.dart';

class HomeScreenBottomNavBar extends StatelessWidget {
  const HomeScreenBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();

    return Obx(
          () =>
          ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(Dimensions.radius30),
              ),
              padding: EdgeInsets.only(
                bottom: Dimensions.height10 * 7,
                left: Dimensions.width15,
                right: Dimensions.width15,
                top: Dimensions.height20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BottomBarItem(
                    name: 'Home',
                    image: 'home-icon',
                    isActive: appController.currentAppPage.value == 0,
                    onClick: () {
                      appController.changeCurrentAppPage(0);
                    },
                  ),
                  BottomBarItem(
                    name: 'Orders',
                    image: 'orders-icon',
                    isActive: appController.currentAppPage.value == 1,
                    onClick: () {
                      appController.changeCurrentAppPage(1);
                    },
                  ),
                  BottomBarItem(
                    name: 'Profile',
                    image: 'profile-icon',
                    isActive: appController.currentAppPage.value == 2,
                    onClick: () {
                      appController.changeCurrentAppPage(2);
                    },

                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class RiderHomeScreenBottomNavBar extends StatelessWidget {
  const RiderHomeScreenBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();
    UserController userController = Get.find<UserController>();

    return Obx(() {
      // 1. SAFELY extract the user. If null, use a dummy or null
      final User? user = userController.userModel.value;

      // 2. Safely check the recommended status (defaults to false if user is null)
      final bool isRecommended = user?.isOtonavRecommended == true;

      return ClipRect(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            bottom: Dimensions.height10 * 7,
            left: Dimensions.width15,
            right: Dimensions.width15,
            top: Dimensions.height20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomBarItem(
                name: 'Home',
                image: 'home-icon',
                isActive: appController.currentAppPage.value == 0,
                onClick: () {
                  appController.changeCurrentAppPage(0);
                },
              ),
              if(!isRecommended)
              BottomBarItem(
                name: 'Orders',
                image: 'orders-icon',
                isActive: appController.currentAppPage.value == 1,
                onClick: () {
                  appController.changeCurrentAppPage(1);
                },
              ),
              if (isRecommended)
                BottomBarItem(
                  name: 'Assignments',
                  image: 'orders-icon',
                  isActive: appController.currentAppPage.value == 4,
                  onClick: () {
                    appController.changeCurrentAppPage(4);
                  },
                ),
              if (isRecommended)
                BottomBarItem(
                  name: 'Waitlist',
                  image: 'board',
                  isActive: appController.currentAppPage.value == 3,
                  onClick: () {
                    appController.changeCurrentAppPage(3);
                  },
                ),
              BottomBarItem(
                name: 'Profile',
                image: 'profile-icon',
                isActive: appController.currentAppPage.value == 2,
                onClick: () {
                  appController.changeCurrentAppPage(2);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

