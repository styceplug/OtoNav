import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OSMHelper {
  final Dio _dio = Dio();

  // 1. FREE ROUTING (OSRM)
  Future<Map<String, dynamic>?> getRoute(LatLng start, LatLng end) async {
    try {
      // Added &steps=true to the URL
      final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        final route = response.data['routes'][0];
        final coordinates = route['geometry']['coordinates'] as List;

        List<LatLng> points = coordinates
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();

        // Parse Turn-by-Turn Instructions & Stops Away
        String instruction = "Head to destination";
        String stepDistance = "";
        int stopsAway = 0; // NEW VARIABLE

        if (route['legs'].isNotEmpty && route['legs'][0]['steps'].isNotEmpty) {
          final steps = route['legs'][0]['steps'] as List;

          // Calculate Stops/Junctions (Total steps minus the final "Arrive" step)
          stopsAway = steps.length > 1 ? steps.length - 1 : 0;

          if (steps.length > 1) {
            final nextStep = steps[1];
            final modifier = nextStep['maneuver']['modifier'] ?? '';
            final type = nextStep['maneuver']['type'] ?? '';

            String name = nextStep['name'] ?? '';
            if (name.trim().isEmpty) name = 'the road';

            if (modifier.isNotEmpty) {
              instruction = "Turn $modifier on $name";
            } else if (type.isNotEmpty) {
              instruction = "$type on $name";
            }
            stepDistance = _formatDistance(nextStep['distance']);
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
          'stops': stopsAway, // RETURN STOPS AWAY
        };


      }
    } catch (e) {
      print("OSRM Error: $e");
    }
    return null;
  }

  // 2. FREE GEOCODING (Nominatim)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search';

      final response = await _dio.get(
        url,
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {
            // REQUIRED: Nominatim requires a User-Agent identifying your app
            'User-Agent': 'OtoNav_App_1.0',
          },
        ),
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final data = response.data[0];
        return LatLng(
          double.parse(data['lat']),
          double.parse(data['lon']),
        );
      }
    } catch (e) {
      print("Nominatim Error: $e");
    }
    return null;
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse';

      final response = await _dio.get(
        url,
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
        },
        options: Options(
          headers: {
            'User-Agent': 'OtoNav_App_1.0',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // 'display_name' gives the full address string
        return response.data['display_name'];
      }
    } catch (e) {
      print("Nominatim Reverse Geo Error: $e");
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