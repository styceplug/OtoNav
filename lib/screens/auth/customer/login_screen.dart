import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/custom_textfield.dart';

import '../../../routes/routes.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  AuthController authController = Get.find<AuthController>();
  bool isPasswordVisible = false;

  void togglePassVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void login() {
    authController.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppConstants.getPngAsset('customer-login')),
            SizedBox(height: Dimensions.height30),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: Dimensions.font30 * 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              'Kindly Login with existing details.',
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Email Address',
              style: TextStyle(fontSize: Dimensions.font17),
            ),
            SizedBox(height: Dimensions.height5),
            CustomTextField(
              hintText: 'abc@gmail.com',
              controller: authController.emailController,
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
            ),
            SizedBox(height: Dimensions.height20),
            Text('Password', style: TextStyle(fontSize: Dimensions.font17)),
            SizedBox(height: Dimensions.height5),
            CustomTextField(
              hintText: 'password',
              controller: authController.passwordController,
              maxLines: 1,
              obscureText: isPasswordVisible,
              suffixIcon: InkWell(
                onTap: togglePassVisibility,
                child: isPasswordVisible
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.forgotPasswordScreen);
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            CustomButton(onPressed: login, text: 'LOGIN'),
            SizedBox(height: Dimensions.height20),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.customerRegisterScreen);
                },
                child: Text(
                  'New here?, Create Account',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
