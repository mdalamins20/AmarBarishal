import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/auto_translated_text.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const NewsDetailScreen({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String title = itemData['name'] ?? 'শিরোনাম নেই';
    final String source = itemData['source'] ?? 'অজানা উৎস';
    final String date = itemData['date'] ?? '';
    final String imageUrl = itemData['image_url'] ?? '';
    final String fullNews = itemData['full_news'] ?? itemData['excerpt'] ?? 'বিস্তারিত খবর পাওয়া যায়নি।';
    final String newsUrl = itemData['url'] ?? '';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Header Image
            if (imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDarkMode),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                child: _buildPlaceholder(isDarkMode),
              ),
            
            // Content Container
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and Date Tag
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AutoTranslatedText(
                            source,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (date.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: isDarkMode ? Colors.white54 : Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    AutoTranslatedText(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Full News
                    AutoTranslatedText(
                      fullNews,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Overlay buttons
      Positioned(
        top: 16,
        left: 16,
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      Positioned(
        top: 16,
        right: 16,
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {
              // Share logic could go here
            },
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_rounded,
            size: 64,
            color: isDarkMode ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 8),
          AutoTranslatedText(
            'ছবি পাওয়া যায়নি',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const NewsWebViewScreen({super.key, required this.url, required this.title});

  @override
  State<NewsWebViewScreen> createState() => _NewsWebViewScreenState();
}

class _NewsWebViewScreenState extends State<NewsWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoTranslatedText(widget.title),
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
