import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class AppRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AppRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> updateDeviceToken(String token) async {
    return await apiClient.postData(AppConstants.POST_FCM_TOKEN, {
      "fcmToken": token,
      // "platform": platform,
    });
  }

  //NOTIFICATION

  Future<Response> getAllNotification() async {
    return await apiClient.getData(AppConstants.GET_NOTIFICATIONS);
  }

  Future<Response> markAllAsRead() async {
    return await apiClient.putData(
      AppConstants.MARK_ALL_NOTIFICATIONS_AS_READ,
      {},
    );
  }

  Future<Response> markAsRead(String notificationId) async {
    return await apiClient.putData(
      AppConstants.MARK_SINGLE_NOTIFICATION_AS_READ(notificationId),
      {},
    );
  }
}
