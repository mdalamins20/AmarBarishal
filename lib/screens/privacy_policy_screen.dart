import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text('প্রাইভেসি পলিসি', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDarkMode 
                    ? [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]
                    : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)],
                ),
                border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                  height: 1.6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'আমাদের প্রাইভেসি পলিসি',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'আপডেট করা হয়েছে: ৯ এপ্রিল, ২০২৬\n\n'
                      '"আমার বরিশাল" অ্যাপ ব্যবহার করার জন্য আপনাকে ধন্যবাদ। আপনার তথ্য এবং গোপনীয়তা আমাদের কাছে অত্যন্ত গুরুত্বপূর্ণ। '
                      'আমরা কিভাবে আপনার তথ্য সংগ্রহ করি, ব্যবহার করি এবং রক্ষা করি তা এই প্রাইভেসি পলিসিতে বর্ণনা করা হয়েছে।',
                    ),
                    const SizedBox(height: 20),
                    Text('১. তথ্য সংগ্রহ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.blueAccent : Colors.blue.shade700)),
                    const SizedBox(height: 10),
                    const Text('আমরা সাধারণত ব্যবহারকারীদের কাছ থেকে শুধুমাত্র বেসিক তথ্য সংগ্রহ করি, যেমন ইমেইল বা নাম (যদি আপনি লগইন করেন)। অ্যাপটি অফলাইনে কাজ করার সুবিধার্থে কিছু ক্যাশ ডাটা আপনার ডিভাইসেই জমা রাখা হয় যা আমরা অ্যাক্সেস করি না।'),
                    
                    const SizedBox(height: 20),
                    Text('২. তথ্যের ব্যবহার', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.blueAccent : Colors.blue.shade700)),
                    const SizedBox(height: 10),
                    const Text('আপনার তথ্য শুধুমাত্র অ্যাপের নিজস্ব সেবার মান উন্নত করার জন্য ব্যবহৃত হয়। থার্ড পার্টি বা অন্য কোনো প্রতিষ্ঠানের কাছে আপনার ব্যক্তিগত কোনো ডেটা বিক্রি বা হস্তান্তর করা হয় না।'),
                    
                    const SizedBox(height: 20),
                    Text('৩. ডেটার নিরাপত্তা', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.blueAccent : Colors.blue.shade700)),
                    const SizedBox(height: 10),
                    const Text('আপনার তথ্য নিরাপদ রাখতে আমরা ইন্ডাস্ট্রি স্টান্ডার্ড নিরাপত্তা ব্যবস্থা ব্যবহার করে থাকি। তবে ইন্টারনেট বা ইলেকট্রনিক স্টোরেজে শতভাগ নিরাপত্তার নিশ্চয়তা দেওয়া সম্ভব নয়।'),
                    
                    const SizedBox(height: 30),
                    const Text('আপনার কোনো প্রশ্ন থাকলে আমাদের সাথে যোগাযোগ করতে পারেন।', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
