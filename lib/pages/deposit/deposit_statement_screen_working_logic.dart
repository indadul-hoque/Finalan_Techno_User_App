import 'package:flutter/material.dart';
import '../../services/statement_service.dart';

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
  _DepositStatementScreenState createState() => _DepositStatementScreenState();
}

class _DepositStatementScreenState extends State<DepositStatementScreen> {
  bool isLoading = false;
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

      // Fetch balance
      final balanceResponse = await StatementService.fetchBalance(
        widget.phoneNumber,
        widget.accountId,
      );

      // Fetch statement
      final statementResponse = await StatementService.fetchSavingsStatement(
        widget.phoneNumber,
        widget.accountId,
      );

      if (balanceResponse != null && statementResponse != null) {
        setState(() {
          print("Balance Response: $balanceResponse");

          final balance = balanceResponse['balance'];

          if (balance is num) {
            currentBalance = balance.toDouble();
          } else if (balance is String) {
            currentBalance = double.tryParse(balance) ?? 0.0;
          } else if (balance is Map && balance['amount'] != null) {
            final amount = balance['amount'];
            if (amount is num) {
              currentBalance = amount.toDouble();
            } else if (amount is String) {
              currentBalance = double.tryParse(amount) ?? 0.0;
            }
          } else {
            currentBalance = 0.0;
          }

          print("Parsed currentBalance: $currentBalance");

          statementData = statementResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch all data. Please try again.';
        });
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
        title: const Text("Deposit Statement"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
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
                      Text(errorMessage!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : statementData == null
                  ? const Center(child: Text("No data available"))
                  : _buildStatementView(),
    );
  }

  Widget _buildStatementView() {
    final transactions =
        statementData?['transactions'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            title: const Text("Current Balance"),
            subtitle: Text(widget.accountType.toUpperCase()),
            trailing: Text(
              '₹${currentBalance?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text("No transactions available"))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final amount = txn['amount'];
                    double? parsedAmount;

                    if (amount is num) {
                      parsedAmount = amount.toDouble();
                    } else if (amount is String) {
                      parsedAmount = double.tryParse(amount);
                    }

                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(txn['narration'] ?? "Transaction"),
                      subtitle: Text(txn['date'] ?? ""),
                      trailing: Text(
                        "₹${parsedAmount?.toStringAsFixed(2) ?? '0.00'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
