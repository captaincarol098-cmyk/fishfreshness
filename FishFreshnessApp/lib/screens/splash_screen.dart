import 'package:flutter/material.dart';
import '../services/ml_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial minimum delay to show off the splash screen animation
    final minimumDelay = Future.delayed(const Duration(seconds: 2));

    // Initialize ML service
    final initML = Future.microtask(() async {
      try {
        final success = await MLService.initialize();
        if (success) {
          print('ML Service initialized successfully');
        } else {
          print('ML Service initialization failed - using demo mode');
        }
      } catch (e) {
        print('Error initializing ML service: $e - using demo mode');
      }
    });

    await Future.wait([minimumDelay, initML]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD), // Light transparent-like bg
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image (we fall back to a built widget if asset is missing)
              Image.asset(
                'assets/logo.jpg',
                width: 220,
                height: 220,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackLogo();
                },
              ),
              const SizedBox(height: 40),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Initializing AI Models...',
                style: TextStyle(
                  color: Color(0xFF5A7DA8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A fallback logo using Flutter widgets just in case the actual logo.png is not found
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Radar waves
            Icon(Icons.wifi, size: 100, color: const Color(0xFF64B5F6).withOpacity(0.5)),
            // Fish icon
            const Icon(Icons.set_meal, size: 80, color: Color(0xFF1565C0)),
            // Arrow (approximate)
            Positioned(
              right: 0,
              top: 20,
              child: Transform.rotate(
                angle: -0.5,
                child: const Icon(Icons.arrow_forward, color: Color(0xFF00B0FF), size: 30),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'FRESHFISH',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'DETECT',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D47A1),
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ADVANCED FRESHNESS TECHNOLOGY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1565C0),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
