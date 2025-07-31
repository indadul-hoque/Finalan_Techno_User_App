import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({Key? key}) : super(key: key);

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  TextEditingController currentpPinController = TextEditingController();
  TextEditingController confiemPinController = TextEditingController();
  TextEditingController newPinCpntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        shadowColor: blackColor.withValues(alpha: 0.4),
        foregroundColor: black33Color,
        backgroundColor: scaffoldBgColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0.0,
        title: Text(
          getTranslation(context, 'change_pin.change_pin'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2),
        children: [
          currentPinField(),
          heightSpace,
          heightSpace,
          newpinField(context),
          heightSpace,
          heightSpace,
          confirmpinfield(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          resetButton(context),
        ],
      ),
    );
  }

  resetButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
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
          getTranslation(context, 'change_pin.reset'),
          style: bold18White,
        ),
      ),
    );
  }

  confirmpinfield() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'change_pin.confirm_pin'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: confiemPinController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'change_pin.confirm_pin_text'),
              hintStyle: semibold15Grey94,
            ),
          ),
        )
      ],
    );
  }

  newpinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'change_pin.new_pin'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            cursorColor: primaryColor,
            controller: newPinCpntroller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'change_pin.enter_new_pin'),
              hintStyle: semibold15Grey94,
            ),
          ),
        )
      ],
    );
  }

  currentPinField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'change_pin.current_pin'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: currentpPinController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'change_pin.enter_current_pin'),
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }
}
