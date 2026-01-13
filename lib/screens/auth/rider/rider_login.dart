import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../widgets/custom_textfield.dart';

class RiderLoginScreen extends StatefulWidget {
  const RiderLoginScreen({super.key});

  @override
  State<RiderLoginScreen> createState() => _RiderLoginScreenState();
}

class _RiderLoginScreenState extends State<RiderLoginScreen> {

  AuthController authController = Get.find<AuthController>();
  bool isPasswordVisible = false;

  void togglePassVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void login(){
    authController.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppConstants.getPngAsset('rider-login')),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: Dimensions.font30 * 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              'Kindly Login with details given to you by your vendor.',
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
            CustomTextField(hintText: 'abc@gmail.com',controller: authController.emailController),
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
            SizedBox(height: Dimensions.height20),
            CustomButton(text: 'LOGIN', onPressed: (){
              Get.offAllNamed(AppRoutes.riderHomeScreen);
            }),
            SizedBox(height: Dimensions.height20),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: (){
                  Get.toNamed(AppRoutes.getStartedScreen);
                },
                child: Text(
                  'Return to Onboarding Screen',
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
