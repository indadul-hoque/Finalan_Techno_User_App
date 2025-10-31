import 'package:fl_banking_app/localization/localization.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fl_banking_app/pages/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_banking_app/routes/app_routes.dart'; // Import the routes

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
  const MyApp({Key? key, required this.isLoggedIn, this.phoneNumber})
      : super(key: key);

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
            prefixIconColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.focused)
                  ? primaryColor
                  : grey94Color,
            ),
          ),
          appBarTheme: const AppBarTheme(
              elevation: 6.0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: scaffoldBgColor),
        ),
        home: const SplashScreen(),
        onGenerateRoute: appRoutes, // Use the imported routes
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
}