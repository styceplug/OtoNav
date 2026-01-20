import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/helpers/global_loader_controller.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repo/auth_repo.dart';
import '../model/user_model.dart';
import '../routes/routes.dart';



class AuthController extends GetxController {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  Rx<User?> userModel = Rx<User?>(null);

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  UserController userController = Get.find<UserController>();






  Future<void> addNewLocation(String label, String address) async {
    if (label.isEmpty || address.isEmpty) {
      CustomSnackBar.failure(message: "Please select a label and generate a location.");
      return;
    }

    Map<String, dynamic> body = {
      "addLocation": {
        "label": label,
        "preciseLocation": address
      }
    };

    loader.showLoader();

    Response response = await authRepo.updateProfile(body);

    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {

      userModel.value = User.fromJson(response.body['data']);
      await userController.getUserProfile();
      update();

      CustomSnackBar.success(message: "Location saved successfully!");
      Get.back();
    } else {
      CustomSnackBar.failure(message: response.body['message'] ?? "Failed to save location");
    }
  }

  Future<void> resetPassword() async {
    String email = emailController.text.trim();


    if (email.isEmpty) {
      CustomSnackBar.failure(message: "Please enter your email address.");
      return;
    }

    loader.showLoader();
    Response response = await authRepo.resetPassword(email);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      CustomSnackBar.success(
          message: response.body['message'] ?? "OTP sent to your email.");

      Get.toNamed(AppRoutes.getStartedScreen);

    } else {
      String errorMsg = _getErrorMessage(response);
      CustomSnackBar.failure(message: errorMsg);
    }
  }

  Future<void> resendOtp() async {
    String email = Get.arguments ?? emailController.text.trim();

    if (email.isEmpty) {
      CustomSnackBar.failure(message: "Error: No email found to resend OTP.");
      return;
    }

    loader.showLoader();
    Response response = await authRepo.resendOtp(email);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      CustomSnackBar.success(
          message: response.body['message'] ?? "OTP resent successfully.");
    } else {
      String errorMsg = _getErrorMessage(response);
      CustomSnackBar.failure(message: errorMsg);
    }
  }

  Future<void> verifyOtp(String otp) async {
    String email = Get.arguments ?? emailController.text.trim();

    if (email.isEmpty) {
      CustomSnackBar.failure(message: "Error: No email address found.");
      return;
    }

    if (otp.length < 6) {
      CustomSnackBar.failure(message: "Please enter the full 6-digit code.");
      return;
    }

    loader.showLoader();
    Response response = await authRepo.verifyEmail(email, otp);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      CustomSnackBar.success(
          message: response.body['message'] ?? "Email verified! Please login.");

      Get.offAllNamed(AppRoutes.customerLoginScreen);
    } else {
      String errorMsg = _getErrorMessage(response);
      CustomSnackBar.failure(message: errorMsg);
    }
  }

  Future<void> registerCustomer() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String phoneNumber = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      CustomSnackBar.failure(message: "All fields are required.");
      return;
    }

    loader.showLoader();
    Response response = await authRepo.registerCustomer(name, email, password, phoneNumber);
    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      RegisterResponse registerResponse = RegisterResponse.fromJson(response.body);

      CustomSnackBar.success(
        message: registerResponse.message ?? "Registration Successful",
      );
      Get.toNamed(AppRoutes.verifyProfileScreen, arguments: email);
    } else {
      String errorMsg = _getErrorMessage(response);
      CustomSnackBar.failure(message: errorMsg);
    }
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.failure(message: "Please enter both your email and password.");
      return;
    }

    loader.showLoader();
    Response response = await authRepo.login(email, password);


    if (response.statusCode == 200 && response.body['success'] == true) {
      LoginResponse loginResponse = LoginResponse.fromJson(response.body);

      String role = loginResponse.data!.user!.role ?? "customer";

      if (role != 'rider' && role != 'customer') {
        loader.hideLoader();
        CustomSnackBar.failure(
          message: "Access Denied: The role '$role' is not supported on this app. Please use the website.",
        );
        return;
      }

      String accessToken = loginResponse.data!.accessToken!;
      String? refreshToken;
      String? rawCookie = response.headers?['set-cookie'];


      if (rawCookie != null) {
        int index = rawCookie.indexOf('refreshToken=');
        if (index != -1) {
          String temp = rawCookie.substring(index + 13);
          if (temp.contains(';')) {
            refreshToken = temp.split(';')[0];
          } else {
            refreshToken = temp;
          }
        }
      }
      authRepo.apiClient.updateHeader(accessToken);

      await saveUserSession(accessToken, refreshToken ?? "", role);
      await userController.getUserProfile();
      loader.hideLoader();

      if (loginResponse.data!.requiresRegistrationCompletion == true) {
        Get.toNamed(AppRoutes.verifyProfileScreen);
      } else {
        if (role == 'rider') {
          Get.offAllNamed(AppRoutes.riderHomeScreen);
        } else {
          if (role =='customer'){
            Get.offAllNamed(AppRoutes.customerHomeScreen);
          }
        }
      }


      CustomSnackBar.success(message: "Welcome back! Login successful.");
    }

    else {
      String errorMsg = _getErrorMessage(response);

      if (errorMsg.toLowerCase().contains("verify your email")) {
        CustomSnackBar.success(message: "Verification required. OTP sent to your email.");
        Get.toNamed(AppRoutes.verifyProfileScreen, arguments: email);
      } else if (response.statusCode == 401) {
        CustomSnackBar.failure(message: "Incorrect email or password.");
      } else {
        CustomSnackBar.failure(message: errorMsg);
      }
    }
    loader.hideLoader();

  }

  String _getErrorMessage(Response response) {
    if (response.status.connectionError) {
      return "No internet connection. Please check your network.";
    }

    try {
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          return response.body['message'];
        }
      }
    } catch (e) {
      // Parsing failed
    }

    switch (response.statusCode) {
      case 400:
        return "Invalid request. Please check your input.";
      case 404:
        return "Account not found.";
      case 500:
        return "Server error. Please try again later.";
      case 502:
        return "Server is currently unavailable.";
      default:
        return response.statusText ?? "An unexpected error occurred.";
    }
  }

  Future<void> saveUserSession(String accessToken, String refreshToken, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authToken, accessToken);
    await prefs.setString(AppConstants.userRole, role);
    if (refreshToken.isNotEmpty) {
      await prefs.setString(AppConstants.refreshToken, refreshToken);
    }
  }
}
