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
  String? kycId; // Store kycId in state

  static const String baseUrl = "https://finalan-techno-api-879235286268.asia-south1.run.app/";

  @override
  void initState() {
    super.initState();
    fetchAccountsData();
  }

  Future<void> fetchAccountsData() async {
    try {
      // Get phone number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Phone number not found in preferences";
        });
        return;
      }

      // Fetch raw response to access kycId
      final response = await http.get(Uri.parse("$baseUrl/user/$phoneNumber/accounts"));
      if (response.statusCode != 200) {
        throw Exception("Failed to load accounts: ${response.statusCode}");
      }

      final responseData = json.decode(response.body);
      final accounts = responseData['accounts'] as List<dynamic>;
      final String? fetchedKycId = responseData['kycId']?.toString();

      if (fetchedKycId != null) {
        await prefs.setString('kycId', fetchedKycId); // Store kycId in SharedPreferences
        setState(() {
          kycId = fetchedKycId; // Store in state
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "KYC ID not found in account data";
        });
        return;
      }

      setState(() {
        // Filter out loan accounts
        accountNoList = accounts.where((account) => account["accountType"] != "loan").toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load accounts: $e";
      });
    }
  }

  static Future<List<dynamic>> fetchAccounts(String mobile) async {
    final response = await http.get(Uri.parse("$baseUrl/user/$mobile/accounts"));
    if (response.statusCode == 200) {
      return json.decode(response.body)['accounts'];
    } else {
      throw Exception("Failed to load accounts: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        title: const Text(
          'Add Deposit',
          style: appBarStyle,
        ),
        foregroundColor: black33Color,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: semibold16Black33))
              : accountNoList.isEmpty
                  ? Center(child: Text("No accounts available", style: semibold16Black33))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(fixPadding * 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Deposit Amount",
                            style: bold17Black33,
                          ),
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
                            padding: EdgeInsets.zero,
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: semibold16Black33,
                              cursorColor: primaryColor,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter deposit amount',
                                hintStyle: semibold16Grey94,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: fixPadding * 1.5, right: 1),
                                  child: Icon(
                                    Icons.currency_rupee,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: fixPadding * 1.2),
                              ),
                            ),
                          ),
                          heightSpace,
                          Text(
                            "Deposit To",
                            style: bold17Black33,
                          ),
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
                            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                            child: DropdownButtonFormField<int>(
                              value: selectedAccountIndex,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select your account',
                                hintStyle: semibold16Grey94,
                              ),
                              style: semibold16Black33,
                              icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
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
                              onChanged: (val) => setState(() => selectedAccountIndex = val),
                            ),
                          ),
                          heightSpace,
                          if (selectedAccountIndex != null) ...[
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              color: whiteColor,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(fixPadding * 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      accountNoList[selectedAccountIndex!]["accountType"].toString(),
                                      style: bold16Black33,
                                    ),
                                    height5Space,
                                    Text(
                                      "Account Number:",
                                      style: semibold15Grey94,
                                    ),
                                    height5Space,
                                    Text(
                                      accountNoList[selectedAccountIndex!]["account"].toString(),
                                      style: semibold16Black33,
                                    ),
                                    height5Space,
                                    Divider(color: greyD9Color, thickness: 1),
                                    height5Space,
                                    Text(
                                      "Available Balance:",
                                      style: semibold15Grey94,
                                    ),
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              textStyle: bold18White,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isDepositing
                                ? null
                                : () async {
                                    if (amountController.text.isNotEmpty && selectedAccountIndex != null && kycId != null) {
                                      setState(() {
                                        isDepositing = true;
                                      });
                                      try {
                                        final amount = double.tryParse(amountController.text);
                                        if (amount == null || amount <= 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text('Please enter a valid amount', style: snackBarStyle),
                                            ),
                                          );
                                          return;
                                        }

                                        // Use DepositService
                                        final depositService = DepositService();
                                        final response = await depositService.createDeposit(
                                          accountType: accountNoList[selectedAccountIndex!]["accountType"],
                                          accountNumber: accountNoList[selectedAccountIndex!]["account"],
                                          amount: amount,
                                          method: 'cash',
                                          kycId: kycId!, // Pass kycId
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: primaryColor,
                                            content: Text(
                                              response['message'] ?? 'Deposit Successful!',
                                              style: snackBarStyle,
                                            ),
                                          ),
                                        );

                                        // Refresh accounts to update balance
                                        await fetchAccountsData();
                                        amountController.clear();
                                        setState(() {
                                          selectedAccountIndex = null;
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text('Deposit Failed: $e', style: snackBarStyle),
                                          ),
                                        );
                                      } finally {
                                        setState(() {
                                          isDepositing = false;
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text('Please select an account and ensure KYC ID is available', style: snackBarStyle),
                                        ),
                                      );
                                    }
                                  },
                            child: isDepositing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Deposit Now'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}