import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class BankAccountsService {
  static const String baseUrl = 'https://finalan-techno-api-879235286268.asia-south1.run.app/';

  // Bank Accounts Model
  static List<Map<String, dynamic>>? accounts;
  static bool isLoading = false;
  static String? errorMessage;

  // Fetch bank accounts for a user
  static Future<List<Map<String, dynamic>>?> fetchBankAccounts(
      String phoneNumber) async {
    try {
      isLoading = true;
      errorMessage = null;

      final response = await http.get(
        Uri.parse('$baseUrl/user/$phoneNumber/accounts'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Accounts fetched successfully.') {
          final rawAccounts = List<Map<String, dynamic>>.from(data['accounts']);
          accounts = rawAccounts.map((acct) {
            final normalized = Map<String, dynamic>.from(acct);
            // Ensure accountId is a String
            if (normalized['accountId'] != null) {
              normalized['accountId'] = normalized['accountId'].toString();
            }
            // Normalize balance and loanAmount to num
            if (normalized['balance'] is String) {
              final parsed = double.tryParse(normalized['balance']);
              if (parsed != null) {
                normalized['balance'] = parsed;
              }
            }
            if (normalized['loanAmount'] is String) {
              final parsed = double.tryParse(normalized['loanAmount']);
              if (parsed != null) {
                normalized['loanAmount'] = parsed;
              }
            }
            if (normalized['emiAmount'] is String) {
              final parsed = double.tryParse(normalized['emiAmount']);
              if (parsed != null) {
                normalized['emiAmount'] = parsed;
              }
            }
            return normalized;
          }).toList();
          return accounts;
        } else {
          errorMessage = data['message'] ?? 'Failed to fetch bank accounts';
          return null;
        }
      } else {
        errorMessage = 'HTTP Error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      errorMessage = 'Network Error: $e';
      return null;
    } finally {
      isLoading = false;
    }
  }

  // Get total balance for deposit accounts (non-loan accounts)
  static double getTotalBalance() {
    if (accounts == null || accounts!.isEmpty) return 0.0;

    return accounts!
        .where((account) => account['accountType'] != 'loan')
        .fold<double>(
          0.0,
          (sum, account) => sum + (account['balance'] ?? 0.0).toDouble(),
        );
  }

  // Get total loan amount for loan accounts
  static double getTotalLoanAmount() {
    if (accounts == null || accounts!.isEmpty) return 0.0;

    return accounts!
        .where((account) => account['accountType'] == 'loan')
        .fold<double>(
          0.0,
          (sum, account) => sum + (account['loanAmount'] ?? 0.0).toDouble(),
        );
  }

  // Get deposit accounts (exclude loan accounts)
  static List<Map<String, dynamic>> getDepositAccounts() {
    if (accounts == null || accounts!.isEmpty) return [];

    return accounts!
        .where((account) => account['accountType'] != 'loan')
        .toList();
  }

  // Get loan accounts
  static List<Map<String, dynamic>> getLoanAccounts() {
    if (accounts == null || accounts!.isEmpty) return [];

    return accounts!
        .where((account) => account['accountType'] == 'loan')
        .toList();
  }

  // Get account by ID
  static Map<String, dynamic>? getAccountById(String accountId) {
    if (accounts == null || accounts!.isEmpty) return null;

    try {
      return accounts!
          .firstWhere((account) => account['accountId'] == accountId);
    } catch (e) {
      return null;
    }
  }

  // Show toast message
  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  // Format account type for display
 static String formatAccountType(String? accountType) {
  if (accountType == null) return 'Unknown';
  switch (accountType.toLowerCase()) {
    case 'savings':
      return 'Savings Account'; // Changed from 'Savings Account' to 'Daily Savings Account'
    case 'daily-savings':
      return 'Daily Savings Account';
    case 'thrift-fund':
      return 'Thrift Fund';
    case 'fixed-deposit':
      return 'Fixed Deposit';
    case 'loan':
      return 'Loan Account';
    case 'current':
      return 'Current Account';
    default:
      return accountType
          .split('-')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
  }
}

  // Format balance for display
  static String formatBalance(dynamic balance) {
    if (balance == null) return '₹0.00';

    double? balanceValue;
    if (balance is num) {
      balanceValue = balance.toDouble();
    } else if (balance is String) {
      balanceValue = double.tryParse(balance);
    }

    return '₹${balanceValue?.toStringAsFixed(2) ?? '0.00'}';
  }

  // Format date for display
  static String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return date.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}