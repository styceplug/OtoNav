import 'package:get/get.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/controllers/order_controller.dart';

import '../data/repo/auth_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../model/user_model.dart';
import '../routes/routes.dart';

class UserController extends GetxController {
  final AuthRepo authRepo;
  UserController({required this.authRepo});

  Rx<User?> userModel = Rx<User?>(null);

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();




  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }



  ProfileStatus getProfileStatus() {
    User? user = userModel.value;
    if (user == null) return ProfileStatus(progress: 0.0, message: "Loading...", route: "");

    int totalSteps = 3;
    int completedSteps = 0;

    // 1. Basic Info
    completedSteps++;

    // 2. Phone Number
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      completedSteps++;
    }

    bool hasLocation = user.locations != null && user.locations!.isNotEmpty;
    if (hasLocation) {
      completedSteps++;
    }

    double progress = completedSteps / totalSteps;

    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return ProfileStatus(
        progress: progress,
        message: "Add your phone number",
        route: AppRoutes.editProfileScreen,
      );
    } else if (!hasLocation) {
      return ProfileStatus(
        progress: progress,
        message: "Add a delivery address",
        route: AppRoutes.locationScreen,
      );
    } else {
      return ProfileStatus(progress: 1.0, message: "Done", route: "");
    }
  }


  Future<void> getUserProfile() async {
    await Future.delayed(Duration.zero);
    loader.hideLoader();

    Response response = await authRepo.getProfile();

    loader.hideLoader();

    if (response.statusCode == 200 && response.body['success'] == true) {
      userModel.value = User.fromJson(response.body['data']);
      update();
    } else {
      print("Failed to get profile: ${response.statusText}");
    }
  }


}


class ProfileStatus {
  final double progress;
  final String message;
  final String route;

  ProfileStatus({required this.progress, required this.message, required this.route});
}