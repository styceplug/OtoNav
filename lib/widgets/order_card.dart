import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'custom_button.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrderCard extends StatefulWidget {
  final String orderId;
  final String itemCount;
  final String vendorName;
  final String status;
  final bool isLocationSet;
  final VoidCallback onSetLocationTap;
  final VoidCallback onTrackOrderTap;
  final VoidCallback onCallVendorTap;
  final VoidCallback? onRateDeliveryTap;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.vendorName,
    required this.status,
    required this.onSetLocationTap,
    required this.onTrackOrderTap,
    required this.onCallVendorTap,
    this.isLocationSet = false,
    this.onRateDeliveryTap,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Helper to determine if order is currently active/tracking allowed
  bool get _isOrderActive {
    final s = widget.status.toLowerCase();
    return s == 'confirmed' ||
        s == 'rider_accepted' ||
        s == 'package_picked_up' ||
        s == 'in_transit' ||
        s == 'arrived_at_location';
  }

  bool get _isCompleted => widget.status.toLowerCase() == 'delivered' || widget.status.toLowerCase() == 'completed';
  bool get _isCancelled => widget.status.toLowerCase() == 'cancelled' || widget.status.toLowerCase() == 'rejected';

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ROW ---
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    color: _isCancelled
                        ? AppColors.error.withOpacity(0.1)
                        : (_isCompleted ? Colors.green.withOpacity(0.1) : AppColors.cardColor),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Icon(
                    _isCompleted ? Iconsax.tick_circle : (_isCancelled ? Iconsax.close_circle : Iconsax.box),
                    color: _isCancelled
                        ? AppColors.error
                        : (_isCompleted ? Colors.green : AppColors.black),
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.orderId,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isCompleted ? 'Delivered' : (_isCancelled ? 'Cancelled' : widget.itemCount),
                        style: TextStyle(
                          fontSize: Dimensions.font13,
                          fontWeight: FontWeight.w300,
                          color: _isCompleted ? Colors.green : (_isCancelled ? AppColors.error : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow rotation
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ],
            ),
          ),

          // --- EXPANDABLE CONTENT ---
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Column(
              children: [
                Divider(color: AppColors.grey4, height: 30),

                // 1. RIDER / VENDOR ROW (Hide if cancelled or pending assignment)
                if (!_isCancelled) ...[
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Dimensions.width10),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radius15),
                        ),
                        child: Icon(Iconsax.profile_2user, color: AppColors.accentColor),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Rider',
                            style: TextStyle(
                              fontSize: Dimensions.font12,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.vendorName,
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Only show call button if active or completed
                      if (_isOrderActive || _isCompleted)
                        InkWell(
                          onTap: widget.onCallVendorTap,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withOpacity(0.1)
                            ),
                            child: Icon(Iconsax.call_calling, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                ],

                // 2. ACTION BUTTONS LOGIC

                // CASE A: Location Not Set
                if (!widget.isLocationSet && !_isCancelled && !_isCompleted) ...[
                  CustomButton(
                    text: 'Set Delivery Location',
                    onPressed: widget.onSetLocationTap,
                    backgroundColor: AppColors.cardColor,
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                    textStyle: TextStyle(
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                    icon: Icon(CupertinoIcons.location_circle_fill, color: AppColors.primaryColor, size: 18),
                  ),
                ]

                // CASE B: Waiting for Rider (Location Set but still Pending)
                else if (widget.isLocationSet && (widget.status == 'pending' || widget.status == 'customer_location_set')) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withOpacity(0.3))
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 15, width: 15,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Waiting for rider to accept...',
                            style: TextStyle(fontSize: 13, color: Colors.orange[800], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]

                // CASE C: Active Order (Track)
                else if (_isOrderActive) ...[
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
                  ]

                  // CASE D: Completed (Rate)
                  else if (_isCompleted) ...[
                      CustomButton(
                        text: 'Rate Delivery',
                        onPressed: widget.onRateDeliveryTap, // Use the new callback
                        backgroundColor: Color(0xFF34C759), // Green color
                        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                        icon: Icon(Iconsax.star1, color: Colors.white, size: 18),
                        textStyle: TextStyle(
                          fontSize: Dimensions.font15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ]

                    // CASE E: Cancelled
                    else if (_isCancelled) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Order Cancelled',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ),
                      ],
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
