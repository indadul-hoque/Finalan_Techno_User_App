import 'package:dotted_border/dotted_border.dart';
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final currentLoans = [
    {
      "icon": "assets/loan/home-database.png",
      "name": "SBI Bank",
      "accountNo": "XXXX XXXX XXXX 1222",
      "amount": 20000.00
    },
    {
      "icon": "assets/loan/car-outline.png",
      "name": "HDFC Bank",
      "accountNo": "XXXX XXXX XXXX 1222",
      "amount": 10000.00
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
          getTranslation(context, 'Deposits'),
          style: bold20White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // Removed currentLoanTitle() to remove the heading
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
                        color: Color(0xFFEDEBEB),
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
              // The entire Padding with period, rate, and EMI text labels has been removed
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/depositStatement');
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
                    getTranslation(context, 'View Deposit Statement'),
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

  dottedLine() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      color: primaryColor,
      dashPattern: const [2, 3],
      child: Container(),
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

