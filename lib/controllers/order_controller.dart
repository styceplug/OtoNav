import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  List<OrderModel> _allOrders = [];
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  WebSocketChannel? _channel;
  StreamSubscription<Position>? _positionStream;
  Rx<LatLng?> currentRiderLatLng = Rx<LatLng?>(null);
  Rx<OrderModel?> trackingOrder = Rx<OrderModel?>(null);
  AppController  appController = Get.find<AppController>();


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOrders();
    });
  }

  @override
  void onClose() {
    _stopTracking();
    super.onClose();
  }






  Future<void> startCustomerTracking(String orderId) async {
    // 1. Fetch latest order details first
    await getOrderDetails(orderId);

    // 2. Get User ID for connection
    String userId = Get.find<UserController>().userModel.value!.id!;

    // 3. Connect to WebSocket as 'customer'
    // Ensure you use the correct URL format from your docs
    final wsUrl = Uri.parse('wss://otonav-backend-production.up.railway.app?orderId=$orderId&userId=$userId&role=customer');

    print("🔌 Connecting to WS: $wsUrl");

    try {
      _channel = IOWebSocketChannel.connect(wsUrl);

      // 4. Listen for INCOMING messages (Rider's location)
      _channel!.stream.listen((message) {
        print("📩 Received WS Message: $message");

        try {
          final data = jsonDecode(message);

          if (data['type'] == 'location_update' && data['location'] != null) {
            // Parse "lat,lng" string
            String loc = data['location'];
            List<String> coords = loc.split(',');
            double lat = double.parse(coords[0]);
            double lng = double.parse(coords[1]);

            // Update the Observable (This triggers the Map UI update)
            currentRiderLatLng.value = LatLng(lat, lng);
          }

          if (data['type'] == 'status_update') {
            getOrderDetails(orderId);
          }
        } catch (e) {
          print("Error parsing WS message: $e");
        }
      }, onError: (error) {
        print("WS Error: $error");
      }, onDone: () {
        print("WS Closed");
      });

    } catch (e) {
      print("WS Connection failed: $e");
    }
  }
  void stopTracking() {
    _channel?.sink.close();
    _channel = null;
    print("🛑 Tracking Stopped");
  }

  Future<void> getOrderDetails(String orderId) async {
    trackingOrder.value = null;
    print('fetching order details....');

    Response response = await orderRepo.getOrderDetails(orderId);

    if (response.statusCode == 200 && response.body['success'] == true) {
      trackingOrder.value = OrderModel.fromJson(response.body['data']);
      update();
    } else {
      CustomSnackBar.failure(message: response.body['message'] ?? "Failed to load order");
    }
  }

  Future<void> confirmDelivery(String orderId) async {
    loader.showLoader();
    Response response = await orderRepo.confirmDelivery(orderId);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      await getOrders();
      CustomSnackBar.success(message: "Delivery Confirmed!");
      Get.offNamed(AppRoutes.riderHomeScreen);
      appController.changeCurrentAppPage(0);
    } else {
      CustomSnackBar.failure(message: response.body['message']);
    }
  }

  void _stopTracking() {
    _positionStream?.cancel();
    _channel?.sink.close();
    _positionStream = null;
    _channel = null;
    print("🛑 Tracking Stopped");
  }

  Future<void> markArrived(String orderId) async {
    loader.showLoader();
    Response response = await orderRepo.markArrived(orderId);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      await getOrders();
      _stopTracking();
      CustomSnackBar.success(message: "You have arrived at the destination.");
    } else {
      CustomSnackBar.failure(message: response.body['message']);
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {

      // 1. Update the Observable for the UI
      currentRiderLatLng.value = LatLng(position.latitude, position.longitude);

      // 2. Send to WebSocket (Existing logic)
      if (_channel != null) {
        final msg = jsonEncode({
          "coords": "${position.latitude},${position.longitude}"
        });
        _channel!.sink.add(msg);
      }
    });
  }

  void _initWebSocket(String orderId, String userId) {

    final wsUrl = Uri.parse('wss://otonav-backend-production.up.railway.app?orderId=$orderId&userId=$userId&role=rider');

    _channel = IOWebSocketChannel.connect(wsUrl);

    // 3. Start Geolocation Stream
    _startLocationUpdates();
  }

  Future<void> startDelivery(String orderId, String userId) async {
    loader.showLoader();
    Response response = await orderRepo.startDelivery(orderId);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      await getOrders();
      CustomSnackBar.success(message: "Delivery started. Location sharing active.");

      _initWebSocket(orderId, userId);
    } else {
      CustomSnackBar.failure(message: response.body['message']);
    }
  }

  Future<void> markPackagePickedUp(String orderId) async {
    loader.showLoader();
    Response response = await orderRepo.markPackagePickedUp(orderId);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      await getOrders();
      CustomSnackBar.success(message: "Package marked as picked up.");
    } else {
      CustomSnackBar.failure(message: response.body['message']);
    }
  }

  Future<void> acceptOrder(String orderId) async {
    loader.showLoader();
    update();

    try {
      // 1. Get Current Location
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

      // 2. Call API
      Response response = await orderRepo.acceptOrder(orderId, locationString);

      if (response.statusCode == 200 && response.body['success'] == true) {
        CustomSnackBar.success(
          message: "Order Accepted! Head to the pickup location.",
        );
        await getOrders();
        OrderModel order = _allOrders.firstWhere((o) => o.id == orderId);
        Get.toNamed(AppRoutes.riderTrackingScreen,arguments: order);
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
      await getOrders(); // Refresh list
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
    loader.showLoader();
    update();

    Response response = await orderRepo.getOrders();

    if (response.statusCode == 200 && response.body['success'] == true) {
      _allOrders = [];
      List<dynamic> data = response.body['data'];
      data.forEach((element) {
        _allOrders.add(OrderModel.fromJson(element));
      });
    } else {
      print("Error fetching orders: ${response.statusText}");
    }

    loader.hideLoader();
    update();
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
      return s == 'confirmed' || s == 'rider_accepted' || s == 'package_picked_up' || s == 'in_transit' || s == 'arrived_at_location';
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
