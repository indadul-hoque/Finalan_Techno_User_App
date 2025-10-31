import 'package:fl_banking_app/pages/deposit/deposit_statement_screen.dart';
import 'package:fl_banking_app/pages/home/widgets/kycstatus/kyc_service.dart';
import 'package:fl_banking_app/pages/loans/loan_statement_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDetailScreen extends StatefulWidget {
  final String selectedType;
  final Map<String, dynamic>? savingsAccountData;

  const AccountDetailScreen({
    Key? key,
    this.selectedType = 'savings',
    this.savingsAccountData,
  }) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  Map<String, dynamic>? accountData;
  List<Map<String, dynamic>> _allAccounts = [];
  bool _isLoading = true;
  String? _errorMessage;
  SharedPreferences? _prefs; // Move this to the top with other state variables

  @override
  void initState() {
    super.initState();
    accountData = widget.savingsAccountData;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Assign SharedPreferences to _prefs
      _prefs = await SharedPreferences.getInstance();
      final phone = _prefs!.getString('phoneNumber') ?? '9519874704';

      // Fetch KYC for holder name
      await KYCService.fetchKYCDetails(phone);

      // Fetch accounts
      final list = await BankAccountsService.fetchBankAccounts(phone);
      if (list == null || list.isEmpty) {
        setState(() {
          _errorMessage =
              BankAccountsService.errorMessage ?? 'No accounts found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _allAccounts = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load account details';
        _isLoading = false;
      });
    }
  }

  Widget detailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Account Details",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_allAccounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Account Details',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        body: Center(
          child: Text(_errorMessage ?? 'No data'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Details",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _allAccounts.length,
          itemBuilder: (context, index) {
            final item = _allAccounts[index];
            final type = (item['accountType'] ?? '').toString();
            final displayType = BankAccountsService.formatAccountType(type);
            final num balanceValue =
                ((item['balance'] ?? item['remainingBalance'] ?? 0) as num);
            final isClosed = item['closed'] == true;
            final statusText = isClosed ? 'Closed' : 'Active';
            final statusColor =
                isClosed ? Colors.red.shade50 : Colors.green.shade50;
            final statusLabelColor =
                isClosed ? Colors.red.shade700 : Colors.green.shade700;
            final typeColor = Colors.blue.shade50;
            final typeLabelColor = Colors.blue.shade700;

            // Check if this is a loan account
            final bool isLoanAccount = type.toLowerCase() == 'loan' ||
                type.toLowerCase().contains('loan');

            return GestureDetector(
              onTap: () {
                final phone = _prefs?.getString('phoneNumber') ?? '9519874704';
                final accountId =
                    (item['accountId'] ?? item['account'] ?? '').toString();
                final accountType = type; // Already computed above

                if (accountType.toLowerCase() == 'loan' ||
                    accountType.toLowerCase().contains('loan')) {
                  // Navigate to Loan statement screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanStatementScreen(
                        phoneNumber: phone,
                        accountId: accountId,
                        accountType: accountType,
                      ),
                    ),
                  );
                } else {
                  // Navigate to Deposit statement screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepositStatementScreen(
                        phoneNumber: phone,
                        accountId: accountId,
                        accountType: accountType,
                      ),
                    ),
                  );
                }
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade100, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: isLoanAccount
                                  ? Colors.orange.shade600
                                  : Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isLoanAccount
                                  ? Icons.credit_card
                                  : Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['accountId'] ?? item['account'] ?? '—')
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  BankAccountsService.formatBalance(
                                      balanceValue.toDouble()),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  displayType,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: typeLabelColor),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusLabelColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Body rows
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          detailTile(
                              'Account number or id',
                              (item['accountId'] ?? item['account'] ?? '—')
                                  .toString()),
                          detailTile('Holder name',
                              (KYCService.kycData?['name'] ?? '—').toString()),
                          detailTile(
                              isLoanAccount ? 'Remaining Balance' : 'Balance',
                              BankAccountsService.formatBalance(
                                  balanceValue.toDouble())),
                          detailTile('Status', statusText),
                          detailTile('Type', displayType),

                          // Show loan-specific details
                          if (isLoanAccount && item['loanAmount'] != null)
                            detailTile(
                                'Loan Amount',
                                BankAccountsService.formatBalance(
                                    item['loanAmount'])),

                          if (isLoanAccount && item['emiAmount'] != null)
                            detailTile(
                                'EMI Amount',
                                BankAccountsService.formatBalance(
                                    item['emiAmount'])),

                          const SizedBox(height: 10),

                          // Add visual indicator for loan accounts
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blue.shade200, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isLoanAccount
                                      ? 'Tap to view loan statement'
                                      : 'Tap to view statement',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
