import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

class WaitlistOrderCard extends StatefulWidget {
  final String orderId;
  final String packageDescription;
  final String businessName;
  final String pickupLocation;
  final String deliveryAreaLabel;
  final DateTime? expiresAt;
  final VoidCallback onAcceptTap;

  const WaitlistOrderCard({
    Key? key,
    required this.orderId,
    required this.packageDescription,
    required this.businessName,
    required this.pickupLocation,
    required this.deliveryAreaLabel,
    this.expiresAt,
    required this.onAcceptTap,
  }) : super(key: key);

  @override
  State<WaitlistOrderCard> createState() => _WaitlistOrderCardState();
}

class _WaitlistOrderCardState extends State<WaitlistOrderCard>
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
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- PREMIUM BADGE ---
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.blue, size: 14),
              SizedBox(width: Dimensions.width5),
              const Text(
                "Verified Exclusive",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (widget.expiresAt != null)
                Text(
                  "Exp: ${DateFormat('h:mm a').format(widget.expiresAt!)}",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: Dimensions.height10),

          // --- HEADER (Always Visible) ---
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: const Icon(Iconsax.box, color: Colors.blue),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.businessName,
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.orderId,
                        style: TextStyle(
                          fontSize: Dimensions.font13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "TAP TO EXPAND",
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- EXPANDED DETAILS ---
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Column(
              children: [
                SizedBox(height: Dimensions.height15),
                Divider(color: Colors.grey.withOpacity(0.2)),
                SizedBox(height: Dimensions.height15),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Column(
                    children: [
                      // PICKUP
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.shop, color: AppColors.primaryColor, size: 20),
                          SizedBox(width: Dimensions.width15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Pickup At", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  widget.pickupLocation,
                                  style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height15),

                      // DELIVERY AREA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.location, color: Colors.orange, size: 20),
                          SizedBox(width: Dimensions.width15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Deliver To", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  widget.deliveryAreaLabel.isNotEmpty
                                      ? widget.deliveryAreaLabel
                                      : "Area hidden until accepted",
                                  style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height15),

                      // PACKAGE DETAILS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.info_circle, color: Colors.grey, size: 20),
                          SizedBox(width: Dimensions.width15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Package", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  widget.packageDescription,
                                  style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // --- ACTION BUTTON ---
                CustomButton(
                  text: 'Accept Order',
                  backgroundColor: Colors.blue,
                  icon: Icon(Iconsax.tick_circle,color: Colors.white,size: Dimensions.iconSize20,),
                  onPressed: widget.onAcceptTap,
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                  textStyle: TextStyle(fontSize: Dimensions.font15,color: Colors.white),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // --- EXPAND ARROW (Only visible when collapsed) ---
          if (!_isExpanded) ...[
            SizedBox(height: Dimensions.height10),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ]
        ],
      ),
    );
  }
}