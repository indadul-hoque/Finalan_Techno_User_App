import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:fl_banking_app/services/statement_service.dart';
import 'package:fl_banking_app/pages/loans/loan_statement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';

class LoansScreen extends StatefulWidget {
  final String? phoneNumber;

  const LoansScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Map<String, dynamic>> currentLoans = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final phoneNumber = widget.phoneNumber ?? '9519874704';
    _fetchLoanAccounts(phoneNumber);
  }

  Future<void> _fetchLoanAccounts([String? phoneNumber]) async {
    final phone = phoneNumber ?? widget.phoneNumber ?? '9519874704';
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final accounts = await BankAccountsService.fetchBankAccounts(phone);

      if (accounts != null) {
        final loanAccounts = BankAccountsService.getLoanAccounts();
        setState(() {
          currentLoans = loanAccounts;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = BankAccountsService.errorMessage ??
              'Failed to fetch loan accounts';
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
    final size = MediaQuery.of(context).size;
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
          getTranslation(context, 'loans.loans'),
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
                        onPressed: () => _fetchLoanAccounts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    heightSpace,
                    heightSpace,
                    currentLoanTitle(),
                    currentLoansListContent(),
                    heightSpace,
                  ],
                ),
    );
  }

  currentLoansListContent() {
    if (currentLoans.isEmpty) {
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
                'No loan accounts found',
                style: bold16Black33,
                textAlign: TextAlign.center,
              ),
              Text(
                'You don\'t have any active loan accounts',
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
        final loan = currentLoans[index];
        final planDetails = loan['planDetails'] ?? {};
        final emiAmount = loan['emiAmount'] ?? 0.0;
        final loanAmount = loan['loanAmount'] ?? 0.0;
        final loanTerm = loan['loanTerm'] ?? 0;
        final interestRate = planDetails['interestRate'] ?? '0';

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
                          Text(
                            planDetails['name'] ?? 'Loan Account',
                            style: bold16Black33,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loan['account'] ?? 'N/A',
                            style: semibold14Grey94,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    Text(
                      BankAccountsService.formatBalance(loanAmount),
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
                        getTranslation(context, 'loans.period'),
                        "$loanTerm months",
                      ),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: infoWidget(
                        getTranslation(context, 'loans.rate'),
                        "$interestRate% ${getTranslation(context, 'loans.rate_text')}",
                      ),
                    )),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: infoWidget(
                          getTranslation(context, 'loans.EMI'),
                          BankAccountsService.formatBalance(emiAmount),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanStatementScreen(
                        phoneNumber: widget.phoneNumber ?? '9519874704',
                        accountId: loan['accountId'],
                        accountType: 'loan',
                      ),
                    ),
                  );
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
                    getTranslation(context, 'loans.view_statement'),
                    style: bold16Primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: currentLoans.length,
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

  currentLoanTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'loans.current_loans'),
        style: bold18Black33,
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
