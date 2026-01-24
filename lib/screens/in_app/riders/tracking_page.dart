import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:otonav/utils/app_constants.dart';
import '../../../controllers/order_controller.dart';
import '../../../helpers/route_helper.dart';
import '../../../model/order_model.dart';
import '../../../utils/colors.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class RiderTrackingPage extends StatefulWidget {
  final String orderId;

  const RiderTrackingPage({super.key, required this.orderId});

  @override
  State<RiderTrackingPage> createState() => _RiderTrackingPageState();
}

class _RiderTrackingPageState extends State<RiderTrackingPage> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? _destinationLatLng;
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _destIcon;

  String _distance = '';
  String _duration = '';
  bool _assetsLoaded = false;

  final RouteHelper _routeHelper = RouteHelper(
    googleApiKey: "AIzaSyBHCvfuITDTbiNlpKh6mN75mt2o_eqTYow",
  );

  late Worker _posWorker;
  late Worker _orderWorker;

  @override
  void initState() {
    super.initState();

    final controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.startRiderTracking(widget.orderId);
    });

    _orderWorker = ever<OrderModel?>(controller.trackingOrder, (order) {
      if (order == null) return;
      _loadAssetsAndDestination(order);
    });

    _posWorker = ever<LatLng?>(controller.currentRiderLatLng, (pos) {
      if (pos == null) return;

      _riderIcon ??= BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      );

      _updateRiderMarker(pos);

      // Trigger route calculation when we have both positions
      if (_destinationLatLng != null) {
        _fetchRoute(pos);
      }
    });
  }

  @override
  void dispose() {
    _routeHelper.dispose();
    _posWorker.dispose();
    _orderWorker.dispose();
    super.dispose();
  }

  Future<LatLng?> geocodeWithGoogle(String address, String apiKey) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey";

      final res = await Dio().get(url);
      final status = res.data['status'];

      if (status != "OK") {
        print("❌ Geocode failed: $status");
        return null;
      }

      final loc = res.data['results'][0]['geometry']['location'];
      return LatLng(loc['lat'], loc['lng']);
    } catch (e) {
      print("❌ Geocode exception: $e");
      return null;
    }
  }

  Future<void> _loadAssetsAndDestination(OrderModel order) async {
    if (_assetsLoaded) return;

    _riderIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      AppConstants.getPngAsset('delivery-bike-2'),
    );
    _destIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      AppConstants.getPngAsset('masculine-user'),
    );

    final address = order.customerLocationPrecise ?? "";
    if (address.isEmpty) {
      setState(() => _assetsLoaded = true);
      return;
    }

    try {
      final dest = await geocodeWithGoogle(address, _routeHelper.googleApiKey);
      if (dest == null) {
        print("❌ Failed to geocode destination");
        setState(() => _assetsLoaded = true);
        return;
      }

      if (!mounted) return;

      setState(() {
        _destinationLatLng = dest;
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: dest,
            icon: _destIcon!,
            infoWindow: const InfoWindow(title: "Delivery Location"),
          ),
        );
        _assetsLoaded = true;
      });

      // Move camera to show both markers
      _fitMapToBounds();

      // Fetch initial route if rider position already exists
      final riderPos = Get.find<OrderController>().currentRiderLatLng.value;
      if (riderPos != null) {
        _fetchRoute(riderPos);
      }
    } catch (e) {
      print("❌ Geocode error: $e");
      setState(() => _assetsLoaded = true);
    }
  }


  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLon = (end.longitude - start.longitude) * pi / 180;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  void _updateRiderMarker(LatLng pos) {
    if (!mounted) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'rider');
      _markers.add(
        Marker(
          markerId: const MarkerId('rider'),
          position: pos,
          icon: _riderIcon!,
          infoWindow: const InfoWindow(title: "You"),
          flat: true,
          // rotation: _calculateBearing(oldPos, pos)
        ),
      );
    });

    // Update camera to follow rider
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(pos),
    );
  }

  void _fetchRoute(LatLng origin) {
    if (_destinationLatLng == null) return;

    _routeHelper.debounceRoute(
      origin: origin,
      destination: _destinationLatLng!,
      onResult: (distance, duration, points) {
        if (!mounted) return;
        setState(() {
          _distance = distance;
          _duration = duration;
          _polylines = {
            Polyline(
              polylineId: const PolylineId("route"),
              points: points,
              width: 5,
              color: AppColors.success,
            ),
          };
        });
      },
    );
  }

  void _fitMapToBounds() {
    if (_mapController == null) return;

    final riderPos = Get.find<OrderController>().currentRiderLatLng.value;
    if (riderPos == null || _destinationLatLng == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(riderPos.latitude, _destinationLatLng!.latitude),
        min(riderPos.longitude, _destinationLatLng!.longitude),
      ),
      northeast: LatLng(
        max(riderPos.latitude, _destinationLatLng!.latitude),
        max(riderPos.longitude, _destinationLatLng!.longitude),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (controller) {
          final order = controller.trackingOrder.value;
          if (order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = order.status ?? 'unknown';

          String buttonText = '...';
          String titleText = '';
          String addressText = '';

          if (status == 'confirmed' || status == 'rider_accepted') {
            buttonText = 'Mark Package as Picked up';
            titleText = 'Pickup Address';
            addressText = order.organization?.address ?? "Pickup";
          } else if (status == 'package_picked_up') {
            buttonText = 'Start Trip';
            titleText = 'Delivery Address';
            addressText = order.customerLocationPrecise ?? "";
          } else if (status == 'in_transit') {
            buttonText = 'I have arrived';
            titleText = 'Delivery Address';
            addressText = order.customerLocationPrecise ?? "";
          } else if (status == 'arrived_at_location') {
            buttonText = 'Mark as Delivered';
            titleText = 'Delivery Address';
            addressText = order.customerLocationPrecise ?? "";
          } else {
            titleText = 'Order Status: $status';
          }

          final riderPos = controller.currentRiderLatLng.value;

          return SafeArea(
            bottom: true,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: riderPos ??
                          _destinationLatLng ??
                          const LatLng(6.5244, 3.3792),
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (c) {
                      _mapController = c;
                      // Fit bounds once map is created if we have both positions
                      if (riderPos != null && _destinationLatLng != null) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _fitMapToBounds();
                        });
                      }
                    },
                  ),
                ),
            
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                addressText,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (_duration.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$_duration • $_distance",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final orderId = order.id!;
                              if (status == 'confirmed' ||
                                  status == 'rider_accepted') {
                                await controller.markPackagePickedUp(orderId);
                              } else if (status == 'package_picked_up') {
                                await controller.startDelivery(orderId);
                              } else if (status == 'in_transit') {
                                await controller.markArrived(orderId);
                              } else if (status == 'arrived_at_location') {
                                await controller.confirmDelivery(orderId);
                              }
                            },
                            child: Text(buttonText),
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