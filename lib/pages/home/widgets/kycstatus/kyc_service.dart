import 'dart:convert';
import 'package:fl_banking_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class KYCService {
  static const String baseUrl = AppConfig.baseUrl;
  //https://gs3-itax-user-app-backend-879235286268.asia-south1.run.app/

  // KYC Model
  static Map<String, dynamic>? kycData;
  static bool isLoading = false;
  static String? errorMessage;

  static String getUserName() {
    return kycData?['name'] ?? '';
  }

  // Fetch KYC details for a user
  static Future<Map<String, dynamic>?> fetchKYCDetails(
      String phoneNumber) async {
    try {
      isLoading = true;
      errorMessage = null;

      final response = await http.get(
        Uri.parse('$baseUrl/user/$phoneNumber/kyc'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("\n\n\n");
      print(response.body);
      print("\n\n\n");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'KYC details fetched successfully.') {
          kycData = data['kycDetails'];
          return kycData;
        } else {
          errorMessage = data['message'] ?? 'Failed to fetch KYC details';
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

  // Update KYC details
  static Future<bool> updateKYCDetails(
      String phoneNumber, Map<String, dynamic> kycData) async {
    try {
      isLoading = true;
      errorMessage = null;

      final response = await http.put(
        Uri.parse('$baseUrl/user/$phoneNumber/kyc'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(kycData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'KYC details updated successfully.') {
          return true;
        } else {
          errorMessage = data['message'] ?? 'Failed to update KYC details';
          return false;
        }
      } else {
        errorMessage = 'HTTP Error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Network Error: $e';
      return false;
    } finally {
      isLoading = false;
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

  // Get KYC status
  static String getKYCStatus() {
    if (kycData == null) return 'Not Available';
    return kycData!['active'] == true ? 'Verified' : 'Pending';
  }

  // Get KYC completion percentage
  static double getKYCCompletionPercentage() {
    if (kycData == null) return 0.0;

    List<String> requiredFields = [
      'name',
      'email',
      'phone',
      'address',
      'aadhar',
      'voter',
      'pan',
      'occupation',
      'income',
      'education'
    ];

    int completedFields = 0;
    for (String field in requiredFields) {
      if (kycData![field] != null && kycData![field].toString().isNotEmpty) {
        completedFields++;
      }
    }

    return (completedFields / requiredFields.length) * 100;
  }
}
