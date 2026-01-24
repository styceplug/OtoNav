import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../model/order_model.dart';
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
  final VoidCallback onCallCustomerTap;
  final VoidCallback onStartDeliveryTap;
  final VoidCallback onCancelDeliveryTap;
  final VoidCallback? onTrackOrderTap;
  final String status;
  final String businessName;

  const RiderOrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.customerName,
    required this.status,
    required this.customerLocationPrecise,
    required this.customerLocationLabel,
    required this.pickupLocation,
    required this.onCallCustomerTap,
    required this.onStartDeliveryTap,
    required this.onCancelDeliveryTap,
    required this.businessName,
    this.onTrackOrderTap,
  }) : super(key: key);

  @override
  State<RiderOrderCard> createState() => _RiderOrderCardState();
}

class _RiderOrderCardState extends State<RiderOrderCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Helper to check if location is valid
  bool get _isLocationSet {
    return widget.customerLocationPrecise.isNotEmpty &&
        widget.customerLocationPrecise != 'Customer Yet to Verify Data' &&
        widget.customerLocationPrecise != 'null';
  }

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
                      widget.orderId,
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.itemCount,
                      style: TextStyle(
                        fontSize: Dimensions.font13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(height: 0),
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
                      // DELIVERY LOCATION SECTION
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
                                // LOGIC: If location is set, show it. Else show waiting text.
                                _isLocationSet
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
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
                                )
                                    : Text(
                                  "Waiting for location...",
                                  style: TextStyle(
                                    fontSize: Dimensions.font14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height15),
                      // PICKUP LOCATION SECTION
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
                                widget.pickupLocation,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                widget.businessName,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Dimensions.font13,
                                  fontWeight: FontWeight.w500,
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

                // --- ACTION BUTTONS ---
                if (widget.status == 'pending' ||
                    widget.status == 'customer_location_set') ...[
                  // IF LOCATION IS NOT SET: Show Waiting Indicator
                  if (!_isLocationSet) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.height15,
                        horizontal: Dimensions.width20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            Dimensions.radius15),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          Flexible(
                            child: Text(
                              "Waiting for customer to set location",
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.font14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    // Optional: You can still allow them to cancel if they wait too long
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          widget.onCancelDeliveryTap();
                        },
                        child: Text(
                          "Decline Order",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  ]
                  // IF LOCATION IS SET: Show Normal Buttons
                  else ...[
                    Row(
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () {
                            print('tapped');
                            widget.onCancelDeliveryTap();
                          },
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10,
                            horizontal: Dimensions.width20,
                          ),
                          backgroundColor: AppColors.primaryColor,
                        ),
                        SizedBox(width: Dimensions.width20),
                        Expanded(
                          child: CustomButton(
                            text: 'Start Delivery',
                            onPressed: () {
                              widget.onStartDeliveryTap();
                            },
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else if (widget.status == 'confirmed' ||
                    widget.status == 'rider_accepted' ||
                    widget.status == 'package_picked_up' ||
                    widget.status == 'in_transit' ||
                    widget.status == 'arrived_at_location') ...[
                  CustomButton(
                    text: 'Head to Map',
                    onPressed: () => widget.onTrackOrderTap?.call(),
                  ),
                ],
                if (widget.status == 'cancelled') ...[
                  Text(
                    'No Actions required: Order Cancelled',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
