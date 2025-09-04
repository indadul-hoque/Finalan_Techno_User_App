import 'dart:io';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/Account/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import '../../theme/theme.dart';
// Import http for API calls
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import fluttertoast for showing toast messages
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  DateTime? backPressTime;
  // State variable to manage the loading indicator
  bool _isLoading = false;

  // Function to handle the API call
  Future<void> _handleLogin() async {
    // Check if the phone number is entered
    String? phoneNumber = phoneController.text;
    if (phoneNumber.isEmpty) {
      _showToast('Please enter your phone number.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('https://api.cornix.tech/login');

    try {
      final response = await http.post(
        url,
        headers: {
        'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        // API call was successful
        final responseData = jsonDecode(response.body);
        print('Login successful: $responseData');
        _showToast('OTP sent successfully!');

        // Navigate to the OTP screen, passing the phone number for verification
        Navigator.pushNamed(context, '/otp', arguments: phoneNumber);
      } else {
        _showToast('Sign Up first to use the Application!');
      }
    } catch (e) {
      print('An error occurred: $e');
      _showToast('An error occurred. Check your connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black54,
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
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Stack(
                children: [
                  backgroundImageBox(size),
                  loginText(size),
                  loginDetails(size, context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  loginDetails(Size size, BuildContext context) {
    return Positioned(
      top: size.height * 0.16,
      left: 0,
      right: 0,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.63,
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
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
          padding: EdgeInsets.only(
              left: fixPadding * 2,
              right: fixPadding * 2,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            heightSpace,
            image(size),
            heightSpace,
            heightSpace,
            welcomeText(),
            contentText(),
            heightSpace,
            heightSpace,
            heightSpace,
            height5Space,
            phoneField(context),
            heightSpace,
            heightSpace,
            heightSpace,
            heightSpace,
            loginButton(size),
            heightSpace,
            heightSpace,
            height5Space,
          ],
        ),
      ),
    );
  }

  loginText(Size size) {
    return Positioned(
      top: size.height * 0.09,
      left: 0,
      right: 0,
      child: Text(
        getTranslation(context, 'login.login'),
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

  loginButton(Size size) {
    return GestureDetector(
      // Use the new _handleLogin function
      onTap: _isLoading ? null : _handleLogin,
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
                getTranslation(context, 'login.login'),
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
      getTranslation(context, 'login.text'),
      style: semibold14Grey94,
      textAlign: TextAlign.center,
    );
  }

  welcomeText() {
    return Text(
      getTranslation(context, 'login.welcome_back'),
      style: bold18Black33,
      textAlign: TextAlign.center,
    );
  }

  phoneField(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
          ),
        ),
        child: IntlPhoneField(
          disableLengthCheck: true,
          textAlignVertical: TextAlignVertical.center,
          dropdownTextStyle: semibold16Black33,
          textAlign: selectedValue == 'عربى' ? TextAlign.right : TextAlign.left,
          showCountryFlag: false,
          initialCountryCode: 'IN',
          dropdownIconPosition: IconPosition.trailing,
          dropdownIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: black33Color,
          ),
          controller: phoneController,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: whiteColor,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: getTranslation(context, 'login.enter_number'),
            hintStyle: semibold16Grey94,
          ),
        ),
      ),
    );
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) >= const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: blackColor,
          content: Text(
            getTranslation(context, 'exit_app.app_exit'),
            style: snackBarStyle,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}

