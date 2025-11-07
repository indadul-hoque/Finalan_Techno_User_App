import 'dart:convert';

import 'package:fl_banking_app/config.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/home/widgets/kycstatus/kyc_service.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:fl_banking_app/services/statement_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/pages/home/widgets/header/top_box.dart';
import 'package:fl_banking_app/pages/home/widgets/services/service_widget.dart';
import 'package:fl_banking_app/pages/home/widgets/kycstatus/kyc_status_card.dart';
import 'package:fl_banking_app/pages/home/widgets/bankaccount/bank_accounts_summary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  final String? phoneNumber;

  const HomeScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedUserId;
  bool isLoadingKYC = false;
  String? userName;
  bool _isLoadingTransactions = false;
  List<Map<String, dynamic>> _recentTransactions = [];


double _walletBalance = 0.0;
  bool _isLoadingWallet = true; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    String? phoneNumber = widget.phoneNumber;
    final prefs = await SharedPreferences.getInstance();

    if (phoneNumber == null) {
      phoneNumber = prefs.getString('phoneNumber');
    }

    if (phoneNumber == null) {
      if (mounted) {
        _showToast('Phone number not found. Please log in again.');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
      return;
    }

    // Normalize phone number (remove +91)
    phoneNumber = phoneNumber.startsWith('+91') ? phoneNumber.substring(3) : phoneNumber;

    if (mounted) {
      setState(() {
        selectedUserId = phoneNumber;
      });
    }

    if (selectedUserId != null) {
      await Future.wait([
        _loadKYCData(),
        _fetchWalletBalance(), // NEW
      ]);
    }
  }

  // ADD: Fetch real wallet balance
  Future<void> _fetchWalletBalance() async {
    if (!mounted || selectedUserId == null) return;

    setState(() {
      _isLoadingWallet = true;
    });

    try {
      final formatted = selectedUserId!.startsWith('91') ? selectedUserId! : '91$selectedUserId!';
      final url = Uri.parse('${AppConfig.baseUrl}/mobile/wallet/$formatted');

      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true) {
          final balance = double.tryParse(json['data']['walletBalance'].toString()) ?? 0.0;
          if (mounted) {
            setState(() {
              _walletBalance = balance;
              _isLoadingWallet = false;
            });
          }
        } else {
          throw Exception('API success false');
        }
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWallet = false;
        });
      }
      print('Wallet fetch error: $e');
      // Optional: show toast only if critical
      // _showToast('Failed to load wallet balance');
    }
  }

  Future<void> _loadKYCData() async {
    if (!mounted) return;
    setState(() {
      isLoadingKYC = true;
    });

    try {
      await KYCService.fetchKYCDetails(selectedUserId!);
      if (mounted) {
        setState(() {
          userName = KYCService.getUserName();
          isLoadingKYC = false;
        });
      }
      await _loadBankAccountsData();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingKYC = false;
        });
        _showToast('Failed to load KYC data. Please complete KYC.');
        Navigator.pushNamed(context, '/kyc', arguments: selectedUserId);
      }
    }
  }

  Future<void> _loadBankAccountsData() async {
    if (!mounted || selectedUserId == null) return;

    try {
      await BankAccountsService.fetchBankAccounts(selectedUserId!);
      await _fetchRecentTransactions();
    } catch (e) {
      if (mounted) {
        _showToast('Failed to load bank accounts.');
      }
    }
  }

  Future<void> _fetchRecentTransactions() async {
  if (!mounted || selectedUserId == null) return;

  setState(() {
    _isLoadingTransactions = true;
  });

  try {
    final depositAccounts = BankAccountsService.getDepositAccounts();
    if (depositAccounts.isNotEmpty) {
      final firstAccount = depositAccounts.first;
      final accountId = firstAccount['accountId'];

      if (accountId != null) {
        final statementData = await StatementService.fetchSavingsStatement(
          selectedUserId!,
          accountId,
        );

        if (statementData != null && statementData['transactions'] != null) {
          final transactions = List<Map<String, dynamic>>.from(statementData['transactions']);
          transactions.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

          final latestTransactions = transactions.take(3).map((transaction) {
            final isCredit = transaction['type'] == 'credit';
            final amount = transaction['amount'] ?? 0.0;
            final narration = transaction['narration']?.isNotEmpty == true
                ? transaction['narration']
                : (isCredit ? 'Deposit' : 'Withdrawal');

            double? amountValue;
            if (amount is num) {
              amountValue = amount.toDouble();
            } else if (amount is String) {
              amountValue = double.tryParse(amount);
            }

            return {
              "icon": isCredit
                  ? CupertinoIcons.arrow_down_circle_fill
                  : CupertinoIcons.arrow_up_circle_fill,
              "name": narration,
              "title": transaction['date'] ?? 'N/A',
              "money": amountValue?.toStringAsFixed(2) ?? '0.00',
              "isCredit": isCredit,
            };
          }).toList();

          if (mounted) {
            setState(() {
              _recentTransactions = latestTransactions;
              _isLoadingTransactions = false;
            });
          }
        } else {
          if (mounted) {
            // Removed the toast message
            setState(() {
              _isLoadingTransactions = false;
            });
          }
        }
      } else {
        if (mounted) {
          _showToast('Invalid account ID.');
          setState(() {
            _isLoadingTransactions = false;
          });
        }
      }
    } else {
      if (mounted) {
        // Optionally, you can also remove this toast if you want
        _showToast('No deposit accounts found.');
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showToast('Failed to fetch transactions: $e');
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }
}

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          TopBox(size: size, userName: userName, accountList: accountList),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
              physics: const BouncingScrollPhysics(),
              children: [
                const ServiceTitle(),
                ServiceList(size: size),
                heightSpace,
                if (selectedUserId != null)
                  KYCStatusCard(
                    isLoadingKYC: isLoadingKYC,
                    onRefresh: _loadKYCData,
                  ),
                heightSpace,
                if (selectedUserId != null)
                  BankAccountsSummary(
                    isLoading: BankAccountsService.isLoading,
                    onRefresh: _loadBankAccountsData,
                    accounts: BankAccountsService.accounts ?? [],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get accountList {
    if (BankAccountsService.accounts == null || BankAccountsService.accounts!.isEmpty) {
      return [
        {
          "totalbalance": 0,
          "accountType": "No accounts found",
          "accountNo": "Please refresh to load accounts",
          "isRealAccount": false,
        }
      ];
    }

    List<Map<String, dynamic>> accounts = [];

    for (var account in BankAccountsService.getDepositAccounts()) {
      accounts.add({
        "totalbalance": account['balance'] ?? 0,
        "accountType": BankAccountsService.formatAccountType(account['accountType']),
        "accountNo": "A/c no ${account['accountId'] ?? 'N/A'}",
        "accountId": account['accountId'],
        "openingDate": account['openingDate'],
        "isRealAccount": true,
      });
    }

    for (var account in BankAccountsService.getLoanAccounts()) {
      accounts.add({
        "totalbalance": account['loanAmount'] ?? 0,
        "accountType": BankAccountsService.formatAccountType(account['accountType']),
        "accountNo": "Loan ID: ${account['accountId'] ?? 'N/A'}",
        "accountId": account['accountId'],
        "loanTerm": account['loanTerm'],
        "emiAmount": account['emiAmount'],
        "isRealAccount": true,
      });
    }

    // ADD: Real Wallet from API
    accounts.add({
      "totalbalance": _walletBalance,
      "accountType": "Digital Wallet",
      "accountNo": _isLoadingWallet ? "Loading..." : "Wallet ID: WLT001",
      "accountId": "WLT001",
      "isRealAccount": false,
      "walletType": "UPI Wallet",
      "isLoading": _isLoadingWallet,
    });

    // Fallback if no accounts
    if (accounts.isEmpty && !_isLoadingWallet) {
      accounts.add({
        "totalbalance": 0,
        "accountType": "No accounts found",
        "accountNo": "Please refresh to load accounts",
        "isRealAccount": false,
      });
    }

    return accounts;
  }
}