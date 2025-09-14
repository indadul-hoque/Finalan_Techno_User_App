import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/services/kyc_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'dart:convert';

import '../../theme/theme.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  String? accountType;
  Map<String, dynamic>? savingsAccountData;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTypeIndex = 1; // 0: Current, 1: Savings, 2: Salary, 3: NRI
  
  // Map UI dropdown types to API accountType values
  static const Map<String, List<String>> _uiTypeToApiTypes = {
    'Savings Account': ['savings'],
    'Daily Savings Account': ['daily-savings'],
    'Thrift Fund': ['thrift-fund'],
    'Fixed Deposit': ['fixed-deposit'],
    'Loan Account': ['loan'],
    'Group Loan Account': ['group-loan']
  };

  final bankAccount = [
    {"name": "Savings Account", "id": 0},
    {"name": "Daily Savings Account", "id": 1},
    {"name": "Thrift Fund", "id": 2},
    {"name": "Fixed Deposit", "id": 3},
    {"name": "Loan Account", "id": 4},
    {"name": "Group Loan Account", "id": 5},
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedTypeIndex = 1;
      accountType = bankAccount[_selectedTypeIndex]['name'].toString();
    });
    _fetchAccountData();
  }

  Future<void> _fetchAccountData() async {
    // Load saved phone number; fallback to API test number
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phoneNumber') ?? '9519874704';

    // Fetch KYC first so holder name is up to date
    await KYCService.fetchKYCDetails(phone);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final accounts = await BankAccountsService.fetchBankAccounts(phone);
      if (accounts != null && accounts.isNotEmpty) {
        _applySelectedTypeFilter();
      } else {
        setState(() {
          _errorMessage = BankAccountsService.errorMessage ?? 'Failed to fetch accounts';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while loading accounts';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySelectedTypeFilter() {
    if (BankAccountsService.accounts == null || BankAccountsService.accounts!.isEmpty) {
      setState(() {
        savingsAccountData = null;
        _errorMessage = 'No accounts found';
      });
      return;
    }

    // Determine allowed API types by selected index (not by translated label)
    List<String> allowedTypes;
    switch (_selectedTypeIndex) {
      case 0: // Current
        allowedTypes = ['current'];
        break;
      case 2: // Salary (map to savings for now)
        allowedTypes = ['savings'];
        break;
      case 3: // NRI (map to savings for now)
        allowedTypes = ['savings'];
        break;
      case 1: // Savings
      default:
        allowedTypes = ['savings', 'daily-savings', 'thrift-fund', 'fixed-deposit'];
        break;
    }

    final filtered = BankAccountsService.accounts!
        .where((a) => allowedTypes.contains((a['accountType'] ?? '').toString().toLowerCase()))
        .toList();

    // Prefer the most recently updated account if multiple match
    filtered.sort((a, b) {
      dynamic aTime = a['lastModified'] ?? a['updatedAt'];
      dynamic bTime = b['lastModified'] ?? b['updatedAt'];

      int toEpoch(dynamic v) {
        try {
          if (v is String) {
            return DateTime.tryParse(v)?.millisecondsSinceEpoch ?? 0;
          }
          if (v is Map && v.containsKey('_seconds')) {
            return ((v['_seconds'] ?? 0) as int) * 1000;
          }
        } catch (_) {}
        return 0;
      }

      return toEpoch(bTime).compareTo(toEpoch(aTime));
    });

    if (filtered.isNotEmpty) {
      setState(() {
        savingsAccountData = Map<String, dynamic>.from(filtered.first);
        _errorMessage = null;
      });
    } else {
      setState(() {
        savingsAccountData = null;
        _errorMessage = 'No account found for selected type';
      });
    }
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
        actions: const [],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2),
        children: [
          Text('Common Details', style: bold18Black33),
          heightSpace,
          detailTile('Account Number/ID', '—'),
          heightSpace,
          detailTile('Holder Name', '—'),
          heightSpace,
          detailTile('Balance', '—'),
          heightSpace,
          detailTile('Status', '—'),
          heightSpace,
          detailTile('Type', '—'),
          heightSpace,
          detailTile('Opening Date', '—'),

          heightSpace,
          heightSpace,
          Text('Savings Account Fields', style: bold18Black33),
          heightSpace,
          detailTile('openingAmount', '—'),
          heightSpace,
          detailTile('modeOfOperation', '—'),
          heightSpace,
          detailTile('jointSurvivorCode', '—'),
          heightSpace,
          detailTile('jointSurvivorName', '—'),
          heightSpace,
          detailTile('relation', '—'),
          heightSpace,
          detailTile('advisorCode', '—'),
          heightSpace,
          detailTile('advisorName', '—'),
          heightSpace,
          detailTile('remarks', '—'),
          heightSpace,
          detailTile('smsSend', '—'),
          heightSpace,
          detailTile('debitCardIssue', '—'),
          heightSpace,
          Text('Savings Plan Details', style: bold18Black33),
          heightSpace,
          detailTile('schemeName', '—'),
          heightSpace,
          detailTile('schemeCode', '—'),
          heightSpace,
          detailTile('minOpeningBalance', '—'),
          heightSpace,
          detailTile('minMonthlyAvgBalance', '—'),
          heightSpace,
          detailTile('annualInterestRate', '—'),
          heightSpace,
          detailTile('interestPayout', '—'),
          heightSpace,
          detailTile('serviceCharges', '—'),
          heightSpace,
          detailTile('smsCharges', '—'),

          heightSpace,
          heightSpace,
          Text('Loan Account Fields', style: bold18Black33),
          heightSpace,
          detailTile('loanTerm', '—'),
          heightSpace,
          detailTile('loanAmount', '—'),
          heightSpace,
          detailTile('loanDate', '—'),
          heightSpace,
          detailTile('emiAmount', '—'),
          heightSpace,
          detailTile('principleEMI', '—'),
          heightSpace,
          detailTile('interestEMI', '—'),
          heightSpace,
          detailTile('totalEMI', '—'),
          heightSpace,
          detailTile('disbursement', '—'),
          heightSpace,
          detailTile('disbursementDate', '—'),
          heightSpace,
          detailTile('transactionDate', '—'),
          heightSpace,
          detailTile('applicants', '—'),
          heightSpace,
          detailTile('transDate', '—'),
          heightSpace,
          detailTile('paidEMI', '—'),
          heightSpace,
          detailTile('remainingBalance', '—'),
          heightSpace,
          detailTile('foreclosureStatus', '—'),
          heightSpace,
          detailTile('foreclosureBalance', '—'),
          heightSpace,
          detailTile('foreclosureFee', '—'),
          heightSpace,
          detailTile('closedDate', '—'),
          heightSpace,
          detailTile('totalPaid', '—'),
          heightSpace,
          detailTile('lastModified', '—'),
          heightSpace,
          Text('Loan Plan Details', style: bold18Black33),
          heightSpace,
          detailTile('id', '—'),
          heightSpace,
          detailTile('name', '—'),
          heightSpace,
          detailTile('type', '—'),
          heightSpace,
          detailTile('emiMode', '—'),
          heightSpace,
          detailTile('interestRate', '—'),
          heightSpace,
          detailTile('processingFee', '—'),
          heightSpace,
          detailTile('legalFee', '—'),
          heightSpace,
          detailTile('insuranceFeeRate', '—'),
          heightSpace,
          detailTile('gstRate', '—'),
          heightSpace,
          detailTile('gracePeriod', '—'),
          heightSpace,
          detailTile('penaltyType', '—'),
          heightSpace,
          detailTile('penaltyRate', '—'),
          heightSpace,
          Text('Guarantor', style: bold18Black33),
          heightSpace,
          detailTile('memberCode', '—'),
          heightSpace,
          detailTile('guarantorName', '—'),
          heightSpace,
          detailTile('address', '—'),
          heightSpace,
          detailTile('pinCode', '—'),
          heightSpace,
          detailTile('phone', '—'),
          heightSpace,
          detailTile('securityType', '—'),
          heightSpace,
          Text('Co-Applicant', style: bold18Black33),
          heightSpace,
          detailTile('memberCode', '—'),
          heightSpace,
          detailTile('coApplicantname', '—'),
          heightSpace,
          detailTile('address', '—'),
          heightSpace,
          detailTile('pinCode', '—'),
          heightSpace,
          detailTile('phone', '—'),
          heightSpace,
          detailTile('securityDetails', '—'),
          heightSpace,
          Text('Deductions', style: bold18Black33),
          heightSpace,
          detailTile('processingFee', '—'),
          heightSpace,
          detailTile('legalAmount', '—'),
          heightSpace,
          detailTile('insuranceAmount', '—'),
          heightSpace,
          detailTile('gst', '—'),
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
                  (KYCService.kycData?['name'] ?? "User Name").toString(),
                  style: bold16Black33,
                ),
                heightSpace,
                Text(
                  getTranslation(context, 'account_detail.account_number'),
                  style: semibold14Grey94,
                ),
                Text(
                  (savingsAccountData?['account'] ?? savingsAccountData?['accountId'] ?? 'N/A')
                      .toString(),
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
              Text(
                BankAccountsService.formatBalance(
                  ((savingsAccountData?['balance'] ?? 0) as num).toDouble(),
                ),
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
                                _selectedTypeIndex = index;
                                accountType = bankAccount[index]['name'].toString();
                              });
                              _applySelectedTypeFilter();
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
