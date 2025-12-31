import 'package:get/get.dart';
import 'package:otonav/screens/auth/customer/create_account.dart';
import 'package:otonav/screens/auth/customer/login_screen.dart';
import 'package:otonav/screens/auth/forgotten_password.dart';
import 'package:otonav/screens/auth/rider/rider_login.dart';
import 'package:otonav/screens/auth/verify_otp.dart';
import 'package:otonav/screens/in_app/customer/location_screen.dart';
import 'package:otonav/screens/in_app/customer/tracking_screen.dart';
import 'package:otonav/screens/pages/rider_pages/rider_home_screen.dart';
import 'package:otonav/screens/splash/get_started.dart';
import 'package:otonav/screens/splash/no_internet_screen.dart';
import 'package:otonav/screens/splash/onboarding_screen.dart';
import 'package:otonav/screens/splash/update_app_screen.dart';
import 'package:otonav/screens/pages/user_pages/screens/orders.dart';
import 'package:otonav/screens/pages/user_pages/screens/profile.dart';

import '../screens/pages/user_pages/user_home_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  //general
  static const String splashScreen = '/splash-screen';
  static const String onboardingScreen = '/onboarding-screen';
  static const String updateAppScreen = '/update-app-screen';
  static const String noInternetScreen = '/no-internet-screen';
  static const String getStartedScreen = '/get-started-screen';

  //auth
  static const String riderLoginScreen = '/rider-login-screen';
  static const String customerLoginScreen = '/customer-login-screen';
  static const String customerRegisterScreen = '/customer-register-screen';
  static const String forgotPasswordScreen = '/forgot-password-screen';
  static const String verifyProfileScreen = '/verify-profile-screen';

  //customer
  static const String customerHomeScreen = '/customer-home-screen';
  static const String HomeScreen = '/customer-home-screen';
  static const String userHomePage = '/user-home-page';
  static const String customerProfilePage = '/customer-profile-screen';
  static const String customerOrdersPage = '/customer-orders-screen';
  static const String locationScreen = '/location-screen';
  static const String trackingScreen = '/tracking-screen';


  //rider
  static const String riderHomeScreen = '/rider-home-screen';



  static final routes = [

    //customer
    GetPage(
      name: customerHomeScreen,
      page: () {
        return const UserHomeScreen();
      },),
    GetPage(
      name: customerProfilePage,
      page: () {
        return const CustomerProfilePage();
      },),
    GetPage(
      name: customerOrdersPage,
      page: () {
        return const CustomerOrdersPage();
      },),
    GetPage(
      name: locationScreen,
      page: () {
        return const LocationScreen();
      },),
    GetPage(
      name: trackingScreen,
      page: () {
        return const TrackingScreen();
      },),


    //rider
    GetPage(
      name: riderHomeScreen,
      page: () {
        return const RiderHomeScreen();
      },),






    //auth
    GetPage(
      name: riderLoginScreen,
      page: () {
        return const RiderLoginScreen();
      },
    ),
    GetPage(
      name: customerLoginScreen,
      page: () {
        return const CustomerLoginScreen();
      },
    ),
    GetPage(
      name: customerRegisterScreen,
      page: () {
        return const CustomerCreateAccount();
      },
    ),
    GetPage(
      name: forgotPasswordScreen,
      page: () {
        return const ForgottenPassword();
      },
    ),
    GetPage(
      name: verifyProfileScreen,
      page: () {
        return const VerifyOtp();
      },
    ),



    //general
    GetPage(
      name: splashScreen,
      page: () {
        return const SplashScreen();
      },
    ),
    GetPage(
      name: onboardingScreen,
      page: () {
        return const OnboardingScreen();
      },
    ),
    GetPage(
      name: updateAppScreen,
      page: () {
        return const UpdateAppScreen();
      },
    ),
    GetPage(
      name: noInternetScreen,
      page: () {
        return const NoInternetScreen();
      },
    ),
    GetPage(
      name: getStartedScreen,
      page: () {
        return const GetStarted();
      },
    ),
  ];
}
