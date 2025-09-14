import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class BankAccountsService {
  static const String baseUrl = 'https://api.cornix.tech';

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
          accounts = List<Map<String, dynamic>>.from(data['accounts']);
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

  // Get total balance across all accounts
  static double getTotalBalance() {
    if (accounts == null || accounts!.isEmpty) return 0.0;

    double total = 0.0;
    for (var account in accounts!) {
      if (account['accountType'] == 'savings') {
        total += (account['balance'] ?? 0.0).toDouble();
      }
    }
    return total;
  }

  // Get savings accounts
  static List<Map<String, dynamic>> getSavingsAccounts() {
    if (accounts == null || accounts!.isEmpty) return [];

    return accounts!
        .where((account) => [
              'savings',
              'daily-savings',
              'thrift-fund',
              'fixed-deposit'
            ].contains((account['accountType'] ?? '').toString().toLowerCase()))
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
  static String formatAccountType(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'daily-savings':
        return 'Daily Savings';
      case 'fixed-deposit':
        return 'Fixed Deposit';
      case 'thrift-fund':
        return 'Thrift Fund';
      case 'loan':
        return 'Loan Account';
      case 'current':
        return 'Current Account';
      default:
        return accountType.toUpperCase();
    }
  }

  // Format balance for display
  static String formatBalance(dynamic balance) {
    if (balance == null) return '₹0.00';
    return '₹${balance.toStringAsFixed(2)}';
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
