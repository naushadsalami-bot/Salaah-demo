import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shahada_app_getx/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shahada_app_getx/Services/api_service.dart';

class CreateAccountController extends GetxController {
  var isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final user = (await FirebaseAuth.instance.signInWithCredential(
        credential,
      )).user;

      // ✅ FIXED: Map return hota hai ab
      final result = await ApiService.socialLogin(
        name: user?.displayName ?? "",
        email: user?.email ?? "",
        uid: user?.uid ?? "",
        photo: user?.photoURL ?? "",
      );

      if (result != null && result['token'] != null) {
        await ApiService.saveToken(result['token']);

        // ✅ FIXED: Naya user → gender/brother-sister page
        //           Purana user → home
        if (result['is_new_user'] == true) {
          Get.offAllNamed('/gender'); // Brother/Sister selection page
        } else {
          Get.offAllNamed('/home');
        }
      } else {
        Get.snackbar(
          'Login Failed',
          'Server se response nahi aaya. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
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
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    if (isLoading.value) return;
    isLoading.value = true;

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

      final user = (await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      )).user;

      final result = await ApiService.socialLogin(
        name: user?.displayName ?? "",
        email: user?.email ?? "",
        uid: user?.uid ?? "",
        photo: "",
      );

      if (result != null && result['token'] != null) {
        await ApiService.saveToken(result['token']);

        if (result['is_new_user'] == true) {
          Get.offAllNamed('/gender');
        } else {
          Get.offAllNamed('/home');
        }
      } else {
        Get.snackbar(
          'Login Failed',
          'Server se response nahi aaya. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Apple Login',
        'iOS only ya configuration pending hai.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.off(() => const LoginScreen());
  }
}
