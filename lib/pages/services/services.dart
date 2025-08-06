import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/screens.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../theme/theme.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final servicelist = [
    {
      "image": "assets/home/account.png",
      "name": "Account",
      "routeName": const AccountDetailScreen()
    },
    {
      "image": "assets/home/statement.png",
      "name": "Statement",
      "routeName": const StatementScreen(),
    },
    {
      "image": "assets/bottomNavigation/Glyph_ undefined.png",
      "name": "Deposit",
      "routeName": const BottomNavigationScreen(id: 1)
    },
    {
      "image": "assets/bottomNavigation/money-16-regular.png",
      "name": "Loans",
      "routeName": const BottomNavigationScreen(id: 2)
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        shadowColor: blackColor.withValues(alpha: 0.4),
        backgroundColor: scaffoldBgColor,
        foregroundColor: black33Color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(getTranslation(context, 'services.services'),
            style: appBarStyle),
      ),
      body: servicesListContent(size),
    );
  }

  servicesListContent(Size size) {
    return GridView.builder(
      padding: const EdgeInsets.all(fixPadding * 2),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: fixPadding * 2,
        crossAxisSpacing: fixPadding * 2,
        childAspectRatio: size.width / (size.height / 2),
      ),
      itemCount: servicelist.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (servicelist[index]['routeName'] != null) {
              Navigator.push(
                context,
                PageTransition(
                  child: servicelist[index]['routeName'] as Widget,
                  type: PageTransitionType.rightToLeft,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  servicelist[index]['image'].toString(),
                  height: 25,
                  width: 25,
                  color: primaryColor,
                ),
                height5Space,
                Text(
                  servicelist[index]['name'].toString(),
                  style: bold15Primary,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
