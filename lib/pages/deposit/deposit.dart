import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:fl_banking_app/pages/deposit/deposit_statement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class DepositScreen extends StatefulWidget {
  final String? phoneNumber;

  const DepositScreen({Key? key, this.phoneNumber}) : super(key: key);
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  List<Map<String, dynamic>> savingsAccounts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final phoneNumber = widget.phoneNumber ?? '9519874704';
    _fetchSavingsAccounts(phoneNumber);
  }

  Future<void> _fetchSavingsAccounts([String? phoneNumber]) async {
    final phone = phoneNumber ?? widget.phoneNumber ?? '9519874704';
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final accounts = await BankAccountsService.fetchBankAccounts(phone);

      if (accounts != null) {
        final savings = BankAccountsService.getSavingsAccounts();
        setState(() {
          savingsAccounts = savings;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = BankAccountsService.errorMessage ??
              'Failed to fetch savings accounts';
        });
        BankAccountsService.showToast(errorMessage!, isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
      BankAccountsService.showToast(errorMessage!, isError: true);
    }
  }

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
          getTranslation(context, 'Deposits'),
          style: bold20White,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: bold16Black33,
                        textAlign: TextAlign.center,
                      ),
                      heightSpace,
                      ElevatedButton(
                        onPressed: () => _fetchSavingsAccounts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    currentLoansListContent(),
                    heightSpace,
                  ],
                ),
    );
  }

  currentLoansListContent() {
    if (savingsAccounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(fixPadding * 2),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 64,
                color: grey94Color,
              ),
              heightSpace,
              Text(
                'No savings accounts found',
                style: bold16Black33,
                textAlign: TextAlign.center,
              ),
              Text(
                'You don\'t have any active savings accounts',
                style: semibold14Grey94,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ColumnBuilder(
      itemBuilder: (context, index) {
        final account = savingsAccounts[index];
        final planDetails = account['planDetails'] ?? {};
        final balance = account['balance'] ?? 0.0;
        final openingDate = account['openingDate'] ?? 'N/A';
        final interestRate = planDetails['annualInterestRate'] ?? '0';

        return Container(
          margin: const EdgeInsets.symmetric(
              vertical: fixPadding, horizontal: fixPadding * 2),
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
                        color: Color(0xFFEDEBEB),
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
                          Text(
                            planDetails['schemeName'] ?? 'Savings Account',
                            style: bold16Black33,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account['accountId'] ?? 'N/A',
                            style: semibold14Grey94,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    Text(
                      BankAccountsService.formatBalance(balance),
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
                        'Opening Date',
                        openingDate,
                      ),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: infoWidget(
                        'Interest Rate',
                        "$interestRate% p.a.",
                      ),
                    )),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: infoWidget(
                          'Account Type',
                          'Savings',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (savingsAccounts.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepositStatementScreen(
                          phoneNumber: widget.phoneNumber ?? '9519874704',
                          accountId: account['accountId'],
                          accountType: 'savings',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 7.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5C4C4),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getTranslation(context, 'View Deposit Statement'),
                    style: bold16Primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: savingsAccounts.length,
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
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: semibold16Black33,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
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
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width - 35, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
