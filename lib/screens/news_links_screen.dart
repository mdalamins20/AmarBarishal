import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class NewsLinksScreen extends StatelessWidget {
  const NewsLinksScreen({super.key});

  final List<Map<String, String>> newsChannels = const [
    {
      'title': 'প্রথম আলো - বরিশাল',
      'url': 'https://www.prothomalo.com/topic/%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2',
    },
    {
      'title': 'BD News 24 - বরিশাল',
      'url': 'https://www.news24bd.tv/search?cx=008012374219124743477%3Auymq7nud2js&cof=FORID%3A10&ie=UTF-8&q=%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2',
    },
    {
      'title': 'দ্য ডেইলি স্টার',
      'url': 'https://bangla.thedailystar.net/',
    },
    {
      'title': 'বরিশাল টাইমস',
      'url': 'https://www.barishaltimes.com/',
    },
    {
      'title': 'যুগান্তর - বরিশাল',
      'url': 'https://www.jugantor.com/country-news/barishal',
    },
    {
      'title': 'সমকাল - বরিশাল',
      'url': 'https://samakal.com/whole-country/barishal',
    },
  ];

  void _openNewsLink(BuildContext context, String title, String url) async {
    bool useUrlLauncher = kIsWeb;
    
    // ওয়েব না হলে ডেস্কটপের ক্ষেত্রে ব্রাউজারে খুলবে
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        useUrlLauncher = true;
      }
    }

    if (useUrlLauncher) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('লিংক খোলা যাচ্ছে না: $url')),
          );
        }
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WebViewScreen(title: title, url: url),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
        elevation: 0,
        title: Text('বরিশালের খবর', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF151928), const Color(0xFF283149)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth > 800) ? 4 : (constraints.maxWidth > 500) ? 3 : 2;
              
              return AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: newsChannels.length,
                  itemBuilder: (context, index) {
                    final channel = newsChannels[index];
                    final title = channel['title']!;
                    final url = channel['url']!;
                    
                    // খবরের আইকনের জন্য একটি নির্দিষ্ট সুন্দর রং
                    final Color baseColor = const Color(0xFF512DA8); // Deep Purple
                    final Color iconColor = isDarkMode ? Colors.purpleAccent : Color.lerp(baseColor, Colors.black, 0.45)!;

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      columnCount: crossAxisCount,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: InkWell(
                            onTap: () => _openNewsLink(context, title, url),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    baseColor.withOpacity(isDarkMode ? 0.3 : 0.15),
                                    baseColor.withOpacity(isDarkMode ? 0.1 : 0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: baseColor.withOpacity(isDarkMode ? 0.6 : 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: baseColor.withOpacity(0.15),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: baseColor.withOpacity(isDarkMode ? 0.2 : 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.newspaper_rounded, // সুন্দর নিউজ আইকন
                                          size: 24, 
                                          color: iconColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}