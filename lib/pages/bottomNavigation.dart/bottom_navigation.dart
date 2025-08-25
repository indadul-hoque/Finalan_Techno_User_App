import 'dart:io';
import 'package:fl_banking_app/pages/Account/account.dart';
import 'package:fl_banking_app/pages/deposit/deposit.dart';
import 'package:fl_banking_app/pages/home/home.dart';
import 'package:fl_banking_app/pages/loans/loans.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BottomNavigationScreen extends StatefulWidget {
  // Add phoneNumber to the constructor
  final String? phoneNumber;
  final int? id;

  const BottomNavigationScreen({Key? key, this.id, this.phoneNumber}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int? currentPage;
  DateTime? backPressTime;
  // State variables for user data and loading state
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentPage = widget.id ?? 0;
    });
    // Fetch user data when the screen initializes
    if (widget.phoneNumber != null) {
      _fetchUserData();
    } else {
      // If phone number is not passed, handle it (e.g., show an error)
      setState(() {
        _isLoading = false;
      });
      // Optionally, you can navigate back to the login screen
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _fetchUserData() async {
    // Skip user data fetching for now since we're using the accounts API directly
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> get pages => [
    const HomeScreen(),
    DepositScreen(phoneNumber: widget.phoneNumber ?? '9519874704'),
    LoansScreen(phoneNumber: widget.phoneNumber ?? '9519874704'),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while fetching user data
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Once data is loaded, build the main UI
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
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/bottomNavigation/Glyph_ undefined.png",
                    height: 24,
                    width: 24,
                    color: grey94Color,
                    fit: BoxFit.cover,
                  ),
                  activeIcon: Image.asset(
                    "assets/bottomNavigation/Glyph_ undefined.png",
                    height: 24,
                    width: 24,
                    color: primaryColor,
                    fit: BoxFit.cover,
                  ),
                  label: 'Deposit'),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/bottomNavigation/money-16-regular.png",
                    height: 24,
                    width: 24,
                    color: grey94Color,
                    fit: BoxFit.cover,
                  ),
                  activeIcon: Image.asset(
                    "assets/bottomNavigation/money-16-regular.png",
                    height: 24,
                    width: 24,
                    color: primaryColor,
                    fit: BoxFit.cover,
                  ),
                  label: 'Loans'),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  label: 'Account')
            ],
          ),
        ),
      ),
    );
  }

  bool _onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) >= const Duration(seconds: 2)) {
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

