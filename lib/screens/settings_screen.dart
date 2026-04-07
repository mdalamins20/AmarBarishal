import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  void _launchWhatsApp() async {
    const message =
        "আসসালামু আলাইকুম, আমি 'আমার বরিশাল' অ্যাপ সম্পর্কে একটি মতামত দিতে চাই।";
    final whatsappUrl =
        "https://wa.me/+8801778189644?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("আপনার ফোনে WhatsApp ইনস্টল করা নেই।")),
      );
    }
  }

  void _checkForUpdate() async {
    const playStoreUrl =
        "https://github.com/malaminA03/AmarBarishal/releases/tag/%E0%A6%86%E0%A6%AE%E0%A6%BE%E0%A6%B0_%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2";
    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
      await launchUrl(Uri.parse(playStoreUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(fontFamily: 'HindSiliguri');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('সেটিংস',
                style: defaultTextStyle.copyWith(fontWeight: FontWeight.w600)),
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 1,
          ),
          SliverToBoxAdapter(
            child: AppInfoHeader(appVersion: _appVersion),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'সাধারণ সেটিংস',
                style: defaultTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          AnimationLimiter(
            child: SliverList(
              // *** সমাধান ১: এখানে AnimationConfiguration.list() সরানো হয়েছে ***
              delegate: SliverChildListDelegate(
                [
                  _buildAnimatedListItem(
                    index: 0,
                    child: SwitchListTile(
                      title: const Text('ডার্ক মোড', style: defaultTextStyle),
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {},
                      secondary: const Icon(Icons.dark_mode_outlined),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildAnimatedListItem(
                    index: 1,
                    child: ListTile(
                      leading: const Icon(Icons.sync_rounded),
                      title: const Text('ডেটা রিলোড করুন',
                          style: defaultTextStyle),
                      subtitle: const Text('সার্ভার থেকে সর্বশেষ তথ্য লোড করুন',
                          style: defaultTextStyle),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("ডেটা সফলভাবে রিলোড হয়েছে।")),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildAnimatedListItem(
                    index: 2,
                    child: ListTile(
                      leading: const Icon(Icons.system_update_rounded),
                      title: const Text('অ্যাপ আপডেট', style: defaultTextStyle),
                      subtitle: const Text('নতুন ভার্সন চেক করুন',
                          style: defaultTextStyle),
                      onTap: _checkForUpdate,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildAnimatedListItem(
                    index: 3,
                    child: ListTile(
                      // *** সমাধান ২: এখানে আইকন পরিবর্তন করা হয়েছে ***
                      leading: const Icon(Icons.chat_bubble_outline_rounded),
                      title: const Text('মতামত জানান', style: defaultTextStyle),
                      subtitle: const Text(
                          'WhatsApp-এ আমাদের সাথে যোগাযোগ করুন',
                          style: defaultTextStyle),
                      onTap: _launchWhatsApp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListItem({required int index, required Widget child}) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

// AppInfoHeader এবং FeatureListItem উইজেট দুটি অপরিবর্তিত থাকবে
class AppInfoHeader extends StatelessWidget {
  final String appVersion;
  const AppInfoHeader({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(fontFamily: 'HindSiliguri');
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'আমার বরিশাল',
            style: defaultTextStyle.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'কেন ব্যবহার করবেন আমার বরিশাল অ্যাপ?',
            style: defaultTextStyle.copyWith(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const FeatureListItem(
            icon: Icons.all_inclusive_rounded,
            title: 'সব তথ্য এক জায়গায়',
            description:
                'শিক্ষা প্রতিষ্ঠান, হাসপাতাল, মার্কেট, জরুরি সেবা—সব প্রয়োজনীয় তথ্য একসাথে পাবেন সহজেই।',
          ),
          const FeatureListItem(
            icon: Icons.timer_off_outlined,
            title: 'সময় ও পরিশ্রমের সাশ্রয়',
            description:
                'ভিন্ন ভিন্ন জায়গায় খুঁজতে হবে না—অ্যাপেই সব তথ্য হাতের মুঠোয়।',
          ),
          const FeatureListItem(
            icon: Icons.verified_user_outlined,
            title: 'নির্ভুল ও নির্ভরযোগ্য তথ্য',
            description:
                'প্রতিটি তথ্য যাচাই বাছাই করা, তাই আপনি নিশ্চিন্তে ব্যবহার করতে পারবেন।',
          ),
          const SizedBox(height: 24),
          Text(
            'অ্যাপ ভার্সন',
            style: defaultTextStyle.copyWith(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'v$appVersion',
            style: defaultTextStyle.copyWith(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class FeatureListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(fontFamily: 'HindSiliguri');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.greenAccent
                  : Colors.green[700],
              size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: defaultTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: defaultTextStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
