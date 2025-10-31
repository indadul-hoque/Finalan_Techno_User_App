import 'package:fl_banking_app/pages/home/widgets/services/loanRepay/loan_repay_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoanRepayment extends StatefulWidget {
  const LoanRepayment({Key? key}) : super(key: key);

  @override
  State<LoanRepayment> createState() => _LoanRepaymentState();
}

class _LoanRepaymentState extends State<LoanRepayment> {
  final TextEditingController amountController = TextEditingController();
  String? selectedLoanId;
  String? selectedPaymentType;
  bool isLoading = false;
  bool isFetchingLoans = true;
  List<Map<String, dynamic>> loanAccounts = [];
  String? phoneNumber;

  // Updated payment types list
  final List<String> paymentTypes = ['UPI', 'Cash', 'Card'];

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber().then((_) => _fetchLoanIds());
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');
    if (phoneNumber == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Phone number not found", style: snackBarStyle),
        ),
      );
    }
  }

  Future<void> _fetchLoanIds() async {
    if (phoneNumber == null) return;

    setState(() {
      isFetchingLoans = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://finalan-techno-api-879235286268.asia-south1.run.app/user/$phoneNumber/accounts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> accounts = data['accounts'] ?? [];
        List<Map<String, dynamic>> fetchedLoanAccounts = accounts
            .where((a) => a['accountType'] == 'loan')
            .map((a) => a as Map<String, dynamic>)
            .toList();

        setState(() {
          loanAccounts = fetchedLoanAccounts;
          isFetchingLoans = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed: ${response.statusCode} - ${errorData['message'] ?? response.body}');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Failed to fetch loan accounts: $error",
              style: snackBarStyle),
        ));
      }
      setState(() {
        isFetchingLoans = false;
      });
    }
  }

  // Removed balance function, now only EMI remains
  String getEmiAmount() {
    if (selectedLoanId == null) return "N/A";
    final selectedLoan = loanAccounts.firstWhere(
      (a) => a['accountId'] == selectedLoanId,
      orElse: () => {},
    );
    return selectedLoan.isNotEmpty && selectedLoan['emiAmount'] != null
        ? selectedLoan['emiAmount'].toString()
        : "N/A";
  }

  void _submitRepayment() async {
    if (selectedLoanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: primaryColor,
        content: Text("Please select a Loan ID", style: snackBarStyle),
      ));
      return;
    }

    if (selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: primaryColor,
        content: Text("Please select a payment type", style: snackBarStyle),
      ));
      return;
    }

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: primaryColor,
        content: Text("Please enter an amount", style: snackBarStyle),
      ));
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: primaryColor,
        content: Text("Please enter a valid amount", style: snackBarStyle),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await LoanRepayService.createLoanRepayment(
        loanId: selectedLoanId!,
        amount: amount,
        paymentType: selectedPaymentType!,
        type: 'loan',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Loan repayment successful! Ref: ${result['referenceId'] ?? 'N/A'}",
            style: snackBarStyle,
          ),
        ));
      }

      amountController.clear();
      setState(() {
        selectedLoanId = null;
        selectedPaymentType = null;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Failed to process loan repayment: $error",
            style: snackBarStyle,
          ),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: _fetchLoanIds,
            tooltip: 'Refresh Loans',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: ListView(
          children: [
            Text("Select Loan", style: bold17Black33),
            heightSpace,
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: blackColor.withOpacity(0.08), blurRadius: 6),
                ],
              ),
              child: isFetchingLoans
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedLoanId,
                      items: loanAccounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account['accountId'].toString(),
                          child: Text(account['accountId'].toString(),
                              style: semibold16Black33),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedLoanId = value),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: loanAccounts.isEmpty
                            ? "No loans available"
                            : "Select Loan ID",
                        hintStyle: semibold16Grey94,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: fixPadding * 1.4,
                            horizontal: fixPadding * 2),
                      ),
                      style: semibold16Black33,
                      icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                    ),
            ),
            heightSpace,
            Text("Loan Details", style: bold17Black33),
            heightSpace,
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: blackColor.withOpacity(0.08), blurRadius: 6),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: fixPadding * 1.4, horizontal: fixPadding * 2),
              child: Text(
                selectedLoanId == null
                    ? "Select a loan to view details"
                    : "EMI: ₹${getEmiAmount()}",
                style: semibold16Black33,
              ),
            ),
            heightSpace,
            Text("Amount", style: bold17Black33),
            heightSpace,
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: blackColor.withOpacity(0.08), blurRadius: 6),
                ],
              ),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: semibold16Black33,
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter amount",
                  hintStyle: semibold16Grey94,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: fixPadding * 1.5),
                    child: Icon(Icons.currency_rupee,
                        color: primaryColor, size: 20),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: fixPadding * 1.4, horizontal: fixPadding * 2),
                ),
              ),
            ),
            heightSpace,
            Text("Payment Type", style: bold17Black33),
            heightSpace,
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: blackColor.withOpacity(0.08), blurRadius: 6),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 0.5, vertical: fixPadding * 0.5),
              child: Column(
                children: paymentTypes.map((type) {
                  return RadioListTile<String>(
                    value: type,
                    groupValue: selectedPaymentType,
                    activeColor: primaryColor,
                    onChanged: (value) =>
                        setState(() => selectedPaymentType = value),
                    title: Text(type, style: semibold16Black33),
                  );
                }).toList(),
              ),
            ),
            heightBox(40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isLoading ? null : _submitRepayment,
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
