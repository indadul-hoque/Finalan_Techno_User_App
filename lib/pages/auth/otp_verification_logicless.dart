import 'dart:io';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import '../../theme/theme.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);
  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  DateTime? backPressTime;
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
              cursor: Container(
                height: 22.0,
                width: 1.5,
                color: primaryColor,
              ),
              onCompleted: (value) {
                // Navigation is now handled exclusively by the Pinput on completion
                Navigator.pushNamed(context, '/bottomNavigation');
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
        onPressed: () {},
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.resolveWith(
              (states) => primaryColor.withValues(alpha: 0.1)),
        ),
        child: Text(
          getTranslation(context, 'otp.resend'),
          style: bold15Grey94,
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
      onTap: () {
        // You can add your OTP verification logic here if needed.
        // The navigation has been moved to the Pinput widget.
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
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

