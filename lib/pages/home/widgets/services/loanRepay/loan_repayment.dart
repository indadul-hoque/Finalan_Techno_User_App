import 'dart:convert';

import 'package:fl_banking_app/config.dart';
import 'package:fl_banking_app/pages/home/widgets/services/loanRepay/wallet_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoanRepayment extends StatefulWidget {
  const LoanRepayment({Key? key}) : super(key: key);
  @override
  State<LoanRepayment> createState() => _LoanRepaymentState();
}

class _LoanRepaymentState extends State<LoanRepayment> {
  final TextEditingController amountController = TextEditingController();
  String? selectedLoanId;
  bool isLoading = false;
  bool isFetchingLoans = true;
  List<Map<String, dynamic>> loanAccounts = [];
  String? phoneNumber;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPhoneAndBalance();
  }

  Future<void> _loadPhoneAndBalance() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      _showSnackBar("Login required", Colors.red);
      return;
    }

    await Future.wait([_fetchWalletBalance(), _fetchLoanIds()]);
  }

  // ── FETCH WALLET BALANCE ─────────────────────────────────────
  Future<void> _fetchWalletBalance() async {
    try {
      final formatted =
          phoneNumber!.startsWith('91') ? phoneNumber : '91$phoneNumber';
      final url = Uri.parse('${AppConfig.baseUrl}/mobile/wallet/$formatted');

      final res = await http.get(url,
          headers: {'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true) {
          final balance = double.tryParse(
                  json['data']['walletBalance'].toString()) ??
              0.0;
          setState(() => _walletBalance = balance);
        }
      }
    } catch (e) {
      debugPrint('Wallet fetch error: $e');
    }
  }

  // ── FETCH LOAN ACCOUNTS ─────────────────────────────────────
  Future<void> _fetchLoanIds() async {
    if (phoneNumber == null) return;
    setState(() => isFetchingLoans = true);

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/user/$phoneNumber/accounts');
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accounts = (data['accounts'] as List)
            .where((a) => a['accountType'] == 'loan')
            .cast<Map<String, dynamic>>()
            .toList();

        setState(() {
          loanAccounts = accounts;
          isFetchingLoans = false;
        });
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      _showSnackBar("No loans found", Colors.orange);
      setState(() => isFetchingLoans = false);
    }
  }

  String getEmiAmount() {
    if (selectedLoanId == null) return "N/A";
    final loan = loanAccounts.firstWhere(
        (a) => a['accountId'] == selectedLoanId,
        orElse: () => {});
    return loan['emiAmount']?.toString() ?? "N/A";
  }

  // ── SUBMIT REPAYMENT ────────────────────────────────────────
  void _submitRepayment() async {
    final amountText = amountController.text;
    final amount = double.tryParse(amountText);

    if (selectedLoanId == null ||
        amount == null ||
        amount <= 0 ||
        amount > _walletBalance) {
      _showSnackBar("Invalid selection or low balance", Colors.red);
      return;
    }

    // Find the selected loan to get accountType
    final selectedLoan = loanAccounts.firstWhere(
        (a) => a['accountId'] == selectedLoanId,
        orElse: () => {});

    if (selectedLoan.isEmpty) {
      _showSnackBar("Loan not found", Colors.red);
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await WalletService.deduct(
        phoneNumber: phoneNumber!,
        amount: amount,
        accountId: selectedLoanId!,
        accountType: selectedLoan['accountType'] ?? 'loan',
      );

      final newBalance = result['newWalletBalance'] as double;
      setState(() => _walletBalance = newBalance);

      _showSnackBar(
          "₹${amount.toStringAsFixed(2)} repaid for Loan $selectedLoanId", Colors.green);

      amountController.clear();
      selectedLoanId = null;
    } catch (e) {
      _showSnackBar("$e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg, style: snackBarStyle), backgroundColor: color),
    );
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        title: const Text("Loan Repayment", style: appBarStyle),
        foregroundColor: black33Color,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadPhoneAndBalance)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: ListView(
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: blackColor.withOpacity(0.08), blurRadius: 6)
                  ]),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: primaryColor),
                  widthSpace,
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Wallet Balance", style: bold15Grey94),
                        Text("₹${_walletBalance.toStringAsFixed(2)}",
                            style: bold18Black33),
                      ]),
                ],
              ),
            ),
            heightBox(20),

            // Loan Dropdown
            Text("Select Loan", style: bold17Black33),
            heightSpace,
            Container(
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: blackColor.withOpacity(0.08), blurRadius: 6)
                  ]),
              child: isFetchingLoans
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedLoanId,
                      hint: Text(
                          loanAccounts.isEmpty ? "No loans" : "Choose loan"),
                      items: loanAccounts
                          .map((a) => DropdownMenuItem(
                              value: a['accountId'].toString(),
                              child: Text(a['accountId'].toString())))
                          .toList(),
                      onChanged: (v) => setState(() => selectedLoanId = v),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16)),
                    ),
            ),
            heightSpace,

            // EMI
            if (selectedLoanId != null) ...[
              Text("EMI Amount", style: bold17Black33),
              heightSpace,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: blackColor.withOpacity(0.08), blurRadius: 6)
                    ]),
                child: Text("₹${getEmiAmount()}", style: bold18Black33),
              ),
              heightSpace,
            ],

            // Amount Field
            Text("Enter Amount", style: bold17Black33),
            heightSpace,
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "e.g. 5000",
                prefixIcon: const Icon(Icons.currency_rupee),
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            heightBox(40),

            // Pay Button
            ElevatedButton(
              onPressed: isLoading ? null : _submitRepayment,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: isLoading
                  ? const CircularProgressIndicator(color: whiteColor)
                  : const Text("Pay Loan", style: bold18White),
            ),
          ],
        ),
      ),
    );
  }
}