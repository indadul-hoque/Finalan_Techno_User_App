import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/services/statement_service.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class LoanStatementScreen extends StatefulWidget {
  final String phoneNumber;
  final String accountId;
  final String accountType;
  
  const LoanStatementScreen({
    Key? key, 
    required this.phoneNumber,
    required this.accountId,
    required this.accountType,
  }) : super(key: key);
  
  @override
  State<LoanStatementScreen> createState() => _LoanStatementScreenState();
}

class _LoanStatementScreenState extends State<LoanStatementScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? statementData;

  @override
  void initState() {
    super.initState();
    _fetchStatement();
  }

  Future<void> _fetchStatement() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Fetch real loan statement data from API
      final data = await StatementService.fetchLoanStatement(
        widget.phoneNumber,
        widget.accountId,
      );
      
      if (data != null) {
        setState(() {
          statementData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = StatementService.errorMessage ?? 'Failed to fetch loan statement';
          isLoading = false;
        });
        StatementService.showToast(errorMessage!, isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
      StatementService.showToast('An error occurred: $e', isError: true);
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
          'Loan Statement',
          style: bold20White,
        ),
        actions: [
          IconButton(
            onPressed: _fetchStatement,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
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
                    onPressed: _fetchStatement,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : statementData == null
            ? const Center(
                child: Text('No statement data available'),
              )
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(fixPadding * 2),
                children: [
                  _buildLoanSummary(),
                  heightSpace,
                  heightSpace,
                  _buildRepaymentSummary(),
                  heightSpace,
                  heightSpace,
                  _buildTransactionsTitle(),
                  heightSpace,
                  _buildTransactionsList(),
                ],
              ),
    );
  }

  Widget _buildLoanSummary() {
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
              const Icon(
                Icons.credit_card,
                color: primaryColor,
                size: 24,
              ),
              widthSpace,
              const Text(
                'Loan Summary',
                style: bold18Black33,
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
                    Text(
                      'Loan ID',
                      style: semibold14Grey94,
                    ),
                    Text(
                      widget.accountId,
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Loan Type',
                      style: semibold14Grey94,
                    ),
                    Text(
                      widget.accountType.toUpperCase(),
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment,
                color: primaryColor,
                size: 24,
              ),
              widthSpace,
              const Text(
                'Repayment Summary',
                style: bold18Black33,
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
                    Text(
                      'Total EMI Paid',
                      style: semibold14Grey94,
                    ),
                    Text(
                      _getTotalEMIPaid(),
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'EMI Amount',
                      style: semibold14Grey94,
                    ),
                    Text(
                      _getAverageEMIAmount(),
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: semibold14Grey94,
                    ),
                    Text(
                      _getRemainingBalance(),
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
            ],
          ),
          heightSpace,
          LinearProgressIndicator(
            value: _getRepaymentProgress(),
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          heightSpace,
          Text(
            'Repayment Progress: ${(_getRepaymentProgress() * 100).toStringAsFixed(1)}%',
            style: semibold14Grey94,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTitle() {
    return Text(
      'Payment History',
      style: bold18Black33,
    );
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
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 20,
            ),
            widthSpace,
            Text(
              'No payment records found',
              style: semibold14Grey94,
            ),
          ],
        ),
      );
    }

    return ColumnBuilder(
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isPayment = transaction['type'] == 'debit';
        
        return Container(
          margin: const EdgeInsets.only(bottom: fixPadding),
          padding: const EdgeInsets.all(fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPayment ? Colors.orange : Colors.grey,
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
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
              widthSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['narration'] ?? 'EMI Payment',
                      style: bold15Black33,
                    ),
                    Text(
                      transaction['date'] ?? 'N/A',
                      style: semibold14Grey94,
                    ),
                    if (transaction['method'] != null)
                      Text(
                        'Method: ${transaction['method']}',
                        style: semibold14Grey94,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-₹${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Balance: ₹${transaction['balance']?.toStringAsFixed(2) ?? '0.00'}',
                    style: semibold14Grey94,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      itemCount: transactions.length,
    );
  }

  // Helper methods to calculate values from API data
  String _getTotalEMIPaid() {
    if (statementData == null || statementData!['transactions'] == null) return '₹0.00';
    
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    double total = 0.0;
    
    for (var transaction in transactions) {
      if (transaction['type'] == 'debit') {
        total += (transaction['amount'] ?? 0.0).toDouble();
      }
    }
    
    return '₹${total.toStringAsFixed(2)}';
  }

  String _getAverageEMIAmount() {
    if (statementData == null || statementData!['transactions'] == null) return '₹0.00';
    
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    double total = 0.0;
    int count = 0;
    
    for (var transaction in transactions) {
      if (transaction['type'] == 'debit') {
        total += (transaction['amount'] ?? 0.0).toDouble();
        count++;
      }
    }
    
    if (count == 0) return '₹0.00';
    return '₹${(total / count).toStringAsFixed(2)}';
  }

  String _getRemainingBalance() {
    if (statementData == null || statementData!['transactions'] == null) return '₹0.00';
    
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    if (transactions.isEmpty) return '₹0.00';
    
    // Get the last transaction's balance (most recent)
    final lastTransaction = transactions.first;
    return '₹${(lastTransaction['balance'] ?? 0.0).toStringAsFixed(2)}';
  }

  double _getRepaymentProgress() {
    if (statementData == null || statementData!['transactions'] == null) return 0.0;
    
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    if (transactions.isEmpty) return 0.0;
    
    // Calculate progress based on total transactions vs completed payments
    // This is a simplified calculation - you might want to adjust based on your API structure
    final totalTransactions = transactions.length;
    final completedPayments = transactions.where((t) => t['type'] == 'debit').length;
    
    if (totalTransactions == 0) return 0.0;
    return completedPayments / totalTransactions;
  }
}
