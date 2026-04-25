import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/auth/controllers/welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(WelcomeController());
    final screenHeight = MediaQuery.of(context).size.height;

    // Reactive variable to track hover state (0: None, 1: Login, 2: Signup)
    final hoveredButton = 0.obs;

    const brandTeal = Color(0xFF0C2B21);
    const normalGrey = Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // ── TOP IMAGE ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.40,
            child: Image.asset('images/bg-1.png', fit: BoxFit.cover),
          ),

          // ── BOTTOM IMAGE ───────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.20,
            child: Image.asset('images/bg-2.png', fit: BoxFit.cover),
          ),

          // ── WHITE WAVE ─────────────────────
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: screenHeight * 0.40,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),

          // ── CONTENT ────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Salaha',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Obx(
                    () => Column(
                      children: [
                        // --- LOGIN BUTTON ---
                        MouseRegion(
                          onEnter: (_) => hoveredButton.value = 1,
                          onExit: (_) => hoveredButton.value = 0,
                          child: _buildWelcomeButton(
                            text: 'Log in',
                            // Agar Login par hover hai, ya default state hai (0), to outlined
                            // Agar Signup par hover hai (2), to ye filled ho jaye
                            isFilled: hoveredButton.value == 2,
                            brandColor: brandTeal,
                            greyColor: normalGrey,
                            onPressed: () => controller.goToLogin(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- SIGN UP BUTTON ---
                        MouseRegion(
                          onEnter: (_) => hoveredButton.value = 2,
                          onExit: (_) => hoveredButton.value = 0,
                          child: _buildWelcomeButton(
                            text: 'Sign up',
                            // Signup default mein filled (0 ya 2),
                            // Lekin agar Login par hover hai (1), to ye outlined ho jaye
                            isFilled: hoveredButton.value != 1,
                            brandColor: brandTeal,
                            greyColor: normalGrey,
                            onPressed: () => controller.goToCreateAccount(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 SYNCED BUTTON UI
  Widget _buildWelcomeButton({
    required String text,
    required bool isFilled,
    required Color brandColor,
    required Color greyColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isFilled ? brandColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isFilled ? null : Border.all(color: greyColor, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFilled ? Colors.white : Colors.black,
              ),
            ),
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
