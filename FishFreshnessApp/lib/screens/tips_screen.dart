import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({Key? key}) : super(key: key);

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
          'Fish Freshness Tips',
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
            _buildTipCard(
              '👁️ Check the Eyes',
              'Fresh fish have clear, bright eyes. Avoid fish with cloudy or sunken eyes.',
              Icons.visibility,
              const Color(0xFF1A5ADE),
              const Color(0xFFE5EFFF),
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              '🐟 Examine the Gills',
              'Fresh gills are bright red or pink. Brown or gray gills indicate the fish is not fresh.',
              Icons.air,
              const Color(0xFFE53E3E),
              const Color(0xFFFFE5E5),
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              '👃 Smell Test',
              'Fresh fish should smell like the ocean - clean and briny. Strong fishy odor means it\'s old.',
              Icons.psychology,
              const Color(0xFF00B5D8),
              const Color(0xFFE0F7FA),
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              '✋ Touch the Flesh',
              'Fresh fish flesh is firm and springs back when pressed. Avoid if flesh is mushy.',
              Icons.touch_app,
              const Color(0xFF38A169),
              const Color(0xFFE6FFFA),
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              '🌊 Check the Scales',
              'Scales should be shiny and firmly attached. Dull or easily removed scales are bad signs.',
              Icons.water_drop,
              const Color(0xFF805AD5),
              const Color(0xFFF7FAFC),
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              '🧊 Storage Tips',
              'Keep fish on ice or refrigerated below 40°F. Use within 1-2 days for best quality.',
              Icons.ac_unit,
              const Color(0xFF3182CE),
              const Color(0xFFEBF8FF),
            ),
            const SizedBox(height: 24),
            _buildBestPracticesSection(),
            const SizedBox(height: 24),
            _buildWarningSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon, Color iconColor, Color bgColor) {
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
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1F3C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A8FA6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPracticesSection() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF38A169), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Best Practices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1F3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('Buy from reputable fishmongers or markets'),
          _buildBulletPoint('Check the "catch date" or "sell by" date'),
          _buildBulletPoint('Choose whole fish over fillets when possible'),
          _buildBulletPoint('Bring a cooler with ice for transportation'),
          _buildBulletPoint('Store fish on the coldest part of your fridge'),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning, color: Color(0xFFE53E3E), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Warning Signs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53E3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWarningPoint('Strong, unpleasant fishy smell'),
          _buildWarningPoint('Slimy or sticky texture'),
          _buildWarningPoint('Discolored or brown flesh'),
          _buildWarningPoint('Cloudy or milky eyes'),
          _buildWarningPoint('Flesh that doesn\'t spring back when pressed'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF38A169), fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7A8FA6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️ ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE53E3E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}