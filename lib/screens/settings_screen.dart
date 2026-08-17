import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';
  
  bool _isNotificationEnabled = true;
  bool _isDataSaverEnabled = false;

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

  void _checkForUpdate() async {
    const playStoreUrl = "https://github.com/malaminA03/AmarBarishal/releases/tag/%E0%A6%86%E0%A6%AE%E0%A6%BE%E0%A6%B0_%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2";
    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
      await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _showClearCacheDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(lang.t('clear_cache_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(lang.t('clear_cache_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.t('no'), style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.cleaning_services_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(lang.t('cache_cleared')),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(lang.t('yes_clear')),
            ),
          ],
        );
      }
    );
  }

  void _showLanguageDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) {
        String selected = lang.languageCode;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(lang.t('select_language'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: 'bn',
                    groupValue: selected,
                    onChanged: (val) {
                      setStateDialog(() => selected = val.toString());
                      lang.changeLanguage('bn');
                      Navigator.pop(context);
                    },
                    title: const Text('বাংলা', style: TextStyle(fontWeight: FontWeight.w600)),
                    activeColor: const Color(0xFF6C63FF),
                  ),
                  RadioListTile(
                    value: 'en',
                    groupValue: selected,
                    onChanged: (val) {
                      setStateDialog(() => selected = val.toString());
                      lang.changeLanguage('en');
                      Navigator.pop(context);
                    },
                    title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                    activeColor: const Color(0xFF6C63FF),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF6C63FF);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                lang.t('settings'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              background: Stack(
                children: [
                   Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.08)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      Center(
                        child: Container(
                           width: 90, height: 90,
                           margin: const EdgeInsets.only(top: 10, bottom: 30),
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             color: isDark ? Colors.black26 : Colors.white,
                             boxShadow: [BoxShadow(color: accentColor.withValues(alpha: isDark ? 0.3 : 0.15), blurRadius: 20, offset: const Offset(0, 8))],
                           ),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(50),
                             child: Image.asset(
                               'assets/icon/icon.png',
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) => const Icon(Icons.location_city_rounded, size: 40, color: accentColor),
                             ),
                           ),
                        ),
                      ),
                      
                      _buildSectionHeader(lang.t('app_config')),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(isDark, [
                        _buildSettingTile(
                          icon: Icons.notifications_active_rounded,
                          iconColor: Colors.amber.shade600,
                          title: lang.t('push_notification'),
                          subtitle: lang.t('push_notification_desc'),
                          isDark: isDark,
                          trailing: Switch.adaptive(
                            value: _isNotificationEnabled,
                            activeColor: accentColor,
                            onChanged: (val) => setState(() => _isNotificationEnabled = val),
                          ),
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.pie_chart_rounded,
                          iconColor: Colors.blue.shade500,
                          title: lang.t('data_saver'),
                          subtitle: lang.t('data_saver_desc'),
                          isDark: isDark,
                          trailing: Switch.adaptive(
                            value: _isDataSaverEnabled,
                            activeColor: accentColor,
                            onChanged: (val) => setState(() => _isDataSaverEnabled = val),
                          ),
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.language_rounded,
                          iconColor: Colors.teal.shade500,
                          title: lang.t('language'),
                          subtitle: lang.t('language_desc'),
                          isDark: isDark,
                          onTap: () => _showLanguageDialog(lang),
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.cleaning_services_rounded,
                          iconColor: Colors.redAccent.shade400,
                          title: lang.t('clear_cache'),
                          subtitle: lang.t('clear_cache_desc'),
                          isDark: isDark,
                          onTap: () => _showClearCacheDialog(lang),
                        ),
                      ]),

                      const SizedBox(height: 30),

                      _buildSectionHeader(lang.t('system_data')),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(isDark, [
                        _buildSettingTile(
                          icon: Icons.sync_rounded,
                          iconColor: Colors.green.shade500,
                          title: lang.t('force_reload'),
                          subtitle: lang.t('force_reload_desc'),
                          isDark: isDark,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(lang.t('data_reloaded'))),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              )
                            );
                          },
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.system_update_alt_rounded,
                          iconColor: Colors.purple.shade400,
                          title: lang.t('server_check'),
                          subtitle: lang.t('server_check_desc'),
                          isDark: isDark,
                          onTap: _checkForUpdate,
                        ),
                      ]),

                      const SizedBox(height: 50),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              lang.t('app_name'),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lang.t("current_version")} $_appVersion',
                              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 1, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2533) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 64, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildSettingTile({
    required IconData icon, required Color iconColor, required String title, required String subtitle, required bool isDark, Widget? trailing, VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600)),
                  ],
                ),
              ),
              if (trailing != null) trailing else Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
