import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/Account/languages.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final currentDepositList = [
    {
      "year": 2,
      "date": "12 march 2022",
      "amount": 500.00,
      "accountNo": "1234 5678 9101",
      "status": "Pending",
      "rate": "2%",
    },
    {
      "year": 3,
      "date": "14 march 2022",
      "amount": 900.00,
      "accountNo": "1234 5678 9101",
      "status": "Pending",
      "rate": "2%",
    },
  ];

  final completedDeposit = [
    {
      "year": 1,
      "date": "10 march 2021",
      "amount": 600.00,
      "accountNo": "1234 5678 9101",
      "status": "Completed",
      "rate": "2%",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/deposite/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: primaryColor.withValues(alpha: 0.5),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light),
        title: Text(
          getTranslation(context, 'deposit.deposit'),
          style: bold20White,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          left: fixPadding * 2,
          right: fixPadding * 2,
          top: fixPadding * 2,
          bottom: fixPadding * 7.5,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            getTranslation(context, 'deposit.current_deposit'),
            style: semibold16Black33,
          ),
          currentDepositeList(),
          heightSpace,
          Text(
            getTranslation(context, 'deposit.completed_deposit'),
            style: semibold16Black33,
          ),
          completedDepositeList(),
        ],
      ),
      floatingActionButton: addButton(context),
    );
  }

  addButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/addDeposit');
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
      backgroundColor: primaryColor,
      child: const Icon(
        Icons.add,
        color: whiteColor,
        size: 30,
      ),
    );
  }

  completedDepositeList() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return listContent(index, completedDeposit, greenColor);
      },
      itemCount: completedDeposit.length,
    );
  }

  currentDepositeList() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return listContent(index, currentDepositList, redColor);
      },
      itemCount: currentDepositList.length,
    );
  }

  listContent(int index, List listname, Color statusTextColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: fixPadding),
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2, vertical: fixPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
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
                    "assets/bottomNavigation/Glyph_ undefined.png",
                    color: primaryColor,
                  ),
                ),
                width5Space,
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${getTranslation(context, 'deposit.deposit_for')} ${listname[index]['year']} ${getTranslation(context, 'deposit.year')}",
                          style: bold16Black33,
                          overflow: TextOverflow.ellipsis),
                      Text(
                        listname[index]['date'].toString(),
                        style: bold14Grey94,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$${listname[index]['amount']}",
                  style: bold18Black33,
                )
              ],
            ),
          ),
          dottedLine(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 2,
              vertical: fixPadding * 1.5,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslation(context, 'deposit.deposit_to')}:",
                        style: semibold14Grey94,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        listname[index]['accountNo'].toString(),
                        style: semibold15Black33,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslation(context, 'deposit.status')}:",
                        style: semibold14Grey94,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        listname[index]['status'].toString(),
                        style: semibold15Red.copyWith(color: statusTextColor),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: selectedValue == 'عربى'
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${getTranslation(context, 'deposit.rate')}:",
                          style: semibold14Grey94,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${listname[index]['rate']} ${getTranslation(context, 'deposit.rate_text')}",
                          style: semibold15Black33,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  dottedLine() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      dashPattern: const [2, 3],
      color: primaryColor,
      child: Container(),
    );
  }
}
