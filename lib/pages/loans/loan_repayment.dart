import 'package:flutter/material.dart';
import 'package:fl_banking_app/pages/loans/online.dart';
import 'package:fl_banking_app/pages/loans/offline.dart';

class LoanRepayment extends StatefulWidget {
  const LoanRepayment({Key? key}) : super(key: key);
  @override
  State<LoanRepayment> createState() => _LoanRepaymentState();
}

class _LoanRepaymentState extends State<LoanRepayment> {
  final TextEditingController amountController = TextEditingController();
  String? selectedLoanId;
  String selectedPaymentType = "Online";
  String selectedPaymentMethod = "Offline";
  bool isLoading = false;
  final List<String> loanIds = [
    "Loan ID 1",
    "Loan ID 2",
    "Loan ID 3",
  ];
  void _submitRepayment() async {
    // Validate input
    if (selectedLoanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Loan ID")),
      );
      return;
    }
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;

    print("\n\n\n");
    print("Submitting repayment:");
    print("\n\n\n");

    if (selectedPaymentType == "Online") {
      // Navigate to Online payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Online(
            selectedLoanId: selectedLoanId,
            amount: amount,
          ),
        ),
      );
    } else if (selectedPaymentType == "Offline") {
      // Navigate to Offline payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Offline(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Repayment"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLoanId,
              hint: const Text("Select Loan ID"),
              items: loanIds.map((loan) {
                return DropdownMenuItem(
                  value: loan,
                  child: Text(loan),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLoanId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Loan ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPaymentType,
              items: ["Online", "Offline"].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Payment Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _submitRepayment,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text("Pay Loan"),
            ),
          ],
        ),
      ),
    );
  }
}
