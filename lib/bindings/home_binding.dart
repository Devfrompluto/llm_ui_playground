import 'package:get/get.dart';
import 'package:mobile_ui_playground/controllers/home_controller.dart';
import 'package:mobile_ui_playground/controllers/theme_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ThemeController>(() => ThemeController());
  }
}
