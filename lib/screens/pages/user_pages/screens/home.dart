import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/order_card.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Locations',
                    style: TextStyle(
                      fontSize: Dimensions.font17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                children: [
                  Container(
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
                        Image.asset(
                          AppConstants.getPngAsset('home-icon'),
                          scale: 2,
                        ),
                        Text(
                          'Home',
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
                  SizedBox(width: Dimensions.width20),
                  InkWell(
                    onTap: (){
                      Get.toNamed(AppRoutes.locationScreen);
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
                          Icon(CupertinoIcons.add, color: AppColors.primaryColor),
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
              OrderCard(
                orderId: 'Order #ABC1234',
                itemCount: '4 Items',
                vendorName: 'ABC Jewelries & Co.',
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
