import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://your-server-ip:5000";

  // Fetch user accounts - you’ll need a separate endpoint for this
  static Future<List<dynamic>> fetchAccounts(String mobile) async {
    final response =
        await http.get(Uri.parse("$baseUrl/users/$mobile/accounts"));
    if (response.statusCode == 200) {
      return json.decode(response.body)['accounts'];
    } else {
      throw Exception("Failed to load accounts");
    }
  }

  // Fetch statement
  static Future<List<dynamic>> fetchStatement(
      String mobile, String accountType, String accountId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/users/$mobile/statement/$accountType/$accountId"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['transactions'] ?? [];
    } else {
      throw Exception("Failed to load statement");
    }
  }
}
