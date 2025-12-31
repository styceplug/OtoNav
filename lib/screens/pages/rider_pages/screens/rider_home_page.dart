import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/rider_order_card.dart';

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
      body: Container(
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
                        'Saturday, December 20',
                        style: TextStyle(
                          fontSize: Dimensions.font15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Hello Alex!',
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
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
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
                        Icon(CupertinoIcons.xmark, size: Dimensions.iconSize20),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    Text('For better interaction and personalized experience'),
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
                          '75%',
                          style: TextStyle(
                            fontSize: Dimensions.font14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    LinearProgressIndicator(
                      value: 0.75,
                      color: AppColors.accentColor,
                    ),
                  ],
                ),
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
              RiderOrderCard(
                orderId: 'Order #ABC1234',
                itemCount: '4 Items',
                customerName: 'ABC Jewelries & Co.',
                onSetLocationTap: () {
                  Get.toNamed(AppRoutes.locationScreen);
                },
                onTrackOrderTap: () {
                  Get.toNamed(AppRoutes.trackingScreen);
                },
                onCallVendorTap: () {
                  print("Call clicked");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
