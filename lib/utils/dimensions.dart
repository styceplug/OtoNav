import 'package:flutter/material.dart';
import 'dart:math';

class Dimensions {
  static late double screenWidth;
  static late double screenHeight;
  static late double _scaleFactor;
  static late bool isSmallScreen;
  static late bool isMediumScreen;
  static late bool isLargeScreen;

  // Reference dimensions (design was made for these)
  static const double _referenceWidth = 430.0;  // Adjust to your design width
  static const double _referenceHeight = 932.0; // Adjust to your design height

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;

    // Calculate scale factor with limits to prevent extreme scaling
    final widthScale = screenWidth / _referenceWidth;
    final heightScale = screenHeight / _referenceHeight;

    // Use the smaller scale factor and clamp it
    _scaleFactor = min(widthScale, heightScale).clamp(0.7, 1.3);

    // Screen size categories
    isSmallScreen = screenWidth < 360 || screenHeight < 640;
    isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    isLargeScreen = screenWidth >= 600;
  }

  // Helper method to scale with minimum constraint
  static double _scale(double size, {double? min}) {
    final scaled = size * _scaleFactor;
    return min != null ? max(scaled, min) : scaled;
  }

  // Heights with minimum constraints
  static double get height5 => _scale(5, min: 4);
  static double get height10 => _scale(10, min: 8);
  static double get height12 => _scale(12, min: 10);
  static double get height13 => _scale(13, min: 11);
  static double get height15 => _scale(15, min: 12);
  static double get height18 => _scale(18, min: 15);
  static double get height20 => _scale(20, min: 16);
  static double get height22 => _scale(22, min: 18);
  static double get height24 => _scale(24, min: 20);
  static double get height28 => _scale(28, min: 24);
  static double get height30 => _scale(30, min: 25);
  static double get height33 => _scale(33, min: 28);
  static double get height38 => _scale(38, min: 32);
  static double get height39 => _scale(39, min: 33);
  static double get height40 => _scale(40, min: 34);
  static double get height43 => _scale(43, min: 36);
  static double get height50 => _scale(50, min: 42);
  static double get height52 => _scale(52, min: 44);
  static double get height54 => _scale(54, min: 46);
  static double get height65 => _scale(65, min: 55);
  static double get height67 => _scale(67, min: 57);
  static double get height70 => _scale(70, min: 60);
  static double get height76 => _scale(76, min: 65);
  static double get height100 => _scale(100, min: 85);
  static double get height134 => _scale(134, min: 110);
  static double get height150 => _scale(150, min: 120);
  static double get height152 => _scale(152, min: 122);
  static double get height161 => _scale(161, min: 130);
  static double get height171 => _scale(171, min: 140);
  static double get height218 => _scale(218, min: 180);
  static double get height240 => _scale(240, min: 200);
  static double get height293 => _scale(293, min: 240);
  static double get height295 => _scale(295, min: 245);
  static double get height313 => _scale(313, min: 260);

  // Widths with minimum constraints
  static double get width5 => _scale(5, min: 4);
  static double get width10 => _scale(10, min: 8);
  static double get width13 => _scale(13, min: 11);
  static double get width15 => _scale(15, min: 12);
  static double get width18 => _scale(18, min: 15);
  static double get width20 => _scale(20, min: 16);
  static double get width22 => _scale(22, min: 18);
  static double get width24 => _scale(24, min: 20);
  static double get width25 => _scale(25, min: 21);
  static double get width28 => _scale(28, min: 24);
  static double get width29 => _scale(29, min: 25);
  static double get width30 => _scale(30, min: 25);
  static double get width33 => _scale(33, min: 28);
  static double get width39 => _scale(39, min: 33);
  static double get width40 => _scale(40, min: 34);
  static double get width43 => _scale(43, min: 36);
  static double get width45 => _scale(45, min: 38);
  static double get width50 => _scale(50, min: 42);
  static double get width52 => _scale(52, min: 44);
  static double get width70 => _scale(70, min: 60);
  static double get width85 => _scale(85, min: 72);
  static double get width100 => _scale(100, min: 85);
  static double get width113 => _scale(113, min: 95);
  static double get width167 => _scale(167, min: 140);
  static double get width188 => _scale(188, min: 160);
  static double get width240 => _scale(240, min: 200);
  static double get width270 => _scale(270, min: 230);
  static double get width285 => _scale(285, min: 240);
  static double get width355 => _scale(355, min: 300);
  static double get width360 => _scale(360, min: 305);

  // Radius
  static double get radius5 => _scale(5, min: 4);
  static double get radius10 => _scale(10, min: 8);
  static double get radius15 => _scale(15, min: 12);
  static double get radius20 => _scale(20, min: 16);
  static double get radius30 => _scale(30, min: 24);
  static double get radius45 => _scale(45, min: 36);

  // Fonts - these especially need minimum sizes for readability
  static double get font8 => _scale(8, min: 8);
  static double get font10 => _scale(10, min: 10);
  static double get font12 => _scale(12, min: 11);
  static double get font13 => _scale(13, min: 12);
  static double get font14 => _scale(14, min: 13);
  static double get font15 => _scale(15, min: 14);
  static double get font16 => _scale(16, min: 15);
  static double get font17 => _scale(17, min: 16);
  static double get font18 => _scale(18, min: 17);
  static double get font20 => _scale(20, min: 18);
  static double get font22 => _scale(22, min: 20);
  static double get font23 => _scale(23, min: 21);
  static double get font25 => _scale(25, min: 22);
  static double get font26 => _scale(26, min: 23);
  static double get font28 => _scale(28, min: 24);
  static double get font30 => _scale(30, min: 26);

  // Icons - minimum 16px for touch targets
  static double get iconSize16 => _scale(16, min: 16);
  static double get iconSize20 => _scale(20, min: 18);
  static double get iconSize24 => _scale(24, min: 22);
  static double get iconSize30 => _scale(30, min: 26);

  // Custom dimensions
  static double get splashLogoHeight => _scale(372, min: 280);
  static double get dpHeight => _scale(36.8, min: 32);
  static double get mainContainerHeight => _scale(168, min: 140);
  static double get mainContainerHeight2 => _scale(155, min: 130);
  static double get bottomNavIconHeight => _scale(34.9, min: 30);

  static double get splashLogoWidth => _scale(372, min: 300);
  static double get dpWidth => _scale(36.8, min: 32);
  static double get bottomNavIconWidth => _scale(36, min: 32);

  // Responsive padding - adjusts based on screen size
  static double get screenPadding => isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;

  // Responsive spacing multipliers
  static double get spacingMultiplier => isSmallScreen ? 0.8 : 1.0;
}



