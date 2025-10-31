import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LatestTransactionWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;
  final List<Map<String, dynamic>> transactions;

  const LatestTransactionWidget({
    Key? key,
    required this.isLoading,
    required this.onRefresh,
    required this.transactions,
  }) : super(key: key);

  // Handle transaction list with default case for empty transactions
  List<Map<String, dynamic>> get transactionList {
    if (transactions.isEmpty) {
      return [
        {
          "icon": Icons.info,
          "name": "No transactions",
          "title": "Pull to refresh",
          "money": "0.00",
          "isCredit": false
        }
      ];
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  getTranslation(context, 'home.latest_transaction'),
                  style: bold18Black33,
                ),
              ),
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
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/transaction');
                },
                child: Text(
                  getTranslation(context, 'home.see_all'),
                  style: bold14Grey94,
                ),
              ),
            ],
          ),
        ),
        // Transaction List Section
        ColumnBuilder(
          itemBuilder: (context, index) {
            final transactionData = transactionList[index];
            final isCredit = transactionData['isCredit'] ?? false;
            final Color iconColor = isCredit ? Colors.green : Colors.red;

            // Safely handle the icon, default to Icons.info if not valid
            final IconData icon = transactionData['icon'] is IconData
                ? transactionData['icon'] as IconData
                : (isCredit
                    ? CupertinoIcons.arrow_down_circle_fill
                    : CupertinoIcons.arrow_up_circle_fill);

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
                      icon,
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
          },
          itemCount: transactionList.length,
        ),
      ],
    );
  }
}