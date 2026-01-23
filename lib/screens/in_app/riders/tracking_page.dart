import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

import '../../../controllers/order_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../model/order_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/colors.dart';

enum OrderStage { pickup, startTrip, inTransit, arrived }

class TrackingPage extends StatefulWidget {
  final String orderId;

  const TrackingPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _destinationLatLng;
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _destIcon;
  Set<Polyline> _polylines = {};
  String _distance = '';
  String _duration = '';
  bool _isMapAssetsLoaded = false;

  final String googleApiKey = "AIzaSyBHCvfuITDTbiNlpKh6mN75mt2o_eqTYow";

  void _showSuccessPopup(OrderController controller, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppConstants.getPngAsset('delivered')),
            SizedBox(height: Dimensions.height20),
            Text(
              "Mark Order as Delivered?",
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                        ),
                        child: Icon(
                          Iconsax.location,
                          color: AppColors.white,
                          size: Dimensions.iconSize16,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Location',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              order.customerLocationPrecise ??
                                  "Delivery Location",
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                        ),
                        child: Icon(
                          Iconsax.location,
                          color: AppColors.white,
                          size: Dimensions.iconSize16,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pick Up Location',
                              style: TextStyle(
                                fontSize: Dimensions.font13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              order.organization?.address ?? 'Loading...',
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimensions.height20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IntrinsicWidth(
                  child: CustomButton(
                    text: "Get Back",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    textStyle: TextStyle(
                      fontSize: Dimensions.font14,
                      color: AppColors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                  ),
                ),

                IntrinsicWidth(
                  child: CustomButton(
                    text: "Mark as Delivered",
                    onPressed: () {
                      Navigator.pop(context);
                      controller.confirmDelivery(order.id!);
                    },
                    backgroundColor: Color(0xFF34C759),
                    textStyle: TextStyle(
                      fontSize: Dimensions.font14,
                      color: AppColors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().getOrderDetails(widget.orderId);
    });
    super.initState();
  }

  Future<void> _loadMapAssets(OrderModel order) async {
    if (_isMapAssetsLoaded) return; // Run once

    // 1. Create Icons
    _riderIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
    _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    // 2. Geocode Address from the fetched order
    String address = order.customerLocationPrecise ?? "";

    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _destinationLatLng = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
            _markers.add(
              Marker(
                markerId: MarkerId('destination'),
                position: _destinationLatLng!,
                icon: _destIcon!,
                infoWindow: InfoWindow(title: "Customer Location"),
              ),
            );
            _isMapAssetsLoaded = true;
          });
        }
      } catch (e) {
        print("Error geocoding address: $e");
      }
    }
  }

  void _getRoute(LatLng riderPos) async {
    if (_destinationLatLng == null) return;

    try {
      // 1. Request Directions from Google
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${riderPos.latitude},${riderPos.longitude}&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&mode=driving&key=$googleApiKey";

      var response = await Dio().get(url);

      if (response.data['status'] == 'OK') {
        var route = response.data['routes'][0];
        var leg = route['legs'][0];

        // 2. Extract Duration & Distance
        setState(() {
          _distance = leg['distance']['text']; // e.g., "5.2 km"
          _duration = leg['duration']['text']; // e.g., "15 mins"
        });

        // 3. Decode Polyline Points
        PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);
        List<PointLatLng> result = PolylinePoints.decodePolyline(
          route['overview_polyline']['points'],
        );

        List<LatLng> polylineCoordinates = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // 4. Draw the Blue Line
        setState(() {
          _polylines = {
            Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: AppColors.primaryColor, // Or Colors.blue
              width: 5,
            ),
          };
        });
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  void _updateRiderMarker(LatLng pos) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'rider');

      _markers.add(
        Marker(
          markerId: MarkerId('rider'),
          position: pos,
          icon: _riderIcon!,
          rotation: 0,
          // You can calculate bearing if needed
          infoWindow: InfoWindow(title: "You"),
        ),
      );
    });

    // Move Camera to follow rider
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    _getRoute(pos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (controller) {
          OrderModel? currentOrder = controller.trackingOrder.value;

          String status = currentOrder?.status ?? 'unknown';

          String buttonText = '';
          String titleText = '';
          String addressText = '';

          if (status == 'confirmed' || status == 'rider_accepted') {
            buttonText = 'Mark Package as Picked up';
            titleText = 'Pickup Address';
            addressText = currentOrder?.organization?.address ?? "Pickup";
          } else if (status == 'package_picked_up') {
            buttonText = 'Start Trip';
            titleText = 'Delivery Address';
            addressText = currentOrder?.customerLocationPrecise ?? "";
          } else if (status == 'in_transit') {
            buttonText = 'I have arrived';
            titleText = 'Delivery Address';
            addressText = currentOrder?.customerLocationPrecise ?? "";
          } else if (status == 'arrived_at_location') {
            buttonText = 'Mark as Delivered';
            titleText = 'Delivery Address';
            addressText = currentOrder?.customerLocationPrecise ?? "";
          } else {
            buttonText = 'Loading...';
            titleText = 'Order Status: $status';
            addressText = '';
          }

          return Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Obx(() {
                    // Listen to Rider Location Updates from Controller
                    LatLng? riderPos = controller.currentRiderLatLng.value;

                    // If we have a new position, update map markers
                    if (riderPos != null && _mapController != null) {
                      // We use a post-frame callback to avoid build conflicts
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateRiderMarker(riderPos);
                      });
                    }

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: riderPos ?? LatLng(37.7749, -122.4194),
                        zoom: 15,
                      ),
                      polylines: _polylines,
                      markers: _markers,
                      myLocationEnabled: false,
                      // We render our own custom marker
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        if (riderPos != null) {
                          _updateRiderMarker(riderPos);
                        }
                      },
                    );
                  }),
                ),

                Positioned(
                  bottom: Dimensions.height10 * 8,
                  left: Dimensions.width20,
                  right: Dimensions.width20,
                  child: Container(
                    width: Dimensions.screenWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height30,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              size: Dimensions.iconSize16,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: Dimensions.width5),
                            Text(
                              addressText,
                              style: TextStyle(
                                fontSize: Dimensions.font12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        if (_duration.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height20),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black, // Dark badge
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "$_duration • $_distance",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: Dimensions.height20),
                        CustomButton(
                          text: buttonText,
                          onPressed: () {
                            // Pass the CURRENT order status logic
                            String userId =
                                Get.find<UserController>().userModel.value!.id!;
                            String? orderId = currentOrder?.id!;

                            if (status == 'confirmed' ||
                                status == 'rider_accepted') {
                              controller.markPackagePickedUp(orderId!);
                            } else if (status == 'package_picked_up') {
                              controller.startDelivery(orderId!, userId);
                            } else if (status == 'in_transit') {
                              controller.markArrived(orderId!);
                            } else if (status == 'arrived_at_location') {
                              _showSuccessPopup(controller, currentOrder!);
                            }
                          },
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10,
                          ),
                          backgroundColor: AppColors.accentColor,
                          textStyle: TextStyle(
                            fontSize: Dimensions.font14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
