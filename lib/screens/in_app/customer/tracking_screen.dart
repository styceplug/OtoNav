import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../../controllers/order_controller.dart';
import '../../../helpers/route_helper.dart';
import '../../../model/order_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import 'dart:async';


class CustomerTrackingPage extends StatefulWidget {
  final String orderId;
  const CustomerTrackingPage({super.key, required this.orderId});

  @override
  State<CustomerTrackingPage> createState() => _CustomerTrackingPageState();
}

class _CustomerTrackingPageState extends State<CustomerTrackingPage> {
  final MapController _mapController = MapController();
  final OSMHelper _osmHelper = OSMHelper();

  LatLng? _destinationLatLng;
  List<LatLng> _routePoints = [];
  String _distance = '';
  String _duration = '';
  bool _isDestLoaded = false;
  bool _isMapReady = false;

  late Worker _posWorker;
  late Worker _orderWorker;
  DateTime? _lastRouteFetch;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.startCustomerTracking(widget.orderId);
    });

    // Load destination once order details arrive
    _orderWorker = ever<OrderModel?>(controller.trackingOrder, (order) {
      if (order != null && !_isDestLoaded) {
        _loadDestination(order);
      }
    });

    // Pan camera to rider on every position update
    _posWorker = ever<LatLng?>(controller.currentRiderLatLng, (pos) {
      if (pos != null) _updateCamera(pos);
    });
  }

  @override
  void dispose() {
    _posWorker.dispose();
    _orderWorker.dispose();
    super.dispose();
  }

  Future<void> _loadDestination(OrderModel order) async {
    final address = order.customerLocationPrecise ?? "";
    if (address.isEmpty) return;

    final dest = await _osmHelper.getCoordinatesFromAddress(address);
    if (!mounted || dest == null) return;

    setState(() {
      _destinationLatLng = dest;
      _isDestLoaded = true;
    });

    final riderPos = Get.find<OrderController>().currentRiderLatLng.value;
    if (riderPos != null) {
      _fetchRoute(riderPos, dest);
      if (_isMapReady) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _fitBounds(riderPos, dest);
        });
      }
    }
  }

  // Only moves the camera — marker position is driven by Obx reactively
  void _updateCamera(LatLng riderPos) {
    if (!mounted || !_isMapReady) return;
    _mapController.move(riderPos, _mapController.camera.zoom);

    if (_destinationLatLng != null) {
      final now = DateTime.now();
      if (_lastRouteFetch == null ||
          now.difference(_lastRouteFetch!).inSeconds > 10) {
        _fetchRoute(riderPos, _destinationLatLng!);
        _lastRouteFetch = now;
      }
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final result = await _osmHelper.getRoute(start, end);
    if (!mounted || result == null) return;
    setState(() {
      _routePoints = result['points'];
      _distance = result['distance'];
      _duration = result['duration'];
    });
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    if (!mounted || !_isMapReady) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(p1, p2),
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (ctrl) {
          final order = ctrl.trackingOrder.value;
          if (order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final initialCenter =
              ctrl.currentRiderLatLng.value ?? const LatLng(6.5244, 3.3792);

          return Stack(
            children: [
              // ── MAP ────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 14.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  onMapReady: () {
                    _isMapReady = true;
                    final pos = controller.currentRiderLatLng.value;
                    if (pos != null) _updateCamera(pos);
                    if (pos != null && _destinationLatLng != null) {
                      _fitBounds(pos, _destinationLatLng!);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.otonav.app',
                  ),

                  // Route polyline
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: AppColors.primaryColor,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),

                  // ✅ Obx wraps MarkerLayer so it rebuilds on EVERY
                  // currentRiderLatLng change without needing update()
                  Obx(() {
                    final riderPos = controller.currentRiderLatLng.value;
                    return MarkerLayer(
                      markers: [
                        if (_destinationLatLng != null)
                          Marker(
                            point: _destinationLatLng!,
                            width: 40,
                            height: 40,
                            child: Image.asset(
                                AppConstants.getPngAsset('masculine-user')),
                          ),
                        if (riderPos != null)
                          Marker(
                            point: riderPos,
                            width: 40,
                            height: 40,
                            child: Image.asset(
                                AppConstants.getPngAsset('delivery-bike-2')),
                          ),
                      ],
                    );
                  }),

                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors',
                          onTap: () {}),
                    ],
                  ),
                ],
              ),

              // ── BACK BUTTON ─────────────────────────────────────────────
              Positioned(
                top: 50,
                left: 20,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),

              // ── RIDER DETAILS CARD ───────────────────────────────────────
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
                          offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "On the way",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              if (_duration.isNotEmpty)
                                Text(
                                  "Arriving in $_duration",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              else
                                const Text(
                                  "Tracking shipment...",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          if (_distance.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _distance,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.rider?.name ?? "Assigned Rider",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  "Verified Rider",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (order.rider?.phoneNumber != null) {
                                // launchUrl logic here
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.call,
                                  color: AppColors.success),
                            ),
                          ),
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
