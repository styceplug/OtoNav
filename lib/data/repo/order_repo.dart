import 'package:get/get.dart';
import 'package:otonav/utils/app_constants.dart';
import '../api/api_client.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;

  OrderRepo({required this.apiClient});


  Future<Response> getOrderDetails(String orderId) async {
    return await apiClient.getData(AppConstants.GET_SINGLE_ORDER(orderId));
  }

  Future<Response> markPackagePickedUp(String orderId) async {
    return await apiClient.postData(AppConstants.POST_PACKAGE_PICKED_UP(orderId), {});
  }

  Future<Response> startDelivery(String orderId) async {
    return await apiClient.postData(AppConstants.POST_START_DELIVERY(orderId), {});
  }

  Future<Response> markArrived(String orderId) async {
    return await apiClient.postData(AppConstants.POST_MARK_ARRIVED(orderId), {});
  }

  Future<Response> confirmDelivery(String orderId) async {
    return await apiClient.postData(AppConstants.POST_CONFIRM_DELIVERY(orderId), {});
  }

  Future<Response> acceptOrder(String orderId, String currentLocation) async {
    return await apiClient.postData(
        AppConstants.POST_RIDER_ACCEPT_DELIVERY(orderId),
        {"currentLocation": currentLocation}
    );
  }

  Future<Response> cancelOrder(String orderId) async {
    return await apiClient.deleteData(
        AppConstants.POST_RIDER_DECLINE_DELIVERY(orderId));
  }

  Future<Response> getOrders() async {
    return await apiClient.getData(AppConstants.GET_ORDERS_LIST);
  }

  Future<Response> setCustomerLocation(String orderId,
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.POST_SET_LOCATION(orderId), body);
  }
}