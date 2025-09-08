import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onepicker/controllers/LoginController.dart';
import 'package:onepicker/theme/AppTheme.dart';
import 'dart:math' as math;

import 'package:onepicker/view/Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put((LoginController()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'One Picker',
      theme: AppTheme.theme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _waveController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse animation for medical cross
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_floatingController);

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    _floatingController.repeat();
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
    _mainController.forward();

    // Navigate to home page after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _floatingController,
          _waveController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppTheme.background,
                  AppTheme.lightTeal,
                  AppTheme.primaryTeal.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated wave background
                CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: WavePainter(_waveAnimation.value),
                ),

                // Floating medical icons
                ...List.generate(15, (index) => _buildFloatingIcon(index)),

                // Animated circles
                _buildAnimatedCircle(
                  top: 80,
                  left: 30,
                  size: 100,
                  color: AppTheme.lightTeal.withOpacity(0.15),
                  delay: 0,
                ),
                _buildAnimatedCircle(
                  bottom: 120,
                  right: 50,
                  size: 150,
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  delay: 1,
                ),
                _buildAnimatedCircle(
                  top: 200,
                  right: 80,
                  size: 80,
                  color: AppTheme.warmAccent.withOpacity(0.12),
                  delay: 0.5,
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Medical logo with pulse effect
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryTeal,
                                    AppTheme.lightTeal,
                                    AppTheme.accentGreen,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryTeal.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: AppTheme.lightTeal.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // App name with slide animation
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppTheme.primaryTeal,
                                    AppTheme.lightTeal,
                                    AppTheme.accentGreen,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'One Picker',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.warmAccent.withOpacity(0.2),
                                      AppTheme.accentGreen.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: AppTheme.lightTeal.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Hassle-Free Picking. Smart,Perfect Checking.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Progress indicator with medical theme
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: 250,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.lightTeal,
                                    AppTheme.primaryTeal.withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: _progressAnimation.value,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTeal,
                                    ),
                                    minHeight: 6,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading Health Solutions...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryTeal.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingIcon(int index) {
    final icons = [
      Icons.medical_services,
      Icons.healing,
      Icons.favorite,
      Icons.health_and_safety,
      Icons.medication,
      Icons.vaccines,
      Icons.monitor_heart,
    ];

    final random = math.Random(index);
    final size = 20.0 + random.nextDouble() * 15;
    final initialX = random.nextDouble();
    final initialY = random.nextDouble();
    final speed = 0.3 + random.nextDouble() * 0.4;

    return Positioned(
      left: MediaQuery.of(context).size.width * initialX,
      top: MediaQuery.of(context).size.height * initialY,
      child: Transform.translate(
        offset: Offset(
          math.sin(_floatingAnimation.value * 2 * math.pi + index * 0.5) * 20,
          math.cos(_floatingAnimation.value * math.pi + index * 0.3) * 15,
        ),
        child: Opacity(
          opacity: 0.4 + 0.3 * math.sin(_floatingAnimation.value * math.pi + index),
          child: Icon(
            icons[index % icons.length],
            size: size,
            color: [
              AppTheme.primaryTeal,
              AppTheme.lightTeal,
              AppTheme.accentGreen,
              AppTheme.warmAccent,
            ][index % 4],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double delay,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.scale(
        scale: 0.7 + 0.3 * math.sin(_floatingAnimation.value * 2 * math.pi + delay * math.pi),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom wave painter for background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryTeal.withOpacity(0.1),
          AppTheme.lightTeal.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x++) {
      double y = size.height * 0.7 +
          30 * math.sin((x / size.width * 2 * math.pi) + animationValue) +
          15 * math.cos((x / size.width * 4 * math.pi) + animationValue * 1.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'One Picker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.lightTeal],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTeal.withOpacity(0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryTeal.withOpacity(0.1),
                      AppTheme.lightTeal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 80,
                      color: AppTheme.lightTeal,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to Pharma Care!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your trusted medical companion\nfor better health management',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


