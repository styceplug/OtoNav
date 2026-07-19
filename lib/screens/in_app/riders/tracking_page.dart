import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../controllers/order_controller.dart';
import '../../../helpers/route_helper.dart';
import '../../../model/order_model.dart';
import '../../../utils/colors.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../../widgets/snackbars.dart';

class RiderTrackingPage extends StatefulWidget {
  final String orderId;
  final bool isVerified;
  const RiderTrackingPage({
    super.key,
    required this.orderId,
    this.isVerified = false,
  });

  @override
  State<RiderTrackingPage> createState() => _RiderTrackingPageState();
}

class _RiderTrackingPageState extends State<RiderTrackingPage>
    with TickerProviderStateMixin {
  static const double _navigationZoom = 16.4;
  static const double _initialNavigationZoom = 16.0;
  static const double _arrivalCueDistanceMeters = 60;
  static const String _arrivalInstruction =
      "You've arrived at your destination";

  final MapController _mapController = MapController();
  final OSMHelper _osmHelper = OSMHelper();
  final FlutterTts _tts = FlutterTts();

  LatLng? _destinationLatLng;
  List<LatLng> _routePoints = [];
  String _distance = '';
  String _duration = '';

  // TURN-BY-TURN VARIABLES
  String _nextInstruction = '';
  String _stepDistance = '';

  bool _isDestLoaded = false;
  bool _isMapReady = false;
  String? _loadedDestinationStatus;
  bool _isLoadingDestination = false;
  bool _hasFitInitialRoute = false;
  bool _isNavigationCameraActive = false;
  bool _voiceEnabled = true;
  bool _isUpdatingStatus = false;
  bool _hasAnnouncedArrival = false;
  String? _lastSpokenInstruction;
  DateTime? _lastSpokenAt;

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
    _configureVoice();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.startRiderTracking(
        widget.orderId,
        isVerified: widget.isVerified,
      );
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
    _tts.stop();
    _posWorker.dispose();
    _orderWorker.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _configureVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.46);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(false);
    if (Platform.isAndroid) {
      await _tts.setAudioAttributesForNavigation();
    }
  }

  Future<void> _speakInstruction(String instruction, String distance) async {
    if (!_voiceEnabled || instruction.trim().isEmpty) return;

    final now = DateTime.now();
    final recentlySpoken =
        _lastSpokenAt != null &&
        now.difference(_lastSpokenAt!) < const Duration(seconds: 15);
    if (_lastSpokenInstruction == instruction && recentlySpoken) return;

    _lastSpokenInstruction = instruction;
    _lastSpokenAt = now;
    final spokenDistance = distance.isNotEmpty ? "In $distance, " : "";
    await _tts.stop();
    await _tts.speak("$spokenDistance$instruction");
  }

  void _toggleVoice() {
    setState(() => _voiceEnabled = !_voiceEnabled);
    if (!_voiceEnabled) {
      _tts.stop();
    } else if (_nextInstruction.isNotEmpty) {
      _speakInstruction(_nextInstruction, _stepDistance);
    }
  }

  void _activateNavigationCamera() {
    if (!mounted) return;
    _isNavigationCameraActive = true;
    final pos =
        _interpolatedPos ??
        Get.find<OrderController>().currentRiderLatLng.value;
    if (pos != null && _isMapReady) {
      _mapController.moveAndRotate(pos, _navigationZoom, _bikeBearing);
    }
  }

  void _recenterNavigation() {
    final pos =
        _interpolatedPos ??
        Get.find<OrderController>().currentRiderLatLng.value;
    if (pos == null || !_isMapReady) return;
    _isNavigationCameraActive = true;
    _mapController.moveAndRotate(
      _projectToRouteIfClose(pos),
      _navigationZoom,
      _bikeBearing,
    );
  }

  Future<void> _openInNativeMaps() async {
    if (_destinationLatLng == null) return;

    // ✅ The official Google Maps universal deep link format
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&travelmode=driving';

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication, // Forces it out of your app
        );
      } else {
        Get.snackbar("Error", "Could not open map application");
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  void _animateBikeToNewPosition(LatLng newPos) {
    final routedPos = _projectToRouteIfClose(newPos);
    if (_oldPos == null) {
      setState(() {
        _interpolatedPos = routedPos;
        _oldPos = routedPos;
      });
      return;
    }

    if (_oldPos!.latitude == routedPos.latitude &&
        _oldPos!.longitude == routedPos.longitude) {
      return;
    }

    _bikeBearing = _calculateBearing(_oldPos!, routedPos);

    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final latTween = Tween<double>(
      begin: _oldPos!.latitude,
      end: routedPos.latitude,
    );
    final lngTween = Tween<double>(
      begin: _oldPos!.longitude,
      end: routedPos.longitude,
    );

    _animController!.addListener(() {
      setState(() {
        _interpolatedPos = LatLng(
          latTween.evaluate(_animController!),
          lngTween.evaluate(_animController!),
        );
      });
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) _oldPos = routedPos;
    });

    _animController!.forward();
  }

  LatLng _projectToRouteIfClose(LatLng gpsPos) {
    if (_routePoints.length < 2) return gpsPos;

    LatLng closest = gpsPos;
    double closestDistance = double.infinity;

    for (int i = 0; i < _routePoints.length - 1; i++) {
      final candidate = _nearestPointOnSegment(
        gpsPos,
        _routePoints[i],
        _routePoints[i + 1],
      );
      final distance = _calculateDistance(gpsPos, candidate);
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = candidate;
      }
    }

    return closestDistance <= 80 ? closest : gpsPos;
  }

  LatLng _nearestPointOnSegment(LatLng point, LatLng start, LatLng end) {
    final latScale = 111320.0;
    final lngScale = 111320.0 * math.cos(point.latitude * math.pi / 180);

    final px = point.longitude * lngScale;
    final py = point.latitude * latScale;
    final ax = start.longitude * lngScale;
    final ay = start.latitude * latScale;
    final bx = end.longitude * lngScale;
    final by = end.latitude * latScale;

    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared == 0) return start;

    final t = (((px - ax) * dx) + ((py - ay) * dy)) / lengthSquared;
    final clampedT = t.clamp(0.0, 1.0);

    final projectedX = ax + clampedT * dx;
    final projectedY = ay + clampedT * dy;
    return LatLng(projectedY / latScale, projectedX / lngScale);
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final lng1 = start.longitude * math.pi / 180;
    final lng2 = end.longitude * math.pi / 180;

    final y = math.sin(lng2 - lng1) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lng2 - lng1);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<void> _loadDestination(OrderModel order) async {
    final status = order.status ?? '';
    if (_isLoadingDestination || _loadedDestinationStatus == status) return;
    _isLoadingDestination = true;
    LatLng? dest;

    try {
      if (status == 'confirmed' || status == 'rider_accepted') {
        final vendorAddress = order.organization?.address ?? "";
        if (vendorAddress.isNotEmpty) {
          dest = await _osmHelper.getCoordinatesFromAddress(vendorAddress);
        }
      } else {
        if (order.customerLocationLat != null &&
            order.customerLocationLng != null) {
          dest = LatLng(order.customerLocationLat!, order.customerLocationLng!);
        }
      }

      if (!mounted) return;

      if (dest == null) {
        setState(() {
          _destinationLatLng = null;
          _isDestLoaded = false;
          _loadedDestinationStatus = status;
          _hasAnnouncedArrival = false;
        });
        return;
      }

      setState(() {
        _destinationLatLng = dest;
        _isDestLoaded = true;
        _loadedDestinationStatus = status;
        _hasFitInitialRoute = false;
        _hasAnnouncedArrival = false;
      });

      final riderPos =
          Get.find<OrderController>().currentRiderLatLng.value ??
          _riderLatLngFromOrder(order);
      if (riderPos != null) {
        if (_applyArrivalCueIfClose(
          status: status,
          riderPos: riderPos,
          destination: dest,
        )) {
          return;
        }
        await _fetchRoute(riderPos, dest);
      }
    } finally {
      _isLoadingDestination = false;
    }
  }

  void _updateCamera(LatLng riderPos) {
    if (!mounted || !_isMapReady) return;

    if (_hasFitInitialRoute && _isNavigationCameraActive) {
      _mapController.moveAndRotate(
        _projectToRouteIfClose(riderPos),
        _navigationZoom,
        _bikeBearing,
      );
    }

    if (_destinationLatLng != null) {
      _handleArrivalCue(riderPos);

      final now = DateTime.now();
      if (_lastRouteFetch == null ||
          now.difference(_lastRouteFetch!).inSeconds > 10) {
        _fetchRoute(riderPos, _destinationLatLng!);
        _lastRouteFetch = now;
      }
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final orderStatus =
        Get.find<OrderController>().trackingOrder.value?.status ?? '';
    if (_applyArrivalCueIfClose(
      status: orderStatus,
      riderPos: start,
      destination: end,
    )) {
      return;
    }

    final result = await _osmHelper.getRoute(start, end);
    if (!mounted || result == null) return;

    final points = List<LatLng>.from(result['points']);
    final isAtDestination =
        _shouldUseArrivalCue(orderStatus) &&
        _calculateDistance(start, end) <= _arrivalCueDistanceMeters;
    final shouldSpeakArrival = isAtDestination && !_hasAnnouncedArrival;

    setState(() {
      _routePoints = points;
      _distance = result['distance'];
      _duration = result['duration'];
      _nextInstruction = isAtDestination
          ? _arrivalInstruction
          : result['instruction'] ?? '';
      _stepDistance = isAtDestination ? '' : result['stepDistance'] ?? '';
      if (isAtDestination) {
        _hasAnnouncedArrival = true;
      }
    });

    if (!_hasFitInitialRoute && _isMapReady && points.isNotEmpty) {
      _fitRoute(points);
      _hasFitInitialRoute = true;
      Future.delayed(
        const Duration(milliseconds: 2400),
        _activateNavigationCamera,
      );
    }

    if (shouldSpeakArrival) {
      _speakInstruction(_arrivalInstruction, '');
    } else if (!isAtDestination) {
      _speakInstruction(_nextInstruction, _stepDistance);
    }
  }

  void _handleArrivalCue(LatLng riderPos) {
    final destination = _destinationLatLng;
    if (destination == null) return;

    final orderStatus =
        Get.find<OrderController>().trackingOrder.value?.status ?? '';
    _applyArrivalCueIfClose(
      status: orderStatus,
      riderPos: riderPos,
      destination: destination,
    );
  }

  bool _shouldUseArrivalCue(String status) {
    return status == 'in_transit' || status == 'arrived_at_location';
  }

  LatLng? _riderLatLngFromOrder(OrderModel order) {
    if (order.riderCurrentLat == null || order.riderCurrentLng == null) {
      return null;
    }
    return LatLng(order.riderCurrentLat!, order.riderCurrentLng!);
  }

  bool _applyArrivalCueIfClose({
    required String status,
    required LatLng riderPos,
    required LatLng destination,
  }) {
    if (!_shouldUseArrivalCue(status)) return false;

    final distanceToDestination = _calculateDistance(riderPos, destination);
    if (distanceToDestination > _arrivalCueDistanceMeters * 2) {
      _hasAnnouncedArrival = false;
      return false;
    }

    if (distanceToDestination > _arrivalCueDistanceMeters) return false;

    final shouldSpeak = !_hasAnnouncedArrival;
    _hasAnnouncedArrival = true;
    if (mounted) {
      setState(() {
        _nextInstruction = _arrivalInstruction;
        _stepDistance = '';
        _duration = '0 mins';
        _distance = '${distanceToDestination.round()} m';
      });
    }
    if (shouldSpeak) {
      _speakInstruction(_arrivalInstruction, '');
    }
    return true;
  }

  void _fitRoute(List<LatLng> points) {
    if (!mounted || !_isMapReady || points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 130, 48, 210),
      ),
    );
  }

  Widget _destinationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.location_pin, color: Color(0xFFFF4B4B), size: 38),
    );
  }

  Widget _riderMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF11D7FF).withValues(alpha: 0.42),
                const Color(0xFF11D7FF).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Transform.rotate(
          angle: _isNavigationCameraActive ? 0 : _bikeBearing * (math.pi / 180),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Image.asset(
              AppConstants.getPngAsset('delivery-bike-2'),
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.navigation_rounded,
                  color: Color(0xFF00D8FF),
                  size: 30,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _instructionIcon() {
    final lower = _nextInstruction.toLowerCase();
    if (lower.contains('left')) return Icons.turn_left_rounded;
    if (lower.contains('right')) return Icons.turn_right_rounded;
    if (lower.contains('arrive')) return Icons.flag_rounded;
    if (lower.contains('u-turn') || lower.contains('uturn')) {
      return Icons.u_turn_left_rounded;
    }
    return Icons.straight_rounded;
  }

  String _compactActionLabel(String status) {
    if (status == 'confirmed' || status == 'rider_accepted') return 'Pickup';
    if (status == 'package_picked_up') return 'Start';
    if (status == 'in_transit') return 'Arrived';
    if (status == 'arrived_at_location') return 'Done';
    return 'Go';
  }

  bool get _hasUsefulStepDistance {
    final rawMeters = int.tryParse(_stepDistance.replaceAll(RegExp(r'\D'), ''));
    return _stepDistance.isNotEmpty && (rawMeters == null || rawMeters > 0);
  }

  Widget _roundMapButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = const Color(0xFF101214),
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }

  void _showPinVerificationSheet(String orderId) {
    final TextEditingController pinController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.security, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              "Verify Delivery",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ask the customer for their 4-digit Delivery PIN to complete this order.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // PIN Input Field
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "0000",
                counterText: "", // Hide the character counter
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (pinController.text.length == 4) {
                    Get.back();
                    final controller = Get.find<OrderController>();
                    if (widget.isVerified) {
                      controller.confirmVerifiedDelivery(
                        orderId,
                        pinController.text,
                      );
                    } else {
                      controller.confirmDelivery(orderId, pinController.text);
                    }
                  } else {
                    CustomSnackBar.failure(
                      message: "Please enter a valid 4-digit PIN",
                    );
                  }
                },
                child: const Text(
                  "Confirm & Complete",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371e3;
    final lat1 = p1.latitude * math.pi / 180;
    final lat2 = p2.latitude * math.pi / 180;
    final deltaLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final deltaLng = (p2.longitude - p1.longitude) * math.pi / 180;

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  void _showProximityOverrideDialog(String orderId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text("Not at location?"),
          ],
        ),
        content: const Text(
          "Your GPS shows you are still far from the delivery destination. Are you sure you want to mark this as arrived?",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              final controller = Get.find<OrderController>();
              if (widget.isVerified) {
                await controller.markVerifiedArrived(orderId);
              } else {
                await controller.markArrived(orderId);
              }
            },
            child: const Text(
              "Yes, I'm here",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
          if (_loadedDestinationStatus != status) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadDestination(order);
            });
          }
          String titleText = '';
          String addressText = '';

          if (status == 'confirmed' || status == 'rider_accepted') {
            titleText = 'Pickup Address';
            addressText = order.organization?.address ?? "Pickup";
          } else if (status == 'package_picked_up') {
            titleText = 'Delivery Address';
            addressText = order.customerLocationLabel ?? "";
          } else if (status == 'in_transit') {
            titleText = 'Delivery Address';
            addressText = order.customerLocationLabel ?? "";
          } else if (status == 'arrived_at_location') {
            titleText = 'Delivery Address';
            addressText = order.customerLocationLabel ?? "";
          }

          final initialCenter =
              _interpolatedPos ??
              ctrl.currentRiderLatLng.value ??
              const LatLng(9.0820, 8.6753);

          return Stack(
            children: [
              // ── 1. MAP ──────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: _initialNavigationZoom,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  backgroundColor: const Color(0xFF15293A),
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
                  onMapReady: () {
                    _isMapReady = true;
                    final pos = controller.currentRiderLatLng.value;
                    if (_routePoints.isNotEmpty && !_hasFitInitialRoute) {
                      _fitRoute(_routePoints);
                      _hasFitInitialRoute = true;
                    } else if (pos != null) {
                      _updateCamera(pos);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.otonav.app',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: const Color(
                            0xFF06141D,
                          ).withValues(alpha: 0.86),
                          strokeWidth: 14,
                        ),
                        Polyline(
                          points: _routePoints,
                          color: const Color(
                            0xFF00D8FF,
                          ).withValues(alpha: 0.20),
                          strokeWidth: 11,
                        ),
                        Polyline(
                          points: _routePoints,
                          color: const Color(0xFF02DFFF),
                          strokeWidth: 7,
                        ),
                        Polyline(
                          points: _routePoints,
                          color: Colors.white.withValues(alpha: 0.45),
                          strokeWidth: 1.8,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_destinationLatLng != null)
                        Marker(
                          point: _destinationLatLng!,
                          width: 40,
                          height: 40,
                          rotate: true,
                          child: _destinationMarker(),
                        ),
                      if ((_interpolatedPos ?? ctrl.currentRiderLatLng.value) !=
                          null)
                        Marker(
                          point:
                              _interpolatedPos ??
                              ctrl.currentRiderLatLng.value!,
                          width: 64,
                          height: 64,
                          rotate: true,
                          child: _riderMarker(),
                        ),
                    ],
                  ),
                ],
              ),

              Positioned(
                right: 18,
                bottom: 224,
                child: Column(
                  children: [
                    _roundMapButton(
                      icon: Icons.explore_rounded,
                      onTap: _recenterNavigation,
                    ),
                    const SizedBox(height: 16),
                    _roundMapButton(
                      icon: Icons.directions_rounded,
                      onTap: _openInNativeMaps,
                    ),
                    const SizedBox(height: 16),
                    _roundMapButton(
                      icon: _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                      onTap: _toggleVoice,
                      backgroundColor: _voiceEnabled
                          ? const Color(0xFF0B6B66)
                          : const Color(0xFF101214),
                    ),
                  ],
                ),
              ),

              // ── 2. TURN-BY-TURN OVERLAY ──────────────────────────────────
              if (_nextInstruction.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 14,
                  left: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B65),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _instructionIcon(),
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _nextInstruction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  height: 1.08,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Color(0xFF4285F4),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        if (_hasUsefulStepDistance) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005651),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Then",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _stepDistance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101112),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _duration.isNotEmpty ? _duration : "--",
                                  style: const TextStyle(
                                    color: Color(0xFF6FF296),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  [
                                    if (_distance.isNotEmpty) _distance,
                                    if (addressText.isNotEmpty) addressText,
                                  ].join(" • "),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.62,
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        titleText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.62,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 64,
                            width: 64,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                elevation: 0,
                                backgroundColor: const Color(0xFF2B2D2F),
                              ),
                              onPressed: _recenterNavigation,
                              child: const Icon(
                                Icons.alt_route_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 64,
                            width: 88,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: status == 'arrived_at_location'
                                    ? const Color(0xFF24A855)
                                    : const Color(0xFFE53935),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : () async {
                                      setState(() => _isUpdatingStatus = true);
                                      try {
                                        await _handleStatusAction(ctrl, order);
                                      } finally {
                                        if (mounted) {
                                          setState(
                                            () => _isUpdatingStatus = false,
                                          );
                                        }
                                      }
                                    },
                              child: _isUpdatingStatus
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      status == 'arrived_at_location'
                                          ? "Done"
                                          : _compactActionLabel(status),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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

  Future<void> _handleStatusAction(
    OrderController ctrl,
    OrderModel order,
  ) async {
    final status = order.status ?? 'unknown';
    final id = order.id!;

    if (status == 'confirmed' || status == 'rider_accepted') {
      if (widget.isVerified) {
        await ctrl.markVerifiedPackagePickedUp(id);
      } else {
        await ctrl.markPackagePickedUp(id);
      }
    } else if (status == 'package_picked_up') {
      if (widget.isVerified) {
        await ctrl.startVerifiedDelivery(id);
      } else {
        await ctrl.startDelivery(id);
      }
    } else if (status == 'in_transit') {
      final riderPos = ctrl.currentRiderLatLng.value;
      if (riderPos != null && _destinationLatLng != null) {
        final distanceInMeters = _calculateDistance(
          riderPos,
          _destinationLatLng!,
        );

        if (distanceInMeters > 150) {
          _showProximityOverrideDialog(id);
        } else {
          if (widget.isVerified) {
            await ctrl.markVerifiedArrived(id);
          } else {
            await ctrl.markArrived(id);
          }
        }
      } else {
        _showProximityOverrideDialog(id);
      }
    } else if (status == 'arrived_at_location') {
      _showPinVerificationSheet(id);
    }
  }
}
