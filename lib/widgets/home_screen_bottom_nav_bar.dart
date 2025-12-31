import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../utils/dimensions.dart';
import 'bottom_bar_item.dart';

class HomeScreenBottomNavBar extends StatelessWidget {
  const HomeScreenBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();

    return Obx(
      () => ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(Dimensions.radius30),
          ),
          padding: EdgeInsets.only(
            bottom: Dimensions.height10*7,
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

    return Obx(
          () => ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(Dimensions.radius30),
          ),
          padding: EdgeInsets.only(
            bottom: Dimensions.height10*7,
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

