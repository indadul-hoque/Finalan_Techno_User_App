import 'package:fl_banking_app/localization/localization.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fl_banking_app/pages/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth/login.dart';
import 'pages/bottomNavigation.dart/bottom_navigation.dart';

import 'package:local_auth/local_auth.dart';
import 'package:fl_banking_app/services/auth_service.dart';
import 'package:fl_banking_app/widgets/biometric_gate.dart';

String? phoneNumber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  phoneNumber = prefs.getString('phoneNumber');
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn, phoneNumber: phoneNumber));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? phoneNumber;
  const MyApp({Key? key, required this.isLoggedIn, this.phoneNumber}) : super(key: key);

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'Banking App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
          ),
          primarySwatch: Colors.blue,
          primaryColor: primaryColor,
          fontFamily: 'NunitoSans',
          scaffoldBackgroundColor: scaffoldBgColor,
          inputDecorationTheme: InputDecorationTheme(
            prefixIconColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? primaryColor
                  : grey94Color,
            ),
          ),
          appBarTheme: const AppBarTheme(
              elevation: 6.0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: scaffoldBgColor),
        ),
	home: (widget.phoneNumber == null || widget.phoneNumber!.isEmpty || !widget.isLoggedIn)
	    ? const SplashScreen()
	    : const BiometricGate(),
        onGenerateRoute: routes,
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('id'),
          Locale('zh'),
          Locale('ar'),
        ],
        localizationsDelegates: [
          DemoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale?.languageCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }

  Route<dynamic>? routes(settings) {
    switch (settings.name) {
      case '/':
        return PageTransition(
          child: (phoneNumber == null || phoneNumber!.isEmpty)
              ? const SplashScreen()
              : const BottomNavigationScreen(),
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
      // The phoneNumber will now be passed through the constructor.
      // This route will need to be updated to pass the phoneNumber.
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
      default:
        return null;
    }
  }
}


