import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/auto_translated_text.dart';
import 'item_detail_screen.dart';
import 'upazila_detail_screen.dart';
import 'fire_service_detail_screen.dart';
import 'hospital_detail_screen.dart';
import 'school_detail_screen.dart';
import 'package:my_barishal_new/screens/library_detail_screen.dart';
import 'ambulance_detail_screen.dart';
import 'news_detail_screen.dart';
import 'hotel_detail_screen.dart';
import 'police_thana_list_screen.dart';
import 'palli_bidyut_screen.dart';
import 'palli_bidyut_1_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Removed PercentageLoader since data comes quickly from database

class CategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDocId;
  final String? upazilaDocId;
  final String? schoolType;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDocId,
    this.upazilaDocId,
    this.schoolType,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  DateTime? _selectedDate;

  late Stream<QuerySnapshot> _itemsStream;
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    var collectionRef = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);
    if (widget.upazilaDocId != null) {
      collectionRef = collectionRef.collection('upazilas').doc(widget.upazilaDocId);
    }
    Query itemsQuery = collectionRef.collection('items');
    if (widget.schoolType != null) {
      itemsQuery = itemsQuery.where('type', isEqualTo: widget.schoolType);
    }
    _itemsStream = itemsQuery.snapshots();
    _newsFuture = _fetchNewsApi();
  }

  Future<List<Map<String, dynamic>>> _fetchNewsApi() async {
    try {
      String url = 'http://192.168.0.246:8000/api/news';
      if (_selectedDate != null) {
        final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
        url += '?date=$dateStr';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching news api: $e");
    }
    return [];
  }

  bool get _isNewspaperCategory {
    final docId = widget.categoryDocId.toLowerCase();
    final title = widget.categoryTitle;
    return docId == 'newspaper' || docId == 'news' || title.contains('খবর') || title.contains('পত্রিকা');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি সত্যিই এই তথ্য মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('না')),
          TextButton(
            onPressed: () {
              var ref = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);
              if (widget.upazilaDocId != null) {
                ref = ref.collection('upazilas').doc(widget.upazilaDocId);
              }
              ref.collection('items').doc(docId).delete();
              Navigator.of(ctx).pop();
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: isDarkMode ? Colors.white30 : Colors.black26),
          const SizedBox(height: 16),
          AutoTranslatedText('কোনো তথ্য পাওয়া যায়নি', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    if (widget.categoryDocId != 'schoolCollege') return const SizedBox.shrink();
    
    final filters = [
      {'id': 'all', 'label': 'সব'},
      {'id': 'প্রাথমিক স্কুল', 'label': 'প্রাথমিক স্কুল'},
      {'id': 'হাই স্কুল', 'label': 'হাই স্কুল'},
      {'id': 'কলেজ', 'label': 'কলেজ'},
      {'id': 'মাদ্রাসা', 'label': 'মাদ্রাসা'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter['id']!;
                  });
                }
              },
              selectedColor: isDarkMode ? Colors.blueAccent.withOpacity(0.5) : Colors.blue.shade100,
              backgroundColor: isDarkMode ? Colors.white10 : Colors.white70,
              labelStyle: TextStyle(
                color: isSelected 
                    ? (isDarkMode ? Colors.white : Colors.blue.shade900) 
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item, bool isDarkMode, BuildContext context) {
    final title = item['name'] ?? 'শিরোনাম নেই';
    final source = item['source'] ?? '';
    final date = item['date'] ?? '';
    final imageUrl = item['image_url'] ?? '';
    final hasImage = imageUrl.toString().isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(itemData: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AutoTranslatedText(
                          source,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 12, color: isDarkMode ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white54 : Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AutoTranslatedText(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: isDarkMode ? Colors.white : Colors.black87,
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

  Widget _buildHotelCard(Map<String, dynamic> item, bool isDarkMode, BuildContext context) {
    final name = item['name'] ?? 'নাম নেই';
    final address = item['address'] ?? 'ঠিকানা নেই';
    final price = item['price_per_night'] ?? '';
    final rating = item['rating']?.toString() ?? 'N/A';
    final imageUrl = item['image_url'] ?? '';
    final hasImage = imageUrl.toString().isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotelData: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 180,
                    width: double.infinity,
                    color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                    child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AutoTranslatedText(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> itemsList, bool isDarkMode) {
    final filteredItems = itemsList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      final type = item['type']?.toString();
      final typeMatch = _selectedFilter == 'all' || type == _selectedFilter;
      final nameMatch = name.contains(searchLower);
      return typeMatch && nameMatch;
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(child: AutoTranslatedText('আপনার সার্চের সাথে মিলে এমন কোনো তথ্য নেই', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final headmaster = item['headmaster'] ?? 'তথ্য নেই';

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _isNewspaperCategory 
                  ? _buildNewsCard(item, isDarkMode, context)
                  : widget.categoryDocId == 'hotel'
                      ? _buildHotelCard(item, isDarkMode, context)
                      : Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDarkMode 
                        ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                        : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
                    ),
                    border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        leading: _isNewspaperCategory && item['image_url'] != null && item['image_url'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image_url'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.newspaper_rounded, size: 40),
                              ),
                            )
                          : null,
                        title: AutoTranslatedText(item['name'] ?? 'নাম নেই',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black87)),
                        subtitle: widget.categoryDocId == 'library'
                            ? AutoTranslatedText("${item['officer'] ?? 'কর্মকর্তা'}\n${item['address'] ?? ''}",
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54))
                            : ['primarySchool', 'highSchool', 'college', 'university', 'madrasa', 'schoolCollege'].contains(widget.categoryDocId)
                            ? AutoTranslatedText("প্রধান শিক্ষক: $headmaster\nমোবাইল: ${item['mobile'] ?? 'নাই'}",
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54))
                            : widget.categoryDocId == 'hospital'
                                ? AutoTranslatedText("তথ্য প্রদানকারী: ${item['provider_name'] ?? 'নাই'} (${item['provider_designation'] ?? 'পদবী নেই'})\nমোবাইল: ${item['mobile'] ?? 'নাই'}",
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54))
                                : null,
                        onTap: () {
                          if (widget.categoryDocId == 'electricity' && item['isPalliBidyut'] == true) {
                            if (item['name'] == 'বরিশাল পল্লী বিদ্যুৎ সমিতি-১') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PalliBidyut1Screen(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PalliBidyutScreen(),
                                ),
                              );
                            }
                          } else if (widget.categoryDocId == 'police' && item['type'] == 'উপজেলা') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PoliceThanaListScreen(upazilaData: item),
                              ),
                            );
                          } else if (item['type'] == 'উপজেলা') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UpazilaDetailScreen(upazilaData: item),
                              ),
                            );
                          } else if (widget.categoryDocId == 'fire_service') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FireServiceDetailScreen(itemData: item),
                              ),
                            );
                          } else if (widget.categoryDocId == 'hospital') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HospitalDetailScreen(itemData: item),
                              ),
                            );
                          } else if (['primarySchool', 'highSchool', 'college', 'university', 'madrasa', 'schoolCollege'].contains(widget.categoryDocId)) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SchoolDetailScreen(itemData: item),
                              ),
                            );
                          } else if (widget.categoryDocId == 'ambulance') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AmbulanceDetailScreen(itemData: item),
                              ),
                            );
                          } else if (widget.categoryDocId == 'library') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LibraryDetailScreen(itemData: item),
                              ),
                            );
                          } else if (widget.categoryDocId == 'hotel') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HotelDetailScreen(hotelData: item),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetailScreen(
                                      itemData: item,
                                      categoryId: widget.categoryDocId,
                                    ),
                              ),
                            );
                          }
                        },
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
        title: AutoTranslatedText(widget.categoryTitle, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
          child: widget.categoryDocId == 'electricity' 
              ? _buildElectricityLayout(isDarkMode)
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isNewspaperCategory ? Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                            _newsFuture = _fetchNewsApi();
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoTranslatedText(
                              _selectedDate == null 
                                  ? 'যেকোনো তারিখের খবর খুঁজুন...' 
                                  : 'নির্বাচিত তারিখ: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null ? (isDarkMode ? Colors.white70 : Colors.black54) : (isDarkMode ? Colors.white : Colors.black87),
                                fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.calendar_month_rounded, color: isDarkMode ? Colors.white70 : Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                ) : Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      label: AutoTranslatedText('এখানে সার্চ করুন...', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                      prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              _buildFilterChips(isDarkMode),
              Expanded(
                child: _isNewspaperCategory
                  ? FutureBuilder<List<Map<String, dynamic>>>(
                      future: _newsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: AutoTranslatedText('একটি সমস্যা হয়েছে: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState(isDarkMode);
                        }
                        return _buildListView(snapshot.data!, isDarkMode);
                      },
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _itemsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink(); // No loading screen as requested
                        }
                        if (snapshot.hasError) {
                          return Center(child: AutoTranslatedText('একটি সমস্যা হয়েছে: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                        }
                        var items = snapshot.hasData ? snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList() : <Map<String, dynamic>>[];
                        
                        if (items.isEmpty) {
                          return _buildEmptyState(isDarkMode);
                        }
                        
                        return _buildListView(items, isDarkMode);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildElectricityLayout(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildElectricityCard(
                  'বরিশাল পল্লী বিদ্যুৎ সমিতি-১',
                  Icons.electric_bolt_rounded,
                  isDarkMode,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PalliBidyut1Screen())),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimationConfiguration.staggeredList(
            position: 1,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildElectricityCard(
                  'বরিশাল পল্লী বিদ্যুৎ সমিতি-২',
                  Icons.power_rounded,
                  isDarkMode,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PalliBidyutScreen())),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricityCard(String title, IconData icon, bool isDarkMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [Colors.blueAccent.withOpacity(0.15), Colors.purpleAccent.withOpacity(0.15)]
                : [Colors.blue.shade50.withOpacity(0.9), Colors.purple.shade50.withOpacity(0.9)],
          ),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Icon(icon, size: 40, color: isDarkMode ? Colors.blueAccent : Colors.blue),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}