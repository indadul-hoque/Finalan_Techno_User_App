import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: black33Color,
        backgroundColor: scaffoldBgColor,
        shadowColor: blackColor.withValues(alpha: 0.4),
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'terms_condition.terms_condition'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2),
        children: [
          logo(size),
          heightSpace,
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. Lorem ipsum dolor sit amet consectetur. Dolposueretellus a volutpat aliquam vestibulum accumsan ipsuTodignissim nulla elementum orci a dictumst. Magna placerat vmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuszattis tristique tellus. Sed ultricies massa lacus sagitintegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. Tellus elementum ut ut morbi nunc lacus et.",
            style: semibold14Grey87,
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. ",
            style: semibold14Grey87,
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. Lorem ipsum dolor sit amet consectetur. Dolposueretellus a volutpat aliquam vestibulum accumsan ipsuTodignissim nulla elementum orci a dictumst. Magna placerat vmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuszattis tristique tellus. Sed ultricies massa lacus sagitintegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. Tellus elementum ut ut morbi nunc lacus et.",
            style: semibold14Grey87,
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. ",
            style: semibold14Grey87,
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Doxposueretellus za volutpat aliquam vestibulum accumsan ipsuodignissim nulla elementum orci a dictumst. Magna placerat xmorbiuf pharetra viverra. Nunc fames scelerisque ac faucibuxmattis tristique tellus. Sed ultricies massa lacus sagittntegelorem. At quisque semper sit aliquet proidiasollicitudinvulputate. ",
            style: semibold14Grey87,
          ),
        ],
      ),
    );
  }

  logo(Size size) {
    return Column(
      children: [
        Image.asset(
          "assets/splash/mdi_star-three-points-outline.png",
          height: size.height * 0.08,
          width: size.height * 0.08,
          color: primaryColor,
        ),
        const Text(
          "Finalan Techno",
          style: interSemibold22Primary,
        )
      ],
    );
  }
}
