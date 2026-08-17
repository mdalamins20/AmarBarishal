import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'news_list_screen.dart';
import '../widgets/auto_translated_text.dart';
import 'dart:ui';

class NewsSourceScreen extends StatelessWidget {
  const NewsSourceScreen({super.key});

  final List<Map<String, String>> sources = const [
    {'id': 'prothom_alo', 'name': 'প্রথম আলো', 'logoUrl': 'https://www.google.com/s2/favicons?domain=prothomalo.com&sz=128', 'logo': 'P', 'color': '#0083C5'},
    {'id': 'jugantor', 'name': 'যুগান্তর', 'logoUrl': 'https://www.google.com/s2/favicons?domain=jugantor.com&sz=128', 'logo': 'J', 'color': '#D32F2F'},
    {'id': 'jagonews24', 'name': 'জাগো নিউজ ২৪', 'logoUrl': 'https://cdn.jagonews24.com/media/common/logo.png', 'logo': 'J24', 'color': '#C2185B'},
    {'id': 'daily_star', 'name': 'ডেইলি স্টার', 'logoUrl': 'https://www.google.com/s2/favicons?domain=thedailystar.net&sz=128', 'logo': 'DS', 'color': '#1976D2'},
    {'id': 'kaler_kantho', 'name': 'কালের কণ্ঠ', 'logoUrl': 'https://www.google.com/s2/favicons?domain=kalerkantho.com&sz=128', 'logo': 'K', 'color': '#388E3C'},
    {'id': 'naya_diganta', 'name': 'নয়া দিগন্ত', 'logoUrl': 'https://www.google.com/s2/favicons?domain=dailynayadiganta.com&sz=128', 'logo': 'N', 'color': '#F57C00'},
    {'id': 'barishal_news', 'name': 'বরিশাল নিউজ', 'logoUrl': 'https://www.google.com/s2/favicons?domain=barishalnews.com&sz=128', 'logo': 'BN', 'color': '#455A64'},
    {'id': 'barishal_times', 'name': 'বরিশাল টাইমস', 'logoUrl': 'https://www.google.com/s2/favicons?domain=barishaltimes.com&sz=128', 'logo': 'BT', 'color': '#512DA8'},
    {'id': 'barishal_crime_news', 'name': 'বরিশাল ক্রাইম নিউজ', 'logoUrl': 'https://www.google.com/s2/favicons?domain=barishalcrimenews.com&sz=128', 'logo': 'BCN', 'color': '#E64A19'},
  ];

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
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
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        title: AutoTranslatedText('পত্রিকা বাছাই করুন', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
          child: AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                final baseColor = _getColorFromHex(source['color']!);

                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    scale: 0.9,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsListScreen(
                                sourceId: source['id']!,
                                sourceName: source['name']!,
                                color: baseColor,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                baseColor.withValues(alpha: isDarkMode ? 0.9 : 0.8),
                                baseColor.withValues(alpha: isDarkMode ? 0.6 : 0.5),
                              ],
                            ),
                            border: Border.all(color: Colors.white24, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 70,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Image.network(
                                  source['logoUrl']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        source['logo']!,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: baseColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AutoTranslatedText(
                                  source['name']!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
