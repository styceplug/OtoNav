import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.onboardingScreen);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          child: Center(
            child: Image.asset(
              AppConstants.getPngAsset('logo1'),
              height: Dimensions.height100 * 1.5,
              width: Dimensions.width100 * 1.5,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
