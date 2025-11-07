import 'package:fl_banking_app/config.dart';
import 'package:fl_banking_app/pages/home/widgets/services/addDeposit/deposit_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({Key? key}) : super(key: key);

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  TextEditingController amountController = TextEditingController();
  int? selectedAccountIndex;
  List<dynamic> accountNoList = [];
  bool isLoading = true;
  String? errorMessage;
  bool isDepositing = false;
  String? kycId;
  String? phoneNumber;

  // REAL wallet balance from API
  double _walletBalance = 0.0;
  bool _isFetchingBalance = true;

  static const String baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  // Load phone, fetch accounts + wallet balance
  Future<void> _loadUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Phone number not found. Please login again.";
      });
      return;
    }

    // Run both in parallel
    await Future.wait([
      fetchAccountsData(),
      _fetchWalletBalance(),
    ]);
  }

  // FETCH REAL WALLET BALANCE FROM BACKEND
  Future<void> _fetchWalletBalance() async {
    try {
      setState(() => _isFetchingBalance = true);

      final formattedPhone =
          phoneNumber!.startsWith('91') ? phoneNumber : '91$phoneNumber';
      final url = Uri.parse('$baseUrl/mobile/wallet/$formattedPhone');

      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true) {
          final balance = double.tryParse(
                json['data']['walletBalance'].toString(),
              ) ??
              0.0;
          setState(() {
            _walletBalance = balance;
            _isFetchingBalance = false;
          });
        } else {
          throw Exception(json['error'] ?? 'Failed to fetch balance');
        }
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      print('Wallet fetch error: $e');
      setState(() {
        _isFetchingBalance = false;
      });
      _showSnackBar('Failed to load wallet balance', Colors.orange);
    }
  }

  Future<void> fetchAccountsData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/$phoneNumber/accounts"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to load accounts: ${response.statusCode}");
      }

      final responseData = json.decode(response.body);
      final accounts = responseData['accounts'] as List<dynamic>;
      final String? fetchedKycId = responseData['kycId']?.toString();

      if (fetchedKycId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kycId', fetchedKycId);
        setState(() => kycId = fetchedKycId);
      } else {
        throw Exception("KYC ID missing");
      }

      setState(() {
        accountNoList = accounts
            .where((account) => account["accountType"] != "loan")
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load accounts: $e";
      });
    }
  }

  void _showSnackBar(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        content: Text(message, style: snackBarStyle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        title: const Text('Add Deposit', style: appBarStyle),
        foregroundColor: black33Color,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserAndData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: semibold16Black33))
              : accountNoList.isEmpty
                  ? Center(
                      child: Text("No accounts available",
                          style: semibold16Black33))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(fixPadding * 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ------------------- Wallet Balance Card -------------------
                          Container(
                            padding: const EdgeInsets.all(fixPadding * 1.5),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.08),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded,
                                    color: primaryColor, size: 28),
                                widthSpace,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Wallet Balance", style: bold15Grey94),
                                    _isFetchingBalance
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: primaryColor,
                                            ),
                                          )
                                        : Text(
                                            "₹${_walletBalance.toStringAsFixed(2)}",
                                            style: bold18Black33,
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          heightBox(20),

                          // ------------------- Deposit To -------------------
                          Text("Deposit To", style: bold17Black33),
                          heightSpace,
                          Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.08),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding * 2),
                            child: DropdownButtonFormField<int>(
                              value: selectedAccountIndex,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select your account',
                                hintStyle: semibold16Grey94,
                              ),
                              style: semibold16Black33,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: primaryColor),
                              items: List.generate(
                                accountNoList.length,
                                (index) => DropdownMenuItem(
                                  value: index,
                                  child: Text(
                                    '${accountNoList[index]["accountType"]} (${accountNoList[index]["account"]})',
                                    style: semibold16Black33,
                                  ),
                                ),
                              ),
                              onChanged: (val) =>
                                  setState(() => selectedAccountIndex = val),
                            ),
                          ),
                          heightSpace,

                          // ------------------- Selected Account Details -------------------
                          if (selectedAccountIndex != null) ...[
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                              color: whiteColor,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(fixPadding * 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      accountNoList[selectedAccountIndex!]
                                              ["accountType"]
                                          .toString(),
                                      style: bold16Black33,
                                    ),
                                    height5Space,
                                    Text("Account Number:",
                                        style: semibold15Grey94),
                                    height5Space,
                                    Text(
                                      accountNoList[selectedAccountIndex!]
                                              ["account"]
                                          .toString(),
                                      style: semibold16Black33,
                                    ),
                                    height5Space,
                                    Divider(color: greyD9Color, thickness: 1),
                                    height5Space,
                                    Text("Available Balance:",
                                        style: semibold15Grey94),
                                    height5Space,
                                    Text(
                                      "₹${accountNoList[selectedAccountIndex!]["balance"]?.toString() ?? 'N/A'}",
                                      style: bold18Primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          heightBox(40),

                          // ------------------- Deposit Amount -------------------
                          Text("Deposit Amount", style: bold17Black33),
                          heightSpace,
                          Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.08),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: semibold16Black33,
                              cursorColor: primaryColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter deposit amount',
                                hintStyle: semibold16Grey94,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: fixPadding * 1.5),
                                  child: Icon(Icons.currency_rupee,
                                      color: primaryColor, size: 20),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0, minHeight: 0),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: fixPadding * 1.2),
                              ),
                            ),
                          ),
                          heightBox(200),

                          // ------------------- Deposit Button -------------------
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              textStyle: bold18White,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isDepositing ? null : _handleDeposit,
                            child: isDepositing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Deposit Now'),
                          ),
                        ],
                      ),
                    ),
    );
  }

  // -----------------------------------------------------------------
  // Handle Deposit – deduct from wallet + call backend
  // -----------------------------------------------------------------
  Future<void> _handleDeposit() async {
    if (amountController.text.isEmpty ||
        selectedAccountIndex == null ||
        kycId == null) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Enter a valid amount', Colors.red);
      return;
    }

    if (amount > _walletBalance) {
      _showSnackBar('Insufficient wallet balance', Colors.red);
      return;
    }

    setState(() => isDepositing = true);

    try {
      final String accountType =
          accountNoList[selectedAccountIndex!]["accountType"];
      final String accountId = accountNoList[selectedAccountIndex!]["account"];

      // Print all parameters
      final Map<String, dynamic> params = {
        'amount': amount,
        'accountType': accountType,
        'accountId': accountId,
        'phoneNumber': phoneNumber,
        'walletBalance': _walletBalance,
      };

      debugPrint('=== DEDUCT PARAMETERS ===');
      params.forEach((key, value) => debugPrint('$key: $value'));
      debugPrint('============================');

      // Call service with all 3 fields
      final depositService = DepositService();
      final response = await depositService.deductFromWallet(
        amount: amount,
        accountType: accountType,
        accountId: accountId,
      );

      // Update UI
      setState(() {
        _walletBalance -= amount;
      });

      _showSnackBar(
          response['message'] ?? 'Deducted Successfully!', primaryColor);

      // Refresh balance
      await _fetchWalletBalance();

      // Reset form
      amountController.clear();
      setState(() => selectedAccountIndex = null);
    } catch (e) {
      _showSnackBar('Failed: $e', Colors.red);
    } finally {
      setState(() => isDepositing = false);
    }
  }
}
