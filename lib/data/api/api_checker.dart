import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../routes/routes.dart';

class ApiChecker {
  static void checkApi(Response response) {
    print('🧩 ApiChecker triggered → Status: ${response.statusCode} [${response.request?.url}]');

    switch (response.statusCode) {
      case 401:
        print('🚫 Unauthorized — Session expired.');
        Get.find<AppController>().clearSharedData();
        Get.offAllNamed(AppRoutes.getStartedScreen);
        break;

      case 403:
        print('🔒 Forbidden request - Permission denied');
        break;

      case 404:
        print('❓ Resource not found');
        break;

      case 408:
      case 504:
        print('⏱ Request timed out');
        break;

      case 500:
        print('💥 Server error: ${response.statusText}');
        break;

      case 0:
      case 1:
        print('📡 No internet / Connection refused');
        Get.offAllNamed(AppRoutes.noInternetScreen);
        break;

      default:
        if (response.body is Map && response.body['code'] == '99') {
          print('❌ App-level error: ${response.body['message']}');
        } else if (response.hasError) {
          print('⚠️ Unknown Error: ${response.statusText}');
        } else {
          print('✅ Request passed API check.');
        }
    }
  }
}
