import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final transactionlist = [
    {
      "image": "assets/home/fundTransfer.png",
      "name": "Jeklin shah",
      "title": "Money transfer",
      "money": 140,
      "isCredit": false,
    },
    {
      "image": "assets/home/logos_paypal.png",
      "name": "Paypal",
      "title": "Deposits",
      "money": 140,
      "isCredit": true
    },
    {
      "image": "assets/statement/clarity_mobile-phone-line.png",
      "name": "+91 987654321",
      "title": "Mobile payment",
      "money": 150,
      "isCredit": false,
    },
    {
      "image": "assets/statement/atm 1.png",
      "name": "Atm",
      "title": "Cash withdrawal",
      "money": 140,
      "isCredit": false
    },
    {
      "image": "assets/home/fundTransfer.png",
      "name": "Jane Cooper",
      "title": "Money transfer",
      "money": 640,
      "isCredit": true,
    },
    {
      "image": "assets/home/receipt.png",
      "name": "Electricity",
      "title": "bill payment",
      "money": 540,
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
      "image": "assets/statement/ebay 1.png",
      "name": "eBay",
      "title": "Online payment",
      "money": 190,
      "isCredit": false
    },
    {
      "image": "assets/home/amozon.png",
      "name": "Amazon",
      "title": "Online payment",
      "money": 440,
      "isCredit": false
    },
    {
      "image": "assets/statement/atm 1.png",
      "name": "Atm",
      "title": "Cash withdrawal",
      "money": 140,
      "isCredit": false
    },
    {
      "image": "assets/statement/clarity_mobile-phone-line.png",
      "name": "+91 987654321",
      "title": "Mobile payment",
      "money": 100,
      "isCredit": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          getTranslation(context, 'transcation.transaction'),
          style: appBarStyle,
        ),
      ),
      body: transactionList(),
    );
  }

  transactionList() {
    return ListView.builder(
      itemCount: transactionlist.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(fixPadding * 1.5),
          margin: const EdgeInsets.symmetric(
            vertical: fixPadding,
            horizontal: fixPadding * 2,
          ),
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
                  shape: BoxShape.circle,
                  color: Color(0xFFEDEBEB),
                ),
                child: Image.asset(
                  transactionlist[index]['image'].toString(),
                ),
              ),
              widthSpace,
              width5Space,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transactionlist[index]['name'].toString(),
                      style: bold15Black33,
                    ),
                    heightBox(3.0),
                    Text(
                      transactionlist[index]['title'].toString(),
                      style: bold12Grey94,
                    ),
                  ],
                ),
              ),
              transactionlist[index]['isCredit'] == true
                  ? Text(
                      "+\₹${transactionlist[index]['money']}",
                      style: bold15Green,
                    )
                  : Text(
                      "-\₹${transactionlist[index]['money']}",
                      style: bold15Red,
                    )
            ],
          ),
        );
      },
    );
  }
}
