import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/data/api/api_client.dart';
import 'package:otonav/data/repo/auth_repo.dart';
import 'package:otonav/screens/pages/rider_pages/screens/active_assignments.dart';
import 'package:otonav/screens/pages/rider_pages/screens/rider_home_page.dart';
import 'package:otonav/screens/pages/rider_pages/screens/rider_profile_page.dart';
import 'package:otonav/screens/pages/rider_pages/screens/waitlist_screen.dart';
import 'package:otonav/screens/pages/user_pages/screens/orders.dart';
import 'package:otonav/screens/pages/user_pages/screens/profile.dart';
import 'package:otonav/widgets/snackbars.dart';

import '../data/repo/app_repo.dart';
import '../model/notification_model.dart';
import '../routes/routes.dart';
import '../screens/pages/rider_pages/screens/rider_order.dart';
import '../screens/pages/user_pages/screens/home.dart';
import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'auth_controller.dart';
import 'order_controller.dart';

class AppController extends GetxController {
  final AppRepo appRepo;
  final AuthRepo authRepo;
  final ApiClient apiClient;

  AppController({
    required this.appRepo,
    required this.apiClient,
    required this.authRepo,
  });

  Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  var currentAppPage = 0.obs;
  var isFirstTime = false.obs;
  PageController pageController = PageController();
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  final List<Widget> customerPages = [
    CustomerHomePage(),
    CustomerOrdersPage(),
    CustomerProfilePage(),
  ];

  final List<Widget> riderPages = [
    RiderHomePage(),
    RiderOrderPage(),
    RiderProfilePage(),
    WaitlistScreen(),
    ActiveAssignments()
  ];

  @override
  void onInit() {
    // initializeApp();
    super.onInit();
  }

  //NOTIFICATIONS
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    Response response = await appRepo.getAllNotification();

    if (response.statusCode == 200 && response.body['success'] == true) {
      notifications.clear();
      List<dynamic> data = response.body['data'] ?? [];

      for (var element in data) {
        notifications.add(NotificationModel.fromJson(element));
      }


      final rawCount = response.body['unreadCount'];
      unreadCount.value = int.tryParse(rawCount.toString()) ?? 0;

    } else {
      print("Failed to fetch notifications: ${response.statusText}");
    }

    isLoading.value = false;
  }

  Future<void> markAsRead(String id) async {
    int index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && notifications[index].read == false) {
      notifications[index].read = true;
      if (unreadCount.value > 0) unreadCount.value--;
      notifications.refresh();

      Response response = await appRepo.markAsRead(id);

      if (response.statusCode != 200 || response.body['success'] != true) {
        notifications[index].read = false;
        unreadCount.value++;
        notifications.refresh();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    for (var n in notifications) {
      n.read = true;
    }
    int previousUnreadCount = unreadCount.value;
    unreadCount.value = 0;
    notifications.refresh();

    Response response = await appRepo.markAllAsRead();

    if (response.statusCode != 200 || response.body['success'] != true) {
      fetchNotifications();
      CustomSnackBar.failure(message: "Failed to mark notifications as read");
    }
  }

  //

  Future<void> initializeApp() async {
    print('Initializing App...');

    await checkFirstTimeUse();

    if (isFirstTime.value) {
      print("First time user -> Onboarding");
      Get.offAllNamed(AppRoutes.onboardingScreen);
      return;
    }

    final prefs = apiClient.sharedPreferences;
    String? accessToken = prefs.getString(AppConstants.authToken);
    String? refreshToken = prefs.getString(AppConstants.refreshToken);
    String? role = prefs.getString(AppConstants.userRole);

    if (accessToken != null && accessToken.isNotEmpty) {
      apiClient.updateHeader(accessToken);

      // 2. VERIFY TOKEN with Backend
      print("🔄 Verifying Session...");
      Response profileResponse = await authRepo.getProfile();
      saveDeviceToken();

      if (profileResponse.statusCode == 200) {
        print("✅ Session Valid");
        _navigateHome(role);
      } else {
        print("⚠️ Session Expired (401). Attempting Refresh...");

        // 3. ATTEMPT REFRESH
        if (refreshToken != null && refreshToken.isNotEmpty) {
          bool refreshed = await _tryTokenRefresh(refreshToken);
          if (refreshed) {
            _navigateHome(role);
          } else {
            _logout();
          }
        } else {
          _logout();
        }
      }
    } else {
      _logout();
    }
  }

  Future<bool> _tryTokenRefresh(String refreshToken) async {
    Response response = await authRepo.refreshToken(refreshToken);

    if (response.statusCode == 200 && response.body['success'] == true) {
      String newAccessToken = response.body['data']['accessToken'];
      print("✅ Token Refreshed Successfully");

      // Save new token
      apiClient.updateHeader(newAccessToken);
      return true;
    } else {
      print("❌ Refresh Failed: ${response.body}");
      return false;
    }
  }

  Future<void> _navigateHome(String? role) async {
    saveDeviceToken();
    if (role == 'rider') {
      Get.offAllNamed(AppRoutes.riderHomeScreen);
    } else {
      if (role == 'customer') Get.offAllNamed(AppRoutes.customerHomeScreen);
    }
    return;
  }

  void _logout() {
    print("🔒 Logging out...");
    apiClient.sharedPreferences.remove(AppConstants.authToken);
    apiClient.sharedPreferences.remove(AppConstants.refreshToken);
    apiClient.sharedPreferences.remove(AppConstants.userRole);
    apiClient.token = '';
    apiClient.updateHeader('');
    Get.offAllNamed(AppRoutes.getStartedScreen);
  }

  Future<void> saveDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (Platform.isIOS) {
          String? apnsToken = await messaging.getAPNSToken();

          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 3));
            apnsToken = await messaging.getAPNSToken();
          }

          if (apnsToken == null) {
            print(
              "❌ APNs Token is null. Are you on a Simulator? Push won't work.",
            );
            return;
          }
        }

        String? token = await messaging.getToken();

        if (token != null) {
          String platform = Platform.isAndroid ? 'android' : 'ios';
          print("📱 Device Token: $token");

          // 3. Send to Backend
          Response response = await appRepo.updateDeviceToken(token);

          if (response.statusCode == 200) {
            print("✅ Device Token Synced Successfully");
          } else {
            print("⚠️ Failed to sync token: ${response.body}");
          }
        }
      }
    } catch (e) {
      print("❌ Error saving device token: $e");
    }
  }

  Future<void> checkFirstTimeUse() async {
    final prefs = appRepo.sharedPreferences;
    bool hasSeen = prefs.getBool('hasSeenOnboarding') ?? false;
    // saveDeviceToken();
    if (!hasSeen) {
      isFirstTime.value = true;
      await prefs.setBool('hasSeenOnboarding', true);
    } else {
      isFirstTime.value = false;
    }
  }

  void clearSharedData() {
    changeCurrentAppPage(0);
    appRepo.sharedPreferences.remove(AppConstants.authToken);
    apiClient.token = '';
    apiClient.updateHeader('');
    Get.offAllNamed(AppRoutes.getStartedScreen);
  }

  void changeCurrentAppPage(int page, {bool movePage = true}) {
    currentAppPage.value = page;

    if (movePage) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }

    update();
  }
}
