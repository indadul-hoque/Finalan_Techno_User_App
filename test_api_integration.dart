import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API Integration...');
  
  // Test the API endpoint
  final phoneNumber = '9519874704';
  final url = 'https://api.cornix.tech/user/$phoneNumber/accounts';
  
  try {
    print('Fetching accounts for phone number: $phoneNumber');
    print('API URL: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['message'] == 'Accounts fetched successfully.') {
        final accounts = data['accounts'] as List;
        
        print('\n=== ACCOUNTS SUMMARY ===');
        print('Total accounts: ${accounts.length}');
        
        // Separate loan and savings accounts
        final loanAccounts = accounts.where((account) => account['accountType'] == 'loan').toList();
        final savingsAccounts = accounts.where((account) => account['accountType'] == 'savings').toList();
        
        print('\n=== LOAN ACCOUNTS (${loanAccounts.length}) ===');
        for (var loan in loanAccounts) {
          print('Account ID: ${loan['accountId']}');
          print('Loan Amount: ₹${loan['loanAmount']}');
          print('EMI Amount: ₹${loan['emiAmount']}');
          print('Loan Term: ${loan['loanTerm']} months');
          print('Plan: ${loan['planDetails']['name']}');
          print('Interest Rate: ${loan['planDetails']['interestRate']}%');
          print('---');
        }
        
        print('\n=== SAVINGS ACCOUNTS (${savingsAccounts.length}) ===');
        for (var savings in savingsAccounts) {
          print('Account ID: ${savings['accountId']}');
          print('Balance: ₹${savings['balance']}');
          print('Opening Date: ${savings['openingDate']}');
          print('Scheme: ${savings['planDetails']['schemeName']}');
          print('Interest Rate: ${savings['planDetails']['annualInterestRate']}%');
          print('---');
        }
        
        print('\n✅ API Integration Test PASSED!');
        print('The API is working correctly and returning the expected data structure.');
        
      } else {
        print('❌ API returned error message: ${data['message']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Error occurred: $e');
  }
}
