import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';

class LoanStatementScreen extends StatefulWidget {
  const LoanStatementScreen({Key? key}) : super(key: key);

  @override
  State<LoanStatementScreen> createState() => _LoanStatementScreenState();
}

class _LoanStatementScreenState extends State<LoanStatementScreen> {
  final recentTransactionList = [
    {"title": "EMI debited", "date": "12 June 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 may 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 april 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 march 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 Feb 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 Jan 2019", "amount": 800.00},
    {"title": "EMI debited", "date": "12 Dec 2018", "amount": 800.00},
    {"title": "EMI debited", "date": "12 Nov 2018", "amount": 800.00},
    {"title": "EMI debited", "date": "12 Oct 2018", "amount": 800.00},
    {"title": "EMI debited", "date": "12Sep 2018", "amount": 800.00},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: black33Color,
        backgroundColor: scaffoldBgColor,
        centerTitle: false,
        shadowColor: blackColor.withValues(alpha: 0.4),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0.0,
        title: Text(
          getTranslation(context, 'loan_statement.home_loans_statement'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: fixPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          loanInformation(),
          recentTransactionTtile(),
          ColumnBuilder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: fixPadding * 1.5,
                      horizontal: fixPadding * 2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recentTransactionList[index]['title']
                                    .toString(),
                                style: bold15Black33,
                              ),
                              Text(
                                recentTransactionList[index]['date'].toString(),
                                style: bold12Grey94,
                              )
                            ],
                          ),
                        ),
                        Text(
                          "-\$${recentTransactionList[index]['amount']}",
                          style: bold15Red,
                        ),
                      ],
                    ),
                  ),
                  recentTransactionList.length - 1 == index
                      ? const SizedBox.shrink()
                      : Container(
                          height: 1,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(color: greyD9Color),
                        ),
                ],
              );
            },
            itemCount: recentTransactionList.length,
          )
        ],
      ),
    );
  }

  recentTransactionTtile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'loan_statement.recent_transaction'),
        style: semibold16Grey94,
      ),
    );
  }

  loanInformation() {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: fixPadding * 2, horizontal: fixPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(fixPadding * 1.5),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(fixPadding / 1.2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFfEDEBEB),
                  ),
                  child: Image.asset(
                    "assets/loan/home-database.png",
                  ),
                ),
                widthSpace,
                width5Space,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslation(context, 'loan_statement.home_loan'),
                          style: bold16Black33,
                          overflow: TextOverflow.ellipsis),
                      const Text(
                        "1234 4567 8956 1222",
                        style: semibold14Grey94,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                const Text(
                  "\$20000.00",
                  style: bold16Primary,
                )
              ],
            ),
          ),
          dottedLine(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 2,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: infoWidget(
                    getTranslation(context, 'loan_statement.period'),
                    "24 ${getTranslation(context, 'loan_statement.month')}",
                  ),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.center,
                  child: infoWidget(
                    getTranslation(context, 'loan_statement.rate'),
                    "13% ${getTranslation(context, 'loan_statement.rate_text')}",
                  ),
                )),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: infoWidget(
                      getTranslation(context, 'loan_statement.EMI'),
                      "\$1000.00",
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  dottedLine() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      color: primaryColor,
      dashPattern: const [2, 3],
      child: Container(),
    );
  }

  infoWidget(String title, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: semibold14Grey94,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          detail,
          style: semibold16Black33,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
