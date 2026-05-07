import 'package:get/get.dart';
import 'package:otonav/utils/app_constants.dart';
import '../api/api_client.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;

  OrderRepo({required this.apiClient});

  //Verified Riders


  Future<Response> getActiveAssignments() async {
    return await apiClient.getData(AppConstants.GET_ACTIVE_ASSIGNMENTS_URI);
  }

  Future<Response> getPendingWaitlist() async {
    return await apiClient.getData(AppConstants.GET_WAITLIST);
  }

  Future<Response> acceptWaitlistOrder(
    String waitlistId,
    double lat,
    double lng,
  ) async {
    return await apiClient.postData(
      AppConstants.ACCEPT_ORDER_ON_WAITLIST(waitlistId),
      {
        "currentLocation": {"lat": lat, "lng": lng},
      },
    );
  }

  Future<Response> updateOrderStatus(
    String orderId,
    String status,
    String timestampField,
  ) async {
    return await apiClient.putData(
      AppConstants.UPDATE_VERIFIED_ORDER_STATUS(orderId),
      {"status": status, "timestampField": timestampField},
    );
  }

  Future<Response> updateOrderLocation(
    String orderId,
    double lat,
    double lng,
  ) async {
    return await apiClient.postData(
      AppConstants.UPDATE_VERIFIED_RIDER_LOCATION(orderId),
      {
        "currentLocation": {"lat": lat, "lng": lng},
      },
    );
  }

  //

  Future<Response> getOrderDetails(String orderId) async {
    return await apiClient.getData(AppConstants.GET_SINGLE_ORDER(orderId));
  }

  Future<Response> markPackagePickedUp(String orderId) async {
    return await apiClient.postData(
      AppConstants.POST_PACKAGE_PICKED_UP(orderId),
      {},
    );
  }

  Future<Response> startDelivery(String orderId) async {
    return await apiClient.postData(
      AppConstants.POST_START_DELIVERY(orderId),
      {},
    );
  }

  Future<Response> markArrived(String orderId) async {
    return await apiClient.postData(
      AppConstants.POST_MARK_ARRIVED(orderId),
      {},
    );
  }

  Future<Response> confirmDelivery(String orderId, String pin) async {
    return await apiClient.postData(
      AppConstants.POST_CONFIRM_DELIVERY(orderId),
      {
        "pin":pin
      },
    );
  }

  Future<Response> acceptOrder(String orderId, String currentLocation) async {
    return await apiClient.postData(
      AppConstants.POST_RIDER_ACCEPT_DELIVERY(orderId),
      {"currentLocation": currentLocation},
    );
  }

  Future<Response> cancelOrder(String orderId) async {
    return await apiClient.deleteData(
      AppConstants.POST_RIDER_DECLINE_DELIVERY(orderId),
    );
  }

  Future<Response> getOrders() async {
    return await apiClient.getData(AppConstants.GET_ORDERS_LIST);
  }

  Future<Response> setCustomerLocation(
    String orderId,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      AppConstants.POST_SET_LOCATION(orderId),
      body,
    );
  }
}
