import 'dart:async';
import 'dart:io';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import '../../theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_banking_app/services/auth_service.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);
  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  bool _isResendEnabled = false;
  int _resendSeconds = 30;
  Timer? _resendTimer;
  DateTime? backPressTime;
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the phone number passed from the previous screen
    _phoneNumber = ModalRoute.of(context)!.settings.arguments as String?;
  }

  @override
void dispose() {
  _resendTimer?.cancel();
  _otpController.dispose();
  super.dispose();
}


  @override
	void initState() {
	  super.initState();
	  _startResendTimer();
	}

  void _startResendTimer() {
  setState(() {
    _isResendEnabled = false;
    _resendSeconds = 30;
  });
  _resendTimer?.cancel();
  _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_resendSeconds == 0) {
      setState(() {
        _isResendEnabled = true;
      });
      timer.cancel();
    } else {
      setState(() {
        _resendSeconds--;
      });
    }
  });
}


Future<void> _verifyOtp() async {
  final otp = _otpController.text;
  if (otp.isEmpty || otp.length < 4) {
    _showToast('Please enter a 4-digit OTP.');
    return;
  }

  setState(() => _isLoading = true);
  
  final url = Uri.parse('https://api.cornix.tech/verify/$_phoneNumber/otp/$otp');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      _showToast('OTP verified successfully!');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', _phoneNumber!);
      await prefs.setBool('isLoggedIn', true);
      
      final authService = AuthService();
      final hasBiometrics = await authService.hasBiometricCapability();
      if (hasBiometrics) {
        final shouldEnable = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Enable Biometric Authentication?'),
            content: Text('Secure your account with fingerprint or face recognition for faster access'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Not Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Enable'),
              ),
            ],
          ),
        );
        
        if (shouldEnable ?? false) {
          final authenticated = await authService.authenticate();
          if (authenticated) {
            await authService.setBiometricEnabled(true);
          }
        }
      }
      
      Navigator.pushNamedAndRemoveUntil(
  context,
  '/bottomNavigation',
  (route) => false
);

    } else {
      final responseData = jsonDecode(response.body);
      _showToast(responseData['message'] ?? 'Invalid OTP. Please try again.');
    }
  } catch (e) {
    _showToast('An error occurred. Check your connection.');
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _resendOtp() async {
  if (!_isResendEnabled) return; // Do nothing if disabled

  setState(() {
    _isLoading = true;
  });

  final url = Uri.parse('https://api.cornix.tech/login'); // Same endpoint as login for OTP send

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': _phoneNumber}),
    );
    if (response.statusCode == 200) {
      _showToast('New OTP sent successfully!');
      _startResendTimer(); // Restart timer after successful resend
    } else {
      final responseData = jsonDecode(response.body);
      _showToast(responseData['message'] ?? 'Failed to resend OTP.');
    }
  } catch (e) {
    _showToast('An error occurred. Please try again.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _showToast(String message, {bool isError = false}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,  // Increased duration
    backgroundColor: isError ? Colors.red : Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              children: [
                backgroundImageBox(size),
                otpText(size),
                otpVerificationDetails(size, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  otpVerificationDetails(Size size, BuildContext context) {
    return Positioned(
      top: size.height * 0.16,
      left: 0,
      right: 0,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.63,
        padding: const EdgeInsets.all(fixPadding * 2),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          children: [
            heightSpace,
            image(size),
            heightSpace,
            contentText(),
            heightSpace,
            heightSpace,
            heightSpace,
            Pinput(
              length: 4,
              controller: _otpController, // Add controller to get the OTP value
              cursor: Container(
                height: 22.0,
                width: 1.5,
                color: primaryColor,
              ),
              onCompleted: (value) {
                // Call the verification logic when Pinput is completed
                _verifyOtp();
              },
              defaultPinTheme: PinTheme(
                height: 48.0,
                width: 48.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: fixPadding / 1.7),
                textStyle: semibold20Primary,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ),
            heightSpace,
            heightSpace,
            heightSpace,
            heightSpace,
            verifyButton(size),
            resendButton(),
          ],
        ),
      ),
    );
  }

  resendButton() {
  return Center(
    child: TextButton(
      onPressed: (_isLoading || !_isResendEnabled) ? null : _resendOtp,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => primaryColor.withOpacity(0.1),
        ),
      ),
      child: Text(
        _isResendEnabled
            ? getTranslation(context, 'otp.resend')
            : 'Resend OTP in ${_resendSeconds}s',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _isResendEnabled ? Colors.black : Colors.grey,
          fontSize: 15,
        ),
      ),
    ),
  );
}


  otpText(Size size) {
    return Positioned(
      top: size.height * 0.09,
      left: 0,
      right: 0,
      child: Text(
        getTranslation(context, 'otp.otp_verification'),
        style: bold25White,
        textAlign: TextAlign.center,
      ),
    );
  }

  title() {
    return const Text(
      "Finalan Techno",
      style: interSemibold22Primary,
      textAlign: TextAlign.center,
    );
  }

  logo() {
    return Image.asset(
      "assets/splash/mdi_star-three-points-outline.png",
      height: 50,
      width: 50,
      color: primaryColor,
    );
  }

  backgroundImageBox(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShapeOfView(
          height: size.height * 0.33,
          width: double.maxFinite,
          elevation: 0,
          shape: ArcShape(
            direction: ArcDirection.Outside,
            height: 35,
            position: ArcPosition.Bottom,
          ),
          child: Image.asset(
            "assets/auth/bgImage.png",
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            logo(),
            height5Space,
            title(),
            heightSpace,
            heightSpace,
          ],
        ),
      ],
    );
  }

  verifyButton(Size size) {
    return GestureDetector(
      // Call the new _verifyOtp function
      onTap: _isLoading ? null : _verifyOtp,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // Change button color when loading
          color: _isLoading ? Colors.grey : primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const CircularProgressIndicator(color: whiteColor)
            : Text(
                getTranslation(context, 'otp.verify'),
                style: bold18White,
              ),
      ),
    );
  }

  image(Size size) {
    return Center(
      child: Image.asset(
        "assets/auth/Mobile-login-bro.png",
        height: size.height * 0.15,
        width: size.height * 0.15,
        fit: BoxFit.cover,
      ),
    );
  }

  contentText() {
    return Text(
      getTranslation(context, 'otp.otp_text'),
      style: semibold14Grey94,
      textAlign: TextAlign.center,
    );
  }

  onWillPop() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

