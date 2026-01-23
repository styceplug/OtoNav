import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/order_controller.dart';
import '../../../model/order_model.dart';
import '../../../utils/colors.dart';

class CustomerTrackingPage extends StatefulWidget {
  final String orderId;
  const CustomerTrackingPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<CustomerTrackingPage> createState() => _CustomerTrackingPageState();
}

class _CustomerTrackingPageState extends State<CustomerTrackingPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _destinationLatLng;
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _destIcon;

  String _distance = '';
  String _duration = '';
  bool _isMapAssetsLoaded = false;
  final String googleApiKey = "YOUR_API_KEY"; // Use your key

  @override
  void initState() {
    super.initState();
    // Start Tracking Immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().startCustomerTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    Get.find<OrderController>().stopTracking(); // Cleanup
    super.dispose();
  }

  Future<void> _loadMapAssets(OrderModel order) async {
    if (_isMapAssetsLoaded) return;

    // Use specific icons if you have them (e.g., bike icon for rider)
    _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    String address = order.customerLocationPrecise ?? "";
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _destinationLatLng = LatLng(locations.first.latitude, locations.first.longitude);
            _markers.add(Marker(
              markerId: MarkerId('destination'),
              position: _destinationLatLng!,
              icon: _destIcon!,
              infoWindow: InfoWindow(title: "My Location"),
            ));
            _isMapAssetsLoaded = true;
          });
        }
      } catch (e) {
        print("Error geocoding: $e");
      }
    }
  }

  void _getRoute(LatLng riderPos) async {
    if (_destinationLatLng == null) return;
    // ... (Reuse the exact same route logic from Rider Tracking Page) ...
    // Make sure to populate _distance and _duration variables
  }

  void _updateRiderMarker(LatLng pos) {
    if (!mounted) return;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'rider');
      _markers.add(Marker(
        markerId: MarkerId('rider'),
        position: pos,
        icon: _riderIcon!,
        infoWindow: InfoWindow(title: "Rider"),
      ));
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    _getRoute(pos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (controller) {
          OrderModel? currentOrder = controller.trackingOrder.value;

          if (currentOrder == null || currentOrder.id != widget.orderId) {
            return Center(child: CircularProgressIndicator());
          }

          if (!_isMapAssetsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadMapAssets(currentOrder));
          }

          // Get Rider Details safely
          String riderName = currentOrder.rider?.name ?? "Assigned Rider";
          String riderPhone = currentOrder.rider?.phoneNumber ?? "";

          return Stack(
            children: [
              // 1. MAP
              SizedBox.expand(
                child: Obx(() {
                  LatLng? riderPos = controller.currentRiderLatLng.value;
                  // Fallback to static location if WS hasn't sent data yet
                  if (riderPos == null && currentOrder.riderCurrentLocation != null) {
                    // Parse "lat,lng" from API string if available
                    var parts = currentOrder.riderCurrentLocation!.split(',');
                    if(parts.length == 2) riderPos = LatLng(double.parse(parts[0]), double.parse(parts[1]));
                  }

                  if (riderPos != null && _mapController != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _updateRiderMarker(riderPos!));
                  }

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: riderPos ?? _destinationLatLng ?? LatLng(37.77, -122.41),
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true, // Show customer's own blue dot
                    onMapCreated: (c) {
                      _mapController = c;
                      if(riderPos != null) _updateRiderMarker(riderPos);
                    },
                  );
                }),
              ),

              // 2. BACK BUTTON
              Positioned(
                top: 50,
                left: 20,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)),
                ),
              ),

              // 3. RIDER DETAILS CARD
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status & ETA Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("On the way", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                              if (_duration.isNotEmpty)
                                Text("Arriving in $_duration", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          // Distance Badge
                          if (_distance.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                              child: Text(_distance, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(),
                      SizedBox(height: 15),

                      // Rider Info Row
                      Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(AppConstants.getPngAsset('profile-icon')),
                          ),
                          SizedBox(width: 15),

                          // Name & Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(riderName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text("Reliable Rider", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),

                          // Call Button
                          InkWell(
                            onTap: () async {
                              if (riderPhone.isNotEmpty) {
                                final Uri launchUri = Uri(scheme: 'tel', path: riderPhone);
                                await launchUrl(launchUri);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Iconsax.call, color: Colors.green),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
