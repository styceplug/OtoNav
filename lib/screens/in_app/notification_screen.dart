import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:otonav/controllers/app_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:otonav/model/notification_model.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';

import '../../widgets/empty_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AppController _notificationController = Get.find<AppController>();

  final List<NotificationModel> _dummyNotifications = List.generate(
    6,
        (index) => NotificationModel(
      title: "Loading Notification Title",
      body: "This is a placeholder for the notification description.",
      read: true,
      createdAt: DateTime.now(),
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationController.fetchNotifications();
    });
  }

  // Dynamic icon and color based on Notification Type
  Map<String, dynamic> _getNotificationStyle(String? type) {
    switch (type) {
      case 'order_created':
      case 'order_assigned':
        return {'icon': Iconsax.box, 'color': Colors.blue};
      case 'package_picked_up':
      case 'delivery_started':
        return {'icon': Iconsax.truck, 'color': Colors.orange};
      case 'rider_arrived':
        return {'icon': Iconsax.location, 'color': Colors.indigo};
      case 'delivery_completed':
        return {'icon': Iconsax.tick_circle, 'color': Colors.green};
      case 'order_cancelled':
        return {'icon': Iconsax.close_circle, 'color': Colors.red};
      case 'rate_rider':
        return {'icon': Iconsax.star1, 'color': Colors.amber};
      default:
        return {'icon': Iconsax.notification, 'color': AppColors.primaryColor};
    }
  }

  // Simple "Time Ago" formatter
  String _timeAgo(DateTime? date) {
    if (date == null) return "";
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return DateFormat('MMM d').format(date);
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Obx(() {
            if (_notificationController.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => _notificationController.markAllAsRead(),
                child: const Text("Mark all read", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final bool isLoading = _notificationController.isLoading.value && _notificationController.notifications.isEmpty;
        final List<NotificationModel> displayData = isLoading ? _dummyNotifications : _notificationController.notifications;

        if (!isLoading && displayData.isEmpty) {
          return Center(
            child: EmptyState(
              message: "No notifications yet",
              imageAsset: "bell-icon",
            ),
          );
        }

        return Skeletonizer(
          enabled: isLoading,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
            itemCount: displayData.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, index) {
              final item = displayData[index];
              final style = _getNotificationStyle(item.type);
              final bool isUnread = item.read == false;

              return InkWell(
                onTap: () {
                  if (isLoading) return;
                  if (isUnread) _notificationController.markAsRead(item.id!);

                  // Optional: Navigate based on type
                  // if (item.orderId != null) Get.toNamed(AppRoutes.trackingScreen, arguments: item.orderId);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                  color: isUnread ? AppColors.primaryColor.withOpacity(0.03) : Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (style['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(style['icon'], color: style['color'], size: 22),
                      ),
                      SizedBox(width: Dimensions.width15),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title ?? "Notification",
                                    style: TextStyle(
                                      fontSize: Dimensions.font16,
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                      color: isUnread ? Colors.black : Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _timeAgo(item.createdAt),
                                  style: TextStyle(fontSize: 11, color: isUnread ? AppColors.primaryColor : Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height5),
                            Text(
                              item.body ?? "",
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                color: isUnread ? Colors.grey[800] : Colors.grey[500],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Unread Indicator Dot
                      if (isUnread) ...[
                        SizedBox(width: Dimensions.width10),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          height: 8, width: 8,
                          decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}