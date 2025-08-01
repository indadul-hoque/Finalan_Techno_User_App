import 'dart:async';
import 'dart:io';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';

import '../../theme/theme.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({Key? key}) : super(key: key);

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              backgroundImage(size),
              backArrow(context),
              pintitle(size),
              enterPinDetails(size, context),
            ],
          ),
        ),
      ),
    );
  }

  enterPinDetails(Size size, BuildContext context) {
    return Positioned(
      top: size.height * 0.16,
      left: 0,
      right: 0,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.457,
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2, vertical: fixPadding),
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
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          physics: const BouncingScrollPhysics(),
          children: [
            heightSpace,
            heightSpace,
            welcomeText(),
            contentText(),
            heightSpace,
            heightSpace,
            heightSpace,
            height5Space,
            Pinput(
              length: 4,
              cursor: Container(
                height: 22.0,
                width: 1.5,
                color: primaryColor,
              ),
              onCompleted: (value) {
                Timer(const Duration(seconds: 3), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/bottomNavigation', (route) => false);
                });
                waitDialog();
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
            height5Space,
            continueButton(size),
          ],
        ),
      ),
    );
  }

  contentText() {
    return Text(
      getTranslation(context, 'enter_pin.text'),
      textAlign: TextAlign.center,
      style: semibold16Black33,
    );
  }

  welcomeText() {
    return Text(
      getTranslation(context, 'enter_pin.welcome'),
      style: bold22Black,
      textAlign: TextAlign.center,
    );
  }

  pintitle(Size size) {
    return Positioned(
      top: size.height * 0.09,
      left: 0,
      right: 0,
      child: Text(
        getTranslation(context, 'enter_pin.enter_pin'),
        style: bold25White,
        textAlign: TextAlign.center,
      ),
    );
  }

  backArrow(BuildContext context) {
    return Positioned(
      top: (Platform.isIOS) ? 40 : 20,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
            icon: const Icon(
              Icons.arrow_back,
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  backgroundImage(Size size) {
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

  continueButton(Size size) {
    return GestureDetector(
      onTap: () {
        Timer(const Duration(seconds: 3), () {
          Navigator.pushNamedAndRemoveUntil(
              context, '/bottomNavigation', (route) => false);
        });
        waitDialog();
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
          getTranslation(context, 'enter_pin.continue'),
          style: bold18White,
        ),
      ),
    );
  }

  waitDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: fixPadding * 3, horizontal: fixPadding),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinKitFadingCircle(
                color: primaryColor,
                size: 40,
              ),
              heightSpace,
              Text(
                getTranslation(context, 'enter_pin.please_wait'),
                style: bold16Primary,
              )
            ],
          ),
        );
      },
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
}
