import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/controllers/order_controller.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_appbar.dart';
import 'package:otonav/widgets/waitlist_order_card.dart';
import '../../../../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:otonav/model/order_model.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/rider_order_card.dart';

import '../../../../widgets/empty_state_widget.dart';

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final OrderController _waitlistController = Get.find<OrderController>();

  final List<WaitlistModel> _dummyData = List.generate(
    3,
    (index) => WaitlistModel(
      id: "dummy_$index",
      order: OrderModel(
        orderNumber: "ORDXXXXXX",
        packageDescription: "Loading package details...",
        status: "pending",
        organization: null,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitlistController.fetchWaitlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height100,
          Dimensions.width20,
          Dimensions.height10 * 13.5, // Padding for bottom nav bar
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Waitlist',
                            style: TextStyle(
                              fontSize: Dimensions.font22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: Dimensions.width5),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 22,
                          ),
                        ],
                      ),
                      Text(
                        'Exclusive pool of delivery requests',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey5,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: const BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.notification,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- INFO BANNER ---
            Container(
              padding: EdgeInsets.all(Dimensions.height15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Dimensions.radius10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.blue[700], size: 20),
                  SizedBox(width: Dimensions.width15),
                  Expanded(
                    child: Text(
                      "As a verified rider, you have exclusive access to these orders. Your exact location will be shared when you accept.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // --- ORDER LIST ---
            Expanded(
              child: Obx(() {
                final bool isLoading =
                    _waitlistController.isFetchingOrders.value &&
                    _waitlistController.pendingWaitlist.isEmpty;
                final List<WaitlistModel> displayData = isLoading
                    ? _dummyData
                    : _waitlistController.pendingWaitlist;

                if (!isLoading && displayData.isEmpty) {
                  return Center(
                    child: EmptyState(
                      message: "No waitlist orders available right now.",
                      imageAsset: "empty-archive",
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      final waitlistItem = displayData[index];
                      final order = waitlistItem.order;

                      return Padding(
                        padding: EdgeInsets.only(bottom: Dimensions.height15),
                        child: WaitlistOrderCard(
                          orderId: order?.orderNumber ?? "N/A",
                          businessName:
                              order?.organization?.name ?? 'Loading...',
                          pickupLocation:
                              order?.organization?.address ?? 'Loading...',
                          packageDescription: order?.packageDescription ?? '',
                          deliveryAreaLabel: order?.customerLocationLabel ?? '',
                          onAcceptTap: () {
                            _waitlistController.acceptWaitlistOrder(waitlistItem.id ?? '');
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
