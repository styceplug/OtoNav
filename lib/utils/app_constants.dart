class AppConstants {
  static const String APP_NAME = "OtoNav";
  static const String VERSION = "1.0.0";
  
  static const String BASE_URL = 'https://otonav-backend-production.up.railway.app';

  //TOKEN
  static const authToken = 'authToken';
  static const String userRole = 'user_role';
  static const String refreshToken = 'refresh_token';


  static const String POST_LOGIN = '/api/auth/login';
  static const String POST_REGISTER_CUSTOMER = '/api/auth/register/customer';
  static const String POST_FORGOT_PASSWORD = '/api/auth/forgot-password';
  static const String POST_VERIFY_OTP= '/api/auth/verify-email';
  static const String POST_RESEND_OTP= '/api/auth/resend-otp';
  static const String GET_PROFILE = '/api/auth/profile';
  static const String REFRESH_TOKEN = '/api/auth/refresh-token';

    static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }
  static String getGifAsset(String image) {
    return 'assets/gifs/$image.gif';
  }
}
