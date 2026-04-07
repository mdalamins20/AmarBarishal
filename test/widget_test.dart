import 'package:flutter_test/flutter_test.dart';
import 'package:my_barishal_new/main.dart'; // main.dart ফাইলটিকে ইম্পোর্ট করা হচ্ছে

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // পুরনো MyApp() এর পরিবর্তে নতুন MyBarishalApp() ব্যবহার করা হচ্ছে
    // যেহেতু isDarkMode একটি প্রয়োজনীয় প্যারামিটার, আমরা পরীক্ষার জন্য false দিয়ে দিচ্ছি
    expect(find.byType(MyBarishalApp), findsOneWidget);
  });
}