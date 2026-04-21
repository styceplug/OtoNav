import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class AppRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AppRepo({required this.apiClient, required this.sharedPreferences});


  Future<Response> updateDeviceToken(String token) async {
    return await apiClient.putData(AppConstants.POST_FCM_TOKEN, {
      "deviceToken": token,
      // "platform": platform,
    });
  }

}