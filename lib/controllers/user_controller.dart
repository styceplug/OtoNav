import 'package:get/get.dart';

import '../data/repo/auth_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../model/user_model.dart';

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