import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';

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

class OrderCard extends StatefulWidget {
  final String orderId;
  final String itemCount;
  final String vendorName;
  final String status;
  final String? customerLocationPrecise;
  final String? deliveryPin;
  final VoidCallback onSetLocationTap;
  final VoidCallback onTrackOrderTap;
  final VoidCallback onCallVendorTap;
  final VoidCallback? onRateDeliveryTap;

  // ✅ NEW: Callback to fetch the PIN
  final Future<String?> Function()? onFetchPin;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.itemCount,
    required this.vendorName,
    required this.status,
    required this.onSetLocationTap,
    required this.onTrackOrderTap,
    required this.onCallVendorTap,
    this.customerLocationPrecise,
    this.deliveryPin,
    this.onRateDeliveryTap,
    this.onFetchPin,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // ✅ NEW: Local states for fetching the PIN dynamically
  bool _isLoadingPin = false;
  String? _localPin;

  bool get _isLocationSet =>
      widget.customerLocationPrecise != null &&
          widget.customerLocationPrecise!.isNotEmpty &&
          widget.customerLocationPrecise != 'null';

  bool get _isTrackable {
    final s = widget.status.toLowerCase();
    return s == 'confirmed' ||
        s == 'package_picked_up' ||
        s == 'in_transit' ||
        s == 'arrived_at_location';
  }

  bool get _isWaitingForRider {
    final s = widget.status.toLowerCase();
    return s == 'pending' || s == 'customer_location_set';
  }

  bool get _isCompleted =>
      widget.status.toLowerCase() == 'delivered' ||
          widget.status.toLowerCase() == 'completed';

  bool get _isCancelled =>
      widget.status.toLowerCase() == 'cancelled' ||
          widget.status.toLowerCase() == 'rejected';

  @override
  Widget build(BuildContext context) {
    // ✅ Determine which PIN to show (from list API or specific fetch)
    String? pinToShow = widget.deliveryPin ?? _localPin;

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
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ROW (Always visible) ---
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    color: _isCancelled
                        ? AppColors.error.withOpacity(0.1)
                        : (_isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.cardColor),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Icon(
                    _isCompleted
                        ? Iconsax.tick_circle
                        : (_isCancelled ? Iconsax.close_circle : Iconsax.box),
                    color: _isCancelled
                        ? AppColors.error
                        : (_isCompleted ? Colors.green : AppColors.primaryColor),
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendorName,
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.itemCount,
                        style: TextStyle(
                          fontSize: Dimensions.font13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : (_isCancelled
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isCompleted
                        ? 'Delivered'
                        : (_isCancelled ? 'Cancelled' : 'Active'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isCompleted
                          ? Colors.green
                          : (_isCancelled ? Colors.red : Colors.blue),
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

                // --- THE DELIVERY PIN BLOCK ---
                if (!_isCancelled && _isTrackable) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery PIN",
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pinToShow != null && pinToShow.isNotEmpty
                                  ? "Give this to your rider"
                                  : "Hidden for security",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        // Show PIN if available
                        if (pinToShow != null && pinToShow.isNotEmpty)
                          Text(
                            pinToShow,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Colors.blue[900],
                            ),
                          )
                        // Show Loader if fetching
                        else if (_isLoadingPin)
                          const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        // Show "Reveal" Button if hidden
                        else
                          TextButton.icon(
                            onPressed: () async {
                              if (widget.onFetchPin == null) return;
                              setState(() => _isLoadingPin = true);

                              String? fetchedPin = await widget.onFetchPin!();

                              if (mounted) {
                                setState(() {
                                  _localPin = fetchedPin;
                                  _isLoadingPin = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text("Reveal"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[800],
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                ],

                // --- ACTION BUTTONS LOGIC ---
                if (!_isLocationSet && !_isCancelled && !_isCompleted) ...[
                  CustomButton(
                    text: 'Set Delivery Location',
                    onPressed: widget.onSetLocationTap,
                    backgroundColor: AppColors.primaryColor,
                    icon: const Icon(CupertinoIcons.location_solid, color: Colors.white, size: 18),
                  ),
                ]
                else if (_isLocationSet && _isWaitingForRider) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          height: 15, width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Waiting for rider to start journey...',
                            style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                else if (_isTrackable) ...[
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onCallVendorTap,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Iconsax.call, color: Colors.green),
                          ),
                        ),
                        SizedBox(width: Dimensions.width15),
                        Expanded(
                          child: CustomButton(
                            text: 'Track Order',
                            onPressed: widget.onTrackOrderTap,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ]
                  else if (_isCompleted) ...[
                      CustomButton(
                        text: 'Rate Delivery',
                        onPressed: widget.onRateDeliveryTap,
                        backgroundColor: Colors.green,
                        icon: const Icon(Iconsax.star1, color: Colors.white, size: 18),
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