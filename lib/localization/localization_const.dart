import 'package:fl_banking_app/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getTranslation(BuildContext context, String key) {
  return DemoLocalizations.of(context).getTranslation(key);
}

String translation(String key) {
  return DemoLocalizations.instance.getTranslation(key);
}

const String english = 'en';
const String hindi = 'hi';
const String indonisian = 'id';
const String chinese = 'zh';
const String arabic = 'ar';
const String languageValue = 'languageCode';

Future<Locale> setLoale(String languageCode) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(languageValue, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String languageCode = preferences.getString(languageValue) ?? english;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale temp;

  switch (languageCode) {
    case english:
      temp = Locale(languageCode);
      break;
    case hindi:
      temp = Locale(languageCode);
      break;
    case indonisian:
      temp = Locale(languageCode);
      break;
    case chinese:
      temp = Locale(languageCode);
      break;
    case arabic:
      temp = Locale(languageCode);
      break;
    default:
      temp = const Locale(english);
  }
  return temp;
}
