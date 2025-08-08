import 'package:flutter/material.dart';
import 'package:fl_banking_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;
  
  const BiometricGate({Key? key, required this.child}) : super(key: key);

  @override
  _BiometricGateState createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = true;
  bool _authSuccess = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _showToast(String message, {bool isError = false}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,      // Duration
    gravity: ToastGravity.BOTTOM,        // Position
    timeInSecForIosWeb: 5,               // iOS/web duration
    backgroundColor: isError ? Colors.red : Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

  Future<void> _checkBiometrics() async {
    _showToast('Checking biometric settings...');
    final isEnabled = await _authService.isBiometricEnabled();
    _showToast('Biometric enabled in settings: $isEnabled');
    if (isEnabled) {
      _showToast('Starting biometric authentication...');
      final authenticated = await _authService.authenticate();
      setState(() {
        _authSuccess = authenticated;
        _isAuthenticating = false;
      });
    } else {
      setState(() {
        _authSuccess = true;
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_authSuccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Authentication required'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkBiometrics,
                child: Text('Try Again'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/login', 
                    (route) => false
                  );
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
