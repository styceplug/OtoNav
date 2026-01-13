import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../../widgets/snackbars.dart';

class VerifyOtp extends StatefulWidget {
  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final AuthController authController = Get.find<AuthController>();
  String otpCode = "";

  @override
  Widget build(BuildContext context) {
    String displayEmail = Get.arguments ?? authController.emailController.text;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppConstants.getPngAsset('verify-otp'),
              height: Dimensions.height100 * 5,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: Dimensions.font30 * 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  ),
                  Text(
                    'Please verify access to $displayEmail check inbox and spam for the OTP code',
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: Dimensions.height40),

                  OtpTextField(
                    numberOfFields: 6,
                    fillColor: Colors.black.withOpacity(0.1),
                    filled: true,
                    borderColor: Colors.black,
                    showFieldAsBox: true,
                    borderWidth: 2,
                    fieldWidth: Dimensions.width50,
                    onCodeChanged: (String code) {
                      otpCode = code;
                    },
                    onSubmit: (code) {
                      otpCode = code;
                      authController.verifyOtp(otpCode);
                    },
                  ),

                  SizedBox(height: Dimensions.height40),

                  CustomButton(
                      text: 'VERIFY',
                      onPressed: () {
                        authController.verifyOtp(otpCode);
                      }
                  ),

                  SizedBox(height: Dimensions.height20),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Didn't receive OTP?"),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        authController.resendOtp();
                      },
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.height50)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
