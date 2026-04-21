import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../controllers/order_controller.dart';
import '../../../helpers/route_helper.dart';
import '../../../model/order_model.dart';
import '../../../utils/colors.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;


class RiderTrackingPage extends StatefulWidget {
  final String orderId;
  const RiderTrackingPage({super.key, required this.orderId});

  @override
  State<RiderTrackingPage> createState() => _RiderTrackingPageState();
}


class _RiderTrackingPageState extends State<RiderTrackingPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final OSMHelper _osmHelper = OSMHelper();

  LatLng? _destinationLatLng;
  List<LatLng> _routePoints = [];
  String _distance = '';
  String _duration = '';

  // TURN-BY-TURN VARIABLES
  String _nextInstruction = '';
  String _stepDistance = '';

  bool _isDestLoaded = false;
  bool _isMapReady = false;

  late Worker _posWorker;
  late Worker _orderWorker;
  DateTime? _lastRouteFetch;

  // Animation Variables
  AnimationController? _animController;
  LatLng? _oldPos;
  LatLng? _interpolatedPos;
  double _bikeBearing = 0.0;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.startRiderTracking(widget.orderId);
    });

    _orderWorker = ever<OrderModel?>(controller.trackingOrder, (order) {
      if (order != null && !_isDestLoaded) {
        _loadDestination(order);
      }
    });

    _posWorker = ever<LatLng?>(controller.currentRiderLatLng, (newPos) {
      if (newPos != null) {
        _animateBikeToNewPosition(newPos);
        _updateCamera(newPos);
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

  // --- External Navigation Launcher ---
  Future<void> _openInNativeMaps() async {
    if (_destinationLatLng == null) return;

    // Universal URL that opens Google Maps app (or Apple Maps on iOS if Google isn't installed)
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&travelmode=driving';

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Could not open map application");
      }
    } catch (e) {
      print("Error launching maps: $e");
    }
  }

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
    }
  }

  void _updateCamera(LatLng riderPos) {
    if (!mounted || !_isMapReady) return;

    // Zoomed in slightly tighter (17.5) for that driving feel
    _mapController.move(riderPos, 17.5);

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
      _nextInstruction = result['instruction'] ?? '';
      _stepDistance = result['stepDistance'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Scaffold(
      body: GetBuilder<OrderController>(
        builder: (ctrl) {
          final order = ctrl.trackingOrder.value;
          if (order == null) return const Center(child: CircularProgressIndicator());

          final status = order.status ?? 'unknown';
          String buttonText = '...';
          String titleText = '';
          String addressText = '';

          if (status == 'confirmed' || status == 'rider_accepted') {
            buttonText = 'Mark Package as Picked Up';
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
          }

          final initialCenter = _interpolatedPos ?? ctrl.currentRiderLatLng.value ?? const LatLng(9.0820, 8.6753);

          return Stack(
            children: [
              // ── 1. MAP ──────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 17.5, // Navigation zoom level
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  onMapReady: () {
                    _isMapReady = true;
                    final pos = controller.currentRiderLatLng.value;
                    if (pos != null) _updateCamera(pos);
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
                          color: Colors.blueAccent,
                          strokeWidth: 6.0,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_destinationLatLng != null)
                        Marker(
                          point: _destinationLatLng!,
                          width: 40, height: 40,
                          child: Image.asset(AppConstants.getPngAsset('masculine-user')),
                        ),
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
                ],
              ),

              // ── 2. TURN-BY-TURN OVERLAY ──────────────────────────────────
              if (_nextInstruction.isNotEmpty)
                Positioned(
                  top: 50, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.turn_right_rounded, color: Colors.white, size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _stepDistance.isNotEmpty ? "In $_stepDistance" : "Continue",
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _nextInstruction,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── 3. EXTERNAL MAPS BUTTON ──────────────────────────────────
              Positioned(
                bottom: 240, right: 20, // Floating right above the bottom card
                child: FloatingActionButton(
                  heroTag: "maps_btn",
                  backgroundColor: Colors.white,
                  onPressed: _openInNativeMaps,
                  child: const Icon(Icons.directions, color: Colors.blueAccent, size: 30),
                ),
              ),

              // ── 4. BOTTOM CARD ───────────────────────────────────────────
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(titleText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(addressText, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      if (_duration.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                          child: Text("$_duration • $_distance", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final id = order.id!;
                            if (status == 'confirmed' || status == 'rider_accepted') {
                              await ctrl.markPackagePickedUp(id);
                            } else if (status == 'package_picked_up') {
                              await ctrl.startDelivery(id);
                            } else if (status == 'in_transit') {
                              await ctrl.markArrived(id);
                            } else if (status == 'arrived_at_location') {
                              await ctrl.confirmDelivery(id);
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
          );
        },
      ),
    );
  }
}