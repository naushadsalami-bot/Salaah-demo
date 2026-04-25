import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/create_account_controller.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(CreateAccountController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // 1. TOP HEADER IMAGE (bg-1)
          // 1. TOP HEADER IMAGE (bg-1)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.40,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('images/bg-1.png', fit: BoxFit.cover),
                ),
                // 🔥 Center Text with manual adjustment
                const Positioned(
                  top: 60,
                  // bottom:
                  //     40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Salaha',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2. WHITE WAVE
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(color: isDark ? Colors.black : Colors.white),
            ),
          ),

          // 3. BOTTOM IMAGE (bg-2) - Wave ke upar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.20,
            child: Image.asset('images/bg-2.png', fit: BoxFit.cover),
          ),

          // 4. CENTERED FORM CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          //color: Color(0xFF1A1A1A),
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Google Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.signInWithGoogle,
                            // 🔥 Google Logo Logic
                            icon: controller.isLoading.value
                                ? const SizedBox.shrink()
                                : Image.asset(
                                    'images/google_logo.png', // Sahi path check kar lena
                                    height: 24,
                                    width: 24,
                                  ),
                            //  Loading vs Text Logic
                            label: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1AA6A6),
                                    ),
                                  )
                                : const Text(
                                    'Sign up with Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDDDDDD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Apple Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: controller.signInWithApple,
                          icon: const Icon(
                            Icons.apple,
                            color: Color(0xFF333333),
                            size: 32,
                          ),
                          label: const Text(
                            'Sign up with Apple',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Already have account link
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account ? ',
                            style: TextStyle(
                              // color: Color(0xFF555555),
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF555555),
                              fontSize: 13.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  //color: Color(0xFF0F3D2E),
                                  color: isDark
                                      ? Color(0xff666666)
                                      : const Color(0xFF0F3D2E),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Bottom image space
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.75, 60, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
