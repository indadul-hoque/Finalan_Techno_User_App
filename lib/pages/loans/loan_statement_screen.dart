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

class _LoanStatementScreenState extends State<LoanStatementScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? statementData;

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fetchStatement();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatement() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await StatementService.fetchLoanStatement(
        widget.phoneNumber,
        widget.accountId,
      );

      if (data != null) {
        setState(() {
          statementData = data;
          isLoading = false;
        });

        double progress = _calculateRepaymentProgress();
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: progress,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );

        _animationController.forward(from: 0.0);
      } else {
        setState(() {
          errorMessage =
              StatementService.errorMessage ?? 'Failed to fetch loan statement';
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

  double _calculateRepaymentProgress() {
    if (statementData == null || statementData!['transactions'] == null) {
      return 0.0;
    }

    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    if (transactions.isEmpty) return 0.0;

    final totalRepaid = _getTotalEMIPaidValue();
    final loanAmount = _getLoanAmountValue();

    return loanAmount > 0 ? (totalRepaid / loanAmount).clamp(0.0, 1.0) : 0.0;
  }

  String formatNumber(dynamic value) {
    return StatementService.formatAmount(value);
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
          statusBarIconBrightness: Brightness.light,
        ),
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
    final loanAmount = _getLoanAmountValue();
    final totalPaid = _getTotalEMIPaidValue();
    final remaining = _getRemainingBalanceValue();
    final emiAmount = _getAverageEMIAmountValue();

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
                      'Loan Amount',
                      style: semibold14Grey94,
                    ),
                    Text(
                      formatNumber(loanAmount),
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
                      'Total EMI Paid',
                      style: semibold14Grey94,
                    ),
                    Text(
                      formatNumber(totalPaid),
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
                      'Remaining Balance',
                      style: semibold14Grey94,
                    ),
                    Text(
                      formatNumber(remaining),
                      style: bold16Black33,
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
                    Text(
                      'EMI Amount',
                      style: semibold14Grey94,
                    ),
                    Text(
                      formatNumber(emiAmount),
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
                      'Repayment Progress',
                      style: semibold14Grey94,
                    ),
                    Text(
                      '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                      style: bold16Black33,
                    ),
                  ],
                ),
              ),
            ],
          ),
          heightSpace,
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 6,
              );
            },
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
        final isCredit = transaction['type'] == 'credit';
        final color = isCredit ? Colors.green : Colors.red;

        double amountValue = 0.0;
        var amt = transaction['amount'];
        if (amt is String) {
          amountValue = double.tryParse(amt) ?? 0.0;
        } else if (amt is num) {
          amountValue = amt.toDouble();
        }

        double balanceValue = 0.0;
        var bal = transaction['balance'];
        if (bal is String) {
          balanceValue = double.tryParse(bal) ?? 0.0;
        } else if (bal is num) {
          balanceValue = bal.toDouble();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: fixPadding),
          padding: const EdgeInsets.all(fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color,
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payment,
                  color: color,
                  size: 18,
                ),
              ),
              widthSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['narration'] ?? (isCredit ? 'Loan Repayment' : 'Loan Disbursement'),
                      style: bold15Black33,
                    ),
                    Text(
                      transaction['entryDate'] ?? 'N/A',
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
                    isCredit ? '+${formatNumber(amountValue)}' : '-${formatNumber(amountValue)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Balance: ${formatNumber(balanceValue)}',
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

  double _getLoanAmountValue() {
    if (statementData == null || statementData!['transactions'] == null) return 0.0;
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    for (var t in transactions) {
      if (t['type'] == 'debit') {
        var amt = t['amount'];
        if (amt is String) {
          return double.tryParse(amt) ?? 0.0;
        } else if (amt is num) {
          return amt.toDouble();
        }
      }
    }
    return 0.0;
  }

  double _getTotalEMIPaidValue() {
    return StatementService.getTotalCredits();
  }

  double _getAverageEMIAmountValue() {
    if (statementData == null || statementData!['transactions'] == null) return 0.0;
    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    double total = 0.0;
    int count = 0;
    for (var t in transactions) {
      if (t['type'] == 'credit') {
        var amt = t['amount'];
        double value = 0.0;
        if (amt is String) {
          value = double.tryParse(amt) ?? 0.0;
        } else if (amt is num) {
          value = amt.toDouble();
        }
        total += value;
        count++;
      }
    }
    return count == 0 ? 0.0 : total / count;
  }

  double _getRemainingBalanceValue() {
    final loanAmount = _getLoanAmountValue();
    final totalPaid = _getTotalEMIPaidValue();
    return (loanAmount - totalPaid).clamp(0.0, double.infinity);
  }
}