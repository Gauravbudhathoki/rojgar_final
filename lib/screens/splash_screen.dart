import 'package:flutter/material.dart';
import 'package:rojgar/feature/onboarding/presentation/pages/onboarding_screen.dart';
import 'dart:async';

// import '../on_boarding_pages/page1.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();


    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/rojgarlogo.png',
                width: 150, // Optional: adjust logo size
                height: 150,
              ),
              const SizedBox(height: 22),
              const Text(
                "Rojgar",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Job Finder & Career Opportunities",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}