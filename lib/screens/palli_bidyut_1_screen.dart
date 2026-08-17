import 'package:flutter/material.dart';

class PalliBidyut1Screen extends StatelessWidget {
  const PalliBidyut1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বরিশাল পল্লী বিদ্যুৎ সমিতি-১'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 16),
            _buildSectionHeader('সংক্ষিপ্ত প্রশাসনিক ও আর্থিক তথ্যাবলী (ফেব্রুয়ারি-২০২৬ খ্রি:)', primaryColor, context),
            const SizedBox(height: 16),
            _buildGeneralTable(isDarkMode),
            const SizedBox(height: 32),
            
            _buildSectionHeader('সমিতির সংযোগ সৃষ্টির গ্রাহক শ্রেণী বিন্যাস (ফেব্রুয়ারি- ২০২৬ খ্রি: পর্যন্ত)', primaryColor, context),
            const SizedBox(height: 16),
            _buildCustomerCategoryTable(isDarkMode),
            const SizedBox(height: 32),
            
            _buildSectionHeader('শ্রেণী ভিত্তিক বিলকৃত গ্রাহকদের শতকরা হার ও শতকরা বিদ্যুৎ ব্যবহার (ফেব্রুয়ারি-২০২৬ খ্রি:)', primaryColor, context),
            const SizedBox(height: 16),
            _buildUsagePercentageTable(isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        Text(
          'বরিশাল পল্লী বিদ্যুৎ সমিতি-১\nরুপাতলী, বরিশাল।',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGeneralTable(bool isDarkMode) {
    final data = [
      ['নিবন্ধনের তারিখ', '১৬-০৪-১৯৯০ ইং।'],
      ['আনুষ্ঠানিক বিদ্যুতায়নের তারিখ', '০১-০৯-১৯৯০ ইং।'],
      ['প্রকল্পের নাম', 'আই, ডি, এ-৩ (ক)'],
      ['অন্তর্ভুক্ত উপজেলা', '০৫ টি (বরিশাল সদর, বাকেরগঞ্জ, হিজলা, মুলাদী ও মেহেন্দিগঞ্জ)'],
      ['আয়তন', '১,৯১২ বর্গ কিলোমিটার'],
      ['সমিতির এলাকার সংখ্যা', '০৭ টি'],
      ['এলাকা পরিচালক ও মহিলা পরিচালকের সংখ্যা', '০৭ (১+৩+৩) জন'],
      ['আওতাভুক্ত ইউনিয়ন', '৫১ টি'],
      ['বিদ্যুতায়িত ইউনিয়ন ও পৌরসভার সংখ্যা', '৫১ টি ও ০৪টি'],
      ['অন্তর্ভুক্ত গ্রাম', '৬৮৬ টি'],
      ['বিদ্যুতায়িত গ্রাম', '৬৮৬ টি'],
      ['নির্মিত লাইন', '৭০৮৬.১৮৬ কিলোমিটার'],
      ['বিদ্যুতায়িত লাইন', '৭০৮৫.২০২ কিলোমিটার'],
      ['মোট গ্রাহক সংখ্যা', '৩,৮০,৩৪০ জন'],
      ['বিদ্যুতায়িত বিতরণ ট্রান্সফরমার এর সংখ্যা', '১২,১২৬ টি'],
      ['মাসিক গড় ক্রয় (কিঃ ওঃ ঘঃ)', '২,৭৭,৯৩,৮৬৪ কিঃ ওঃ ঘঃ'],
      ['মাসিক গড় বিক্রয় (কিঃ ওঃ ঘঃ)', '২,৪৯,৩৭,০৫৪ কিঃ ওঃ ঘঃ'],
      ['মাসিক গড় বিক্রয় (টাকা)', '১৯,৮৯,২৩,২৭৭ টাকা'],
      ['মাসিক গড় আদায় (টাকা)', '২০,২২,০৯,১০৯ টাকা'],
      ['পরিচালন আয় (বিক্রয়) প্রতি কিঃ ওঃ ঘঃ', '৭.৯৮ টাকা'],
      ['পরিচালন আয় (অন্যান্য) প্রতি কিঃ ওঃ ঘঃ', '০.২৯ টাকা'],
      ['মোট পরিচালন আয় প্রতি কিঃ ওঃ ঘঃ (২০+২১)', '৮.২৭ টাকা'],
      ['মোট পরিচালন ব্যয় (ক্রস সাবসিডি সহ)', '৯.০৮ টাকা'],
      ['মোট পরিচালন ব্যয় (ক্রস সাবসিডি ব্যতীত)', '১১.০৮ টাকা'],
      ['পরিচালন মার্জিন (ক্রস সাবসিডি সহ)', '(০.৮১) টাকা'],
      ['পরিচালন মার্জিন (ক্রস সাবসিডি ব্যতীত)', '(২.৮১) টাকা'],
      ['নন-অপারেটিং আয় প্রতি (আদায়+সুদ) (কিঃ ওঃ ঘঃ)', '০.৫১ টাকা'],
      ['বিদ্যুৎ ক্রয় মূল্য প্রতি কিঃ ওঃ ঘঃ', '৬.৫৪৬৯ টাকা'],
      ['কর্মকর্তা/কর্মচারীদের মাসিক বেতন-ভাতাদি', '১ কোটি ৮০ লক্ষ'],
      ['বিতরণ খরচ (পরিচালন ও রক্ষণাবেক্ষণ) প্রতি কিঃ ওঃ ঘঃ', '০.৪৬ টাকা'],
      ['গ্রাহক খাতে ব্যয় প্রতি কিঃ ওঃ ঘঃ', '০.৫০ টাকা'],
      ['প্রশাসনিক ও সাধারণ ব্যয় প্রতি কিঃ ওঃ ঘঃ', '০.৪১ টাকা'],
      ['দীর্ঘ মেয়াদী লোন', '৬ শত ৬৯ কোটি'],
      ['ব্যবহার উপযোগী চালু সম্পত্তি', '৫ শত ৩৬ কোটি'],
      ['মোট বিনিয়োগ', '১ শত ৫২ কোটি'],
      ['বকেয়া মাস', '১.২৫ (লক্ষ্যমাত্রা-১.০৫)'],
      ['সিস্টেম লস (বিলিং মিটার)', '১০.২৮ % (লক্ষ্যমাত্রা-১০%)'],
      ['জোনাল অফিসের সংখ্যা', '০৩ টি (মুলাদী, বাকেরগঞ্জ ও মেহেন্দিগঞ্জ)'],
      ['সাব জোনাল অফিসের সংখ্যা', '০১ টি (হিজলা)'],
      ['এরিয়া অফিসের সংখ্যা', '০৩ টি (সাহেবেরহাট, চরমদ্দি ও কাজিরহাট)'],
      ['অভিযোগ কেন্দ্রের সংখ্যা', '২৫ টি।\nক) সদর দপ্তর অফিস আওতাধীনঃ- সদর দপ্তর, কড়াপুর, ছয়মাইল (কলসগ্রাম), কামারখালী, বুখাইনগর, চরকাউয়া, চরবাড়ীয়া।\nখ) মুলাদী জোনাল অফিস আওতাধীনঃ- মুলাদী, নাজিরপুর, চরপদ্মা, সোনামুদ্দি বন্দর, রহমানের হাট।\nগ) বাকেরগঞ্জ জোনাল অফিস আওতাধীনঃ- বাকেরগঞ্জ, কলসকাঠী, মহেশপুর, পেয়াপুর, সেনেরহাট, নলুয়া, পাদ্রিশিবপুর।\nঘ) মেহেন্দিগঞ্জ জোনাল অফিস আওতাধীনঃ- মেহেন্দিগঞ্জ, মাস্টারহাট, জাঙ্গালিয়া।\nঙ) হিজলা সাব-জোনাল অফিস আওতাধীনঃ হিজলা, কাউরিয়া, মেমানিয়া।'],
      ['উপকেন্দ্রের সংখ্যা ও ক্ষমতা', '১১ টি।\nক) সদর দপ্তর অফিস আওতাধীনঃ বরিশাল সদর ১-১০ এমভিএ, বরিশাল সদর ২-১০ এমভিএ, বরিশাল সদর ৩-১০ এমভিএ, বন্দর ১-২০ এমভিএ।\nখ) মুলাদী জোনাল অফিস আওতাধীনঃ মুলাদী-২০ এমভিএ,\nগ) বাকেরগঞ্জ জোনাল অফিস আওতাধীনঃ বাকেরগঞ্জ ১-২০ এমভিএ, বাকেরগঞ্জ ২-১০ এমভিএ, বাকেরগঞ্জ ৩ - ১০ এমভিএ,\nঘ) মেহেন্দিগঞ্জ জোনাল অফিস আওতাধীনঃ মেহেন্দিগঞ্জ ১-২০ এমভিএ\nঙ) হিজলা সাব-জোনাল অফিস আওতাধীনঃ হিজলা ১-১৫ এমভিএ, হিজলা ২-১০ এমভিএ, সর্বমোট= ১৬০ এমভিএ'],
      ['মোট চাহিদা (পিক)', '৮৫ মেঃওঃ'],
      ['কর্মকর্তা/কর্মচারীর সংখ্যা', '৫২৬ জন (কর্মকর্তা-১৬ জন, কর্মচারী- ৫১০ জন)'],
      ['আবাসিক সংযোগ প্রদানে ২(কর্ম দিবসে) ডিমান্ড নোট ইস্যু', 'লক্ষ্যমাত্রা: ১০০%\nঅর্জন: ১০০%'],
      ['২(কর্ম দিবসে) আবাসিক সংযোগ প্রদান (ডিমান্ড নোটের অর্থ জমা হওয়ার পর)', 'লক্ষ্যমাত্রা: ১০০%\nঅর্জন: ১০০%'],
      ['১১ কেভি ও তদুর্ধ্ব ভোল্টেজের বিদ্যুৎ সংযোগ প্রদানের ডিমান্ড নোট ইস্যু', 'লক্ষ্যমাত্রা: ১০০%\nঅর্জন: ১০০%'],
      ['১১ কেভি ও তদুর্ধ্ব ভোল্টেজের বিদ্যুৎ সংযোগ প্রদান', 'লক্ষ্যমাত্রা: ১০০%\nঅর্জন: ১০০%'],
    ];

    return _buildCustomTable(
      headers: ['ক্র: নং', 'বিষয়', 'বিবরণ'],
      data: data,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildCustomerCategoryTable(bool isDarkMode) {
    final data = [
      ['আবাসিক', '৩,৪১,৭৯২ জন'],
      ['বাণিজ্যিক', '২৯,২৯৫ জন'],
      ['শিল্প', '১,৪০২ জন'],
      ['সেচ', '৩৬৭ জন'],
      ['অটো চার্জিং', '৬৯ জন'],
      ['দাতব্য প্রতিষ্ঠান', '৪,৭৭৯ জন'],
      ['অন্যান্য', '২,৬৩৬ জন'],
    ];

    return _buildCustomTable(
      headers: ['ধরন', 'গ্রাহক সংখ্যা'],
      data: data,
      isDarkMode: isDarkMode,
      footer: ['মোট', '৩,৮০,৩৪০ জন'],
      showSerialNo: false,
    );
  }

  Widget _buildUsagePercentageTable(bool isDarkMode) {
    final data = [
      ['আবাসিক', '৯০.০০%', '৮০.৩%'],
      ['বাণিজ্যিক', '০৮%', '৯.৮০%'],
      ['শিল্প', '০.৩৬%', '৬.৯০%'],
      ['দাতব্য প্রতিষ্ঠান', '১.২৫%', '১.৫%'],
      ['অন্যান্য', '০.৬৯%', '১.৫%'],
    ];

    return _buildCustomTable(
      headers: ['ধরন', 'শতকরা গ্রাহক সংখ্যা', 'শতকরা বিদ্যুৎ ব্যবহার'],
      data: data,
      isDarkMode: isDarkMode,
      footer: ['মোট', '১০০%', '১০০%'],
      showSerialNo: false,
    );
  }

  Widget _buildCustomTable({
    required List<String> headers,
    required List<List<String>> data,
    required bool isDarkMode,
    List<String>? footer,
    bool showSerialNo = true,
  }) {
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final headerColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder.symmetric(inside: BorderSide(color: borderColor)),
        columnWidths: {
          0: showSerialNo ? const IntrinsicColumnWidth() : const FlexColumnWidth(),
          for (int i = 1; i < headers.length; i++) i: const FlexColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: headerColor),
            children: headers.map((h) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )).toList(),
          ),
          ...List.generate(data.length, (index) {
            final row = data[index];
            return TableRow(
              children: [
                if (showSerialNo)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _convertToBengaliNumber((index + 1).toString()),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...row.map((cell) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(cell),
                )),
              ],
            );
          }),
          if (footer != null)
            TableRow(
              decoration: BoxDecoration(color: headerColor),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    footer[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    footer[1],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: showSerialNo ? TextAlign.left : TextAlign.center,
                  ),
                ),
                if (footer.length > 2)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      footer[2],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            )
        ],
      ),
    );
  }

  String _convertToBengaliNumber(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    
    String result = number;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }
}
