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
  final accountList = [
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

  final servicelist = [
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
      "isDetail" : true
    },
    {
      "image": "assets/bottomNavigation/money-16-regular.png",
      "name": "Loans",
      "routeName": "/educationLoan",
      "isDetail" : true
    }

  ];

  final transectionlist = [
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
                color: blackColor.withValues(alpha: 0.25),
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
                  transectionlist[index]['image'].toString(),
                ),
              ),
              widthSpace,
              width5Space,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transectionlist[index]['name'].toString(),
                      style: bold15Black33,
                    ),
                    heightBox(3.0),
                    Text(
                      transectionlist[index]['title'].toString(),
                      style: bold12Grey94,
                    )
                  ],
                ),
              ),
              transectionlist[index]['isCredit'] == false
                  ? Text(
                      "-\$${transectionlist[index]['money']}",
                      style: bold15Red,
                    )
                  : Text(
                      "+\$${transectionlist[index]['money']}",
                      style: bold15Green,
                    )
            ],
          ),
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
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      shrinkWrap: true,
      mainAxisSpacing: fixPadding * 3,
      crossAxisSpacing: fixPadding * 3,
      children: [
        for (int i = 0; i < servicelist.length; i++)
          GestureDetector(
            onTap: () {
              if (servicelist[i]['isDetail'] == true) {
                Navigator.pushNamed(
                  context,
                  servicelist[i]['routeName'].toString(),
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
                    servicelist[i]['image'].toString(),
                    height: 24,
                    width: 24,
                    color: primaryColor,
                  ),
                  height5Space,
                  Text(servicelist[i]['name'].toString(),
                      style: bold15Primary,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
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
          color: primaryColor.withValues(alpha: 0.5),
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
            child: BlurryContainer(
              blur: 8.0,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: size.width * 0.8,
                padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding * 1.5, vertical: fixPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFDEB16C).withValues(alpha: 0.15),
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
                            text: "\$${accountList[index]['totalbalance']}",
                            style: bold22GreyD6,
                          )
                        ],
                      ),
                    ),
                    heightSpace,
                    height5Space,
                    Text(
                      accountList[index]['accountType'].toString(),
                      style: semibold14EE,
                    ),
                    Text(
                      accountList[index]['accountNo'].toString(),
                      style: bold14EE,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
