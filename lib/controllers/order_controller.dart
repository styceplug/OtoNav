import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:otonav/controllers/app_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/helpers/global_loader_controller.dart';
import 'package:otonav/routes/routes.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/repo/order_repo.dart';
import '../model/order_model.dart';
import '../widgets/snackbars.dart';
import 'package:geolocator/geolocator.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;

  OrderController({required this.orderRepo});

  RxList<OrderModel> _allOrders = <OrderModel>[].obs;
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  Rx<LatLng?> currentRiderLatLng = Rx<LatLng?>(null);
  Rx<OrderModel?> trackingOrder = Rx<OrderModel?>(null);
  AppController appController = Get.find<AppController>();
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  StreamSubscription<Position>? _posSub;
  var isFetchingOrders = false.obs;


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOrders();
    });
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  LatLng? parseLatLng(String? s) {
    if (s == null || !s.contains(',')) return null;
    final parts = s.split(',');
    if (parts.length < 2) return null;
    double? a = double.tryParse(parts[0].trim());
    double? b = double.tryParse(parts[1].trim());
    if (a == null || b == null) return null;
    return LatLng(a, b);
  }

  Uri _wsUrl({
    required String orderId,
    required String userId,
    required String role,
  }) {
    return Uri.parse(
      'wss://otonav-backend.onrender.com/ws'
          '?orderId=$orderId&userId=$userId&role=$role',
    );
  }

  Future<void> getOrderDetails(String orderId) async {
    final res = await orderRepo.getOrderDetails(orderId);

    if (res.statusCode == 200 && res.body['success'] == true) {
      final order = OrderModel.fromJson(res.body['data']);
      trackingOrder.value = order;

      final rider = parseLatLng(order.riderCurrentLocation);
      if (rider != null) {
        currentRiderLatLng.value = rider;
      }

      update(); // ✅ Notify GetBuilder
    } else {
      CustomSnackBar.failure(
        message: res.body['message'] ?? "Failed to load order",
      );
    }
  }

  void _connectWs({
    required String orderId,
    required String userId,
    required String role,
  }) {
    stopTracking();

    final url = _wsUrl(orderId: orderId, userId: userId, role: role);
    print("🔌 Connecting WS: $url");

    _channel = IOWebSocketChannel.connect(url);

    _wsSub = _channel!.stream.listen(
          (message) {
        print("📩 WS: $message");
        _handleWsMessage(orderId, message);
      },
      onError: (e) => print("❌ WS Error: $e"),
      onDone: () => print("🧯 WS Closed"),
      cancelOnError: false,
    );
  }

  void _handleWsMessage(String orderId, dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data is! Map) return;

      if (data['type'] == 'location_update') {
        final rider = parseLatLng(data['location']);
        if (rider != null) {
          currentRiderLatLng.value = rider;
          update(); // ✅ CRITICAL FIX: tell GetBuilder to rebuild the marker
        }
        return;
      }

      if (data['type'] == 'status_update') {
        getOrderDetails(orderId);
        return;
      }
    } catch (e) {
      print("⚠️ WS Parse Error: $e");
    }
  }

  void _sendCoords(LatLng pos) {
    if (_channel == null) return;
    final payload = jsonEncode({"coords": "${pos.latitude},${pos.longitude}"});
    _channel!.sink.add(payload);
    print("📤 WS SEND -> $payload");
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      CustomSnackBar.failure(message: "Location permission is required.");
      return false;
    }
    return true;
  }

  void _startRiderStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // ✅ reduced from 10 → 5m for more frequent updates
    );

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((p) {
      final pos = LatLng(p.latitude, p.longitude);
      currentRiderLatLng.value = pos;
      update(); // ✅ CRITICAL FIX: rebuild marker on own GPS update too
      _sendCoords(pos);
    });
  }

  Future<void> startCustomerTracking(String orderId) async {
    await getOrderDetails(orderId);
    final userId = Get.find<UserController>().userModel.value!.id!;
    _connectWs(orderId: orderId, userId: userId, role: 'customer');
  }

  Future<void> startRiderTracking(String orderId) async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    await getOrderDetails(orderId);
    final userId = Get.find<UserController>().userModel.value!.id!;
    _connectWs(orderId: orderId, userId: userId, role: 'rider');
    _startRiderStream();
  }

  void stopTracking() {
    _posSub?.cancel();
    _posSub = null;

    _wsSub?.cancel();
    _wsSub = null;

    _channel?.sink.close();
    _channel = null;

    print("🛑 Tracking stopped");
  }

  Future<void> markPackagePickedUp(String orderId) async {
    loader.showLoader();
    final res = await orderRepo.markPackagePickedUp(orderId);
    loader.hideLoader();

    if (res.statusCode == 200 && res.body['success'] == true) {
      await getOrderDetails(orderId);
      CustomSnackBar.success(message: "Package picked up.");
    } else {
      CustomSnackBar.failure(message: res.body['message']);
    }
  }

  Future<void> startDelivery(String orderId) async {
    loader.showLoader();
    final res = await orderRepo.startDelivery(orderId);
    loader.hideLoader();

    if (res.statusCode == 200 && res.body['success'] == true) {
      await getOrderDetails(orderId);
      CustomSnackBar.success(message: "Trip started.");
    } else {
      CustomSnackBar.failure(message: res.body['message']);
    }
  }

  Future<void> markArrived(String orderId) async {
    loader.showLoader();
    final res = await orderRepo.markArrived(orderId);
    loader.hideLoader();

    if (res.statusCode == 200 && res.body['success'] == true) {
      await getOrderDetails(orderId);
      CustomSnackBar.success(message: "Arrived at location.");
    } else {
      CustomSnackBar.failure(message: res.body['message']);
    }
  }

  Future<void> confirmDelivery(String orderId) async {
    loader.showLoader();
    final res = await orderRepo.confirmDelivery(orderId);
    loader.hideLoader();

    if (res.statusCode == 200 && res.body['success'] == true) {
      stopTracking();
      CustomSnackBar.success(message: "Delivery confirmed!");
      Get.offAllNamed(AppRoutes.riderHomeScreen);
      appController.changeCurrentAppPage(0);
    } else {
      CustomSnackBar.failure(message: res.body['message']);
    }
  }

  Future<void> startOwnerTracking(String orderId) async {
    await getOrderDetails(orderId);
    final userId = Get.find<UserController>().userModel.value!.id!;
    _connectWs(orderId: orderId, userId: userId, role: "owner");
  }

  Future<void> acceptOrder(String orderId) async {
    loader.showLoader();
    update();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CustomSnackBar.failure(
            message: "Location permission is required to accept orders.",
          );
          loader.hideLoader();
          update();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String locationString = "${position.latitude},${position.longitude}";

      Response response = await orderRepo.acceptOrder(orderId, locationString);

      if (response.statusCode == 200 && response.body['success'] == true) {
        CustomSnackBar.success(
          message: "Order Accepted! Head to the pickup location.",
        );
        await getOrders();
        OrderModel order = _allOrders.firstWhere((o) => o.id == orderId);
        Get.toNamed(AppRoutes.riderTrackingScreen, arguments: order);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? "Failed to accept order",
        );
      }
    } catch (e) {
      print(e);
      CustomSnackBar.failure(message: "Error fetching location.");
    }

    loader.hideLoader();
    update();
  }

  Future<void> cancelOrder(String orderId) async {
    loader.showLoader();
    update();

    Response response = await orderRepo.cancelOrder(orderId);

    if (response.statusCode == 200 && response.body['success'] == true) {
      CustomSnackBar.success(message: "Order cancelled successfully.");
      await getOrders();
    } else {
      CustomSnackBar.failure(
        message: response.body['message'] ?? "Failed to cancel order",
      );
    }

    loader.hideLoader();
    update();
  }

  Future<void> setOrderLocation(
      String orderId,
      String label,
      String preciseLocation,
      ) async {
    Map<String, dynamic> body = {
      "locationLabel": label,
      "locationPrecise": preciseLocation,
    };

    loader.showLoader();
    update();

    Response response = await orderRepo.setCustomerLocation(orderId, body);

    if (response.statusCode == 200 && response.body['success'] == true) {
      await getOrders();
      Get.back();
      CustomSnackBar.success(message: "Location set successfully!");
    } else {
      CustomSnackBar.failure(
        message: response.body['message'] ?? "Failed to set location",
      );
    }

    loader.hideLoader();
    update();
  }

  Future<void> getOrders() async {
    isFetchingOrders.value = true;
    Response response = await orderRepo.getOrders();

    if (response.statusCode == 200 && response.body['success'] == true) {
      _allOrders.clear();
      List<dynamic> data = response.body['data'];
      data.forEach((element) {
        _allOrders.add(OrderModel.fromJson(element));
      });
      update();
    } else {
      print("Error fetching orders: ${response.statusText}");
    }

    isFetchingOrders.value = false;
  }

  List<OrderModel> get pendingOrders {
    return _allOrders.where((order) {
      String s = order.status?.toLowerCase() ?? '';
      return s == 'pending' || s == 'customer_location_set';
    }).toList();
  }

  List<OrderModel> get confirmedOrders {
    return _allOrders.where((order) {
      String s = order.status?.toLowerCase() ?? '';
      return s == 'confirmed' ||
          s == 'rider_accepted' ||
          s == 'package_picked_up' ||
          s == 'in_transit' ||
          s == 'arrived_at_location';
    }).toList();
  }

  List<OrderModel> get deliveredOrders {
    return _allOrders.where((order) {
      String s = order.status?.toLowerCase() ?? '';
      return s == 'delivered';
    }).toList();
  }

  List<OrderModel> get cancelledOrders {
    return _allOrders.where((order) {
      String s = order.status?.toLowerCase() ?? '';
      return s == 'cancelled';
    }).toList();
  }
}
