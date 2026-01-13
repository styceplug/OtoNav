import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';


enum OrderStage {
  pickup,
  startTrip,
  inTransit,
  arrived,
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {

  OrderStage _currentStage = OrderStage.pickup;

  String get _titleText {
    if (_currentStage == OrderStage.pickup) {
      return 'Pickup Address';
    }
    return 'Delivery Address';
  }

  String get _addressText {
    if (_currentStage == OrderStage.pickup) {
      return 'Old Garage, Lagos';
    }
    return '123, Victoria Island, Lagos';
  }

  String get _buttonText {
    switch (_currentStage) {
      case OrderStage.pickup:
        return 'Mark Package as Picked up';
      case OrderStage.startTrip:
        return 'Start Trip';
      case OrderStage.inTransit:
        return 'I have arrived at delivery address';
      case OrderStage.arrived:
        return 'Mark as Delivered';
    }
  }

  void _handleButtonPress() {
    setState(() {
      switch (_currentStage) {
        case OrderStage.pickup:
          _currentStage = OrderStage.startTrip;
          break;
        case OrderStage.startTrip:
          _currentStage = OrderStage.inTransit;
          break;
        case OrderStage.inTransit:
          _currentStage = OrderStage.arrived;
          break;
        case OrderStage.arrived:
          _showSuccessPopup();
          break;
      }
    });
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppConstants.getPngAsset('delivered')),
            SizedBox(height: Dimensions.height20),
            Text(
              "Mark Order as Delivered?",
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,vertical: Dimensions.height20
              ),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radius15)
              ),
              child: Column(
                children: [
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
                            Dimensions.radius20,
                          ),
                        ),
                        child: Icon(
                          Iconsax.location,
                          color: AppColors.white,
                          size: Dimensions.iconSize16,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Location',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '24B Gold City Estate, Lugbe',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
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
                            Dimensions.radius20,
                          ),
                        ),
                        child: Icon(
                          Iconsax.location,
                          color: AppColors.white,
                          size: Dimensions.iconSize16,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pick Up Location',
                            style: TextStyle(
                              fontSize: Dimensions.font13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            'ABC Phones', // Used parameter
                            style: TextStyle(
                              fontSize: Dimensions.font14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimensions.height20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IntrinsicWidth(
                  child: CustomButton(
                    text: "Get Back",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    textStyle: TextStyle(fontSize: Dimensions.font14,color: AppColors.white),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width15,vertical: Dimensions.height10),
                  ),
                ),

                IntrinsicWidth(
                  child: CustomButton(
                    text: "Mark as Delivered",
                    onPressed: () {
                      Get.toNamed(AppRoutes.orderCompletedPage);
                    },
                    backgroundColor: Color(0xFF34C759),
                    textStyle: TextStyle(fontSize: Dimensions.font14,color: AppColors.white),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width10,vertical: Dimensions.height10),
                  ),

                ),

              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                AppConstants.getPngAsset('track-map'),
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              bottom: Dimensions.height50,
              left: Dimensions.width20,
              right: Dimensions.width20,
              child: Container(
                width: Dimensions.screenWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height30,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleText,
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: Dimensions.iconSize16,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: Dimensions.width5),
                        Text(
                          _addressText,
                          style: TextStyle(
                            fontSize: Dimensions.font12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomButton(
                      text: _buttonText,
                      onPressed: _handleButtonPress,
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                      backgroundColor: AppColors.accentColor,
                      textStyle: TextStyle(
                        fontSize: Dimensions.font14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                    ),
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
