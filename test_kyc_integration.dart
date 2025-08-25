import 'package:flutter/material.dart';
import 'package:fl_banking_app/services/kyc_service.dart';

void main() {
  runApp(const KYCIntegrationTestApp());
}

class KYCIntegrationTestApp extends StatelessWidget {
  const KYCIntegrationTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYC Integration Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const KYCIntegrationTestPage(),
    );
  }
}

class KYCIntegrationTestPage extends StatefulWidget {
  const KYCIntegrationTestPage({Key? key}) : super(key: key);

  @override
  State<KYCIntegrationTestPage> createState() => _KYCIntegrationTestPageState();
}

class _KYCIntegrationTestPageState extends State<KYCIntegrationTestPage> {
  final TextEditingController phoneController = TextEditingController();
  Map<String, dynamic>? kycData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the test phone number from the API
    phoneController.text = '9519874704';
  }

  Future<void> fetchKYCData() async {
    if (phoneController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a phone number';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await KYCService.fetchKYCDetails(phoneController.text);
      setState(() {
        kycData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC API Integration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone number input
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number to fetch KYC data',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Fetch button
            ElevatedButton(
              onPressed: isLoading ? null : fetchKYCData,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Fetch KYC Data'),
            ),
            const SizedBox(height: 16),
            
            // Error message
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // KYC data display
            if (kycData != null) ...[
              const Text(
                'KYC Data Retrieved:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataRow('ID', kycData!['id']),
                        _buildDataRow('Name', kycData!['name']),
                        _buildDataRow('Email', kycData!['email']),
                        _buildDataRow('Phone', kycData!['phone']),
                        _buildDataRow('Gender', kycData!['gender']),
                        _buildDataRow('Marital Status', kycData!['materialStatus']),
                        _buildDataRow('Guardian', kycData!['guardian']),
                        _buildDataRow('Address', kycData!['address']),
                        _buildDataRow('Aadhar', kycData!['aadhar']),
                        _buildDataRow('Voter ID', kycData!['voter']),
                        _buildDataRow('PAN', kycData!['pan']),
                        _buildDataRow('Occupation', kycData!['occupation']),
                        _buildDataRow('Income', kycData!['income']),
                        _buildDataRow('Education', kycData!['education']),
                        _buildDataRow('Active', kycData!['active'].toString()),
                        _buildDataRow('Group', kycData!['group']),
                        _buildDataRow('Created Date', kycData!['date']),
                        
                        const SizedBox(height: 16),
                        const Text(
                          'Nominee Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (kycData!['nominee'] != null) ...[
                          _buildDataRow('Nominee Name', kycData!['nominee']['name']),
                          _buildDataRow('Relation', kycData!['nominee']['relation']),
                          _buildDataRow('Nominee Aadhar', kycData!['nominee']['aadhar']),
                        ] else
                          const Text('No nominee details available'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not provided',
              style: TextStyle(
                color: value != null && value.isNotEmpty 
                    ? Colors.black 
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
