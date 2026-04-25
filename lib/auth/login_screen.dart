import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(LoginController());
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
          // TOP IMAGE
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
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 60,
                    ), // 👈 upar se space control
                    child: Text(
                      'Salaha',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WHITE WAVE
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

          // BOTTOM IMAGE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.20,
            child: Image.asset('images/bg-2.png', fit: BoxFit.cover),
          ),

          // CONTENT
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        //color: Color(0xFF333333),
                        color: isDark ? Colors.white : Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ✅ GOOGLE BUTTON — isGoogleLoading
                    Obx(
                      () => _SocialButton(
                        label: 'Sign In with Google',
                        icon: Image.asset('images/google_logo.png', height: 22),
                        isLoading: controller.isGoogleLoading.value,
                        onPressed: () => controller.signInWithGoogle(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ APPLE BUTTON — isAppleLoading
                    Obx(
                      () => _SocialButton(
                        label: 'Sign In with Apple',
                        icon: const Icon(
                          Icons.apple,
                          size: 34,
                          color: Colors.black,
                        ),
                        isLoading: controller.isAppleLoading.value,
                        onPressed: () => controller.signInWithApple(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () => controller.goToCreateAccount(),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            //color: Color(0xFF555555)
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF555555),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                // color: Color(0xFF0F3D2E),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox.shrink() : icon,
        label: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: const TextStyle(color: Colors.black87)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
