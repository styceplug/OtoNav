import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/helpers/global_loader_controller.dart';
import 'package:otonav/routes/routes.dart';
import '../data/repo/order_repo.dart';
import '../model/order_model.dart';
import '../widgets/snackbars.dart';
import 'package:geolocator/geolocator.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;

  OrderController({required this.orderRepo});

  List<OrderModel> _allOrders = [];
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOrders();
    });
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
        Get.toNamed(AppRoutes.riderTrackingScreen);
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
      return s == 'confirmed';
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
