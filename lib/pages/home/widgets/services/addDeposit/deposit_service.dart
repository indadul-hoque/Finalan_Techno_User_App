import 'dart:convert';
import 'package:fl_banking_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DepositService {
  static const String baseUrl = AppConfig.baseUrl;

  /// Deducts from wallet with accountType & accountId
  /// POST body:
  /// {
  ///   "amount": 100,
  ///   "accountType": "loan",
  ///   "accountId": "LN0010"
  /// }
  Future<Map<String, dynamic>> deductFromWallet({
    required double amount,
    required String accountType,
    required String accountId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        throw Exception('Phone number not found in local storage');
      }

      // Format phone with country code
      final formattedPhone =
          phoneNumber.startsWith('91') ? phoneNumber : '91$phoneNumber';

      // Correct endpoint
      final deductUrl =
          Uri.parse('$baseUrl/mobile/wallet/$formattedPhone/deduct');

      // Prepare request body
      final requestBody = {
        "amount": amount,
        "accountType": accountType,
        "accountId": accountId,
      };

      // Log full request
      debugPrint('=== WALLET DEDUCT REQUEST ===');
      debugPrint('URL: $deductUrl');
      debugPrint('Body: ${jsonEncode(requestBody)}');
      debugPrint('============================');

      final response = await http.post(
        deductUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Wallet deduction successful: $responseBody');
        return responseBody;
      } else {
        final error = responseBody['error'] ?? 'Wallet deduction failed';
        debugPrint('Wallet deduction failed: $error');
        throw Exception(error);
      }
    } catch (error) {
      debugPrint('Deduction failed: $error');
      throw Exception('Wallet deduction failed: $error');
    }
  }
}