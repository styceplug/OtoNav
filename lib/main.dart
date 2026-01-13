import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otonav/routes/routes.dart';
import 'package:otonav/utils/app_constants.dart';
import 'package:otonav/utils/colors.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/app_loading_overlay.dart';
import 'controllers/app_controller.dart';
import 'helpers/dependencies.dart' as dep;
import 'helpers/global_loader_controller.dart';
import 'helpers/version_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await VersionService.init();
  await dep.init();

  Get.put(GlobalLoaderController(), permanent: true);

  HardwareKeyboard.instance.clearState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalLoaderController>(builder: (_) {
      return GetBuilder<AppController>(builder: (_) {
        return LayoutBuilder(builder: (context, constraint) {
          Dimensions.init(context);

          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.APP_NAME,
            theme: ThemeData(
                fontFamily: 'Poppins',
                scaffoldBackgroundColor: AppColors.backgroundColor
            ),

            getPages: AppRoutes.routes,
            initialRoute: AppRoutes.splashScreen,
            builder: (context, child) {
              final loaderController = Get.find<GlobalLoaderController>();
              return Obx(() {
                return Stack(
                  children: [
                    child!,
                    if (loaderController.isLoading.value)
                      const Positioned.fill(
                        child: AppLoadingOverlay(),
                      ),
                  ],
                );
              });
            },
          );
        });
      });
    });
  }
}

