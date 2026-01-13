import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/rider_order_card.dart';

import '../../../controllers/app_controller.dart';
import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../widgets/custom_button.dart';

class OrderCompleted extends StatefulWidget {
  const OrderCompleted({super.key});

  @override
  State<OrderCompleted> createState() => _OrderCompletedState();
}

class _OrderCompletedState extends State<OrderCompleted> {

  AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppConstants.getGifAsset('check'),
              width: Dimensions.screenWidth * 0.4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Order Completed',
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Order ABC124 has been marked as completed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Dimensions.height10),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radius10),
                          ),
                          child: Icon(Iconsax.box),
                        ),
                        SizedBox(width: Dimensions.width20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #ABC123',
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '4',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  Divider(color: AppColors.grey4),
                  SizedBox(height: Dimensions.height10),


                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                        ),
                        child: Icon(
                          Iconsax.profile_2user,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Receiver',
                            style: TextStyle(
                              fontSize: Dimensions.font14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            'Otonye-Esther Ita',
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.location_circle_fill,
                              color: AppColors.primaryColor,
                              size: Dimensions.iconSize30*1.2,
                            ),
                            SizedBox(width: Dimensions.width15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Delivery Location',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '24B Gold City Estate, Lugbe',
                                  style: TextStyle(
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  'Near Arcade Lane',
                                  style: TextStyle(
                                    fontSize: Dimensions.font13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.location_circle_fill,
                              color: AppColors.primaryColor,
                              size: Dimensions.iconSize30*1.2,
                            ),
                            SizedBox(width: Dimensions.width15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Pick-up Location',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'ABC Phones',
                                  style: TextStyle(
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  'Bannex Plaza',
                                  style: TextStyle(
                                    fontSize: Dimensions.font13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
            CustomButton(text: 'Go Back Home', onPressed: (){
              Get.offAllNamed(AppRoutes.riderHomeScreen);
              appController.changeCurrentAppPage(0);
            })
          ],
        ),
      ),
    );
  }
}
