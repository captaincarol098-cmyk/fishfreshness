import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveResults = true;
  bool _hapticFeedback = true;
  double _confidenceThreshold = 0.7;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFEDF4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF0D1F3C), size: 22),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF0D1F3C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('App Preferences'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                'Notifications',
                'Get alerts for scan results',
                Icons.notifications_outlined,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Auto-save Results',
                'Automatically save scan results',
                Icons.save_outlined,
                _autoSaveResults,
                (value) => setState(() => _autoSaveResults = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Haptic Feedback',
                'Vibration for button taps',
                Icons.vibration_outlined,
                _hapticFeedback,
                (value) => setState(() => _hapticFeedback = value),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSectionTitle('AI Detection'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSliderTile(
                'Confidence Threshold',
                'Minimum confidence for results',
                Icons.tune_outlined,
                _confidenceThreshold,
                (value) => setState(() => _confidenceThreshold = value),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('Data Management'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                'Export Data',
                'Export scan history as CSV',
                Icons.download_outlined,
                () => _exportData(context),
              ),
              _buildDivider(),
              _buildActionTile(
                'Clear History',
                'Delete all scan records',
                Icons.delete_outline,
                () => _showClearHistoryDialog(context),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                'App Version',
                'v1.0.0 (Build 1)',
                Icons.info_outline,
                () {},
                showArrow: false,
              ),
              _buildDivider(),
              _buildActionTile(
                'Privacy Policy',
                'View our privacy policy',
                Icons.privacy_tip_outlined,
                () => _showPrivacyPolicy(context),
              ),
              _buildDivider(),
              _buildActionTile(
                'Terms of Service',
                'View terms and conditions',
                Icons.description_outlined,
                () => _showTermsOfService(context),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D1F3C),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1A5ADE), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0D1F3C),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF7A8FA6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1A5ADE),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, IconData icon, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF1A5ADE), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1F3C),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8FA6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A5ADE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1A5ADE),
              inactiveTrackColor: const Color(0xFFE5EFFF),
              thumbColor: const Color(0xFF1A5ADE),
              overlayColor: const Color(0xFF1A5ADE).withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: 0.5,
              max: 0.95,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false, bool showArrow = true}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFE5E5) : const Color(0xFFE5EFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF1A5ADE), 
          size: 20
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF0D1F3C),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDestructive ? const Color(0xFFE53E3E).withOpacity(0.7) : const Color(0xFF7A8FA6),
        ),
      ),
      trailing: showArrow ? Icon(
        Icons.chevron_right,
        color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF7A8FA6),
      ) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: const Color(0xFFE5EFFF),
      indent: 76,
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: Color(0xFF1A5ADE),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Clear All History?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will permanently delete all your scan results. This action cannot be undone.',
            style: TextStyle(color: Color(0xFF7A8FA6)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<HistoryProvider>(context, listen: false).clearHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully'),
                    backgroundColor: Color(0xFF38A169),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'Your privacy is important to us. This app:\n\n'
              '• Processes images locally on your device\n'
              '• Does not send any data to external servers\n'
              '• Stores scan results only on your device\n'
              '• Does not collect personal information\n'
              '• Does not use tracking or analytics\n\n'
              'All fish images and scan results remain private and secure on your device.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Terms of Service'),
          content: const SingleChildScrollView(
            child: Text(
              'By using this app, you agree to:\n\n'
              '• Use the app for food safety guidance only\n'
              '• Not rely solely on app results for food safety decisions\n'
              '• Use your own judgment and expertise\n'
              '• Understand that AI predictions are not 100% accurate\n'
              '• Follow proper food safety practices\n\n'
              'This app is a tool to assist with fish freshness assessment but should not replace professional judgment or food safety guidelines.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}