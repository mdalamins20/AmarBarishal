import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_barishal_new/screens/webview_screen.dart';
import '../widgets/auto_translated_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class NewsLinksScreen extends StatelessWidget {
  const NewsLinksScreen({super.key});

  void _openNewsLink(BuildContext context, String title, String url) async {
    bool useUrlLauncher = kIsWeb;
    
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
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        title: AutoTranslatedText('বরিশালের খবর', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('news_links').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: AutoTranslatedText('কোনো পত্রিকা পাওয়া যায়নি!'));
              }

              final newsDocs = snapshot.data!.docs;

              return LayoutBuilder(
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
                      itemCount: newsDocs.length,
                      itemBuilder: (context, index) {
                        final data = newsDocs[index].data() as Map<String, dynamic>;
                        final title = data['title'] ?? 'সংবাদপত্র';
                        final url = data['url'] ?? '';
                        
                        const Color baseColor = Color(0xFF512DA8);
                        final Color iconColor = isDarkMode ? Colors.purpleAccent : Color.lerp(baseColor, Colors.black, 0.45)!;

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          columnCount: crossAxisCount,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: InkWell(
                                onTap: () {
                                  if (url.toString().isNotEmpty) {
                                    _openNewsLink(context, title, url);
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        baseColor.withValues(alpha: isDarkMode ? 0.3 : 0.15),
                                        baseColor.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: baseColor.withValues(alpha: isDarkMode ? 0.6 : 0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: baseColor.withValues(alpha: 0.15),
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
                                              color: baseColor.withValues(alpha: isDarkMode ? 0.2 : 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.newspaper_rounded,
                                              size: 24, 
                                              color: iconColor,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: AutoTranslatedText(
                                              title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
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
              );
            },
          ),
        ),
      ),
    );
  }
}