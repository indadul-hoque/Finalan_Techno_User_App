import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../widget/column_builder.dart';

class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({Key? key}) : super(key: key);

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController accountControlelr = TextEditingController();

  final depositPeriod = [
    {"name": "1 month", "id": 0},
    {"name": "3 month", "id": 1},
    {"name": "6 month", "id": 2},
    {"name": "12 month", "id": 3},
    {"name": "18 month", "id": 4},
    {"name": "24 month", "id": 5},
  ];

  int selectedindex = 4;

  int? selectedAccountNumber;

  final accountNoList = [
    {
      "name": translation('add_deposite.saving_account'),
      "account": "SB-*******1234"
    },
    {
      "name": translation('add_deposite.current_account'),
      "account": "SB-*******4848"
    },
    {
      "name": translation('add_deposite.salary_account'),
      "account": "SB-*******4567"
    },
    {
      "name": translation('add_deposite.NRI_account'),
      "account": "SB-*******8981"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: scaffoldBgColor,
        foregroundColor: black33Color,
        shadowColor: blackColor.withValues(alpha: 0.4),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0.0,
        title: Text(
          getTranslation(context, 'add_deposite.add_deposit'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
            child: Text(
              getTranslation(context, 'add_deposite.choose_deposit_period'),
              style: bold17Black33,
            ),
          ),
          heightSpace,
          deposirPeriodOption(),
          heightSpace,
          height5Space,
          amountTitle(),
          heightSpace,
          amountField(),
          heightBox(3.0),
          rateText(),
          heightSpace,
          height5Space,
          depositTitle(),
          heightSpace,
          accountField(),
          heightSpace,
          height5Space,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
            child: Text(
              getTranslation(context, 'add_deposite.upload_check_image'),
              style: bold17Black33,
            ),
          ),
          uploadBoxWidget(
              getTranslation(context, 'add_deposite.front_side_image')),
          uploadBoxWidget(
              getTranslation(context, 'add_deposite.back_side_image')),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          depositNowButton(context, size),
        ],
      ),
    );
  }

  depositNowButton(BuildContext context, Size size) {
    return GestureDetector(
      onTap: () {
        successDailog(context, size);
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
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
          getTranslation(context, 'add_deposite.deposit_now'),
          style: bold18White,
        ),
      ),
    );
  }

  successDailog(BuildContext context, Size size) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          contentPadding: const EdgeInsets.all(fixPadding * 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size.height * 0.09,
                width: size.height * 0.09,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: greenColor,
                ),
                child: const Icon(
                  Icons.done,
                  color: whiteColor,
                  size: 30,
                ),
              ),
              height5Space,
              Text(
                getTranslation(context, 'add_deposite.succeess'),
                style: bold20Black33,
              ),
              heightSpace,
              heightSpace,
              Text(
                getTranslation(context, 'add_deposite.congratulation'),
                style: semibold16Black33,
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
                    getTranslation(context, 'add_deposite.okay'),
                    style: bold18Primary,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  uploadBoxWidget(String text) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 3),
      margin: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2),
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
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEDEBEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: primaryColor,
              size: 18,
            ),
          ),
          widthSpace,
          width5Space,
          Expanded(
            child: Text(
              text,
              style: semibold15Grey94,
            ),
          )
        ],
      ),
    );
  }

  depositTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'add_deposite.deposit_to'),
        style: bold17Black33,
      ),
    );
  }

  accountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
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
        style: semibold16Black33,
        readOnly: true,
        onTap: () {
          selectAccountSheet();
        },
        controller: accountControlelr,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: getTranslation(context, 'add_deposite.select_account'),
          hintStyle: semibold16Grey94,
        ),
      ),
    );
  }

  selectAccountSheet() {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              vertical: fixPadding,
            ),
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(fixPadding * 2),
              ),
            ),
            child: ColumnBuilder(
              mainAxisSize: MainAxisSize.min,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    state(() {
                      setState(() {
                        selectedAccountNumber = index;
                        accountControlelr.text =
                            accountNoList[index]['account'].toString();
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: fixPadding,
                      horizontal: fixPadding * 2,
                    ),
                    padding: const EdgeInsets.symmetric(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                accountNoList[index]['name'].toString(),
                                style: bold16Black33,
                              ),
                              height5Space,
                              Text(
                                accountNoList[index]['account'].toString(),
                                style: semibold16Black33,
                              )
                            ],
                          ),
                        ),
                        selectedAccountNumber == index
                            ? Container(
                                height: 22,
                                width: 22,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: whiteColor,
                                  size: 14,
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                );
              },
              itemCount: accountNoList.length,
            ),
          );
        });
      },
    );
  }

  rateText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'add_deposite.your_rate'),
        style: semibold14Primary,
      ),
    );
  }

  amountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
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
        style: semibold16Black33,
        keyboardType: TextInputType.number,
        controller: amountController,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              getTranslation(context, 'add_deposite.enter_deposit_amount'),
          hintStyle: semibold16Grey94,
        ),
      ),
    );
  }

  amountTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'add_deposite.amount'),
        style: bold17Black33,
      ),
    );
  }

  deposirPeriodOption() {
    return Wrap(
      runSpacing: fixPadding,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Row(
            children: depositPeriod
                .getRange(0, 3)
                .map((e) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedindex = e['id'] as int;
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: fixPadding),
                          margin: const EdgeInsets.symmetric(
                              horizontal: fixPadding),
                          decoration: BoxDecoration(
                            color: selectedindex == (e['id'] as int)
                                ? primaryColor
                                : whiteColor,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withValues(alpha: 0.25),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e['name'].toString(),
                            style: selectedindex == (e['id'] as int)
                                ? semibold16White
                                : semibold16Black33,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Row(
            children: depositPeriod
                .getRange(3, depositPeriod.length)
                .map((e) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedindex = e['id'] as int;
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: fixPadding),
                          margin: const EdgeInsets.symmetric(
                              horizontal: fixPadding),
                          decoration: BoxDecoration(
                            color: selectedindex == (e['id'] as int)
                                ? primaryColor
                                : whiteColor,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withValues(alpha: 0.25),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e['name'].toString(),
                            style: selectedindex == (e['id'] as int)
                                ? semibold16White
                                : semibold16Black33,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
