import 'package:get/get.dart';
// Apne screens ke sahi path yahan check karlein
import 'package:shahada_app_getx/Auth/login_screen.dart';
import 'package:shahada_app_getx/auth/create_account_screen.dart';

class WelcomeController extends GetxController {
  void goToLogin() {
    Get.to(() => const LoginScreen());
  }

  void goToCreateAccount() {
    Get.to(() => const CreateAccountScreen());
  }
}
