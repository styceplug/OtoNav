import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'custom_button.dart';

class OrderCard extends StatefulWidget {
  final String orderId;
  final String itemCount;
  final String vendorName;
  final VoidCallback onSetLocationTap;
  final VoidCallback onTrackOrderTap;
  final VoidCallback? onCallVendorTap;
  final bool isLocationSet;
  final String status;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.vendorName,
    required this.onSetLocationTap,
    required this.onTrackOrderTap,
    this.onCallVendorTap,
    this.isLocationSet = false,
    required this.status,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
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

                // Vendor Row
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
                          'Assigned Rider',
                          style: TextStyle(
                            fontSize: Dimensions.font14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          widget.vendorName, // Used parameter
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: widget.onCallVendorTap,
                      child: Icon(Iconsax.call_calling),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),

                if (!widget.isLocationSet) ...[
                  CustomButton(
                    text: 'Set Delivery Location',
                    onPressed: widget.onSetLocationTap,
                    backgroundColor: AppColors.cardColor,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height10,
                    ),
                    textStyle: TextStyle(
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w400,
                    ),
                    icon: Icon(
                      CupertinoIcons.location_circle_fill,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                ],
                if (widget.isLocationSet && widget.status =='pending') ...[
                  Text(
                    'Waiting for Assigned Rider to Confirm order...',
                    maxLines: 1,
                  ),
                  SizedBox(height: Dimensions.height10),
                ],



                if(widget.status != 'pending' && widget.status != 'customer_location_set' && widget.status != 'cancelled')...[
                  CustomButton(
                    text: 'Track Order',
                    onPressed: widget.onTrackOrderTap,
                    backgroundColor: AppColors.accentColor,
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                    textStyle: TextStyle(
                      fontSize: Dimensions.font15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
                if (widget.status == 'cancelled')...[
                  Text('No Actions required: Order Cancelled',style: TextStyle(color: AppColors.error,fontWeight: FontWeight.w500),)]

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
