import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/category_detail_screen.dart';
import 'package:my_barishal_new/screens/upazila_list_screen.dart';
import 'package:my_barishal_new/screens/news_list_screen.dart';
import 'package:my_barishal_new/screens/sos_list_screen.dart';
import 'package:my_barishal_new/screens/specialist_list_screen.dart';
import '../widgets/auto_translated_text.dart';
import 'global_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:xml/xml.dart';
import 'diagnostic_screen.dart';
import 'all_services_screen.dart';
import 'ticket_providers_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _hospitalCount = '...';
  String _schoolCount = '...';
  String _hotelCount = '...';
  String _emergencyCount = '...';

  List<String> _recentUpdates = [];
  bool _isLoadingUpdates = true;

  String _temperature = '--';
  String _weatherDescription = 'লোড হচ্ছে...';
  String _weatherEmoji = '🌤️';
  String _locationName = 'বরিশাল';

  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final List<String> _bannerImages = [
    'https://res.cloudinary.com/dqmmlwqig/image/upload/v1778841868/kuakata-patuakhai-02_cwo4l8.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/9/90/%E0%A6%A6%E0%A7%81%E0%A6%B0%E0%A7%8D%E0%A6%97%E0%A6%BE%E0%A6%B8%E0%A6%BE%E0%A6%97%E0%A6%B0_%E0%A6%A6%E0%A6%BF%E0%A6%98%E0%A6%BF....jpg',
    'https://vromonguide.com/wp-content/uploads/swarupkathi-guava-floating-market-770x420.jpg',
    'https://objectstorage.ap-dcc-gazipur-1.oraclecloud15.com/n/axvjbnqprylg/b/V2Ministry/o/office-barishal/2024/12/8de562958b6b4c3986333d9891c1fae0.png'
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _fetchNews();
    _fetchWeather();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  String _toBengaliNumber(int number) {
    const englishToBengali = {
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
    };
    return number.toString().split('').map((e) => englishToBengali[e] ?? e).join('');
  }

  Future<void> _loadStats() async {
    final firestore = FirebaseFirestore.instance;
    
    Future<int> getCount(String categoryId) async {
      try {
        final snap = await firestore.collection('categories').doc(categoryId).collection('items').count().get();
        return snap.count ?? 0;
      } catch (e) {
        return 0;
      }
    }

    // Load hospital
    getCount('hospital').then((count) {
      if (mounted) setState(() => _hospitalCount = '${_toBengaliNumber(count)}+');
    });

    // Load school (Concurrent Execution)
    final schoolCategories = ['primarySchool', 'highSchool', 'college', 'university', 'madrasa', 'schoolCollege', 'medical_college', 'engineering_college', 'polytechnic', 'higher_secondary', 'english_medium', 'technical_school', 'drama_school', 'art_school', 'training_institute', 'research_institution', 'special_school'];
    
    Future.wait(schoolCategories.map((cat) => getCount(cat))).then((results) {
      int totalSchool = results.fold(0, (sum, count) => sum + count);
      if (mounted) setState(() => _schoolCount = '${_toBengaliNumber(totalSchool)}+');
    });

    // Load hotel
    getCount('hotel').then((count) {
      if (mounted) setState(() => _hotelCount = '${_toBengaliNumber(count)}+');
    });

    // Load emergency (Concurrent Execution)
    final emergencyCategories = ['police', 'fire_service', 'fireService', 'ambulance'];
    Future.wait(emergencyCategories.map((cat) => getCount(cat))).then((results) {
      int totalEmergency = results.fold(0, (sum, count) => sum + count);
      if (mounted) setState(() => _emergencyCount = '${_toBengaliNumber(totalEmergency)}+');
    });
  }

  Future<void> _fetchNews() async {
    try {
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(Uri.parse('https://news.google.com/rss/search?q=%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2&hl=bn&gl=BD&ceid=BD:bn&_cb=$cacheBuster'));
      if (response.statusCode == 200) {
        // Proper XML Parsing using xml package
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        final news = items.map((node) {
          final titleElement = node.findElements('title').firstOrNull;
          return titleElement?.innerText.trim() ?? '';
        }).where((text) => text.isNotEmpty).toList();
        
        news.shuffle();
        
        if (mounted) {
          setState(() {
            _recentUpdates = news.take(5).toList();
            _isLoadingUpdates = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingUpdates = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUpdates = false);
    }
  }

  Future<void> _fetchWeather() async {
    try {
      double lat = 22.701;
      double lon = 90.353;
      String locName = 'বরিশাল';

      // Check if location permission is granted
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          // Show dialog before requesting permission (UX improvement)
          bool? userConsent = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('লোকেশন পারমিশন প্রয়োজন', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('আপনার আশেপাশের সঠিক আবহাওয়ার তথ্য এবং জরুরি সুবিধাগুলো দেখাতে আমাদের আপনার বর্তমান লোকেশনটি জানা প্রয়োজন। আপনি কি অনুমতি দিচ্ছেন?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('না', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('হ্যাঁ, অনুমতি দিচ্ছি'),
                ),
              ],
            ),
          );

          if (userConsent == true) {
            permission = await Geolocator.requestPermission();
          }
        }
        
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          lat = position.latitude;
          lon = position.longitude;
          locName = 'আপনার অবস্থান'; // Default once we have GPS

          // Attempt to get location name using reverse geocoding
          try {
            final geoResponse = await http.get(
              Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=bn'),
            );
            if (geoResponse.statusCode == 200) {
              final geoData = json.decode(geoResponse.body);
              String? name = geoData['city'] ?? geoData['locality'] ?? geoData['principalSubdivision'];
              if (name != null && name.isNotEmpty) {
                locName = name.replaceAll(' বিভাগ', '').replaceAll(' জেলা', '');
              }
            }
          } catch (e) {
            // keep 'আপনার অবস্থান'
          }
        }
      }

      final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,is_day,cloud_cover&timezone=auto'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final temp = current['temperature_2m'].round().toString();
        final code = current['weather_code'] as int;
        final isDay = current['is_day'] as int;
        final cloudCover = current['cloud_cover'] as int;
        
        String desc = isDay == 1 ? 'পরিষ্কার আকাশ' : 'পরিষ্কার রাত';
        String emoji = isDay == 1 ? '☀️' : '🌙';
        
        // Smart override for tropical inaccuracies (API says rain but it's sunny)
        if (isDay == 1 && cloudCover < 50 && code >= 50) {
          desc = cloudCover < 20 ? 'রৌদ্রোজ্জ্বল' : 'আংশিক মেঘলা';
          emoji = cloudCover < 20 ? '☀️' : '🌤️';
        } else {
          if (code == 1 || code == 2) { desc = 'আংশিক মেঘলা'; emoji = isDay == 1 ? '🌤️' : '☁️'; }
          else if (code == 3) { desc = 'মেঘলা'; emoji = '☁️'; }
          else if (code >= 45 && code <= 48) { desc = 'কুয়াশা'; emoji = '🌫️'; }
          else if (code >= 51 && code <= 55) { desc = 'গুড়ি গুড়ি বৃষ্টি'; emoji = '🌧️'; }
          else if (code >= 61 && code <= 65) { desc = 'বৃষ্টি'; emoji = '☔'; }
          else if (code >= 71 && code <= 77) { desc = 'তুষারপাত'; emoji = '❄️'; }
          else if (code >= 80 && code <= 82) { desc = 'ভারী বৃষ্টি'; emoji = '🌧️'; }
          else if (code >= 95) { desc = 'বজ্রসহ বৃষ্টি'; emoji = '⛈️'; }
        }
        
        if (mounted) {
          setState(() {
            _temperature = '${_toBengaliNumber(int.parse(temp))}°C';
            _weatherDescription = desc;
            _weatherEmoji = emoji;
            _locationName = locName;
          });
        }
      }
    } catch (e) {
      // Ignored for now, UI handles empty state
    }
  }

  Future<void> _refreshAll() async {
    // Reset state for loading indicators if needed
    if (mounted) {
      setState(() {
        _isLoadingUpdates = true;
      });
    }
    await Future.wait([
      _loadStats(),
      _fetchNews(),
      _fetchWeather(),
    ]);
  }

  void _onCategoryTap(String categoryId, String categoryName) {
    if (categoryName == "উপজেলা পরিচিতি" || categoryId == 'upazila') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpazilaListScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else if (categoryId == 'news' || categoryName == 'পত্রিকা') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsListScreen(
        sourceId: 'all',
        sourceName: 'সকল খবর',
        color: Color(0xFF0F4C81),
      )));
    } else if (categoryId == 'sos') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SosListScreen()));
    } else if (categoryId == 'doctor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistListScreen(categoryTitle: categoryName, categoryDocId: categoryId)));
    } else if (categoryId == 'diagnostic') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(categoryTitle: categoryName, categoryDocId: categoryId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0F4C81);
    const secondaryColor = Color(0xFF22A699);
    const accentColor = Color(0xFFFF6B35);
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            slivers: [
            // Custom App Bar with Header Banner
            SliverToBoxAdapter(
              child: _buildHeaderBanner(context, isDarkMode, primaryColor),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(isDarkMode, primaryColor),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: _buildQuickStats(isDarkMode, primaryColor, secondaryColor, accentColor),
            ),

            // Emergency Services (জরুরি সেবা)
            SliverToBoxAdapter(
              child: _buildEmergencySection(isDarkMode, accentColor),
            ),

            // Categorized Services (সকল সেবা)
            SliverToBoxAdapter(
              child: _buildAllServicesSection(isDarkMode, primaryColor, secondaryColor),
            ),

            // Latest Updates (সাম্প্রতিক আপডেট)
            SliverToBoxAdapter(
              child: _buildRecentUpdates(isDarkMode, primaryColor),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FAB
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Transform.scale(
                  key: ValueKey<int>(_currentBannerIndex),
                  scale: 1.15, // Zoom to hide watermarks
                  child: Image.network(
                    _bannerImages[_currentBannerIndex],
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      (isDarkMode ? const Color(0xFF1E293B) : primaryColor).withValues(alpha: 0.95),
                      (isDarkMode ? const Color(0xFF1E293B) : primaryColor).withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Widget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_weatherEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          _locationName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _temperature,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      _weatherDescription,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Theme Toggle using ThemeProvider
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
                          (themeProvider.themeMode == ThemeMode.system &&
                              MediaQuery.of(context).platformBrightness == Brightness.dark);
                      return IconButton(
                        icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                        onPressed: () {
                          themeProvider.toggleTheme(isDarkMode);
                        },
                      );
                    },
                  ),
                  // Settings Icon
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AutoTranslatedText(
            'আমার বরিশাল',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          AutoTranslatedText(
            'বরিশালের সকল তথ্য এক জায়গায়',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate(isDarkMode: isDarkMode, primaryColor: primaryColor),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'হাসপাতাল, থানা, ডাক্তার, হোটেল খুঁজুন...',
                    style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDarkMode, Color primary, Color secondary, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('হাসপাতাল', _hospitalCount, Icons.local_hospital, primary, isDarkMode),
          _buildStatCard('স্কুল', _schoolCount, Icons.school, secondary, isDarkMode),
          _buildStatCard('হোটেল', _hotelCount, Icons.hotel, primary, isDarkMode),
          _buildStatCard('জরুরি', _emergencyCount, Icons.emergency, accent, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, bool isDarkMode) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AutoTranslatedText(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          AutoTranslatedText(title, style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(bool isDarkMode, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('জরুরি সেবা', isDarkMode),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceButton('অ্যাম্বুলেন্স', Icons.emergency_share, accentColor, () => _onCategoryTap('ambulance', 'অ্যাম্বুলেন্স'), isDarkMode),
              _buildServiceButton('পুলিশ', Icons.local_police, accentColor, () => _onCategoryTap('police', 'পুলিশ ও থানা'), isDarkMode),
              _buildServiceButton('ফায়ার সার্ভিস', Icons.fire_truck, accentColor, () => _onCategoryTap('fire_service', 'ফায়ার সার্ভিস'), isDarkMode),
              _buildServiceButton('জরুরি কল', Icons.sos_rounded, accentColor, () => _onCategoryTap('sos', 'জরুরি কল'), isDarkMode),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAllServicesSection(bool isDarkMode, Color primaryColor, Color secondaryColor) {
    final topServices = [
      {'id': 'hospital', 'name': 'হাসপাতাল', 'icon': Icons.local_hospital, 'color': secondaryColor},
      {'id': 'doctor', 'name': 'ডাক্তার', 'icon': Icons.health_and_safety, 'color': secondaryColor},
      {'id': 'diagnostic', 'name': 'ডায়াগনস্টিক', 'icon': Icons.biotech, 'color': secondaryColor},
      {'id': 'busTicket', 'name': 'বাসের টিকেট', 'icon': Icons.directions_bus, 'color': const Color(0xFFFF6B35)},
      {'id': 'news', 'name': 'পত্রিকা', 'icon': Icons.newspaper, 'color': primaryColor},
      {'id': 'college', 'name': 'শিক্ষা', 'icon': Icons.account_balance, 'color': primaryColor},
      {'id': 'hotel', 'name': 'হোটেল', 'icon': Icons.hotel, 'color': const Color(0xFF8E24AA)},
      {'id': 'all', 'name': 'সকল সেবা', 'icon': Icons.grid_view, 'color': const Color(0xFF0F4C81)},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('শীর্ষ সেবা', isDarkMode),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: topServices.length,
            itemBuilder: (context, index) {
              final item = topServices[index];
              return _buildSmallServiceButton(
                item['name'] as String, 
                item['icon'] as IconData, 
                item['color'] as Color, 
                () {
                  if (item['id'] == 'all') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllServicesScreen()));
                  } else if (item['id'] == 'busTicket') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TicketProvidersScreen()));
                  } else {
                    _onCategoryTap(item['id'] as String, item['name'] as String);
                  }
                }, 
                isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmallServiceButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AutoTranslatedText(
                title, 
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDarkMode, {bool isLarge = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 75 : null,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            AutoTranslatedText(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUpdates(bool isDarkMode, Color primaryColor) {
    if (_isLoadingUpdates) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_recentUpdates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('সাম্প্রতিক আপডেট', isDarkMode),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentUpdates.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.newspaper, color: primaryColor, size: 20),
                  ),
                  title: AutoTranslatedText(
                    _recentUpdates[index],
                    style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDarkMode) {
    return AutoTranslatedText(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}