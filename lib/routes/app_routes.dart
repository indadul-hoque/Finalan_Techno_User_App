import 'package:fl_banking_app/main.dart';
import 'package:fl_banking_app/pages/home/widgets/services/wallet/wallet_screen.dart';
import 'package:fl_banking_app/pages/screens.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';

Route<dynamic>? appRoutes(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return PageTransition(
        child: (phoneNumber == null || phoneNumber!.isEmpty)
            ? const SplashScreen()
            : BottomNavigationScreen(phoneNumber: phoneNumber),
        type: PageTransitionType.fade,
        settings: settings,
      );
    case '/onboarding':
      return PageTransition(
        child: const OnboardingScreen(),
        type: PageTransitionType.fade,
        settings: settings,
      );
    case '/login':
      return PageTransition(
        child: const LoginScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/otp':
      return PageTransition(
        child: const OtpVerification(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/bottomNavigation':
      final args = settings.arguments as String?;
      return PageTransition(
        child: BottomNavigationScreen(phoneNumber: args),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/home':
      return PageTransition(
        child: const HomeScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/notification':
      return PageTransition(
        child: const NotificationScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/account':
      return PageTransition(
        child: const AccountDetailScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/statement':
      return PageTransition(
        child: const StatementScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/fundTransfer':
      return PageTransition(
        child: const FundTransferScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/success':
      return PageTransition(
        child: const TransferSuccessScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/services':
      return PageTransition(
        child: const ServicesScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/transaction':
      return PageTransition(
        child: const TransactionScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/addDeposit':
      return PageTransition(
        child: const AddDepositScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/educationLoan':
      return PageTransition(
        child: const EducationLoan(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/loanStatement':
      return PageTransition(
        child: const LoanStatementScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/editProfile':
      return PageTransition(
        child: const EditProfile(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/loanRepayment':
      return PageTransition(
        child: const LoanRepayment(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/wallet':
      return PageTransition(
        child: const WalletScreen(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/offline':
      return PageTransition(
        child: const Offline(),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    case '/online':
      final args = settings.arguments as Map<String, dynamic>;
      return PageTransition(
        child: Online(
          selectedLoanId: args['selectedLoanId'],
          amount: args['amount'],
        ),
        type: PageTransitionType.rightToLeft,
        settings: settings,
      );
    default:
      return null;
  }
}
