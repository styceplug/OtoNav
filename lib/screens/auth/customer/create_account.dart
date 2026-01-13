import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class CustomerCreateAccount extends StatefulWidget {
  const CustomerCreateAccount({super.key});

  @override
  State<CustomerCreateAccount> createState() => _CustomerCreateAccountState();
}

class _CustomerCreateAccountState extends State<CustomerCreateAccount> {
  AuthController authController = Get.find<AuthController>();
  bool isPasswordVisible = false;

  void togglePassVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
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
            Center(
              child: Image.asset(
                AppConstants.getPngAsset('customer-sign-up'),
                height: Dimensions.height100 * 2.5,
                width: Dimensions.width100 * 2.5,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Join us Today!',
              style: TextStyle(
                fontSize: Dimensions.font30 * 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              'Fill form to create a new account',
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: Dimensions.height15),
            Text('Full Name', style: TextStyle(fontSize: Dimensions.font17)),
            SizedBox(height: Dimensions.height5),
            CustomTextField(
              hintText: 'Full Name',
              controller: authController.nameController,
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
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Phone number',
              style: TextStyle(fontSize: Dimensions.font17),
            ),
            SizedBox(height: Dimensions.height5),
            CustomTextField(
              hintText: '2348012345678',
              controller: authController.phoneController,
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
            SizedBox(height: Dimensions.height20),
            CustomButton(
              onPressed: () {
                authController.registerCustomer();
              },
              text: 'CREATE ACCOUNT',
            ),
            SizedBox(height: Dimensions.height20),
            Align(
              alignment: AlignmentGeometry.center,
              child: InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.customerLoginScreen);
                },
                child: Text(
                  'Have an existing Account?, Log in',
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
