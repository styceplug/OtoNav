import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class OSMHelper {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        final route = response.data['routes'][0];
        final coordinates = route['geometry']['coordinates'] as List;

        List<LatLng> points = coordinates
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();

        String instruction = "Head to destination";
        String stepDistance = "";
        int majorStopsAway = 0; // ✅ The new intelligent counter

        if (route['legs'].isNotEmpty && route['legs'][0]['steps'].isNotEmpty) {
          final steps = route['legs'][0]['steps'] as List;

          // ✅ INTELLIGENT JUNCTION FILTER
          // Instead of counting every tiny bend, we only count significant turns.
          for (var step in steps) {
            double dist = (step['distance'] ?? 0).toDouble();

            // Only count if it's a named road AND the rider will be on it for more than 200 meters.
            if (dist > 200) {
              majorStopsAway++;
            }
          }

          final nextStep = steps
              .skip(1)
              .cast<Map>()
              .firstWhere(
                (step) => ((step['distance'] ?? 0) as num).toDouble() > 15,
                orElse: () => steps.length > 1 ? steps[1] : steps[0],
              );

          if (steps.length > 1) {
            final modifier = nextStep['maneuver']['modifier'] ?? '';
            final type = nextStep['maneuver']['type'] ?? '';

            String name = nextStep['name'] ?? '';
            if (name.trim().isEmpty) name = 'the road';

            if (modifier.isNotEmpty) {
              instruction = "Turn $modifier on $name";
            } else if (type.isNotEmpty) {
              instruction = "$type on $name";
            }
            final distance = (nextStep['distance'] ?? 0) as num;
            stepDistance = distance > 15 ? _formatDistance(distance) : "";
          } else if (steps.length == 1) {
            instruction = "Arrive at destination";
            stepDistance = _formatDistance(steps[0]['distance']);
          }
        }

        return {
          'points': points,
          'distance': _formatDistance(route['distance']),
          'duration': _formatDuration(route['duration']),
          'instruction': instruction,
          'stepDistance': stepDistance,
          'stops': majorStopsAway, // ✅ Return the filtered major stops
        };
      }
    } catch (e) {
      debugPrint("OSRM Error: $e");
    }
    return null;
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search';

      final response = await _dio.get(
        url,
        queryParameters: {'q': address, 'format': 'json', 'limit': 1},
        options: Options(headers: {'User-Agent': 'OtoNav_App_1.0'}),
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final data = response.data[0];
        return LatLng(double.parse(data['lat']), double.parse(data['lon']));
      }
    } catch (e) {
      debugPrint("Nominatim Error: $e");
    }
    return null;
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse';

      final response = await _dio.get(
        url,
        queryParameters: {'lat': lat, 'lon': lng, 'format': 'json'},
        options: Options(headers: {'User-Agent': 'OtoNav_App_1.0'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // 'display_name' gives the full address string
        return response.data['display_name'];
      }
    } catch (e) {
      debugPrint("Nominatim Reverse Geo Error: $e");
    }
    return null;
  }

  String _formatDistance(num meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(num seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes mins';
    final hours = (minutes / 60).floor();
    final remMins = minutes % 60;
    return '${hours}h ${remMins}m';
  }
}
