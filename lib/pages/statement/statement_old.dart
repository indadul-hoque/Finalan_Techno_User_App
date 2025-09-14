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
  static const String baseUrl = "https://api.cornix.tech";

  String? mobile;
  List<Map<String, dynamic>> accounts = [];
  Map<String, dynamic>? selectedAccount;
  List<dynamic> transactions = [];

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
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
    final phone =
        prefs.getString('phoneNumber') ?? '9519874704'; // default fallback
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

        setState(() {
          accounts = List<Map<String, dynamic>>.from(data['accounts']);
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
    });

    // Use 'accountId' if present, fallback to 'accountNumber'
    final accountId =
        selectedAccount!['accountId'] ?? selectedAccount!['accountNumber'];
    final accountType = selectedAccount!['accountType'];

    final url =
        Uri.parse("$baseUrl/users/$mobile/statement/$accountType/$accountId");
    print("Fetching: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          transactions = data['transactions'] ?? [];
        });
      } else {
        debugPrint("Error fetching statement: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception fetching statement: $e");
    }

    setState(() => loadingTransactions = false);
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fromDate) {
      setState(() => fromDate = picked);
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate) {
      setState(() => toDate = picked);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download as PDF
            },
          ),
        ],
      ),
      body: mobile == null
          ? const Center(child: CircularProgressIndicator())
          : loadingAccounts
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
                                return DropdownMenuItem<Map<String, dynamic>>(
                                    value: acc,
                                    child: Text(
                                        "${acc['accountType'] ?? '' ?? ''} - ${acc['accountNumber'] ?? acc['id']}"));
                              }).toList(),
                              onChanged: (Map<String, dynamic>? acc) {
                                setState(() => selectedAccount = acc);
                                fetchTransactions();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "₹${selectedAccount?['balance'] ?? '0.00'}",
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
                          label:
                              Text(DateFormat("dd MMM, yyyy").format(fromDate)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: pickToDate,
                          icon: const Icon(Icons.calendar_today),
                          label:
                              Text(DateFormat("dd MMM, yyyy").format(toDate)),
                        ),
                        ElevatedButton(
                          onPressed: fetchTransactions,
                          child: const Text("Go"),
                        ),
                      ],
                    ),

                    const Divider(),

                    // Transaction list
                    Expanded(
                      child: loadingTransactions
                          ? const Center(child: CircularProgressIndicator())
                          : transactions.isEmpty
                              ? const Center(
                                  child: Text("No transactions found"))
                              : ListView.builder(
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final tx = transactions[index];
                                    final isCredit =
                                        (tx['type'] ?? '').toLowerCase() ==
                                            "credit";

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isCredit
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        child: Icon(
                                          isCredit
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isCredit
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      title: Text(tx['name'] ?? "Unknown"),
                                      subtitle: Text(tx['narration'] ?? ""),
                                      trailing: Text(
                                        "${isCredit ? '+' : '-'}₹${tx['amount'] ?? 0}",
                                        style: TextStyle(
                                          color: isCredit
                                              ? Colors.green
                                              : Colors.red,
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
