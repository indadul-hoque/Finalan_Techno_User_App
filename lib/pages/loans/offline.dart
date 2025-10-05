import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class Offline extends StatefulWidget {
  const Offline({Key? key}) : super(key: key);

  @override
  _OfflineState createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  // Bank accounts initialized inside the app
  final List<Map<String, String>> bankAccounts = [
    {
      'name': 'John Doe',
      'accountNumber': '1234567890',
      'ifsc': 'ABCD0123456',
      'branch': 'Main Branch',
      'address': '123 Street, City'
    },
    {
      'name': 'Jane Smith',
      'accountNumber': '9876543210',
      'ifsc': 'WXYZ0987654',
      'branch': 'City Branch',
      'address': '456 Avenue, City'
    }
  ];

  final TextEditingController _txnController = TextEditingController();
  File? _paymentScreenshot;
  bool _isSubmitEnabled = false;

  void _checkSubmitEnabled() {
    setState(() {
      _isSubmitEnabled =
          _txnController.text.isNotEmpty && _paymentScreenshot != null;
    });
  }

  Future<void> _pickScreenshot() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _paymentScreenshot = File(pickedFile.path);
      });
      _checkSubmitEnabled();
    }
  }

  void _copyDetail(String detail) {
    Clipboard.setData(ClipboardData(text: detail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$detail copied!')),
    );
  }

  void _submitRepayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repayment request has been generated')),
    );
    setState(() {
      _txnController.clear();
      _paymentScreenshot = null;
      _isSubmitEnabled = false;
    });
  }

  Widget _buildBankCard(Map<String, String> account) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCopyRow('Name', account['name'] ?? ''),
            _buildCopyRow('Account Number', account['accountNumber'] ?? ''),
            _buildCopyRow('IFSC', account['ifsc'] ?? ''),
            _buildCopyRow('Branch', account['branch'] ?? ''),
            // _buildCopyRow('Address', account['address'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text('$label: $value')),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyDetail(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Loan Repayment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bank Accounts List
            ...bankAccounts.map(_buildBankCard).toList(),
            const SizedBox(height: 20),
            // Transaction Number Input
            TextField(
              controller: _txnController,
              decoration: const InputDecoration(
                labelText: 'Transaction Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _checkSubmitEnabled(),
            ),
            const SizedBox(height: 16),
            // Payment Screenshot Upload
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickScreenshot,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Payment Screenshot'),
                ),
                const SizedBox(width: 16),
                _paymentScreenshot != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitEnabled ? _submitRepayment : null,
                child: const Text('Repaid '),
              ),
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Offline(),
  ));
}
