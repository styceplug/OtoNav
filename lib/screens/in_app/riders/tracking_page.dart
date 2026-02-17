import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/utils/app_constants.dart';
import '../../../controllers/order_controller.dart';
import '../../../helpers/route_helper.dart';
import '../../../model/order_model.dart';
import '../../../utils/colors.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class RiderTrackingPage extends StatefulWidget {
  final String orderId;
  const RiderTrackingPage({super.key, required this.orderId});

  @override
  State<RiderTrackingPage> createState() => _RiderTrackingPageState();
}

class _RiderTrackingPageState extends State<RiderTrackingPage> {
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
      await controller.startRiderTracking(widget.orderId);
    });

    _orderWorker = ever<OrderModel?>(controller.trackingOrder, (order) {
      if (order != null && !_isDestLoaded) {
        _loadDestination(order);
      }
    });

    // Pan camera to own GPS position on every update
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
        padding: const EdgeInsets.all(50),
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

          final initialCenter =
              ctrl.currentRiderLatLng.value ?? const LatLng(9.0820, 8.6753);

          return Stack(
            children: [
              // ── MAP ──────────────────────────────────────────────────────
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
                          color: Colors.blue,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),

                  // ✅ Obx so the rider marker updates on every GPS ping
                  // without needing a full GetBuilder rebuild
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

              // ── BOTTOM CARD ──────────────────────────────────────────────
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              addressText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (_duration.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$_duration • $_distance",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
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
                            if (status == 'confirmed' ||
                                status == 'rider_accepted') {
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