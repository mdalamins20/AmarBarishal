// lib/screens/news_links_screen.dart

import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/webview_screen.dart'; // WebView স্ক্রিনটি import করা হচ্ছে

class NewsLinksScreen extends StatelessWidget {
  const NewsLinksScreen({super.key});

  // --- এখানে নিউজ চ্যানেলের তালিকা যোগ বা পরিবর্তন করুন ---
  final List<Map<String, String>> newsChannels = const [
    {
      'title': 'প্রথম আলো - বরিশাল বিভাগ',
      'url': 'https://www.prothomalo.com/topic/%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2',
    },
    {
      'title': 'BD News 24 - বরিশাল',
      'url': 'https://www.news24bd.tv/search?cx=008012374219124743477%3Auymq7nud2js&cof=FORID%3A10&ie=UTF-8&q=%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2',
    },
    {
      'title': 'দ্য ডেইলি স্টার (বাংলা)',
      'url': 'https://bangla.thedailystar.net/',
    },
    {
      'title': 'বরিশাল টাইমস',
      'url': 'https://www.barishaltimes.com/',
    },
    // আপনি চাইলে এখানে আরও নিউজ চ্যানেল যোগ করতে পারেন
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বরিশালের খবর'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: newsChannels.length,
        itemBuilder: (context, index) {
          final channel = newsChannels[index];
          final title = channel['title']!;
          final url = channel['url']!;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.article_rounded, color: Colors.blueAccent),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                    title: title,
                    url: url,
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}