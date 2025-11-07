// lib/services/wallet_service.dart
import 'dart:convert';
import 'package:fl_banking_app/config.dart';
import 'package:http/http.dart' as http;

class WalletService {
  /// Deducts from wallet and records loan repayment
  ///
  /// POST body (exactly 3 fields):
  /// {
  ///   "amount": 5000,
  ///   "accountId": "LN00123",
  ///   "accountType": "loan"
  /// }
  static Future<Map<String, dynamic>> deduct({
    required String phoneNumber,
    required double amount,
    required String accountId,
    required String accountType,
  }) async {
    try {
      // Format phone
      final formattedPhone =
          phoneNumber.startsWith('91') ? phoneNumber : '91$phoneNumber';

      final url = Uri.parse(
          '${AppConfig.baseUrl}/mobile/wallet/$formattedPhone/deduct');

      final body = jsonEncode({
        'amount': amount,
        'accountId': accountId,
        'accountType': accountType,
      });

      print('''
┌─ WALLET DEDUCT REQUEST ──────────────────────
│ POST $url
│ Body: 
${const JsonEncoder.withIndent('  ').convert(jsonDecode(body))}
└───────────────────────────────────────────────''');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final json = jsonDecode(response.body);

      print('''
┌─ WALLET DEDUCT RESPONSE ─────────────────────
│ ${response.statusCode} $url
│ Body: 
${const JsonEncoder.withIndent('  ').convert(json)}
└───────────────────────────────────────────────''');

      if (response.statusCode == 200 && json['success'] == true) {
        final data = json['data'] ?? {};

        final newBalance = (data['newWalletBalance'] is int)
            ? data['newWalletBalance'].toDouble()
            : (data['newWalletBalance'] as num?)?.toDouble() ?? 0.0;

        return {'newWalletBalance': newBalance, ...data};
      } else {
        throw Exception(json['error'] ?? 'Deduction failed');
      }
    } catch (e) {
      print('WalletService.deduct error: $e');
      rethrow;
    }
  }
}
