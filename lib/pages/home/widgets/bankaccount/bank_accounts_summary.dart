import 'package:fl_banking_app/services/bank_accounts_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class BankAccountsSummary extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;
  final List<Map<String, dynamic>> accounts;

  const BankAccountsSummary({
    Key? key,
    required this.isLoading,
    required this.onRefresh,
    required this.accounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Separate accounts into deposits and loans using service methods
    final depositAccounts = BankAccountsService.getDepositAccounts();
    final loanAccounts = BankAccountsService.getLoanAccounts();

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
            // Header
            Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  color: primaryColor,
                  size: 24,
                ),
                widthSpace,
                const Text(
                  'Accounts Overview',
                  style: bold18Black33,
                ),
                const Spacer(),
                if (isLoading)
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
                    onPressed: onRefresh,
                    icon: const Icon(
                      Icons.refresh,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            heightSpace,
            // Deposit Accounts Section
            _buildSectionTitle('Deposit Accounts'),
            if (depositAccounts.isNotEmpty) ...[
              _buildTotalBalance(),
              heightSpace,
              ...depositAccounts.map((account) => _buildAccountCard(
                    account: account,
                    isSavings: true,
                  )),
            ] else
              _buildEmptyState('No deposit accounts found.'),
            heightSpace,
            // Loans Section
            _buildSectionTitle('Loans'),
            if (loanAccounts.isNotEmpty) ...[
              _buildTotalLoanAmount(),
              heightSpace,
              ...loanAccounts.map((account) => _buildAccountCard(
                    account: account,
                    isSavings: false,
                  )),
            ] else
              _buildEmptyState('No loans found.'),
            heightSpace,
            // Wallet Section
            _buildSectionTitle('Wallet'),
            _buildWalletCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: bold16Black33,
    );
  }

  Widget _buildTotalBalance() {
    return Container(
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
            BankAccountsService.formatBalance(BankAccountsService.getTotalBalance()),
            style: bold18Primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLoanAmount() {
    return Container(
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Loan Amount:',
            style: semibold16Black33,
          ),
          Text(
            BankAccountsService.formatBalance(BankAccountsService.getTotalLoanAmount()),
            style: bold18Primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required Map<String, dynamic> account,
    required bool isSavings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: fixPadding / 2),
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: isSavings ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
                      ? '${BankAccountsService.formatAccountType(account['accountType'])}: ${BankAccountsService.formatBalance(account['balance'])}'
                      : 'Loan Amount: ${BankAccountsService.formatBalance(account['loanAmount'])}',
                  style: semibold14Grey94,
                ),
                if (!isSavings && account['emiAmount'] != null)
                  Text(
                    'EMI: ${BankAccountsService.formatBalance(account['emiAmount'])}',
                    style: semibold14Grey94,
                  ),
              ],
            ),
          ),
          Text(
            isSavings
                ? BankAccountsService.formatBalance(account['balance'])
                : BankAccountsService.formatBalance(account['loanAmount']),
            style: bold16Primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WLT001',
                  style: bold15Black33,
                ),
                Text(
                  'Digital Wallet - UPI Wallet',
                  style: semibold14Grey94,
                ),
              ],
            ),
          ),
          const Text(
            '₹2,500.00',
            style: bold16Primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.grey,
            size: 20,
          ),
          widthSpace,
          Text(
            message,
            style: semibold14Grey94,
          ),
        ],
      ),
    );
  }
}