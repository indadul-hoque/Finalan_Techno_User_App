import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepositService {
  static const String baseUrl =
      "https://finalan-techno-api-879235286268.asia-south1.run.app";

  /// Creates a deposit transaction
  /// Returns the response data if successful, throws an exception if failed
  Future<Map<String, dynamic>> createDeposit({
    required String accountType,
    required String accountNumber,
    required double amount,
    required String method,
    required String kycId, // Added kycId parameter
  }) async {
    try {
      // Get phone number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? phoneNumber = prefs.getString('phoneNumber');
      

      // if (phoneNumber == null || uid == null) {
      //   throw Exception('User details not found in local storage');
      // }

      final url = Uri.parse('$baseUrl/users/$phoneNumber/deposit/create-transaction');

      final body = jsonEncode({
        'accountType': accountType,
        'accountNumber': accountNumber,
        'amount': amount,
        'method': method,
        // 'uid': uid,
        'uid': kycId, // Include kycId in the request body
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to create deposit. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (error) {
      throw Exception('Error creating deposit: $error');
    }
  }
}