import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import 'api_checker.dart';

class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;



  ApiClient({required this.appBaseUrl, required this.sharedPreferences});

  /*{
    baseUrl = appBaseUrl;
    httpClient.baseUrl = appBaseUrl;
    httpClient.timeout = const Duration(seconds: 60);
    timeout = const Duration(seconds: 60);
    token = sharedPreferences.getString(AppConstants.authToken) ?? "";

    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }*/

  @override
  void onInit() {
    // 1. Set Base URL first
    baseUrl = appBaseUrl;
    httpClient.baseUrl = appBaseUrl;

    // 2. INCREASE TIMEOUT to 2 minutes (120s)
    // Railway cold starts can take >45 seconds. 30s is not enough.
    httpClient.timeout = const Duration(seconds: 120);
    timeout = const Duration(seconds: 120);

    // 3. Initialize Token
    token = sharedPreferences.getString(AppConstants.authToken) ?? "";

    // 4. Set Headers
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // 5. Add a request modifier for debugging (Optional but helpful)
    httpClient.addRequestModifier<dynamic>((request) {
      if (kDebugMode) print('🛫 Sending request to: ${request.url}');
      return request;
    });

    super.onInit();
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    sharedPreferences.setString(AppConstants.authToken, token);
    if (kDebugMode) {
      print('🔑 Header updated with token: $token');
    }
  }

  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    try {
      print('📡 GET: $baseUrl$uri');
      print('📤 Headers: ${headers ?? _mainHeaders}');
      final response = await get(uri, headers: headers ?? _mainHeaders);
      print("✅ Response: ${response.statusCode}, ${response.body}");
      return response;
    } catch (e) {
      print("❌ ERROR in getData($uri): $e");
      ApiChecker.checkApi(Response(statusCode: 1, statusText: e.toString()));
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(
      String uri,
      dynamic body, {
        Map<String, String>? headers,
      }) async {
    try {
      if (kDebugMode) {
        print('POST → $appBaseUrl$uri');
        print('HEADERS → ${headers ?? _mainHeaders}');
        print('BODY → ${_formatBody(body)}');
      }

      Response response = await post(
        uri,
        body,
        headers: headers ?? _mainHeaders,
      );

      if (kDebugMode) {
        print('RESPONSE → ${response.body}');

        final responseSize =
            utf8.encode(response.body.toString()).length;
        print(
          'Response Size: $responseSize bytes '
              '(${(responseSize / 1024).toStringAsFixed(2)} KB)',
        );
      }
      if (kDebugMode) {
        print('STATUS CODE → ${response.statusCode}');
        print('STATUS TEXT → ${response.statusText}');
        print('BODY → ${response.body}');
        print('BODY STRING → ${response.bodyString}');
      }


      return response;
    } catch (e, s) {
      if (kDebugMode) {
        print('API POST ERROR');
        print('STACK → $s');
        print('ERROR → $e');
      }

      return Response(statusCode: 1, statusText: e.toString());


    }
  }

  String _formatBody(dynamic body) {
    try {
      if (body == null) return 'null';

      if (body is String) {
        return body;
      }

      if (body is Map || body is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(body);
      }

      return body.toString();
    } catch (e) {
      return 'Unable to format body: $e';
    }
  }


  Future<Response> patchData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      Response response = await patch(uri, body, headers: headers ?? _mainHeaders);

      if (kDebugMode) {
        print('patching $appBaseUrl$uri $body ${headers ?? _mainHeaders}');
        print("response body ${response.body}");

        final responseSize = utf8.encode(response.body.toString()).length;
        print('Response Size for $uri: $responseSize bytes (${(responseSize / 1024).toStringAsFixed(2)} KB)');
      }

      return response;
    } catch (e, s) {
      if (kDebugMode) {
        print('from api patch client');
        print(s);
        print(e.toString());
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {

      Response response = await put(uri, body, headers: headers ?? _mainHeaders);
      if (kDebugMode) {
        print("putting ${response.body}");
        print("response body ${response.body}");

        final responseSize = utf8.encode(response.body.toString()).length;
        print('Response Size for $uri: $responseSize bytes (${(responseSize / 1024).toStringAsFixed(2)} KB)');
      }
      // ApiChecker.checkApi(response);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('from api put client');
        print(e.toString());
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postMultipartData(String uri, http.MultipartRequest request) async {
    try {
      // Add your main headers to the request
      request.headers.addAll(_mainHeaders);

      if (kDebugMode) {
        print('🧾 POST Multipart to $uri: ${request.fields}');
        print('🧾 Files: ${request.files.map((f) => f.field).join(', ')}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📦 Response Status: ${response.statusCode}');
        print('📦 Response: ${response.body}');
      }

      return Response(
        statusCode: response.statusCode,
        body: response.body,
        statusText: response.reasonPhrase,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Multipart POST Error: $e');
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }



  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    try {
      print('🗑️ DELETE: $baseUrl$uri');
      print('📤 Headers: ${headers ?? _mainHeaders}');
      Response response = await delete(uri, headers: headers ?? _mainHeaders);

      if (kDebugMode) {
        print("🗑️ Response: ${response.statusCode}, ${response.body}");
        final responseSize = utf8.encode(response.body.toString()).length;
        print('Response Size for $uri: $responseSize bytes (${(responseSize / 1024).toStringAsFixed(2)} KB)');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERROR in deleteData($uri): $e');
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }



}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}