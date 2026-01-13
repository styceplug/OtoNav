import 'package:get/get.dart';
import 'package:otonav/data/api/api_client.dart';

import '../../utils/app_constants.dart';

class AuthRepo extends GetConnect {

  ApiClient apiClient;

  AuthRepo({required this.apiClient});


  Future<Response> getProfile() async {
    return await apiClient.getData(AppConstants.GET_PROFILE);
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await apiClient.postData(AppConstants.REFRESH_TOKEN, {
      "refreshToken": refreshToken
    });
  }

  Future<Response> resetPassword(String email) async {
    final body = {
      "email": email,
    };
    return await apiClient.postData(AppConstants.POST_FORGOT_PASSWORD, body);
  }

  Future<Response> resendOtp(String email) async {
    final body = {
      "email": email,
    };
    return await apiClient.postData(AppConstants.POST_RESEND_OTP, body);
  }

  Future<Response> verifyEmail(String email, String otp) async {
    final body = {
      "email": email,
      "otp": otp,
    };
    return await apiClient.postData(AppConstants.POST_VERIFY_OTP, body);
  }

  Future<Response> registerCustomer(String name, String email, String password, String phoneNumber) async {
    final body = {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
    };
    return await apiClient.postData(AppConstants.POST_REGISTER_CUSTOMER, body);
  }

  Future<Response> login(String email, String password) async {
    final body = {
      "email": email,
      "password": password,
    };
    return await apiClient.postData(AppConstants.POST_LOGIN, body);
  }
}