import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class FundTransferScreen extends StatefulWidget {
  const FundTransferScreen({Key? key}) : super(key: key);

  @override
  State<FundTransferScreen> createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  final tabbarlist = [
    translation('fund_transfer.beneficiary_pay'),
    translation('fund_transfer.IBAN_payment'),
    translation('fund_transfer.IMPS_pay')
  ];

  int selectedPayMethod = 0;
  int selectedAccountNumber = 0;
  int selectedIBANAccount = 0;
  int selectedimpsAccount = 0;

  final accountNoList = [
    {
      "name": translation('fund_transfer.saving_account'),
      "account": "SB-*******1234"
    },
    {
      "name": translation('fund_transfer.current_account'),
      "account": "SB-*******4848"
    },
    {
      "name": translation('fund_transfer.salary_account'),
      "account": "SB-*******4567"
    },
    {
      "name": translation('fund_transfer.NRI_account'),
      "account": "SB-*******8981"
    },
  ];

  final bankNameList = [
    "Indian bank",
    "SBI bank",
    "Axis bank",
    "HDFC bank",
    "ICICI bank",
    "Star bank"
  ];

  TextEditingController beneficiaryAccountController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
  TextEditingController beneficiaryBankName = TextEditingController();
  TextEditingController beneficiaryAccountNoController =
      TextEditingController();
  TextEditingController beneficiaryAmountController = TextEditingController();
  TextEditingController beneficiaryTransferController = TextEditingController();

  TextEditingController iBANaccountController = TextEditingController();
  TextEditingController iBANnumberController = TextEditingController();
  TextEditingController iBANnameController = TextEditingController();
  TextEditingController iBANbicController = TextEditingController();
  TextEditingController iBANBankNameController = TextEditingController();
  TextEditingController iBANAmountController = TextEditingController();
  TextEditingController iBANRemarkController = TextEditingController();

  TextEditingController impsAccontController = TextEditingController();
  TextEditingController impsHolderNameController = TextEditingController();
  TextEditingController impsToAccountController = TextEditingController();
  TextEditingController impsBankNameController = TextEditingController();
  TextEditingController impsIFSCController = TextEditingController();
  TextEditingController impsAmountController = TextEditingController();

  @override
  void initState() {
    beneficiaryAccountController.text =
        accountNoList[selectedAccountNumber]['account'].toString();
    iBANaccountController.text =
        accountNoList[selectedIBANAccount]['account'].toString();
    impsAccontController.text =
        accountNoList[selectedimpsAccount]['account'].toString();
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
          getTranslation(context, 'fund_transfer.fund_transfer'),
          style: appBarStyle,
        ),
      ),
      body: Column(
        children: [
          heightSpace,
          heightSpace,
          tabBar(),
          heightSpace,
          if (selectedPayMethod == 0) beneficiaryPayView(context),
          if (selectedPayMethod == 1) iBANPayView(context),
          if (selectedPayMethod == 2) impsPayView(context)
        ],
      ),
    );
  }

  impsPayView(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2, vertical: fixPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          title(getTranslation(context, 'fund_transfer.from_account')),
          heightSpace,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                impsNumberDialog(context);
              },
              controller: impsAccontController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.select_account'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          height5Space,
          title(getTranslation(context, 'fund_transfer.account_name')),
          heightSpace,
          textFieldWidget(getTranslation(context, 'fund_transfer.enter_name'),
              impsHolderNameController, TextInputType.name),
          heightSpace,
          height5Space,
          title(getTranslation(context, 'fund_transfer.to_account')),
          heightSpace,
          textFieldWidget(
              getTranslation(context, 'fund_transfer.enter_account_no'),
              impsToAccountController,
              TextInputType.number),
          heightSpace,
          height5Space,
          title(getTranslation(context, 'fund_transfer.bank_name')),
          heightSpace,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                impsBankList(context);
              },
              controller: impsBankNameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.enter_bank_name'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          height5Space,
          title(getTranslation(context, 'fund_transfer.IFSC_code')),
          heightSpace,
          textFieldWidget(
              getTranslation(context, 'fund_transfer.enter_IFSC_code'),
              impsIFSCController,
              TextInputType.text),
          heightSpace,
          height5Space,
          title(getTranslation(context, 'fund_transfer.amount')),
          heightSpace,
          textFieldWidget(getTranslation(context, 'fund_transfer.enter_amount'),
              impsAmountController, TextInputType.number),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          transferNowButton(),
          heightSpace,
        ],
      ),
    );
  }

  impsBankList(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            vertical: fixPadding / 2,
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
              return banknamelist(index, context, () {
                setState(() {
                  impsBankNameController.text = bankNameList[index].toString();
                });
                Navigator.pop(context);
              });
            },
            itemCount: bankNameList.length,
          ),
        );
      },
    );
  }

  impsNumberDialog(BuildContext context) {
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
                return dialogContent(state, index, context, () {
                  state(() {
                    setState(() {
                      selectedimpsAccount = index;
                      impsAccontController.text =
                          accountNoList[index]['account'].toString();
                    });
                  });
                  Navigator.pop(context);
                }, selectedimpsAccount);
              },
              itemCount: accountNoList.length,
            ),
          );
        });
      },
    );
  }

  iBANPayView(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2, vertical: fixPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          title(getTranslation(context, 'fund_transfer.from_account')),
          heightSpace,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                iBANNumberDialog(context);
              },
              controller: iBANaccountController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.select_account'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          heightSpace,
          title(getTranslation(context, 'fund_transfer.beneficiary_info')),
          heightSpace,
          textFieldWidget(getTranslation(context, 'fund_transfer.IBAN_number'),
              iBANnumberController, TextInputType.text),
          height5Space,
          heightSpace,
          textFieldWidget(
              getTranslation(context, 'fund_transfer.beneficiary_name'),
              iBANnameController,
              TextInputType.name),
          height5Space,
          heightSpace,
          textFieldWidget(getTranslation(context, 'fund_transfer.BIC_code'),
              iBANbicController, TextInputType.text),
          height5Space,
          heightSpace,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                iBANBankList(context);
              },
              controller: iBANBankNameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.beneficiary_bank'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          height5Space,
          textFieldWidget(getTranslation(context, 'fund_transfer.amount'),
              iBANAmountController, TextInputType.number),
          heightSpace,
          height5Space,
          textFieldWidget(getTranslation(context, 'fund_transfer.remark'),
              iBANRemarkController, TextInputType.text),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          transferNowButton(),
          heightSpace,
        ],
      ),
    );
  }

  iBANNumberDialog(BuildContext context) {
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
                return dialogContent(state, index, context, () {
                  state(() {
                    setState(() {
                      selectedIBANAccount = index;
                      iBANaccountController.text =
                          accountNoList[index]['account'].toString();
                    });
                  });
                  Navigator.pop(context);
                }, selectedIBANAccount);
              },
              itemCount: accountNoList.length,
            ),
          );
        });
      },
    );
  }

  iBANBankList(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            vertical: fixPadding / 2,
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
              return banknamelist(index, context, () {
                setState(() {
                  iBANBankNameController.text = bankNameList[index].toString();
                });
                Navigator.pop(context);
              });
            },
            itemCount: bankNameList.length,
          ),
        );
      },
    );
  }

  beneficiaryPayView(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2, vertical: fixPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          title(getTranslation(context, 'fund_transfer.from_account')),
          heightSpace,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                beneficiaryNumberDialog(context);
              },
              controller: beneficiaryAccountController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.select_account'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          heightSpace,
          title(getTranslation(context, 'fund_transfer.beneficiary_info')),
          heightSpace,
          textFieldWidget(
              getTranslation(context, 'fund_transfer.beneficiary_name'),
              beneficiaryNameController,
              TextInputType.name),
          heightSpace,
          height5Space,
          textField(
            TextField(
              style: semibold15Black33,
              readOnly: true,
              onTap: () {
                baneficiaryBankListSheet(context);
              },
              controller: beneficiaryBankName,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    getTranslation(context, 'fund_transfer.beneficiary_bank'),
                hintStyle: semibold15Grey94,
              ),
            ),
          ),
          heightSpace,
          height5Space,
          textFieldWidget(
              getTranslation(
                  context, 'fund_transfer.beneficiary_account_number'),
              beneficiaryAccountNoController,
              TextInputType.number),
          heightSpace,
          height5Space,
          textFieldWidget(getTranslation(context, 'fund_transfer.amount'),
              beneficiaryAmountController, TextInputType.number),
          heightSpace,
          height5Space,
          textFieldWidget(
              getTranslation(context, 'fund_transfer.transfer_limit'),
              beneficiaryTransferController,
              TextInputType.number),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          transferNowButton(),
          heightSpace,
        ],
      ),
    );
  }

  textFieldWidget(String hintText, TextEditingController controller,
      TextInputType keyboardType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: blackColor.withValues(alpha: 0.25), blurRadius: 6)
        ],
      ),
      child: TextField(
        style: semibold15Black33,
        keyboardType: keyboardType,
        cursorColor: primaryColor,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: semibold15Grey94,
        ),
      ),
    );
  }

  title(String text) {
    return Text(
      text,
      style: bold17Black33,
    );
  }

  baneficiaryBankListSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            vertical: fixPadding / 2,
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
              return banknamelist(index, context, () {
                setState(() {
                  beneficiaryBankName.text = bankNameList[index].toString();
                });
                Navigator.pop(context);
              });
            },
            itemCount: bankNameList.length,
          ),
        );
      },
    );
  }

  banknamelist(int index, BuildContext context, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              bankNameList[index].toString(),
              style: bold16Black33,
            ),
          ),
          bankNameList.length - 1 == index
              ? const SizedBox.shrink()
              : Container(
                  width: double.maxFinite,
                  height: 1,
                  color: greyD9Color,
                ),
        ],
      ),
    );
  }

  beneficiaryNumberDialog(BuildContext context) {
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
                return dialogContent(state, index, context, () {
                  state(() {
                    setState(() {
                      selectedAccountNumber = index;
                      beneficiaryAccountController.text =
                          accountNoList[index]['account'].toString();
                    });
                  });
                  Navigator.pop(context);
                }, selectedAccountNumber);
              },
              itemCount: accountNoList.length,
            ),
          );
        });
      },
    );
  }

  dialogContent(StateSetter state, int index, BuildContext context,
      Function() onTap, int selected) {
    return GestureDetector(
      onTap: onTap,
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
            selected == index
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
  }

  textField(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: blackColor.withValues(alpha: 0.25), blurRadius: 6)
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor)),
        child: child,
      ),
    );
  }

  tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding),
      child: Row(
        children: List.generate(
          tabbarlist.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedPayMethod = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: fixPadding),
                padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                height: 60,
                decoration: BoxDecoration(
                  color: selectedPayMethod == index ? primaryColor : whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Center(
                    child: Text(
                      tabbarlist[index],
                      style: selectedPayMethod == index
                          ? bold16White
                          : bold16Grey87,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  transferNowButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/success');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'fund_transfer.transfer_now'),
          style: bold18White,
        ),
      ),
    );
  }
}
