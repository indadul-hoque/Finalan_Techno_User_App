import 'dart:convert';
import 'package:fl_banking_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class StatementService {
  static const String baseUrl = AppConfig.baseUrl;

  // Statement Model
  static Map<String, dynamic>? statementData;
  static bool isLoading = false;
  static String? errorMessage;

  static Future<Map<String, dynamic>?> fetchBalance(
      String phoneNumber, String accountId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$phoneNumber/balance/$accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorMessage = 'Failed to fetch balance';
        return null;
      }
    } catch (e) {
      errorMessage = 'Network Error: $e';
      return null;
    }
  }

  // Fetch savings account statement
  static Future<Map<String, dynamic>?> fetchSavingsStatement(
      String phoneNumber, String accountId) async {
    try {
      isLoading = true;
      errorMessage = null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/$phoneNumber/statement/savings/$accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Transactions fetched successfully.') {
          statementData = data;
          return statementData;
        } else {
          errorMessage = data['message'] ?? 'Failed to fetch statement';
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

  // Fetch loan account statement
  static Future<Map<String, dynamic>?> fetchLoanStatement(
      String phoneNumber, String accountId) async {
    try {
      isLoading = true;
      errorMessage = null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/$phoneNumber/statement/loan/$accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Transactions fetched successfully.') {
          statementData = data;
          return statementData;
        } else {
          errorMessage = data['message'] ?? 'Failed to fetch loan statement';
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

  // Get recent transactions
  static List<Map<String, dynamic>> getRecentTransactions() {
    if (statementData == null || statementData!['transactions'] == null) {
      return [];
    }

    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    // Sort by date (most recent first)
    transactions.sort((a, b) => (b['entryDate'] ?? '').compareTo(a['entryDate'] ?? ''));
    return transactions.take(5).toList(); // Return last 5 transactions
  }

  // Get account balance from statement
  static double getCurrentBalance() {
    if (statementData == null || statementData!['transactions'] == null) {
      return 0.0;
    }

    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    if (transactions.isEmpty) return 0.0;

    // Get the last transaction's balance
    final lastTransaction = transactions.first;
    return (lastTransaction['balance'] ?? 0.0).toDouble();
  }

  // Get total credits
  static double getTotalCredits() {
    if (statementData == null || statementData!['transactions'] == null) {
      return 0.0;
    }

    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    double total = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'credit') {
        total += (transaction['amount'] ?? 0.0).toDouble();
      }
    }

    return total;
  }

  // Get total debits
  static double getTotalDebits() {
    if (statementData == null || statementData!['transactions'] == null) {
      return 0.0;
    }

    final transactions = List<Map<String, dynamic>>.from(statementData!['transactions']);
    double total = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'debit') {
        total += (transaction['amount'] ?? 0.0).toDouble();
      }
    }

    return total;
  }

  // Format transaction type for display
  static String formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return 'Credit';
      case 'debit':
        return 'Debit';
      default:
        return type.toUpperCase();
    }
  }

  // Format amount for display
  static String formatAmount(dynamic amount) {
    if (amount == null) return '₹0.00';

    double? amountValue;
    if (amount is num) {
      amountValue = amount.toDouble();
    } else if (amount is String) {
      amountValue = double.tryParse(amount);
    }

    return '₹${amountValue?.toStringAsFixed(2) ?? '0.00'}';
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
}