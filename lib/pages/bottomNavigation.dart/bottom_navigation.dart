
import 'dart:io';
import 'package:fl_banking_app/pages/profile/account.dart';
import 'package:fl_banking_app/pages/deposit/deposit.dart';
import 'package:fl_banking_app/pages/home/home.dart';
import 'package:fl_banking_app/pages/loans/loans.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigationScreen extends StatefulWidget {
  final String? phoneNumber;
  final int? id;

  const BottomNavigationScreen({Key? key, this.id, this.phoneNumber}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int? currentPage;
  DateTime? backPressTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentPage = widget.id ?? 0;
    });
    _checkPhoneNumber();
  }

  Future<void> _checkPhoneNumber() async {
    if (!mounted) return;
    String? phoneNumber = widget.phoneNumber;
    if (phoneNumber == null) {
      final prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString('phoneNumber');
      if (phoneNumber == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showToast('Phone number not found. Please log in again.');
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        }
        return;
      }
    }
    // Remove country code for consistency with KYCService
    phoneNumber = phoneNumber.startsWith('+91') ? phoneNumber.substring(3) : phoneNumber;
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Skip user data API and proceed to HomeScreen
      // KYC validation will be handled by HomeScreen
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  List<Widget> get pages => [
        HomeScreen(phoneNumber: widget.phoneNumber ?? '9831209756'),
        DepositScreen(phoneNumber: widget.phoneNumber ?? '9831209756'),
        LoansScreen(phoneNumber: widget.phoneNumber ?? '9831209756'),
        const AccountScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = _onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: pages.elementAt(currentPage!),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: whiteColor,
            selectedItemColor: primaryColor,
            unselectedItemColor: grey94Color,
            selectedLabelStyle: bold15Primary,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            unselectedLabelStyle: bold15Grey94,
            currentIndex: currentPage!,
            onTap: (index) {
              setState(() {
                currentPage = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.account_balance_wallet_outlined, color: grey94Color),
                  activeIcon: const Icon(Icons.account_balance_wallet_outlined, color: primaryColor),
                  label: 'Deposit'),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.monetization_on_outlined, color: grey94Color),
                  activeIcon: const Icon(Icons.monetization_on_outlined, color: primaryColor),
                  label: 'Loans'),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  bool _onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null || now.difference(backPressTime!) >= const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: blackColor,
          content: const Text(
            'Press back again to exit',
            style: snackBarStyle,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}