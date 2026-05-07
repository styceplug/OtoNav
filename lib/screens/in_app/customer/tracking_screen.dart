import 'dart:math';
import 'dart:math' as math;

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

class _CustomerTrackingPageState extends State<CustomerTrackingPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final OSMHelper _osmHelper = OSMHelper();

  LatLng? _destinationLatLng;
  List<LatLng> _routePoints = [];
  String _distance = '';
  String _duration = '';
  int _stopsAway = 0; // Tracking Junctions/Stops

  bool _isDestLoaded = false;
  bool _isMapReady = false;

  late Worker _posWorker;
  late Worker _orderWorker;
  DateTime? _lastRouteFetch;

  // Animation & Rotation Variables
  AnimationController? _animController;
  LatLng? _oldPos;
  LatLng? _interpolatedPos;
  double _bikeBearing = 0.0;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.startCustomerTracking(widget.orderId);
    });

    _orderWorker = ever<OrderModel?>(controller.trackingOrder, (order) {
      if (order != null && !_isDestLoaded) {
        _loadDestination(order);
      }
    });

    _posWorker = ever<LatLng?>(controller.currentRiderLatLng, (pos) {
      if (pos != null) {
        _animateBikeToNewPosition(pos);
        _updateCamera(pos);
      }
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    _posWorker.dispose();
    _orderWorker.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --- Animation & Bearing Logic ---
  void _animateBikeToNewPosition(LatLng newPos) {
    if (_oldPos == null) {
      setState(() {
        _interpolatedPos = newPos;
        _oldPos = newPos;
      });
      return;
    }

    if (_oldPos!.latitude == newPos.latitude && _oldPos!.longitude == newPos.longitude) return;

    _bikeBearing = _calculateBearing(_oldPos!, newPos);

    _animController?.dispose();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    final latTween = Tween<double>(begin: _oldPos!.latitude, end: newPos.latitude);
    final lngTween = Tween<double>(begin: _oldPos!.longitude, end: newPos.longitude);

    _animController!.addListener(() {
      setState(() {
        _interpolatedPos = LatLng(latTween.evaluate(_animController!), lngTween.evaluate(_animController!));
      });
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) _oldPos = newPos;
    });

    _animController!.forward();
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final lng1 = start.longitude * math.pi / 180;
    final lng2 = end.longitude * math.pi / 180;

    final y = math.sin(lng2 - lng1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(lng2 - lng1);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<void> _loadDestination(OrderModel order) async {
    // ✅ Use the direct coordinates from the model!
    if (order.customerLocationLat == null || order.customerLocationLng == null) return;

    final dest = LatLng(order.customerLocationLat!, order.customerLocationLng!);

    if (!mounted) return;

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

  void _updateCamera(LatLng riderPos) {
    if (!mounted || !_isMapReady) return;
    _mapController.move(riderPos, _mapController.camera.zoom);

    if (_destinationLatLng != null) {
      final now = DateTime.now();
      if (_lastRouteFetch == null || now.difference(_lastRouteFetch!).inSeconds > 10) {
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
      _stopsAway = result['stops'] ?? 0; // Extract stops
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

  // Formatting the stops away text
  String get _stopsText {
    if (_stopsAway <= 0) return "Arriving shortly";
    if (_stopsAway > 9) return "9+ junctions away";
    return "$_stopsAway junction${_stopsAway > 1 ? 's' : ''} away";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (ctrl) {
          final order = ctrl.trackingOrder.value;
          if (order == null) return const Center(child: CircularProgressIndicator());

          final initialCenter = _interpolatedPos ?? ctrl.currentRiderLatLng.value ?? const LatLng(6.5244, 3.3792);

          return Stack(
            children: [
              // ── MAP ────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 15.0,
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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.otonav.app',
                  ),
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
                  // Standard MarkerLayer driven by AnimationController's setState
                  MarkerLayer(
                    markers: [
                      if (_destinationLatLng != null)
                        Marker(
                          point: _destinationLatLng!,
                          width: 40, height: 40,
                          child: Image.asset(AppConstants.getPngAsset('masculine-user')),
                        ),
                      // Animated & Rotated Rider Marker
                      if (_interpolatedPos != null)
                        Marker(
                          point: _interpolatedPos!,
                          width: 50, height: 50,
                          child: Transform.rotate(
                            angle: _bikeBearing * (math.pi / 180),
                            child: Image.asset(AppConstants.getPngAsset('delivery-bike-2')),
                          ),
                        ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [TextSourceAttribution('OpenStreetMap contributors', onTap: () {})],
                  ),
                ],
              ),

              // ── BACK BUTTON ─────────────────────────────────────────────
              Positioned(
                top: 50, left: 20,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),

              // ── RIDER DETAILS CARD ───────────────────────────────────────
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
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
                              Text(
                                _duration.isNotEmpty ? _stopsText : "Connecting...",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              if (_duration.isNotEmpty)
                                Text(
                                  "Arriving in $_duration",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                )
                            ],
                          ),
                          if (_distance.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _distance,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  "Verified Rider",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (order.rider?.phoneNumber != null) {
                                // launchUrl logic
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.call, color: AppColors.success),
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

