import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteHelper {
  RouteHelper({required this.googleApiKey});

  final String googleApiKey;

  Timer? _debounce;

  void dispose() {
    _debounce?.cancel();
  }

  void debounceRoute({
    required LatLng origin,
    required LatLng destination,
    required void Function(String distance, String duration, List<LatLng> points) onResult,
  }) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 6), () async {
      final result = await getRoute(origin: origin, destination: destination);
      if (result == null) return;
      onResult(result.distance, result.duration, result.points);
    });
  }

  Future<_RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/directions/json"
          "?origin=${origin.latitude},${origin.longitude}"
          "&destination=${destination.latitude},${destination.longitude}"
          "&mode=driving"
          "&key=$googleApiKey";

      final res = await Dio().get(url);

      if (res.data['status'] != 'OK') return null;

      final route = res.data['routes'][0];
      final leg = route['legs'][0];

      final distance = leg['distance']['text'];
      final duration = leg['duration']['text'];

      final encoded = route['overview_polyline']['points'];
      final decoded = PolylinePoints.decodePolyline(encoded);

      final points = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      return _RouteResult(distance: distance, duration: duration, points: points);
    } catch (_) {
      return null;
    }
  }
}

class _RouteResult {
  final String distance;
  final String duration;
  final List<LatLng> points;

  _RouteResult({
    required this.distance,
    required this.duration,
    required this.points,
  });
}