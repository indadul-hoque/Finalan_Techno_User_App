// lib/pages/home/home_screen.dart
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/services/kyc_service.dart';
import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:fl_banking_app/services/statement_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedUserId;
  bool isLoadingKYC = false;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedUserId = prefs.getString('phoneNumber');
    });
    if (selectedUserId != null) {
      _loadKYCData();
    }
  }

  Future<void> _loadKYCData() async {
    setState(() {
      isLoadingKYC = true;
    });
    await KYCService.fetchKYCDetails(selectedUserId!);
    userName = KYCService.getUserName();
    await _loadBankAccountsData();
    setState(() {
      isLoadingKYC = false;
    });
  }

  Future<void> _loadBankAccountsData() async {
    if (selectedUserId != null) {
      await BankAccountsService.fetchBankAccounts(selectedUserId!);
      await _fetchRecentTransactions();
    }
  }

  Future<void> _fetchRecentTransactions() async {
    if (selectedUserId == null) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      // Get savings accounts to fetch transactions from the first one
      final savingsAccounts = BankAccountsService.getSavingsAccounts();
      if (savingsAccounts.isNotEmpty) {
        final firstAccount = savingsAccounts.first;
        final accountId = firstAccount['accountId'];

        if (accountId != null) {
          final statementData = await StatementService.fetchSavingsStatement(
              selectedUserId!, accountId);

          if (statementData != null && statementData['transactions'] != null) {
            final transactions =
                List<Map<String, dynamic>>.from(statementData['transactions']);
            // Sort by date (most recent first) and take latest 3
            transactions
                .sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

            final latestTransactions = transactions.take(3).map((transaction) {
              final isCredit = transaction['type'] == 'credit';
              final amount = transaction['amount'] ?? 0.0;
              final narration = transaction['narration']?.isNotEmpty == true
                  ? transaction['narration']
                  : (isCredit ? 'Deposit' : 'Withdrawal');

              return {
                "icon": isCredit
                    ? CupertinoIcons.arrow_down_circle_fill // Deposit
                    : CupertinoIcons.arrow_up_circle_fill, // Withdrawal

                "name": narration,
                "title": transaction['date'] ?? 'N/A',
                "money": amount.toStringAsFixed(2),
                "isCredit": isCredit
              };
            }).toList();

            setState(() {
              _recentTransactions = latestTransactions;
            });
          }
        }
      }
    } catch (e) {
      print('Failed to fetch recent transactions: $e');
    } finally {
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }

  List<Map<String, dynamic>> get accountList {
    if (BankAccountsService.accounts == null ||
        BankAccountsService.accounts!.isEmpty) {
      return [
        {
          "totalbalance": 0,
          "accountType": "No accounts found",
          "accountNo": "Please refresh to load accounts",
        }
      ];
    }

    List<Map<String, dynamic>> accounts = [];

    // Add savings accounts
    for (var account in BankAccountsService.getSavingsAccounts()) {
      accounts.add({
        "totalbalance": account['balance'] ?? 0,
        "accountType":
            BankAccountsService.formatAccountType(account['accountType']),
        "accountNo": "A/c no ${account['account']}",
        "accountId": account['accountId'],
        "openingDate": account['openingDate'],
        "isRealAccount": true,
      });
    }

    // Add loan accounts
    for (var account in BankAccountsService.getLoanAccounts()) {
      accounts.add({
        "totalbalance": account['loanAmount'] ?? 0,
        "accountType":
            BankAccountsService.formatAccountType(account['accountType']),
        "accountNo": "Loan ID: ${account['account']}",
        "accountId": account['accountId'],
        "loanTerm": account['loanTerm'],
        "emiAmount": account['emiAmount'],
        "isRealAccount": true,
      });
    }

    // Add wallet account
    accounts.add({
      "totalbalance": 2500.00,
      "accountType": "Digital Wallet",
      "accountNo": "Wallet ID: WLT001",
      "accountId": "WLT001",
      "isRealAccount": false,
      "walletType": "UPI Wallet",
    });

    return accounts;
  }

  final servicelist = const [
    {
      "image": "assets/home/account.png",
      "name": "Account",
      "isDetail": true,
      "routeName": "/account"
    },
    {
      "image": "assets/home/statement.png",
      "name": "Statement",
      "isDetail": true,
      "routeName": "/statement"
    },
    {
      "image": "assets/bottomNavigation/Glyph_ undefined.png",
      "name": "Deposit",
      "routeName": "/addDeposit",
      "isDetail": true
    },
    {
      "image": "assets/home/loan.png",
      "name": "Loan Repayment",
      "routeName": "/loanRepayment",
      "isDetail": true
    }
  ];

  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoadingTransactions = false;

  List<Map<String, dynamic>> get transectionlist {
    if (_recentTransactions.isEmpty) {
      return [
        {
          "image": "assets/home/fundTransfer.png",
          "name": "No transactions",
          "title": "Pull to refresh",
          "money": 0,
          "isCredit": false
        }
      ];
    }
    return _recentTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          topBox(size),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
              physics: const BouncingScrollPhysics(),
              children: [
                serviceTitle(),
                serviceList(size),
                heightSpace,
                _buildKYCStatusCard(),
                heightSpace,
                _buildBankAccountsSummary(),
                heightSpace,
                latestTtile(),
                latestTransectionList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  latestTransectionList() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return OptimizedTransactionCard(
          transactionData: transectionlist[index],
        );
      },
      itemCount: transectionlist.length,
    );
  }

  latestTtile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              getTranslation(context, 'home.latest_transaction'),
              style: bold18Black33,
            ),
          ),
          if (_isLoadingTransactions)
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              onPressed: _fetchRecentTransactions,
              icon: const Icon(
                Icons.refresh,
                color: primaryColor,
                size: 20,
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/transaction');
            },
            child: Text(
              getTranslation(context, 'home.see_all'),
              style: bold14Grey94,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKYCStatusCard() {
    if (selectedUserId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  color: whiteColor,
                  size: 24,
                ),
                widthSpace,
                const Text(
                  'KYC Status',
                  style: bold18White,
                ),
                const Spacer(),
                if (isLoadingKYC)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: whiteColor,
                      strokeWidth: 2,
                    ),
                  )
                else
                  IconButton(
                    onPressed: _loadKYCData,
                    icon: const Icon(
                      Icons.refresh,
                      color: whiteColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            heightSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${KYCService.getKYCStatus()}',
                  style: semibold16White,
                ),
                Text(
                  '${KYCService.getKYCCompletionPercentage().toStringAsFixed(0)}% Complete',
                  style: bold16White,
                ),
              ],
            ),
            heightSpace,
            LinearProgressIndicator(
              value: KYCService.getKYCCompletionPercentage() / 100,
              backgroundColor: whiteColor.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(whiteColor),
            ),
            heightSpace,
            if (KYCService.getKYCCompletionPercentage() < 100)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding,
                    vertical: fixPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Complete KYC',
                    style: bold14Primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  serviceList(Size size) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
          left: fixPadding * 2,
          right: fixPadding * 2,
          bottom: fixPadding,
          top: fixPadding),
      crossAxisCount: 3,
      childAspectRatio: (size.width) / (size.height / 2),
      shrinkWrap: true,
      mainAxisSpacing: fixPadding * 2,
      crossAxisSpacing: fixPadding * 2,
      children: [
        for (int i = 0; i < servicelist.length; i++)
          OptimizedServiceCard(
            serviceData: servicelist[i],
          ),
      ],
    );
  }

  serviceTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'home.services'),
        style: bold18Black33,
      ),
    );
  }

  topBox(Size size) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/bg.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.5),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightSpace,
              topTitle(),
              heightSpace,
              // _buildTotalBalanceDisplay(),
              heightSpace,
              height5Space,
              accountTypeList(size),
              heightSpace,
              height5Space,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountsSummary() {
    if (selectedUserId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  color: primaryColor,
                  size: 24,
                ),
                widthSpace,
                const Text(
                  'Bank Accounts Summary',
                  style: bold18Black33,
                ),
                const Spacer(),
                if (BankAccountsService.isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                else
                  IconButton(
                    onPressed: _loadBankAccountsData,
                    icon: const Icon(
                      Icons.refresh,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            heightSpace,
            if (BankAccountsService.accounts != null &&
                BankAccountsService.accounts!.isNotEmpty) ...[
              // Total Balance
              Container(
                padding: const EdgeInsets.all(fixPadding),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Balance:',
                      style: semibold16Black33,
                    ),
                    Text(
                      BankAccountsService.formatBalance(
                          BankAccountsService.getTotalBalance()),
                      style: bold18Primary,
                    ),
                  ],
                ),
              ),
              heightSpace,
              // Accounts List
              ...BankAccountsService.accounts!.map((account) {
                bool isSavings = account['accountType'] == 'savings';
                bool isLoan = account['accountType'] == 'loan';

                return Container(
                  margin: const EdgeInsets.only(bottom: fixPadding / 2),
                  padding: const EdgeInsets.all(fixPadding),
                  decoration: BoxDecoration(
                    color: isSavings
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSavings ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSavings ? Icons.savings : Icons.credit_card,
                        color: isSavings ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      widthSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account['accountId'] ?? 'N/A',
                              style: bold15Black33,
                            ),
                            Text(
                              isSavings
                                  ? 'Balance: ${BankAccountsService.formatBalance(account['balance'])}'
                                  : 'Loan Amount: ${BankAccountsService.formatBalance(account['loanAmount'])}',
                              style: semibold14Grey94,
                            ),
                            if (isLoan && account['emiAmount'] != null)
                              Text(
                                'EMI: ${BankAccountsService.formatBalance(account['emiAmount'])}',
                                style: semibold14Grey94,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        isSavings
                            ? BankAccountsService.formatBalance(
                                account['balance'])
                            : BankAccountsService.formatBalance(
                                account['loanAmount']),
                        style: bold16Primary,
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Wallet Account Card
              Container(
                margin: const EdgeInsets.only(bottom: fixPadding / 2),
                padding: const EdgeInsets.all(fixPadding),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    widthSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WLT001',
                            style: bold15Black33,
                          ),
                          const Text(
                            'Digital Wallet - UPI Wallet',
                            style: semibold14Grey94,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹2,500.00',
                      style: bold16Primary,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(fixPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    widthSpace,
                    Text(
                      'No accounts found. Pull to refresh.',
                      style: semibold14Grey94,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  topTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/splash/mdi_star-three-points-outline.png",
                height: 28,
                width: 28,
                color: whiteColor,
              ),
              widthSpace,
              Text(
                "Hi, ${userName ?? 'User'}",
                style: interSemibold20White,
              )
            ],
          ),
        ],
      ),
    );
  }

  accountTypeList(Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: fixPadding),
      child: Row(
        children: List.generate(
          accountList.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding),
            child: OptimizedAccountCard(
              accountData: accountList[index],
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

class OptimizedAccountCard extends StatelessWidget {
  const OptimizedAccountCard({
    Key? key,
    required this.accountData,
    required this.size,
  }) : super(key: key);

  final Map<String, dynamic> accountData;
  final Size size;

  @override
  Widget build(BuildContext context) {
    // Check account types for appropriate icons
    bool isWallet = accountData['accountType'] == 'Digital Wallet';
    bool isSavings = accountData['accountType'] == 'Savings Account';
    bool isLoan = accountData['accountType'] == 'Loan Account';

    return Container(
      width: size.width * 0.8,
      padding: const EdgeInsets.symmetric(
        horizontal: fixPadding * 1.5,
        vertical: fixPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // Different styling for each account type
        gradient: LinearGradient(
          colors: isWallet
              ? [
                  const Color(0xFF4CAF50).withOpacity(0.15), // Green for wallet
                  const Color(0xFF8BC34A).withOpacity(0.10),
                ]
              : isSavings
                  ? [
                      const Color(0xFF2196F3)
                          .withOpacity(0.12), // Blue for savings
                      const Color(0xFF64B5F6).withOpacity(0.08),
                    ]
                  : isLoan
                      ? [
                          const Color(0xFFFF9800)
                              .withOpacity(0.12), // Orange for loan
                          const Color(0xFFFFB74D).withOpacity(0.08),
                        ]
                      : [
                          const Color(0xFFDEB16C)
                              .withOpacity(0.12), // Default colors
                          const Color(0xFFEC98B3).withOpacity(0.08),
                        ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isWallet
              ? const Color(0xFF4CAF50)
                  .withOpacity(0.7) // Green border for wallet
              : isSavings
                  ? const Color(0xFF2196F3)
                      .withOpacity(0.6) // Blue border for savings
                  : isLoan
                      ? const Color(0xFFFF9800)
                          .withOpacity(0.6) // Orange border for loan
                      : const Color(0xFFEC98B3)
                          .withOpacity(0.6), // Default border
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isWallet) ...[
                const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ] else if (isSavings) ...[
                const Icon(
                  Icons.savings,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ] else if (isLoan) ...[
                const Icon(
                  Icons.credit_card,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text.rich(
                  overflow: TextOverflow.ellipsis,
                  TextSpan(
                    text: getTranslation(context, 'home.total_balance'),
                    style: bold18GreyD6,
                    children: [
                      const TextSpan(text: " : "),
                      TextSpan(
                        text: "\₹${accountData['totalbalance']}",
                        style: bold22GreyD6,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          heightSpace,
          height5Space,
          Text(
            accountData['accountType'].toString(),
            style: semibold14EE,
          ),
          Text(
            accountData['accountNo'].toString(),
            style: bold14EE,
          )
        ],
      ),
    );
  }
}

class OptimizedTransactionCard extends StatelessWidget {
  const OptimizedTransactionCard({Key? key, required this.transactionData})
      : super(key: key);

  final Map<String, dynamic> transactionData;

  @override
  Widget build(BuildContext context) {
    final isCredit = transactionData['isCredit'] ?? false;
    final Color iconColor = isCredit ? Colors.green : Colors.red;

    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2),
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transactionData['icon'] as IconData,
              color: iconColor,
              size: 22,
            ),
          ),
          widthSpace,
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionData['name'].toString(),
                  style: bold15Black33,
                ),
                heightBox(3.0),
                Text(
                  transactionData['title'].toString(),
                  style: bold12Grey94,
                )
              ],
            ),
          ),
          Text(
            "${isCredit ? '+' : '-'}\₹${transactionData['money']}",
            style: isCredit ? bold15Green : bold15Red,
          )
        ],
      ),
    );
  }
}

class OptimizedServiceCard extends StatelessWidget {
  const OptimizedServiceCard({Key? key, required this.serviceData})
      : super(key: key);

  final Map<String, dynamic> serviceData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (serviceData['isDetail'] == true) {
          Navigator.pushNamed(
            context,
            serviceData['routeName'].toString(),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.25),
              blurRadius: 6,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              serviceData['image'].toString(),
              height: 24,
              width: 24,
              color: primaryColor,
            ),
            height5Space,
            Text(
              serviceData['name'].toString(),
              style: bold15Primary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
