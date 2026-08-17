import 'package:flutter/material.dart';

class PalliBidyutScreen extends StatelessWidget {
  const PalliBidyutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বরিশাল পল্লী বিদ্যুৎ সমিতি-২'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('এক নজরে বরিশাল পল্লী বিদ্যুৎ সমিতি-২', primaryColor, context),
            const SizedBox(height: 16),
            _buildGeneralTable(isDarkMode),
            const SizedBox(height: 32),
            
            _buildSectionHeader('শ্রেণীভিত্তিক গ্রাহক সংখ্যা', primaryColor, context),
            const SizedBox(height: 16),
            _buildCustomerTable(isDarkMode),
            const SizedBox(height: 32),
            
            _buildSectionHeader('উপকেন্দ্রের তথ্য', primaryColor, context),
            const SizedBox(height: 16),
            _buildSubstationTable(isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGeneralTable(bool isDarkMode) {
    final data = [
      ['আনুষ্ঠানিক বিদ্যুতায়নের তারিখ', '২২-০৯-১৯৮৫খ্রি.'],
      ['অন্তর্ভূক্ত উপজেলা', '০৫ টি (বাবুগঞ্জ, বানারীপাড়া, উজিরপুর, গৌরনদী ও আগৈলঝাড়া)'],
      ['অন্তর্ভূক্ত ইউনিয়ন ও পৌরসভা', '৩৫ ও ০৩ টি'],
      ['অন্তর্ভূক্ত গ্রাম', '৫৩৫ টি'],
      ['বিদ্যুতায়িত গ্রাম', '৫৩৫ টি'],
      ['বিদ্যুতায়িত লাইন', '৫৬৭৪.৬৪৩ কিলোমিটার'],
      ['বিদ্যুৎ সুবিধা প্রাপ্ত জনসংখ্যার হার', '১০০%'],
      ['প্রতি কিলোমিটারে গ্রাহক সংখ্যা', '৫৮ জন'],
      ['বিলিং গ্রাহক সংখ্যা', '২,৯০,৩২২ জন'],
      ['বিচ্ছিন্ন গ্রাহক সংখ্যা', '২৭,৩৯৯ জন'],
      ['মাসিক গড় বিক্রয় (টাকা)', '১৯,৭৮,৮৪,৬২০.০০ টাকা'],
      ['মোট বকেয়ার পরিমাণ', '১৮,২২,০৮,১৭৩.০০ টাকা'],
      ['বকেয়া মাস (২০২৪-২৫) (জুন-২০২৫) পর্যন্ত', 'লক্ষ্যমাত্রা - ১.০০ মাস, অর্জন - ০.৯৪ মাস'],
      ['সিস্টেম লস (২০২৪-২৫) (জুন-২০২৪) পর্যন্ত', 'লক্ষ্যমাত্রা - ৮.০০, অর্জন - ৭.৯৭%'],
      ['জোনাল অফিস', '০৩ টি (গৌরনদী,আগৈলঝাড়া, উজিরপুর)'],
      ['সাব-জোনাল অফিস', '০২ টি (বানারীপাড়া, সরিকল)'],
      ['এরিয়া অফিস', '০১ টি (ধামুরা)'],
      ['অভিযোগ কেন্দ্র', '১৫ টি (বাবুগঞ্জ, দেহেরগতি, শরিকল, বার্থী, হোসনাবাদ, পয়সারহাট, সাতলা, বাসাইল, চাখার, লবণসারা, উদয়কাঠী, বিশারকান্দি, হারতা, বামরাইল, ভবানীপুর)'],
      ['বিদ্যুতায়িত ট্রান্সফরমার', '১২,১৪৬ টি'],
      ['৩৩ কেভি ফিডার', '০৫ টি'],
      ['১১ কেভি ফিডার', '৬৩টি'],
      ['মোট চাহিদা (পিক)', '৭২ মেগাওয়াট'],
      ['কর্মকর্তা-কর্মচারীর সংখ্যা', '৪৫৩ জন'],
    ];

    return _buildCustomTable(
      headers: ['ক্র: নং', 'বিষয়', 'বিবরণ'],
      data: data,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildCustomerTable(bool isDarkMode) {
    final data = [
      ['এলটি-এ (আবাসিক)', '২,৮৫,৫৩৩ জন'],
      ['এলটি-ই (বানিজ্যিক)', '৩২,৯৯৩ জন'],
      ['এলটি-বি (সেচ)', '৬৬৯ জন'],
      ['এলটি-ডি১ (দাতব্য প্রতিষ্ঠান)', '৫,৭৪৫ জন'],
      ['এলটি-সি১', '২,৫৬৯ টি'],
      ['এলটি-সি২ (নির্মাণ)', '২৮৬ টি'],
      ['এলটি-ডি২ (রাস্তার বাতি, পানির পাম্প)', '২৪১টি'],
      ['এলটি-ডি৩ (চার্জিং স্টেশন)', '২৯১ টি'],
      ['এলটি টি (অস্থায়ী)', '২৭ টি'],
      ['এসপিভি', '৪৯ টি'],
      ['এমটি-১ (আবাসিক)', '০১টি'],
      ['এমটি-২ (বানিজ্যিক ও অফিস)', '০৯ টি'],
      ['এমটি-৩ (শিল্প)', '১২ টি'],
      ['এমটি-৫ (সাধারণ)', '১৫ টি'],
      ['এমটি-৬ (অস্থায়ী)', '০২ টি'],
    ];

    return _buildCustomTable(
      headers: ['ক্র: নং', 'বিবরণ', 'পরিমাণ'],
      data: data,
      isDarkMode: isDarkMode,
      footer: ['মোট', '৩,২৮,৪৪২ জন'],
    );
  }

  Widget _buildSubstationTable(bool isDarkMode) {
    final data = [
      ['বাবুগঞ্জ-১ (সদর)', '১০ এমভিএ', 'আউটডোর', '১৬-০৯-১৯৮৫ খ্রি.'],
      ['বাবুগঞ্জ-২ (দেহেরগতি)', '১০ এমভিএ', 'আউটডোর', '০২-০৮-১৯৯৫ খ্রি.'],
      ['গৌরনদী-১ (অফিস ক্যাম্পাস)', '২০ এমভিএ', 'আউটডোর', '০৩-১০-১৯৮৫ খ্রি.'],
      ['গৌরনদী-২ (অফিস ক্যাম্পাস)', '১০ এমভিএ', 'আউটডোর', 'পিডিবি অধিগ্রহনকৃত'],
      ['গৌরনদী-৩ (বার্থী)', '১০ এমভিএ', 'ইনডোর', '২৭-০৬-২০১৯ খ্রি.'],
      ['গৌরনদী-৪ (শরিকল)', '১০ এমভিএ', 'ইনডোর', '২৪-০৬-২০১৯ খ্রি.'],
      ['আগৈলঝাড়া-১ (গৈলা)', '২০ এমভিএ', 'ইউনিট-১ সেমি ইনডোর ও ইউনিট-২ আউটডোর', '২৯-১২-২০১৫ খ্রি.'],
      ['বানারীপাড়া-১ (বানারীপাড়া)', '১০ এমভিএ', 'সেমি ইনডোর', '৩০-১১-১৯৯২ খ্রি.'],
      ['বানারীপাড়া-২ (চাখার)', '১০ এমভিএ', 'সেমি ইনডোর', '২৪-১১-২০১৩ খ্রি.'],
      ['উজিরপুর-১ (ইচলাদী)', '১৫ এমভিএ', 'ইনডোর', '১৫-০১-১৯৯৩ খ্রি.'],
      ['উজিরপুর-২ (ধামুরা)', '১০ এমভিএ', 'আউটডোর', '২৬-০৪-২০১৮ খ্রি.'],
      ['উজিরপুর-৩ (গুঠিয়া)', '১০ এমভিএ', 'আউটডোর', '১৫-০১-২০২০ খ্রি.'],
      ['আগৈলঝাড়া-২ (পয়সারহাট)', '১০ এমভিএ', 'ইনডোর', '২৮-১০-২০২১ খ্রি.'],
      ['আগৈলঝাড়া-৩ (সাতলা)', '১০ এমভিএ', 'ইনডোর', '১৮-০৫-২০২৩ খ্রি.'],
    ];

    return _buildCustomTable(
      headers: ['ক্র: নং', 'উপকেন্দ্রের নাম', 'ক্ষমতা', 'উপকেন্দ্রের ধরণ', 'বিদ্যুতায়নের তারিখ'],
      data: data,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildCustomTable({
    required List<String> headers,
    required List<List<String>> data,
    required bool isDarkMode,
    List<String>? footer,
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
          0: const IntrinsicColumnWidth(),
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
                const SizedBox(), // Empty cell for serial number
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
