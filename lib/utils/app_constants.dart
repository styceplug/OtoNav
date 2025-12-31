class AppConstants {
  static const String APP_NAME = "OtoNav";
  static const String VERSION = "1.0.0";
  
  static const String BASE_URL = '';

  //TOKEN
  static const authToken = 'authToken';
  static const header = 'header';
  static const String lastVersionCheck = 'lastVersionCheck';
  
    static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }
  static String getGifAsset(String image) {
    return 'assets/gifs/$image.gif';
  }
}
