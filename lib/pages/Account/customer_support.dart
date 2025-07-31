import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        shadowColor: blackColor.withValues(alpha: 0.4),
        backgroundColor: scaffoldBgColor,
        foregroundColor: black33Color,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'customer_support.customer_support'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2),
        physics: const BouncingScrollPhysics(),
        children: [
          topImage(size),
          heightSpace,
          contentText(),
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          messageField(size),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          submitButton(context),
        ],
      ),
    );
  }

  submitButton(BuildContext context) {
    return GestureDetector(
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
              offset: const Offset(0.0, 6.0),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'customer_support.submit'),
          style: bold18White,
        ),
      ),
    );
  }

  messageField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'customer_support.message'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          height: size.height * 0.16,
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
            keyboardType: TextInputType.text,
            expands: true,
            maxLines: null,
            minLines: null,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  getTranslation(context, 'customer_support.enter_message'),
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'customer_support.email_address'),
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
            keyboardType: TextInputType.emailAddress,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(
                  context, 'customer_support.enter_email_address'),
              hintStyle: semibold15Grey94,
            ),
          ),
        )
      ],
    );
  }

  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'customer_support.name'),
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
            keyboardType: TextInputType.name,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'customer_support.enter_name'),
              hintStyle: semibold15Grey94,
            ),
          ),
        )
      ],
    );
  }

  contentText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'customer_support.text'),
        style: semibold18Black33,
        textAlign: TextAlign.center,
      ),
    );
  }

  topImage(Size size) {
    return Center(
      child: Image.asset(
        "assets/profile/Contact us-pana 1.png",
        height: size.height * 0.17,
        fit: BoxFit.cover,
      ),
    );
  }
}
