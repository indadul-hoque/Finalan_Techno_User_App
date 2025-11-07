import 'package:flutter/material.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();

  // UI state
  bool _isLoading = true;
  bool _isLoadingTransactions = true;
  double _availableBalance = 0.0;
  DateTime _openingDate = DateTime.now();

  // Razorpay
  late Razorpay _razorpay;

  // Dynamic Transaction Data
  List<Map<String, dynamic>> _transactions = [];

  // -----------------------------------------------------------------
  // 1. FETCH WALLET DETAILS
  // -----------------------------------------------------------------
  Future<void> _fetchWalletDetails() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar('Mobile number not found. Please login', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    final String formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber.substring(3)
        : phoneNumber.startsWith('91')
            ? phoneNumber
            : '91$phoneNumber';

    final url = Uri.parse(
        'https://gs3-itax-user-app-backend-879235286268.asia-south1.run.app/mobile/wallet/$formattedPhone');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true) {
          final data = json['data'];
          final String balanceStr = data['walletBalance'].toString();

          setState(() {
            _availableBalance = double.tryParse(balanceStr) ?? 0.0;
            _openingDate = DateTime.now();
            _isLoading = false;
          });

          print('Wallet Balance: ₹$_availableBalance');
        } else {
          throw Exception(json['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
      _showSnackBar('Failed to load wallet: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------------------------------
  // 2. FETCH TRANSACTION HISTORY (DYNAMIC)
  // -----------------------------------------------------------------
  Future<void> _fetchTransactions() async {
    setState(() => _isLoadingTransactions = true);

    final prefs = await SharedPreferences.getInstance();
    final String? phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar('Login required to view transactions', Colors.red);
      setState(() => _isLoadingTransactions = false);
      return;
    }

    final String formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber.substring(3)
        : phoneNumber.startsWith('91')
            ? phoneNumber
            : '91$phoneNumber';

    final url = Uri.parse(
        'https://gs3-itax-user-app-backend-879235286268.asia-south1.run.app/mobile/wallet/$formattedPhone/transactions');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('TRANSACTIONS RESPONSE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true && json['transactions'] != null) {
          final List<dynamic> rawList = json['transactions'];
          setState(() {
            _transactions = rawList.map((t) {
              return {
                'amount': (t['amount'] is int)
                    ? t['amount'].toDouble()
                    : double.tryParse(t['amount'].toString()) ?? 0.0,
                'date': DateTime.tryParse(t['createdAt'] ?? '') ?? DateTime.now(),
                'type': t['type'] ?? 'credit', // optional
              };
            }).toList();
            _isLoadingTransactions = false;
          });
        } else {
          throw Exception(json['message'] ?? 'No transactions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Transaction fetch error: $e');
      _showSnackBar('Failed to load transactions', Colors.red);
      setState(() {
        _transactions = [];
        _isLoadingTransactions = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Fetch both wallet and transactions
    _fetchWalletDetails().then((_) => _fetchTransactions());
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------
  // CREATE ORDER & PAYMENT LOGIC (unchanged)
  // -----------------------------------------------------------------
  Future<Map<String, dynamic>?> _createOrder(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawPhone = prefs.getString('phoneNumber');

      if (rawPhone == null || rawPhone.isEmpty) {
        _showSnackBar('Login required', Colors.red);
        return null;
      }

      final String phone = rawPhone.replaceAll(RegExp(r'\D'), '');
      final String formattedPhone = phone.length == 10 ? '91$phone' : phone;

      final url = Uri.parse(
        'https://gs3-itax-user-app-backend-879235286268.asia-south1.run.app/mobile/wallet/$formattedPhone/add',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'amount': amount.toInt()}),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['order'] != null) {
          _showSnackBar('Order ready!', primaryColor);
          return json['order'] as Map<String, dynamic>;
        } else {
          _showSnackBar('Server error: ${json['message'] ?? 'No order'}', Colors.red);
        }
      } else {
        _showSnackBar('Server down (${response.statusCode})', Colors.red);
      }
    } catch (e) {
      _showSnackBar('No internet / timeout', Colors.red);
    }
    return null;
  }

  void _openCheckout() async {
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      _showSnackBar('Enter amount', primaryColor);
      return;
    }

    final double amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0 || amount > 50000) {
      _showSnackBar('Amount must be ₹1 - ₹50,000', Colors.red);
      return;
    }

    _showSnackBar('Creating order...', primaryColor);

    final order = await _createOrder(amount);
    if (order == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('userName') ?? 'User';
    final String? phone = prefs.getString('phoneNumber') ?? '';

    var options = {
      'key': 'rzp_test_RQfYIFyZYuKgkF',
      'amount': order['amount'],
      'name': 'GS3 iTax Wallet',
      'order_id': order['id'],
      'description': 'Add ₹$amount to wallet',
      'prefill': {
        'contact': phone,
        'email': '$name@example.com',
        'name': name,
      },
      'notes': {
        'phoneNumber': phone,
      },
      'theme': {
        'color': '#${primaryColor.value.toRadixString(16).substring(2)}'
      },
      'retry': {'enabled': true, 'max_count': 2}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Razorpay error: $e', Colors.red);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phoneNumber') ?? '';

    _showSnackBar('Verifying payment...', primaryColor);

    try {
      final verifyUrl = Uri.parse(
        'https://gs3-itax-user-app-backend-879235286268.asia-south1.run.app/mobile/wallet/verify-payment',
      );

      final verifyResponse = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'amount': amount.toInt(),
          'phoneNumber': phone,
        }),
      );

      if (verifyResponse.statusCode == 200) {
        final json = jsonDecode(verifyResponse.body);
        if (json['success'] == true) {
          await _fetchWalletDetails();
          await _fetchTransactions(); // Refresh transactions
          _amountController.clear();
          _showSnackBar('₹${amount.toInt()} added!', greenColor);
        } else {
          _showSnackBar('Server: ${json['error']}', Colors.red);
        }
      } else {
        _showSnackBar('Verify failed (${verifyResponse.statusCode})', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Network error', Colors.red);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message}', Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('Paid via ${response.walletName}', Colors.orange);
  }

  // Helper function to format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _showSnackBar(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: snackBarStyle), backgroundColor: bg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text('My Wallet', style: bold20White),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // ------------------- Wallet Card -------------------
                Container(
                  margin: const EdgeInsets.all(fixPadding * 2),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(fixPadding * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEDEBEB),
                              ),
                              child: Icon(Icons.account_balance_wallet_rounded,
                                  color: primaryColor, size: 28),
                            ),
                            widthSpace,
                            Text('Wallet Details', style: bold16Black33),
                          ],
                        ),
                        heightSpace,
                        Center(
                          child: Column(
                            children: [
                              Text('Available Balance', style: bold15Grey94),
                              height5Space,
                              Text(
                                '₹${_availableBalance.toStringAsFixed(2)}',
                                style: bold22Black,
                              ),
                              heightSpace,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 18),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child:
                                    Text('Safe & Secure', style: bold15Green),
                              ),
                            ],
                          ),
                        ),
                        heightSpace,
                        Row(
                          children: [
                            Expanded(
                                child: infoWidget('Opening Date',
                                    '${_openingDate.day}-${_openingDate.month}-${_openingDate.year}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ------------------- Transaction History Header -------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      fixPadding * 2, 0, fixPadding * 2, fixPadding),
                  child: Text('Recent Transactions', style: bold16Black33),
                ),

                // ------------------- Transaction List (Dynamic) -------------------
                _isLoadingTransactions
                    ? const Padding(
                        padding: EdgeInsets.all(fixPadding * 4),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _transactions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(fixPadding * 4),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 48, color: Colors.grey[400]),
                                  heightSpace,
                                  Text('No transactions yet',
                                      style: semibold14Grey94),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding * 2),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return _buildTransactionCard(
                                amount: transaction['amount'],
                                date: transaction['date'],
                              );
                            },
                          ),
                heightBox(100),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(
            fixPadding * 2, fixPadding * 2, fixPadding * 2, fixPadding * 2 + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Money to Wallet', style: bold16Black33),
            heightSpace,
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: semibold16Black33,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.currency_rupee, color: primaryColor),
                labelText: 'Enter amount',
                labelStyle: semibold15Grey94,
                hintText: 'e.g. 5000',
                hintStyle: semibold14Grey87,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: scaffoldBgColor,
              ),
            ),
            heightSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openCheckout,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Money', style: bold16White),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Transaction Card Widget -------------------
  Widget _buildTransactionCard({
    required double amount,
    required DateTime date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: fixPadding * 1.2),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 1.5, vertical: fixPadding * 1.3),
        child: Row(
          children: [
            // Green Circle Icon
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: greenColor,
                size: 22,
              ),
            ),
            const SizedBox(width: fixPadding * 1.2),
            
            // Date
            Expanded(
              child: Text(
                _formatDate(date),
                style: semibold15Black33,
              ),
            ),
            
            // Amount
            Text(
              '+₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: greenColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoWidget(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: semibold14Grey94,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        height5Space,
        Text(value,
            style: semibold16Black33,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}