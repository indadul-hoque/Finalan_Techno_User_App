import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final offerList = [
    {
      "image": "assets/loan/image1.jpg",
      "title": "Make education your top priority",
      "info": "Lowest interest rate",
    },
    {
      "image": "assets/loan/image2.jpg",
      "title": "The right choice to finance your car",
      "info": "Buy your dream car",
    },
  ];

  final currentLoans = [
    {
      "icon": "assets/loan/home-database.png",
      "name": "Home loan",
      "accountNo": "1234 4567 8956 1222",
      "amount": 20000.00,
      "period": "24 month",
      "Rate": "13%",
      "EMI": 1000.00,
    },
    {
      "icon": "assets/loan/car-outline.png",
      "name": "Car loan",
      "accountNo": "1234 4567 8956 1222",
      "amount": 10000.00,
      "period": "12 month",
      "Rate": "10%",
      "EMI": 1000.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/deposite/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: primaryColor.withValues(alpha: 0.5),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light),
        title: Text(
          getTranslation(context, 'loans.loans'),
          style: bold20White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          offerApplyListContent(size, context),
          dottedLine(),
          heightSpace,
          heightSpace,
          currentLoanTitle(),
          currentLoansListContent(),
          heightSpace,
        ],
      ),
    );
  }

  currentLoansListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
              vertical: fixPadding, horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(fixPadding * 1.5),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(fixPadding / 1.2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFfEDEBEB),
                      ),
                      child: Image.asset(
                        currentLoans[index]['icon'].toString(),
                      ),
                    ),
                    widthSpace,
                    width5Space,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentLoans[index]['name'].toString(),
                            style: bold16Black33,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentLoans[index]['accountNo'].toString(),
                            style: semibold14Grey94,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    Text(
                      "\$${currentLoans[index]['amount']}",
                      style: bold16Primary,
                    )
                  ],
                ),
              ),
              dottedLine(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2,
                  vertical: fixPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: infoWidget(
                        getTranslation(context, 'loans.period'),
                        currentLoans[index]['period'].toString(),
                      ),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: infoWidget(
                        getTranslation(context, 'loans.rate'),
                        "${currentLoans[index]['Rate']} ${getTranslation(context, 'loans.rate_text')}",
                      ),
                    )),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: infoWidget(
                          getTranslation(context, 'loans.EMI'),
                          "\$${currentLoans[index]['EMI']}",
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/loanStatement');
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 7.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5C4C4),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getTranslation(context, 'loans.view_statement'),
                    style: bold16Primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: currentLoans.length,
    );
  }

  infoWidget(String title, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: semibold14Grey94,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          detail,
          style: semibold16Black33,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  currentLoanTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'loans.current_loans'),
        style: bold18Black33,
      ),
    );
  }

  dottedLine() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      color: primaryColor,
      dashPattern: const [2, 3],
      child: Container(),
    );
  }

  offerApplyListContent(Size size, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 2, horizontal: fixPadding),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          offerList.length,
          (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/educationLoan');
              },
              child: Container(
                height: 152,
                width: size.width * 0.8,
                margin: const EdgeInsets.symmetric(horizontal: fixPadding),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF034E65).withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      child: ClipPath(
                        clipper: ImageClipper(),
                        child: Container(
                          height: double.maxFinite,
                          width: size.width * 0.43,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(10),
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                offerList[index]['image'].toString(),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: fixPadding,
                          top: fixPadding,
                          bottom: fixPadding,
                          left: size.width * 0.45),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerList[index]['title'].toString(),
                            style: bold16Primary,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          FittedBox(
                            child: Text(
                              offerList[index]['info'].toString(),
                              style: bold14Grey87,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          heightSpace,
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/educationLoan');
                            },
                            child: Container(
                              width: 100,
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: fixPadding / 2),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: primaryColor,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                child: Text(
                                  getTranslation(context, 'loans.apply_now'),
                                  style: bold14Primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width - 35, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
