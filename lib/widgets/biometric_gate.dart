import 'package:flutter/material.dart';
import 'package:fl_banking_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BiometricGate extends StatefulWidget {
  const BiometricGate({Key? key}) : super(key: key);

  @override
  _BiometricGateState createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: isError ? Colors.red : Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _checkBiometrics() async {
    final isEnabled = await _authService.isBiometricEnabled();

    if (isEnabled) {
      final authenticated = await _authService.authenticate();
      if (authenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottomNavigation',
          (route) => false,
        );
      } else {
        setState(() {
          _isAuthenticating = false;
        });
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/bottomNavigation',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Authentication required'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAuthenticating = true;
                  _checkBiometrics();
                });
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

