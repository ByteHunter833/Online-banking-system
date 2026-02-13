// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Dots animation controller
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _dotsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _dotsController.repeat(reverse: true);

    // Navigate to next screen after delay
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(), // Replace with your next screen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B4CCC),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated decorative dots in background
            ..._buildBackgroundDots(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo/icon
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // App name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'SecureAuth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Your Security, Our Priority',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoadingIndicator(),
                  ),
                ],
              ),
            ),

            // Version text at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield icon
          const Icon(Icons.shield_outlined, size: 80, color: Color(0xFF5B4CCC)),

          // Lock in center
          Positioned(
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4CCC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          // Custom loading bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _dotsAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Loading text
          const Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundDots() {
    return [
      // Top left
      Positioned(
        top: 50,
        left: 30,
        child: _buildAnimatedDot(color: Colors.white24, size: 60, delay: 0),
      ),
      Positioned(
        top: 100,
        left: 80,
        child: _buildAnimatedDot(color: Colors.white12, size: 40, delay: 0.5),
      ),

      // Top right
      Positioned(
        top: 70,
        right: 40,
        child: _buildAnimatedDot(color: Colors.white24, size: 50, delay: 0.3),
      ),
      Positioned(
        top: 150,
        right: 30,
        child: _buildAnimatedDot(color: Colors.white12, size: 35, delay: 0.7),
      ),

      // Bottom left
      Positioned(
        bottom: 100,
        left: 50,
        child: _buildAnimatedDot(color: Colors.white24, size: 45, delay: 0.2),
      ),
      Positioned(
        bottom: 150,
        left: 25,
        child: _buildAnimatedDot(color: Colors.white12, size: 55, delay: 0.6),
      ),

      // Bottom right
      Positioned(
        bottom: 120,
        right: 60,
        child: _buildAnimatedDot(color: Colors.white24, size: 50, delay: 0.4),
      ),
      Positioned(
        bottom: 180,
        right: 35,
        child: _buildAnimatedDot(color: Colors.white12, size: 38, delay: 0.8),
      ),

      // Middle dots
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 40,
        child: _buildAnimatedDot(color: Colors.white12, size: 42, delay: 0.1),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.6,
        right: 50,
        child: _buildAnimatedDot(color: Colors.white12, size: 48, delay: 0.9),
      ),
    ];
  }

  Widget _buildAnimatedDot({
    required Color color,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final animationValue = (_dotsController.value + delay) % 1.0;
        final scale = 0.8 + (0.2 * animationValue);
        final opacity = 0.3 + (0.4 * animationValue);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Import this at the top of the file
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder - replace with your actual AuthScreen
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Screen')),
      body: const Center(
        child: Text('Replace this with your AuthScreen widget'),
      ),
    );
  }
}
