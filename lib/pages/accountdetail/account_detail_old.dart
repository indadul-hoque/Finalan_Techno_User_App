import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/services/kyc_service.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  String? accountType;

  final bankAccount = [
    {"name": translation('account_detail.current_account'), "id": 0},
    {"name": translation('account_detail.saving_account'), "id": 1},
    {"name": translation('account_detail.salary_account'), "id": 2},
    {"name": translation('account_detail.NRI_account'), "id": 3},
  ];

  @override
  void initState() {
    setState(() {
      accountType = bankAccount[1]['name'].toString();
    });
    super.initState();
  }

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
          getTranslation(context, 'account_detail.account'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2),
        children: [
          bankAccountType(context),
          heightSpace,
          heightSpace,
          totalbalanceinfo(),
          heightSpace,
          heightSpace,
          accountDetailTitle(),
          heightSpace,
          detailTile(
              getTranslation(context, 'account_detail.CIF'), "12345678921"),
          heightSpace,
          detailTile(
              getTranslation(context, 'account_detail.IFSC'), "SMART000S600"),
          heightSpace,
          detailTile(
              getTranslation(context, 'account_detail.branch_code'), "1235"),
          heightSpace,
          detailTile(getTranslation(context, 'account_detail.branch_name'),
              "Andheri, Mumbai"),
          heightSpace,
          detailTile(
              getTranslation(context, 'account_detail.account_opening_date'),
              "10/12/2020"),
          heightSpace,
          detailTile(getTranslation(context, 'account_detail.MMId'), "120546"),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          viewStatementButton(context)
        ],
      ),
    );
  }

  viewStatementButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/statement');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'account_detail.view_statement'),
          style: bold18White,
        ),
      ),
    );
  }

  detailTile(String title, String detail) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: semibold15Grey94,
          ),
        ),
        widthSpace,
        Text(
          detail,
          style: semibold15Black33,
        )
      ],
    );
  }

  accountDetailTitle() {
    return Text(
      getTranslation(context, 'account_detail.account_details'),
      style: bold18Black33,
    );
  }

  totalbalanceinfo() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  KYCService.kycData?['name'] ?? "User Name",
                  style: bold16Black33,
                ),
                heightSpace,
                Text(
                  getTranslation(context, 'account_detail.account_number'),
                  style: semibold14Grey94,
                ),
                const Text(
                  "SB-******1234",
                  style: semibold15Black33,
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getTranslation(context, 'account_detail.total_balance'),
                style: bold14Grey94,
              ),
              height5Space,
              const Text(
                "\$1000.00",
                style: bold20Primary,
              )
            ],
          ),
        ],
      ),
    );
  }

  bankAccountType(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Container(
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: fixPadding),
                child: ColumnBuilder(
                    mainAxisSize: MainAxisSize.min,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            onTap: () {
                              setState(() {
                                accountType =
                                    bankAccount[index]['name'].toString();
                              });
                              Navigator.pop(context);
                            },
                            title: Text(
                              bankAccount[index]['name'].toString(),
                              style: bold16Black33,
                            ),
                          ),
                          bankAccount.length - 1 == index
                              ? const SizedBox()
                              : Container(
                                  color: greyD9Color,
                                  height: 1,
                                  width: double.maxFinite,
                                )
                        ],
                      );
                    },
                    itemCount: bankAccount.length),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: fixPadding / 1.5,
            horizontal: fixPadding * 1.5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: whiteColor,
            border: Border.all(color: primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accountType.toString(),
                style: bold16Primary,
              ),
              widthSpace,
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
