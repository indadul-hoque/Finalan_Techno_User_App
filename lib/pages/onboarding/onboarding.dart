import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  DateTime? backPressTime;

  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Auto-slide every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = currentPage + 1;
        if (nextPage >= 3) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final pageList = [
      _buildPage(
        size,
        "assets/onboarding/onboarding1.png",
        getTranslation(context, 'onboarding.text1'),
        "Experience banking like never before with our secure, lightning-fast platform. Your financial safety is our top priority.",
      ),
      _buildPage(
        size,
        "assets/onboarding/onboarding2.png",
        getTranslation(context, 'onboarding.text2'),
        "Take control of your finances with smart tools and insights. Track spending, save smarter, and grow your wealth effortlessly.",
      ),
      _buildPage(
        size,
        "assets/onboarding/onboarding3.png",
        getTranslation(context, 'onboarding.text3'),
        "Never worry about finding banking services again. Locate ATMs, branches, and financial centers instantly with our smart location services.",
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = onWillPop();
        if (backStatus) exit(0);
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFCFD),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pageList.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (context, index) => pageList[index],
                ),
              ),
              // Footer (fancy dots + buttons)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    currentPage == pageList.length - 1
                        ? const SizedBox(width: 60) // keep layout balanced
                        : skipButton(context),

                    // 🔥 Fancy SmoothPageIndicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: pageList.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: primaryColor,
                        dotColor: greyD9Color,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),

                    arrowButton(pageList.length, context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Size size, String asset, String title, String desc) {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Image.asset(
            asset,
            width: size.height * 0.35,
            height: size.height * 0.35,
            fit: BoxFit.cover,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          child: Text(title, style: bold20Black33, textAlign: TextAlign.center),
        ),
        height5Space,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          child:
              Text(desc, textAlign: TextAlign.center, style: semibold14Grey94),
        ),
        heightSpace,
        heightSpace,
      ],
    );
  }

  skipButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith(
            (states) => primaryColor.withValues(alpha: 0.1)),
      ),
      child:
          Text(getTranslation(context, 'onboarding.skip'), style: bold14Grey94),
    );
  }

  arrowButton(int pageLength, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          if (currentPage == pageLength - 1) {
            Navigator.pushNamed(context, '/login');
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        child: DottedBorder(
          borderType: BorderType.Circle,
          padding: const EdgeInsets.all(5),
          color: const Color(0xFFDA8BA3),
          dashPattern: const [2, 3],
          strokeWidth: 2,
          strokeCap: StrokeCap.square,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
                color: primaryColor, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, color: whiteColor),
          ),
        ),
      ),
    );
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) >= const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: blackColor,
          content: Text(
            getTranslation(context, 'exit_app.app_exit'),
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
