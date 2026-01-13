import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/rider_order_card.dart';


class RiderOrderPage extends StatefulWidget {
  const RiderOrderPage({super.key});

  @override
  State<RiderOrderPage> createState() => _RiderOrderPageState();
}

class _RiderOrderPageState extends State<RiderOrderPage> {
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orders',
                          style: TextStyle(
                            fontSize: Dimensions.font22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Check Ongoing and Completed orders here',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radius10),
                        color: AppColors.white
                    ),
                    child: Text('Active'),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                    child: Text('Completed'),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                    child: Text('Rejected'),
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
