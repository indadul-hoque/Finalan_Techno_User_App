import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoanRepayService {
  static const String baseUrl =
      'https://finalan-techno-api-879235286268.asia-south1.run.app';

  /// Creates a loan repayment entry for the given user.
  /// Requires stored 'phoneNumber' in SharedPreferences.
  static Future<Map<String, dynamic>> createLoanRepayment({
    required String loanId,
    required double amount,
    required String paymentType,
    required String type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        throw Exception('Phone number not found in local storage.');
      }

      final url = Uri.parse('$baseUrl/users/$phoneNumber/loan/repay');

      final body = {
        "loanId": loanId,
        "amount": amount,
        "type": type,
        "paymentType": paymentType.toLowerCase(), // Convert to lowercase here
        "uid": phoneNumber,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print(
          'Response Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData is Map<String, dynamic>
            ? responseData
            : {'error': 'Invalid response format'};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to create loan repayment: ${errorData['message'] ?? 'Unknown error'}. Status: ${response.statusCode}',
        );
      }
    } catch (error) {
      print('Error in createLoanRepayment: $error');
      throw Exception('Error in createLoanRepayment: $error');
    }
  }
}
