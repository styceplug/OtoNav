import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OSMHelper {
  final Dio _dio = Dio();

  // 1. FREE ROUTING (OSRM)
  Future<Map<String, dynamic>?> getRoute(LatLng start, LatLng end) async {
    try {
      // OSRM Public Server (Demo)
      // Note: For heavy commercial use, you should eventually host your own OSRM instance (free software)
      final url =
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        final route = response.data['routes'][0];
        final geometry = route['geometry'];
        final coordinates = geometry['coordinates'] as List;

        // Convert raw coords to LatLng list
        List<LatLng> points = coordinates
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();

        // Format Duration & Distance
        final durationSeconds = route['duration'];
        final distanceMeters = route['distance'];

        return {
          'points': points,
          'distance': _formatDistance(distanceMeters),
          'duration': _formatDuration(durationSeconds),
        };
      }
    } on DioException catch (e){
      if (e.response?.statusCode == 400) {
        print("OSRM Error: ${e.response?.data}");
        print("⚠️ Route Error: Cannot calculate route (e.g. across ocean).");
        return null;
      }
    }catch (e) {
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