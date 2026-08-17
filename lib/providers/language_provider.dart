import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'bn';
  final Map<String, String> _dynamicTranslationCache = {};

  String get languageCode => _languageCode;
  bool get isEnglish => _languageCode == 'en';
  bool get isBangla => _languageCode == 'bn';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('language') ?? 'bn';
    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    notifyListeners();
  }

  // Dynamic async translator block (Disabled to prevent API rate limits)
  Future<String> translateDynamic(String text) async {
    // Return original text immediately as runtime translation is disabled
    return text;
  }

  static const Map<String, String> _bn = {
    'welcome': 'স্বাগতম!',
    'app_name': 'আমার বরিশাল',
    'app_subtitle': 'সব তথ্য এক জায়গায়, আপনার হাতের মুঠোয়। এই অ্যাপটি ব্যবহার করে নির্ভরযোগ্য তথ্য খুব সহজেই খুঁজে নিন।',
    'drawer_subtitle': 'বরিশালের সেরা স্মার্ট গাইড',
    'category_empty': 'কোনো ক্যাটাগরি ডাটাবেসে নেই!',
    'home': 'হোম',
    'admin_title': 'অ্যাডমিন প্যানেল',
    'admin_dashboard': 'অ্যাডমিন ড্যাশবোর্ড',
    'others': 'অন্যান্য',
    'settings': 'সেটিংস',
    'about_us': 'আমাদের সম্পর্কে',
    'privacy_policy': 'প্রাইভেসি পলিসি',
    'community': 'কমিউনিটি',
    'share_app': 'বন্ধুদের সাথে শেয়ার করুন',
    'rate_us': 'রেটিং দিন (Rate Us)',
    'support': 'যোগাযোগ ও সাপোর্ট',
    'logout': 'লগআউট',
    'login': 'লগইন করুন',
    'version': 'ভার্সন',
    'current_version': 'বর্তমান ভার্সন',
    
    'app_about': 'অ্যাপ সম্পর্কে',
    'app_config': 'অ্যাপ কনফিগারেশন',
    'push_notification': 'পুশ নোটিফিকেশন',
    'push_notification_desc': 'গুরুত্বপূর্ণ খবরের অ্যালার্ট পান',
    'data_saver': 'ডাটা সেভার মোড',
    'data_saver_desc': 'লো-রেজুলেশন ছবি লোড করে ডাটা বাঁচান',
    'language': 'ভাষা পরিবর্তন (Language)',
    'language_desc': 'বর্তমান ভাষা: বাংলা',
    'clear_cache': 'ক্যাশে ক্লিয়ার করুন',
    'clear_cache_desc': 'অ্যাপের অপ্রয়োজনীয় ডাটা মুছে ফেলুন',
    'system_data': 'সিস্টেম ও ডাটা',
    'force_reload': 'ফোর্স ডাটা রিলোড',
    'force_reload_desc': 'সার্ভার ইনডেক্স থেকে নতুন তথ্য টানুন',
    'server_check': 'সার্ভার ভার্সন চেক',
    'server_check_desc': 'অ্যাপের কোনো আপডেট এসেছে কিনা দেখুন',
    'clear_cache_title': 'ক্যাশে ক্লিয়ার',
    'clear_cache_msg': 'আপনি কি অ্যাপের সব টেম্পোরারি বা ক্যাশে ফাইল মুছে ফেলতে চান? এতে আপনার কোনো ডেটা হারাবে না, তবে অ্যাপ একটু ফার্স্ট হতে পারে।',
    'no': 'না',
    'yes_clear': 'হ্যাঁ, ক্লিয়ার করুন',
    'cache_cleared': 'ক্যাশে সফলভাবে ক্লিয়ার করা হয়েছে! (6.4 MB)',
    'data_reloaded': 'ডাটা সাকসেসফুলি রিলোড করা হয়েছে!',
    'select_language': 'ভাষা নির্বাচন করুন',
  };

  static const Map<String, String> _en = {
    'welcome': 'Welcome!',
    'app_name': 'My Barishal',
    'app_subtitle': 'All information in one place, at your fingertips. Easily find reliable information using this application.',
    'drawer_subtitle': 'The smart guide to Barishal',
    'category_empty': 'No categories in the database!',
    'home': 'Home',
    'admin_title': 'Admin Panel',
    'admin_dashboard': 'Admin Dashboard',
    'others': 'Others',
    'settings': 'Settings',
    'about_us': 'About Us',
    'privacy_policy': 'Privacy Policy',
    'community': 'Community',
    'share_app': 'Share with Friends',
    'rate_us': 'Rate Us',
    'support': 'Contact & Support',
    'logout': 'Logout',
    'login': 'Login',
    'version': 'Version',
    'current_version': 'Current Version',
    
    'app_about': 'About App',
    'app_config': 'App Configuration',
    'push_notification': 'Push Notifications',
    'push_notification_desc': 'Get important news alerts',
    'data_saver': 'Data Saver Mode',
    'data_saver_desc': 'Load low-res images to save data',
    'language': 'Change Language',
    'language_desc': 'Current Language: English',
    'clear_cache': 'Clear Cache',
    'clear_cache_desc': 'Remove temporary app data',
    'system_data': 'System & Data',
    'force_reload': 'Force Data Reload',
    'force_reload_desc': 'Fetch fresh data from server',
    'server_check': 'Check Server Version',
    'server_check_desc': 'See if new app updates are available',
    'clear_cache_title': 'Clear Cache',
    'clear_cache_msg': 'Do you want to clear all temporary or cache files? No data will be lost, but the app might perform better.',
    'no': 'No',
    'yes_clear': 'Yes, Clear',
    'cache_cleared': 'Cache successfully cleared! (6.4 MB)',
    'data_reloaded': 'Data reloaded successfully!',
    'select_language': 'Select Language',
  };

  String t(String key) {
    if (isEnglish) return _en[key] ?? key;
    return _bn[key] ?? key;
  }
}
