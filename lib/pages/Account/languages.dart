import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/main.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? selectedValue;

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  SharedPreferences? pref;
  String keys = 'value';

  read() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      selectedValue = pref!.getString(keys) ?? 'English';
    });
  }

  changeLanguage(String languageCode) async {
    Locale temp = await setLoale(languageCode);

    // ignore: use_build_context_synchronously
    MyApp.setLocale(context, temp);
  }

  @override
  void initState() {
    read();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: black33Color,
        backgroundColor: scaffoldBgColor,
        shadowColor: blackColor.withValues(alpha: 0.4),
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'language.language'),
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: fixPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          languageListContent(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          updateButton(context),
        ],
      ),
    );
  }

  updateButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < (Languages.languageList.length); i++) {
            if (selectedValue == Languages.languageList[i].name) {
              changeLanguage(Languages.languageList[i].languageCode!);
            }
          }
        });
        pref?.setString(keys, selectedValue!);
        Navigator.pop(context);
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'language.update'),
          style: bold18White,
        ),
      ),
    );
  }

  languageListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedValue = Languages.languageList[index].name;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2),
            padding: const EdgeInsets.symmetric(
                vertical: fixPadding * 1.2, horizontal: fixPadding * 2),
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Languages.languageList[index].name.toString(),
                    style: semibold16Black33,
                  ),
                ),
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    shape: BoxShape.circle,
                    border: selectedValue == Languages.languageList[index].name
                        ? Border.all(
                            color: primaryColor,
                            width: 8,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: Languages.languageList.length,
    );
  }
}

class Languages {
  final String? name;
  final String? languageCode;
  final int? id;

  Languages({this.name, this.languageCode, this.id});

  static List<Languages> languageList = [
    Languages(name: "English", languageCode: 'en'),
    Languages(name: "हिंदी", languageCode: 'hi'),
    Languages(name: "Indonesian", languageCode: 'id'),
    Languages(name: "中国人", languageCode: 'zh'),
    Languages(name: "عربى", languageCode: 'ar'),
  ];
}
