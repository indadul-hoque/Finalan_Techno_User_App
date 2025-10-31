import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

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