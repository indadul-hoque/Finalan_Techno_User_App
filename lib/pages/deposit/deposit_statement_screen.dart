import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:fl_banking_app/localization/localization_const.dart';

class StatementService {
  static String? errorMessage;

  static void showToast(String message, {bool isError = false}) {
    // Placeholder for toast
    print('Toast: $message');
  }

  static Future<Map<String, dynamic>?> fetchBalance(
      String phoneNumber, String accountId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://finalan-techno-api-879235286268.asia-south1.run.app/users/$phoneNumber/balance/$accountId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorMessage = 'Balance fetch failed: ${response.statusCode} - ${response.body}';
        print('StatementService.fetchBalance error: ${response.statusCode} -> ${response.body}');
        return null;
      }
    } catch (e) {
      errorMessage = e.toString();
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchSavingsStatement(
      String phoneNumber, String accountId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://finalan-techno-api-879235286268.asia-south1.run.app/users/$phoneNumber/statement/savings/$accountId'),
      );
      print("\nStatement Response:\n${response.body}\n");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorMessage = 'Statement fetch failed: ${response.statusCode} - ${response.body}';
        print('StatementService.fetchSavingsStatement error: ${response.statusCode} -> ${response.body}');
        return null;
      }
    } catch (e) {
      errorMessage = e.toString();
      return null;
    }
  }
}

class DepositStatementScreen extends StatefulWidget {
  final String phoneNumber;
  final String accountId;
  final String accountType;

  const DepositStatementScreen({
    Key? key,
    required this.phoneNumber,
    required this.accountId,
    required this.accountType,
  }) : super(key: key);

  @override
  State<DepositStatementScreen> createState() => _DepositStatementScreenState();
}

class _DepositStatementScreenState extends State<DepositStatementScreen> {
  // Helper method to format amount values that could be String or num
  String _formatAmount(dynamic value) {
    if (value == null) return '0.00';
    
    double numValue = 0.0;
    if (value is String) {
      numValue = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      numValue = value.toDouble();
    }
    
    return numValue.toStringAsFixed(2);
  }
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? statementData;
  double? currentBalance;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final balanceResponse =
          await StatementService.fetchBalance(widget.phoneNumber, widget.accountId);
      final statementResponse =
          await StatementService.fetchSavingsStatement(widget.phoneNumber, widget.accountId);

      if (balanceResponse != null && statementResponse != null) {
        setState(() {
          // Parse balance safely
          final balance = balanceResponse['balance'];
          if (balance is num) {
            currentBalance = balance.toDouble();
          } else if (balance is String) {
            currentBalance = double.tryParse(balance);
          } else if (balance is Map && balance['amount'] != null) {
            final amount = balance['amount'];
            if (amount is num) {
              currentBalance = amount.toDouble();
            } else if (amount is String) {
              currentBalance = double.tryParse(amount);
            }
          } else {
            currentBalance = 0.0;
          }

          statementData = statementResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          // Prefer the detailed message from StatementService if available.
          errorMessage = StatementService.errorMessage ?? 'Failed to fetch data. Please try again.';
        });
        if (StatementService.errorMessage != null) {
          print('StatementService reported: ${StatementService.errorMessage}');
        }
        StatementService.showToast(errorMessage!, isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
      StatementService.showToast(errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
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
          'Account Statement',
          style: bold20White,
        ),
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
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
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : statementData == null
                  ? const Center(child: Text('No statement data available'))
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(fixPadding * 2),
                      children: [
                        _buildAccountSummary(),
                        heightSpace,
                        heightSpace,
                        _buildTransactionsTitle(),
                        heightSpace,
                        _buildTransactionsList(),
                      ],
                    ),
    );
  }

  Widget _buildAccountSummary() {
    final transactions = statementData!['transactions'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
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
              const Icon(Icons.account_balance, color: primaryColor, size: 24),
              widthSpace,
              const Text('Account Summary', style: bold18Black33),
            ],
          ),
          heightSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account ID', style: semibold14Grey94),
                    Text(widget.accountId, style: bold16Black33),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Current Balance', style: semibold14Grey94),
                    Text(
                      '₹${currentBalance?.toStringAsFixed(2) ?? '0.00'}',
                      style: bold18Primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          heightSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Type', style: semibold14Grey94),
                    Text(widget.accountType.toUpperCase(), style: bold16Black33),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Transactions', style: semibold14Grey94),
                    Text('${transactions.length}', style: bold16Black33),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTitle() {
    return Text('Transaction History', style: bold18Black33);
  }

  Widget _buildTransactionsList() {
    final transactions = statementData!['transactions'] as List<dynamic>? ?? [];

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(fixPadding * 2),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 20),
            widthSpace,
            Text('No transactions found', style: semibold14Grey94),
          ],
        ),
      );
    }

    return ColumnBuilder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = transaction['type'] == 'credit';

        return Container(
          margin: const EdgeInsets.only(bottom: fixPadding),
          padding: const EdgeInsets.all(fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCredit ? Colors.green : Colors.red,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.add : Icons.remove,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 18,
                    ),
                  ),
                  widthSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['narration']?.isNotEmpty == true
                              ? transaction['narration']
                              : (isCredit ? 'Deposit' : 'Withdrawal'),
                          style: bold15Black33,
                        ),
                        Text(transaction['date'] ?? 'N/A', style: semibold14Grey94),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCredit
                            ? '+₹${(transaction['amount'] is num ? (transaction['amount'] as num).toDouble() : double.tryParse(transaction['amount'].toString()))?.toStringAsFixed(2) ?? '0.00'}'
                            : '-₹${(transaction['amount'] is num ? (transaction['amount'] as num).toDouble() : double.tryParse(transaction['amount'].toString()))?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color: isCredit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Balance: ₹${(transaction['balance'] is num ? (transaction['balance'] as num).toDouble() : double.tryParse(transaction['balance'].toString()))?.toStringAsFixed(2) ?? '0.00'}',
                        style: semibold14Grey94,
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction['method'] != null || transaction['glHead'] != null) ...[
                heightSpace,
                Container(
                  padding: const EdgeInsets.all(fixPadding / 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      if (transaction['method'] != null) ...[
                        Text('Method: ${transaction['method']}', style: semibold14Grey94),
                        if (transaction['glHead'] != null) ...[
                          const SizedBox(width: 10),
                          Text('•', style: semibold14Grey94),
                          const SizedBox(width: 10),
                        ],
                      ],
                      if (transaction['glHead'] != null)
                        Expanded(
                          child: Text(
                            transaction['glHead'],
                            style: semibold14Grey94,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
