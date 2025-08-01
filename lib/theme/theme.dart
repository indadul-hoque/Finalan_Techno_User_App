import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF0077E6);
const Color blackColor = Colors.black;
const Color whiteColor = Colors.white;
const Color black33Color = Color(0xFF333333);
const Color grey94Color = Color(0xFF949494);
const Color greenColor = Color(0xFF478616);
const Color redColor = Color(0xFFC00E0E);
const Color grey87Color = Color(0xFF878686);
const Color greyD9Color = Color(0xFFD9D9D9);
const Color scaffoldBgColor = Color(0xFFF2F2F2);

const double fixPadding = 10.0;

const SizedBox height5Space = SizedBox(height: fixPadding / 2);
const SizedBox heightSpace = SizedBox(height: fixPadding);
const SizedBox width5Space = SizedBox(width: fixPadding / 2);
const SizedBox widthSpace = SizedBox(width: fixPadding);

SizedBox heightBox(double height) {
  return SizedBox(height: height);
}

SizedBox widthBox(double width) {
  return SizedBox(width: width);
}

const TextStyle interSemibold25White = TextStyle(
    color: whiteColor,
    fontWeight: FontWeight.w600,
    fontSize: 25,
    fontFamily: 'Inter');

const TextStyle interSemibold20White = TextStyle(
    color: whiteColor,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    fontFamily: 'Inter');

const TextStyle interSemibold22Primary = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    fontFamily: 'Inter');

const TextStyle bold20Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 20);

const TextStyle bold20Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 20);

const TextStyle bold22Black =
    TextStyle(color: blackColor, fontWeight: FontWeight.w700, fontSize: 22);

const TextStyle bold18Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 18);

const TextStyle bold16Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 16);

const TextStyle bold17Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 17);

const TextStyle bold16White =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w700, fontSize: 16);

const TextStyle bold15Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 15);

const TextStyle bold20White =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w700, fontSize: 20);

const TextStyle bold18White =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w700, fontSize: 18);

const TextStyle bold18GreyD6 = TextStyle(
    color: Color(0xFfD6D6D6), fontWeight: FontWeight.w700, fontSize: 18);

const TextStyle bold22GreyD6 = TextStyle(
    color: Color(0xFfD6D6D6), fontWeight: FontWeight.w700, fontSize: 22);

const TextStyle bold16Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 16);

const TextStyle bold18Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 18);

const TextStyle bold16Grey87 =
    TextStyle(color: grey87Color, fontWeight: FontWeight.w700, fontSize: 16);

const TextStyle bold18Grey87 =
    TextStyle(color: grey87Color, fontWeight: FontWeight.w700, fontSize: 18);

const TextStyle bold14Grey87 =
    TextStyle(color: grey87Color, fontWeight: FontWeight.w700, fontSize: 14);

const TextStyle bold14Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w700, fontSize: 14);

const TextStyle bold15Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 15);

const TextStyle bold14Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 14);

const TextStyle bold15Red =
    TextStyle(color: redColor, fontWeight: FontWeight.w700, fontSize: 15);

const TextStyle bold15Green =
    TextStyle(color: greenColor, fontWeight: FontWeight.w700, fontSize: 15);

const TextStyle bold14EE = TextStyle(
    color: Color(0xFFEED9D9), fontWeight: FontWeight.w700, fontSize: 14);

const TextStyle bold12Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w700, fontSize: 12);

const TextStyle bold14Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w700, fontSize: 14);

const TextStyle bold15Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w700, fontSize: 15);

const TextStyle bold25White =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w700, fontSize: 25);

const TextStyle semibold14Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w600, fontSize: 14);

const TextStyle semibold15Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w600, fontSize: 15);

const TextStyle semibold14EE = TextStyle(
    color: Color(0xFFEED9D9), fontWeight: FontWeight.w600, fontSize: 14);

const TextStyle semibold16Grey94 =
    TextStyle(color: grey94Color, fontWeight: FontWeight.w600, fontSize: 16);

const TextStyle semibold12Grey87 =
    TextStyle(color: grey87Color, fontWeight: FontWeight.w600, fontSize: 12);

const TextStyle semibold14Grey87 =
    TextStyle(color: grey87Color, fontWeight: FontWeight.w600, fontSize: 14);

const TextStyle semibold16Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w600, fontSize: 16);

const TextStyle semibold18Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w600, fontSize: 18);

const TextStyle semibold16White =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w600, fontSize: 16);

const TextStyle semibold15Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w600, fontSize: 15);

const TextStyle semibold14Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w600, fontSize: 14);

const TextStyle semibold15Red =
    TextStyle(color: redColor, fontWeight: FontWeight.w600, fontSize: 15);

const TextStyle semibold15Black =
    TextStyle(color: blackColor, fontWeight: FontWeight.w600, fontSize: 15);

const TextStyle semibold20Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20);

const TextStyle semibold14Primary =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14);

const TextStyle regular15Black33 =
    TextStyle(color: black33Color, fontWeight: FontWeight.w400, fontSize: 15);

const TextStyle snackBarStyle =
    TextStyle(color: whiteColor, fontWeight: FontWeight.w600, fontSize: 15);

const TextStyle appBarStyle =
    TextStyle(color: black33Color, fontSize: 20.0, fontWeight: FontWeight.w700);
