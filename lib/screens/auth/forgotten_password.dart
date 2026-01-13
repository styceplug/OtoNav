import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgottenPassword extends StatefulWidget {
  const ForgottenPassword({super.key});

  @override
  State<ForgottenPassword> createState() => _ForgottenPasswordState();
}

class _ForgottenPasswordState extends State<ForgottenPassword> {
  AuthController authController = Get.find<AuthController>();

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
            Image.asset(AppConstants.getPngAsset('forgot-pass')),
            SizedBox(height: Dimensions.height30),
            Text(
              'Forgotten Password',
              style: TextStyle(
                fontSize: Dimensions.font30 * 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              'If there is an existing account attached to provided mail, a reset link will be sent ',
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
            ),
            SizedBox(height: Dimensions.height20),
            CustomButton(
              onPressed: () {
                authController.resetPassword();
              },
              text: 'REQUEST LINK',
            ),
          ],
        ),
      ),
    );
  }
}
