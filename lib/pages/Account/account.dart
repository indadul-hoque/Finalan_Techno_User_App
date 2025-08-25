import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_banking_app/services/kyc_service.dart';

import '../../theme/theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/deposite/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: primaryColor.withValues(alpha: 0.5),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light),
        title: Text(
          getTranslation(context, 'account.account'),
          style: bold20White,
        ),
      ),
      body: Column(
        children: [
          userInfo(size, context),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: fixPadding),
                physics: const BouncingScrollPhysics()),
          )
        ],
      ),
    );
  }

  tileWidget(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      leading: Container(
        height: 35,
        width: 35,
        decoration: const BoxDecoration(
          color: Color(0xFfDFDFDF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: primaryColor,
          size: 18,
        ),
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: semibold15Black,
      ),
    );
  }

  userInfo(Size size, BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5, horizontal: fixPadding * 2),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: size.height * 0.08,
            width: size.height * 0.08,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  "assets/profile/profileImage.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  KYCService.kycData?['name'] ?? "User Name",
                  style: bold16Black33,
                ),
                heightBox(3.0),
                Text(
                  KYCService.kycData?['phone'] ?? "+91 1234567890",
                  style: semibold14Grey94,
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
            icon: const Icon(
              FontAwesomeIcons.penToSquare,
              color: primaryColor,
              size: 18,
            ),
          )
        ],
      ),
    );
  }
}
