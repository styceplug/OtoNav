import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../model/order_model.dart';
import '../routes/routes.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'custom_button.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

class RiderOrderCard extends StatefulWidget {
  final String orderId;
  final String itemCount;
  final String customerName;
  final String? customerLocationPrecise;
  final String? customerLocationLabel;
  final String pickupLocation;
  final String status;
  final String businessName;
  final VoidCallback onCallCustomerTap;
  final VoidCallback onStartDeliveryTap;
  final VoidCallback onCancelDeliveryTap;
  final VoidCallback? onTrackOrderTap;

  const RiderOrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.customerName,
    required this.status,
    this.customerLocationPrecise,
    this.customerLocationLabel,
    required this.pickupLocation,
    required this.businessName,
    required this.onCallCustomerTap,
    required this.onStartDeliveryTap,
    required this.onCancelDeliveryTap,
    this.onTrackOrderTap,
  }) : super(key: key);

  @override
  State<RiderOrderCard> createState() => _RiderOrderCardState();
}

class _RiderOrderCardState extends State<RiderOrderCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _isLocationSet =>
      widget.customerLocationLabel != null &&
          widget.customerLocationLabel!.isNotEmpty &&
          widget.customerLocationLabel != 'Customer Yet to Verify Data' &&
          widget.customerLocationLabel != 'null';

  bool get _isCompleted =>
      widget.status.toLowerCase() == 'delivered' ||
          widget.status.toLowerCase() == 'completed';

  bool get _isCancelled =>
      widget.status.toLowerCase() == 'cancelled' ||
          widget.status.toLowerCase() == 'rejected';

  bool get _isActive =>
      widget.status.toLowerCase() == 'confirmed' ||
          widget.status.toLowerCase() == 'rider_accepted' ||
          widget.status.toLowerCase() == 'package_picked_up' ||
          widget.status.toLowerCase() == 'in_transit' ||
          widget.status.toLowerCase() == 'arrived_at_location';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ---
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    color: _isCancelled
                        ? Colors.red.withOpacity(0.1)
                        : (_isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Icon(
                    _isCompleted ? Iconsax.tick_circle : (_isCancelled ? Iconsax.close_circle : Iconsax.box),
                    color: _isCancelled ? Colors.red : (_isCompleted ? Colors.green : Colors.blue),
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customerName,
                        style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.orderId,
                        style: TextStyle(fontSize: Dimensions.font13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // ✅ NEW: Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isCompleted ? Colors.green.withOpacity(0.1) : (_isCancelled ? Colors.red.withOpacity(0.1) : (_isActive ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1))),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isCompleted ? 'Delivered' : (_isCancelled ? 'Cancelled' : (_isActive ? 'Active' : 'Pending')),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isCompleted ? Colors.green : (_isCancelled ? Colors.red : (_isActive ? Colors.blue : Colors.orange)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ],
            ),
          ),

          // --- EXPANDABLE CONTENT ---
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Column(
              children: [
                SizedBox(height: Dimensions.height15),
                Divider(color: Colors.grey.withOpacity(0.2)),
                SizedBox(height: Dimensions.height15),

                // ✅ NEW: Premium Timeline Locations Block
                Container(
                  padding: EdgeInsets.all(Dimensions.width15),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline Graphics
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          const Icon(Icons.circle, color: Colors.blue, size: 14),
                          Container(
                            width: 2,
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          Icon(
                            Icons.location_on,
                            color: _isLocationSet ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                        ],
                      ),
                      SizedBox(width: Dimensions.width15),
                      // Location Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pickup
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Pickup", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  widget.pickupLocation,
                                  style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Dropoff
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Dropoff", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  _isLocationSet
                                      ? widget.customerLocationLabel!
                                      : "Waiting for customer location...",
                                  style: TextStyle(
                                    fontSize: Dimensions.font14,
                                    fontWeight: _isLocationSet ? FontWeight.w600 : FontWeight.normal,
                                    fontStyle: _isLocationSet ? FontStyle.normal : FontStyle.italic,
                                    color: _isLocationSet ? Colors.black : Colors.orange,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

                // --- ACTION BUTTONS ---

                // CASE A: NOT SET YET -> Only allow Cancel/Decline
                if (!_isLocationSet && widget.status == 'pending') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                        const SizedBox(width: 10),
                        const Expanded(child: Text("Waiting for dropoff pin...", style: TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w500))),
                        TextButton(
                          onPressed: widget.onCancelDeliveryTap,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                          child: const Text("Decline", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ]

                // CASE B: READY TO START -> Location Set
                else if (widget.status == 'customer_location_set') ...[
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onCancelDeliveryTap,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Icon(Iconsax.close_circle, color: Colors.red),
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Expanded(
                        child: CustomButton(
                          text: 'Start Delivery',
                          onPressed: widget.onStartDeliveryTap,
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ]

                // CASE C: ACTIVE IN TRANSIT
                else if (widget.status != 'delivered' && widget.status != 'cancelled' && widget.status != 'pending') ...[
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onCallCustomerTap,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: const Icon(Iconsax.call, color: Colors.green),
                          ),
                        ),
                        SizedBox(width: Dimensions.width15),
                        Expanded(
                          child: CustomButton(
                            text: 'Head to Map',
                            onPressed: () => widget.onTrackOrderTap?.call(),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
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