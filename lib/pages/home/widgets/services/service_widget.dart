import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

// Service list data extracted from HomeScreen
const serviceListData = [
  {
    "image": "assets/home/account.png",
    "name": "Account",
    "isDetail": true,
    "routeName": "/account"
  },
  {
    "image": "assets/home/statement.png",
    "name": "Statement",
    "isDetail": true,
    "routeName": "/statement"
  },
  {
    "image": "assets/bottomNavigation/Glyph_ undefined.png",
    "name": "Deposit",
    "routeName": "/addDeposit",
    "isDetail": true
  },
  {
    "image": "assets/home/loan.png",
    "name": "Loan Repayment",
    "routeName": "/loanRepayment",
    "isDetail": true
  },
  {
    "image": "assets/home/wallet.png",
    "name": "Wallet",
    "routeName": "/wallet",
    "isDetail": true
  }
];

// Service title widget
class ServiceTitle extends StatelessWidget {
  const ServiceTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'home.services'),
        style: bold18Black33,
      ),
    );
  }
}

// Service card widget
class OptimizedServiceCard extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const OptimizedServiceCard({Key? key, required this.serviceData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (serviceData['isDetail'] == true) {
          Navigator.pushNamed(context, serviceData['routeName'].toString());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.25),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              serviceData['image'].toString(),
              height: 24,
              width: 24,
              color: primaryColor,
            ),
            height5Space,
            Text(
              serviceData['name'].toString(),
              style: bold15Primary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}

// Grid service list widget
class ServiceList extends StatelessWidget {
  final Size size;
  final List<Map<String, dynamic>>? servicelist;

  const ServiceList({Key? key, required this.size, this.servicelist})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = servicelist ?? serviceListData;

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: fixPadding * 2,
        right: fixPadding * 2,
        bottom: fixPadding,
        top: fixPadding,
      ),
      crossAxisCount: 3,
      childAspectRatio: (size.width) / (size.height / 2),
      shrinkWrap: true,
      mainAxisSpacing: fixPadding * 2,
      crossAxisSpacing: fixPadding * 2,
      children: [
        for (int i = 0; i < list.length; i++)
          OptimizedServiceCard(serviceData: list[i]),
      ],
    );
  }
}
