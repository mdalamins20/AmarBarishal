import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ChangeNotifier ব্যবহার করে এই ক্লাসটিকে একটি "provider" বানানো হয়েছে,
// যা তার ভেতরের ডেটা পরিবর্তন হলে সবাইকে জানাতে পারে।
class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale(); // ক্লাসটি তৈরি হওয়ার সাথেই সংরক্ষিত ভাষা লোড করবে
  }

  // SharedPreferences থেকে সংরক্ষিত ভাষা লোড করার ফাংশন
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners(); // সবাইকে জানানো হচ্ছে যে ভাষা পরিবর্তন হয়েছে
    }
  }

  // নতুন ভাষা সেট করার এবং SharedPreferences-এ সেভ করার ফাংশন
  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners(); // সবাইকে জানানো হচ্ছে যে নতুন ভাষা সেট করা হয়েছে
  }
}