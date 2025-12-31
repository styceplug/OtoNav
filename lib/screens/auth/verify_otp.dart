import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/otp_box.dart';

import '../../utils/colors.dart';
import '../../widgets/custom_textfield.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({super.key});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  @override
  Widget build(BuildContext context) {
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
                    'Provide a phone number you currently have access to',
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Text(
                    'Phone Number',
                    style: TextStyle(fontSize: Dimensions.font17),
                  ),
                  SizedBox(height: Dimensions.height5),
                  CustomTextField(
                    hintText: '080*******',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'SEND OTP',
                    onPressed: () {
                      showMoreOptions(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width30,
            vertical: Dimensions.height30,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: Dimensions.font30 * 0.9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentColor,
                  ),
                ),
                Text(
                  'Provide a phone number you currently have access to',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: Dimensions.height40),
                OtpTextField(
                  numberOfFields: 4,
                  fillColor: Colors.black.withOpacity(0.1),
                  filled: true,
                  borderColor: Colors.black,
                  showFieldAsBox: true,
                  borderWidth: 2,
                  fieldWidth: Dimensions.width50,
                  onSubmit: (code) {
                    print("OTP is $code");
                  },
                ),
                SizedBox(height: Dimensions.height20),
                CustomButton(text: 'VERIFY', onPressed: () {
                  Get.offAllNamed(AppRoutes.customerHomeScreen);
                }),
                SizedBox(height: Dimensions.height20),
                Align(
                  alignment: Alignment.center,
                  child: Text('Did\'nt receive OTP?'),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Resend Code',
                    style: TextStyle(color: AppColors.warning),
                  ),
                ),
                SizedBox(height: Dimensions.height50)
              ],
            ),
          ),
        );
      },
    );
  }
}
