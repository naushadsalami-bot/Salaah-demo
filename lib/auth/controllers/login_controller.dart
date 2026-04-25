import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shahada_app_getx/auth/create_account_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../Services/api_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ FIXED: Alag alag loading — Google aur Apple ke liye
  var isGoogleLoading = false.obs;
  var isAppleLoading = false.obs;
  var obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    isGoogleLoading.value = true;
    try {
      final token = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (token != null) {
        await ApiService.saveToken(token);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          'Login failed.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ✅ GOOGLE — sirf isGoogleLoading
  Future<void> signInWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isGoogleLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      final result = await ApiService.socialLogin(
        name: user?.displayName ?? "",
        email: user?.email ?? "",
        uid: user?.uid ?? "",
        photo: user?.photoURL ?? "",
      );

      if (result != null && result['token'] != null) {
        await ApiService.saveToken(result['token']);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Login Failed',
          'Server se response nahi aaya.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Google Login Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ✅ APPLE — sirf isAppleLoading
  Future<void> signInWithApple() async {
    if (isAppleLoading.value) return;
    isAppleLoading.value = true;
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      final user = userCredential.user;

      final result = await ApiService.socialLogin(
        name: user?.displayName ?? "",
        email: user?.email ?? "",
        uid: user?.uid ?? "",
        photo: "",
      );

      if (result != null && result['token'] != null) {
        await ApiService.saveToken(result['token']);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Login Failed',
          'Server se response nahi aaya.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Apple Login',
        'iOS only ya configuration pending.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } finally {
      isAppleLoading.value = false;
    }
  }

  void goToCreateAccount() {
    Get.to(() => const CreateAccountScreen());
  }
}
