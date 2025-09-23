import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widgets/biometric_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoFadeAnimation;

  final String _fullText = "Finalan Techno";
  String _visibleText = "";
  int _textIndex = 0;

  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();

    // Logo fade controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Start logo fade
    _logoController.forward();

    // Start typewriter text after logo finishes
    Future.delayed(const Duration(seconds: 1), () {
      _startTypewriter();
      _startCursorBlink();
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (phoneNumber == null || phoneNumber.isEmpty || !isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BiometricGate()),
      );
    }
  }

  void _startTypewriter() {
    Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _visibleText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 16, 17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: Image.asset(
                "assets/splash/mdi_star-three-points-outline.png",
                height: 70,
                width: 70,
              ),
            ),
            height5Space,
            Text(
              "$_visibleText${_showCursor ? '|' : ''}",
              style: interSemibold25White,
            ),
          ],
        ),
      ),
    );
  }
}
