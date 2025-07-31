import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class EducationLoan extends StatefulWidget {
  const EducationLoan({Key? key}) : super(key: key);

  @override
  State<EducationLoan> createState() => _EducationLoanState();
}

class _EducationLoanState extends State<EducationLoan> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          getTranslation(context, 'education_loan.education_loan'),
          style: bold20Black33,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: fixPadding * 2),
        physics: const BouncingScrollPhysics(),
        children: [
          topImage(size),
          descriptionText(),
          dottedline(),
          heightSpace,
          heightSpace,
          phoneTitle(),
          heightSpace,
          phoneField(),
          heightSpace,
          heightSpace,
          messageTitle(),
          heightSpace,
          messageField(size),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          iamInterestedButton(),
        ],
      ),
    );
  }

  iamInterestedButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.all(fixPadding * 2),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslation(context, 'education_loan.education_loan'),
                  style: bold18Primary,
                  textAlign: TextAlign.center,
                ),
                heightSpace,
                Text(
                  getTranslation(context, 'education_loan.thank_you'),
                  style: bold16Black33,
                  textAlign: TextAlign.center,
                ),
                const Divider(
                  thickness: 1.5,
                  color: greyD9Color,
                  height: 30,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      getTranslation(context, 'education_loan.okay'),
                      style: bold18Primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        decoration: BoxDecoration(
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'education_loan.interested'),
          style: bold18White,
        ),
      ),
    );
  }

  messageField(Size size) {
    return Container(
      height: size.height * 0.14,
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
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
        expands: true,
        maxLines: null,
        minLines: null,
        style: semibold15Black33,
        controller: messageController,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              getTranslation(context, 'education_loan.write_your_message'),
          hintStyle: semibold15Grey94,
        ),
      ),
    );
  }

  messageTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'education_loan.message'),
        style: bold17Black33,
      ),
    );
  }

  phoneField() {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
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
        controller: phoneController,
        keyboardType: TextInputType.phone,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              getTranslation(context, 'education_loan.enter_phone_number'),
          hintStyle: semibold15Grey94,
        ),
      ),
    );
  }

  phoneTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, "education_loan.phone_number"),
        style: bold17Black33,
      ),
    );
  }

  dottedline() {
    return DottedBorder(
      dashPattern: const [2, 3],
      padding: EdgeInsets.zero,
      color: grey87Color,
      child: Container(),
    );
  }

  descriptionText() {
    return const Padding(
      padding: EdgeInsets.all(fixPadding * 2),
      child: Text(
        "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. ",
        style: semibold14Grey87,
      ),
    );
  }

  topImage(Size size) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 2),
      height: size.height * 0.25,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/loan/image1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Text(
          "Make education\nyour top priority",
          style: bold18Primary,
        ),
      ),
    );
  }
}
