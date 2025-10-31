import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({Key? key}) : super(key: key);

  @override
  _StatementScreenState createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  static const String baseUrl =
      "https://finalan-techno-api-879235286268.asia-south1.run.app/";

  String? mobile;
  List<Map<String, dynamic>> accounts = [];
  Map<String, dynamic>? selectedAccount;
  List<dynamic> transactions = [];
  List<dynamic> filteredTransactions = [];

  DateTime? fromDate;
  DateTime toDate = DateTime.now();

  bool loadingAccounts = true;
  bool loadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadMobileAndFetchAccounts();
  }

  Future<void> _loadMobileAndFetchAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phoneNumber') ?? '9519874704';
    setState(() => mobile = phone);
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    if (mobile == null) return;

    setState(() => loadingAccounts = true);

    final url = Uri.parse("$baseUrl/user/$mobile/accounts");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedAccounts =
            List<Map<String, dynamic>>.from(data['accounts'] ?? []);

        setState(() {
          accounts = fetchedAccounts;
          if (accounts.isNotEmpty) {
            selectedAccount = accounts[0];
            fetchTransactions();
          }
        });
      } else {
        debugPrint("Error fetching accounts: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception fetching accounts: $e");
    }

    setState(() => loadingAccounts = false);
  }

  Future<void> fetchTransactions() async {
    if (selectedAccount == null || mobile == null) return;

    setState(() {
      loadingTransactions = true;
      transactions = [];
      filteredTransactions = [];
    });

    final accountId =
        selectedAccount!['accountId'] ?? selectedAccount!['accountNumber'];
    final accountType = selectedAccount!['accountType'] as String? ?? '';

    final url =
        Uri.parse("$baseUrl/users/$mobile/statement/$accountType/$accountId");
    print("Fetching: $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedTransactions = data['transactions'] ?? [];

        DateTime? earliestDate;
        for (var tx in fetchedTransactions) {
          final txDateStr = tx['date'] ?? tx['entryDate'];
          if (txDateStr != null) {
            final txDate = DateTime.tryParse(txDateStr);
            if (txDate != null &&
                (earliestDate == null || txDate.isBefore(earliestDate))) {
              earliestDate = txDate;
            }
          }
        }

        setState(() {
          transactions = fetchedTransactions;
          fromDate =
              earliestDate ?? DateTime.now().subtract(const Duration(days: 7));
          filterTransactions();
        });
      } else {
        debugPrint("Error fetching statement: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception fetching statement: $e");
    }

    setState(() => loadingTransactions = false);
  }

  String _getAccountBalance() {
    if (selectedAccount == null) return '0.00';

    final accountType = selectedAccount!['accountType'] as String?;
    final isLoan = accountType?.toLowerCase() == 'loan';

    dynamic amount = isLoan
        ? selectedAccount!['loanAmount']
        : selectedAccount!['balance'];

    if (amount == null) return '0.00';
    if (amount is num) return amount.toStringAsFixed(2);
    if (amount is String) {
      final parsed = double.tryParse(amount);
      return parsed?.toStringAsFixed(2) ?? '0.00';
    }

    return '0.00';
  }

  void filterTransactions() {
    if (fromDate == null) return;

    setState(() {
      filteredTransactions = transactions.where((tx) {
        final txDateStr = tx['date'] ?? tx['entryDate'];
        if (txDateStr == null) return false;
        final txDate = DateTime.tryParse(txDateStr);
        if (txDate == null) return false;

        return txDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
            txDate.isBefore(toDate.add(const Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: toDate,
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        filterTransactions();
      });
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        filterTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statement"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Download button removed
      ),
      body: mobile == null || loadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Account selector
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: selectedAccount,
                          hint: const Text("Select Account"),
                          isExpanded: true,
                          items: accounts
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (acc) {
                            final accountType =
                                acc['accountType'] as String? ?? '';
                            final capitalizedType =
                                toBeginningOfSentenceCase(accountType) ?? '';
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: acc,
                              child: Text(
                                  "$capitalizedType - ${acc['accountNumber'] ?? acc['accountId']}"),
                            );
                          }).toList(),
                          onChanged: (Map<String, dynamic>? acc) {
                            setState(() {
                              selectedAccount = acc;
                              fromDate = null;
                            });
                            fetchTransactions();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "₹${_getAccountBalance()}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Date range selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: pickFromDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(fromDate != null
                          ? DateFormat("dd MMM, yyyy").format(fromDate!)
                          : "Select From Date"),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: pickToDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat("dd MMM, yyyy").format(toDate)),
                    ),
                    ElevatedButton(
                      onPressed: filterTransactions,
                      child: const Text("Go"),
                    ),
                  ],
                ),

                const Divider(),

                // Transaction list
                Expanded(
                  child: loadingTransactions
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTransactions.isEmpty
                          ? const Center(child: Text("No transactions found"))
                          : ListView.builder(
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = filteredTransactions[index];
                                final isCredit =
                                    (tx['type'] ?? '').toLowerCase() == "credit";
                                final txDateStr = tx['date'] ?? tx['entryDate'];
                                final displayDate = txDateStr ?? '';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isCredit
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    child: Icon(
                                      isCredit
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color:
                                          isCredit ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(tx['name'] ?? "Unknown"),
                                  subtitle: Text(
                                      "${tx['narration'] ?? ''}\n${displayDate}"),
                                  trailing: Text(
                                    "${isCredit ? '+' : '-'}₹${tx['amount'] ?? 0}",
                                    style: TextStyle(
                                      color: isCredit ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}