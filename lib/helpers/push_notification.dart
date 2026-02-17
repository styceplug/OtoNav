import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

import '../controllers/user_controller.dart';
import '../routes/routes.dart';




@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🌙 Background Message: ${message.messageId} | data: ${message.data}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Local notifications init
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      // initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped, settings: initSettings,
    );

    await _createNotificationChannels();

    // iOS: show notifications while app is open (optional but recommended)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initPushNotifications();
  }

  Future<void> _initPushNotifications() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ Push Permission Denied');
      return;
    }

    print('✅ Push Permission Granted');

    // Get current token + sync
    await syncTokenToServer();

    // Token refresh (VERY IMPORTANT)
    _fcm.onTokenRefresh.listen((newToken) async {
      print("🔁 FCM Token refreshed: $newToken");
      await syncTokenToServer(tokenOverride: newToken);
    });

    // Foreground messages -> show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && (android != null || Platform.isIOS)) {
        showRemoteNotification(notification, message.data);
      }
    });

    // Click from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data);
    });

    // Click from terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }
  }

  /// Call this after login too (and it’s safe to call multiple times)
  Future<void> syncTokenToServer({String? tokenOverride}) async {
    final token = tokenOverride ?? await _fcm.getToken();
    if (token == null) return;

    try {
      // This should call POST /users/fcm-token with auth header
      final userController = Get.find<UserController>();
      await userController.saveDeviceToken(token);
      print("✅ Token synced to backend");
    } catch (e) {
      print("⚠️ Could not sync token now (user not ready/logged out): $e");
    }
  }

  Future<void> showRemoteNotification(
      RemoteNotification notification,
      Map<String, dynamic> payload,
      ) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'otoNav system alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(payload),
    );
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    const generalChannel = AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'otoNav system alerts',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      // _handleNavigation(data);
    } catch (_) {
      // ignore
    }
  }
/*
  void _handleNavigation(Map<String, dynamic> data) {
    // You decide your payload contract from backend.
    // Example:
    // { "type": "order", "orderId": "123", "status": "picked_up" }

    final type = data['type'];

    if (type == 'order' && data['orderId'] != null) {
      Get.toNamed(AppRoutes.orderDetails, arguments: {
        "orderId": data['orderId'],
      });
      return;
    }

    // fallback
    Get.offAllNamed(AppRoutes.homeScreen);
  }*/
}

