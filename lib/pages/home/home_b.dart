// lib/pages/home/home_screen.dart

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final accountList = const [
    {
      "totalbalance": 15000,
      "accountType": "Saving account",
      "accountNo": "A/c no xxxxxxx785",
    },
    {
      "totalbalance": 5000,
      "accountType": "Wallet Status - Active",
      "accountNo": "Activation Date - 06/08/2025",
    }
  ];

  final servicelist = const [
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
      "image": "assets/bottomNavigation/money-16-regular.png",
      "name": "Loans",
      "routeName": "/educationLoan",
      "isDetail": true
    }
  ];

  final transectionlist = const [
    {
      "image": "assets/home/fundTransfer.png",
      "name": "Jeklin shah",
      "title": "Money transfer",
      "money": 140,
      "isCredit": false
    },
    {
      "image": "assets/home/logos_paypal.png",
      "name": "Paypal",
      "title": "Deposits",
      "money": 140,
      "isCredit": true
    },
    {
      "image": "assets/home/amozon.png",
      "name": "Amazon",
      "title": "Online payment",
      "money": 140,
      "isCredit": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          topBox(size),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
              physics: const BouncingScrollPhysics(),
              children: [
                serviceTitle(),
                serviceList(size),
                heightSpace,
                latestTtile(),
                latestTransectionList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  latestTransectionList() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return OptimizedTransactionCard(
          transactionData: transectionlist[index],
        );
      },
      itemCount: transectionlist.length,
    );
  }

  latestTtile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              getTranslation(context, 'home.latest_transaction'),
              style: bold18Black33,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/transaction');
            },
            child: Text(
              getTranslation(context, 'home.see_all'),
              style: bold14Grey94,
            ),
          )
        ],
      ),
    );
  }

  serviceList(Size size) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
          left: fixPadding * 2,
          right: fixPadding * 2,
          bottom: fixPadding,
          top: fixPadding),
      crossAxisCount: 3,
      childAspectRatio: (size.width) / (size.height / 2),
      shrinkWrap: true,
      mainAxisSpacing: fixPadding * 2,
      crossAxisSpacing: fixPadding * 2,
      children: [
        for (int i = 0; i < servicelist.length; i++)
          OptimizedServiceCard(
            serviceData: servicelist[i],
          ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/services');
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
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/home/more.png",
                  height: 24,
                  width: 24,
                ),
                Text(
                  getTranslation(context, 'home.more'),
                  style: bold15Grey94,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  serviceTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'home.services'),
        style: bold18Black33,
      ),
    );
  }

  topBox(Size size) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/bg.png",
          ),
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
              topTitle(),
              heightSpace,
              height5Space,
              accountTypeList(size),
              heightSpace,
              height5Space,
            ],
          ),
        ),
      ),
    );
  }

  topTitle() {
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
              const Text(
                "Finalan Techno",
                style: interSemibold20White,
              )
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/notification');
            },
            child: const SizedBox(
              height: 26,
              width: 26,
              child: Icon(
                CupertinoIcons.bell,
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  accountTypeList(Size size) {
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

class OptimizedAccountCard extends StatelessWidget {
  const OptimizedAccountCard({
    Key? key,
    required this.accountData,
    required this.size,
  }) : super(key: key);

  final Map<String, dynamic> accountData;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      blur: 8.0,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size.width * 0.8,
        padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 1.5,
          vertical: fixPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFDEB16C).withOpacity(0.15),
          border: Border.all(
            color: const Color(0xFFEC98B3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              overflow: TextOverflow.ellipsis,
              TextSpan(
                text: getTranslation(context, 'home.total_balance'),
                style: bold18GreyD6,
                children: [
                  const TextSpan(text: " : "),
                  TextSpan(
                    text: "\$${accountData['totalbalance']}",
                    style: bold22GreyD6,
                  )
                ],
              ),
            ),
            heightSpace,
            height5Space,
            Text(
              accountData['accountType'].toString(),
              style: semibold14EE,
            ),
            Text(
              accountData['accountNo'].toString(),
              style: bold14EE,
            )
          ],
        ),
      ),
    );
  }
}

class OptimizedTransactionCard extends StatelessWidget {
  const OptimizedTransactionCard({Key? key, required this.transactionData}) : super(key: key);

  final Map<String, dynamic> transactionData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2),
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            padding: const EdgeInsets.all(fixPadding / 1.2),
            decoration: const BoxDecoration(
              color: Color(0xFFEDEBEB),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              transactionData['image'].toString(),
            ),
          ),
          widthSpace,
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionData['name'].toString(),
                  style: bold15Black33,
                ),
                heightBox(3.0),
                Text(
                  transactionData['title'].toString(),
                  style: bold12Grey94,
                )
              ],
            ),
          ),
          transactionData['isCredit'] == false
              ? Text(
                  "-\$${transactionData['money']}",
                  style: bold15Red,
                )
              : Text(
                  "+\$${transactionData['money']}",
                  style: bold15Green,
                )
        ],
      ),
    );
  }
}

class OptimizedServiceCard extends StatelessWidget {
  const OptimizedServiceCard({Key? key, required this.serviceData}) : super(key: key);

  final Map<String, dynamic> serviceData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (serviceData['isDetail'] == true) {
          Navigator.pushNamed(
            context,
            serviceData['routeName'].toString(),
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
              color: blackColor.withOpacity(0.25),
              blurRadius: 6,
            )
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

