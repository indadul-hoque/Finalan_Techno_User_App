import 'dart:io';

import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';

import '../../theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
            children: [
              backgroundImageBox(size),
              backButton(context),
              register(size),
              registerDetails(size, context)
            ],
          ),
        ),
      ),
    );
  }

  registerDetails(Size size, BuildContext context) {
    return Positioned(
      top: size.height * 0.16,
      left: 0,
      right: 0,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.63,
        padding: const EdgeInsets.symmetric(vertical: fixPadding),
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
          padding: EdgeInsets.only(
              left: fixPadding * 2,
              right: fixPadding * 2,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          children: [
            image(size),
            heightSpace,
            nameField(context),
            heightSpace,
            heightSpace,
            phoneField(context),
            heightSpace,
            heightSpace,
            emailField(context),
            heightSpace,
            heightSpace,
            heightSpace,
            height5Space,
            registerButton(size),
            heightSpace,
            height5Space,
          ],
        ),
      ),
    );
  }

  backButton(BuildContext context) {
    return Positioned(
      top: (Platform.isIOS) ? 40 : 20,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        icon: const Icon(
          Icons.arrow_back,
          color: whiteColor,
        ),
      ),
    );
  }

  register(Size size) {
    return Positioned(
      top: size.height * 0.09,
      left: 0,
      right: 0,
      child: Text(
        getTranslation(context, 'register.register'),
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

  registerButton(Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/otp');
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
          getTranslation(context, 'register.register'),
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

  phoneField(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
        child: TextField(
          style: semibold16Black33,
          textAlignVertical: TextAlignVertical.center,
          controller: phoneController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: getTranslation(context, 'register.enter_mobile_number'),
            hintStyle: semibold16Grey94,
            prefixIcon: const Icon(
              Icons.call_outlined,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  nameField(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
        child: TextField(
          style: semibold16Black33,
          textAlignVertical: TextAlignVertical.center,
          controller: nameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: getTranslation(context, 'register.enter_your_name'),
            hintStyle: semibold16Grey94,
            prefixIcon: const Icon(
              Icons.person_outline,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  emailField(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
        child: TextField(
          style: semibold16Black33,
          textAlignVertical: TextAlignVertical.center,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: getTranslation(context, 'register.enter_your_email'),
            hintStyle: semibold16Grey94,
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
