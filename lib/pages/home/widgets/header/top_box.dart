import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/home/widgets/header/optimized_account_card.dart';

import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class TopBox extends StatelessWidget {
  final Size size;
  final String? userName;
  final List<Map<String, dynamic>> accountList;

  const TopBox({
    Key? key,
    required this.size,
    required this.userName,
    required this.accountList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.5),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightSpace,
              topTitle(context),
              heightSpace,
              height5Space,
              accountTypeList(context),
              heightSpace,
              height5Space,
            ],
          ),
        ),
      ),
    );
  }

  Widget topTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/splash/mdi_star-three-points-outline.png",
                height: 28,
                width: 28,
                color: whiteColor,
              ),
              widthSpace,
              Text(
                "Hi, ${userName ?? 'User'}",
                style: interSemibold20White,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget accountTypeList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: fixPadding),
      child: Row(
        children: List.generate(
          accountList.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding),
            child: OptimizedAccountCard(
              accountData: accountList[index],
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}