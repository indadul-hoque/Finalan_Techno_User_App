import 'package:flutter/material.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/services.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final double availableBalance = 12500.75;
  final DateTime openingDate = DateTime(2023, 8, 12);

  void _addMoney() {
    final enteredAmount = _amountController.text;
    if (enteredAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: primaryColor),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹$enteredAmount added to wallet (demo only)',
          style: snackBarStyle),
        backgroundColor: greenColor),
    );
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text('My Wallet', style: bold20White),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            margin: const EdgeInsets.all(fixPadding * 2),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(fixPadding * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEDEBEB),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded,
                            color: primaryColor, size: 28),
                      ),
                      widthSpace,
                      Text('Wallet Details', style: bold16Black33),
                    ],
                  ),
                  heightSpace,
                  // Balance prominent
                  Center(
                    child: Column(
                      children: [
                        Text('Available Balance', style: bold15Grey94),
                        height5Space,
                        Text(
                          '₹${availableBalance.toStringAsFixed(2)}',
                          style: bold22Black,
                        ),
                        heightSpace,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 18),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('Safe & Secure', style: bold15Green),
                        ),
                      ],
                    ),
                  ),
                  heightSpace,
                  // Info row
                  Row(
                    children: [
                      Expanded(
                          child: infoWidget('Opening Date',
                              '${openingDate.day}-${openingDate.month}-${openingDate.year}')),
                      Expanded(child: infoWidget('Account Type', 'Wallet')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          heightBox(26),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(fixPadding * 2, fixPadding * 2, fixPadding * 2, fixPadding * 2 + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Money to Wallet', style: bold16Black33),
            heightSpace,
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: semibold16Black33,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee, color: primaryColor),
                labelText: 'Enter amount',
                labelStyle: semibold15Grey94,
                hintText: 'e.g. 5000',
                hintStyle: semibold14Grey87,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: scaffoldBgColor,
              ),
            ),
            heightSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addMoney,
                icon: const Icon(Icons.add_circle_outline),
                label: Text('Add Money', style: bold16White),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoWidget(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: semibold14Grey94,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        height5Space,
        Text(value,
            style: semibold16Black33,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
