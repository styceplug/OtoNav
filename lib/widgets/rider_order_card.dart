import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../routes/routes.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'custom_button.dart';

class RiderOrderCard extends StatefulWidget {
  final String orderId;
  final String itemCount;
  final String customerName;
  final String customerLocationPrecise;
  final String customerLocationLabel;
  final String pickupLocation;
  final VoidCallback? onCallCustomerTap;
  final VoidCallback? onStartDeliveryTap;
  final VoidCallback? onCancelDeliveryTap;
  final String status;

  const RiderOrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.customerName,
    required this.status,
    required this.customerLocationPrecise,
    required this.customerLocationLabel,
    required this.pickupLocation,
    this.onCallCustomerTap,
    this.onStartDeliveryTap,
    this.onCancelDeliveryTap,
  }) : super(key: key);

  @override
  State<RiderOrderCard> createState() => _RiderOrderCardState();
}

class _RiderOrderCardState extends State<RiderOrderCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
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
                      widget.orderId, // Used parameter
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.itemCount, // Used parameter
                      style: TextStyle(
                        fontSize: Dimensions.font13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Rotates the arrow based on state
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: Container(height: 0), // Collapsed state
            secondChild: Column(
              children: [
                Divider(color: AppColors.grey4),
                SizedBox(height: Dimensions.height10),

                // Customer Row
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
                          widget.customerName,
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: widget.onCallCustomerTap,
                      child: Icon(Iconsax.call_calling),
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
                    color: AppColors.cardColor,
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
                            size: Dimensions.iconSize30 * 1.2,
                          ),
                          SizedBox(width: Dimensions.width15),
                          Expanded(
                            child: Column(
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
                                  widget.customerLocationPrecise,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  widget.customerLocationLabel,
                                  style: TextStyle(
                                    fontSize: Dimensions.font13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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
                            size: Dimensions.iconSize30 * 1.2,
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
                SizedBox(height: Dimensions.height20),
                Row(
                  children: [
                    IntrinsicWidth(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () {
                          widget.onCancelDeliveryTap;
                        },
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height10,
                          horizontal: Dimensions.width20
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width20),
                    Expanded(
                      child: CustomButton(
                        text: 'Start Delivery',
                        onPressed: () {
                          widget.onStartDeliveryTap;
                        },
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
