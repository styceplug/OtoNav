import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:otonav/widgets/custom_button.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> onboardImages = ['onboard1', 'onboard2'];

  final List<String> onboardTitles = [
    'Instant \nDoorstep Pickup',
    'Track \nEvery Move',
  ];

  final List<String> onboardSubtitles = [
    'Skip the trip to the dispatch center. We collect packages right from your door and get them moving instantly.',
    'No more guessing games. Watch your package travel on the map in real-time, from pickup to drop-off.',
  ];

  void _nextPage() {
    if (_currentPage < onboardImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offAllNamed(AppRoutes.splashScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardImages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width30,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: Dimensions.height100),
                                Text(
                                  onboardTitles[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Dimensions.font10 * 3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: Dimensions.height20),
                                Image.asset(
                                  AppConstants.getPngAsset(
                                    onboardImages[_currentPage],
                                  ),
                                ),
                                SizedBox(height: Dimensions.height100),
                                Text(
                                  onboardSubtitles[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Dimensions.font16,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: Dimensions.height100,
                    top: Dimensions.height10,
                    left: Dimensions.width30,
                    right: Dimensions.width30,
                  ),
                  child: Column(
                    children: [
                      CustomButton(onPressed: () {
                        Get.toNamed(AppRoutes.getStartedScreen);
                      }, text: 'Get Started'),
                      SizedBox(height: Dimensions.height5),
                     /* Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(color: AppColors.black),
                          ),
                          Text(
                            ' Log in',
                            style: TextStyle(color: AppColors.accentColor),
                          ),
                        ],
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
