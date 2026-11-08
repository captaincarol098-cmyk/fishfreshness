import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

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
          'Statistics',
          style: TextStyle(
            color: Color(0xFF0D1F3C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          if (historyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5ADE)),
            );
          }

          final stats = historyProvider.statistics;
          final history = historyProvider.history;

          if (history.isEmpty) {
            return _buildEmpty();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCards(stats),
                const SizedBox(height: 20),
                
                // Recent Activity
                _buildRecentActivity(historyProvider),
                const SizedBox(height: 20),
                
                // Charts Section
                _buildChartsSection(stats, history),
                const SizedBox(height: 20),
                
                // Quick Stats
                _buildQuickStats(stats, history),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEAFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart, size: 40, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Statistics Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning fish to see statistics',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    final totalScans = stats['totalScans'] ?? 0;
    final freshScans = stats['freshScans'] ?? 0;
    final notFreshScans = stats['notFreshScans'] ?? 0;
    final freshPercentage = stats['freshPercentage'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Scans',
            value: totalScans.toString(),
            icon: Icons.camera_alt,
            color: const Color(0xFF1A5ADE),
            backgroundColor: const Color(0xFFE5EFFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Fresh Fish',
            value: freshScans.toString(),
            subtitle: '${freshPercentage.toStringAsFixed(1)}%',
            icon: Icons.check_circle,
            color: const Color(0xFF1B8C4E),
            backgroundColor: const Color(0xFFE8F5E8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Not Fresh',
            value: notFreshScans.toString(),
            subtitle: '${(100 - freshPercentage).toStringAsFixed(1)}%',
            icon: Icons.cancel,
            color: const Color(0xFFB71C1C),
            backgroundColor: const Color(0xFFFFE5E5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(HistoryProvider historyProvider) {
    final recentScans = historyProvider.getRecentScans(days: 7);
    
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
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1F3C),
                ),
              ),
              const Spacer(),
              Text(
                'Last 7 days',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentScans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            Column(
              children: recentScans.take(3).map((scan) {
                final isFresh = scan.classification == 'fresh';
                final isUncertain = scan.classification == 'uncertain';
                final dotColor = isFresh
                    ? const Color(0xFF1B8C4E)
                    : isUncertain
                        ? const Color(0xFFF57C00)
                        : const Color(0xFFB71C1C);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isFresh
                              ? 'Fresh fish detected'
                              : isUncertain
                                  ? 'Uncertain result'
                                  : 'Not fresh fish detected',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0D1F3C),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(scan.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
  Widget _buildChartsSection(Map<String, dynamic> stats, List<dynamic> history) {
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
          const Text(
            'Success Rate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 16),
          _buildSuccessRateChart(stats),
        ],
      ),
    );
  }

  Widget _buildSuccessRateChart(Map<String, dynamic> stats) {
    final freshPercentage = stats['freshPercentage'] ?? 0.0;
    final notFreshPercentage = 100 - freshPercentage;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: freshPercentage.round(),
              child: Container(
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B8C4E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: notFreshPercentage.round(),
              child: Container(
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B8C4E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Fresh (${freshPercentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB71C1C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Not Fresh (${notFreshPercentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats, List<dynamic> history) {
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
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickStatRow(
            'Average Fresh Confidence', 
            '${(stats['averageFreshConfidence'] ?? 0.0).toStringAsFixed(1)}%',
            Icons.trending_up,
            const Color(0xFF1B8C4E),
          ),
          const SizedBox(height: 12),
          _buildQuickStatRow(
            'Average Not Fresh Confidence', 
            '${(stats['averageNotFreshConfidence'] ?? 0.0).toStringAsFixed(1)}%',
            Icons.trending_down,
            const Color(0xFFB71C1C),
          ),
          const SizedBox(height: 12),
          _buildQuickStatRow(
            'Recent Scans (7 days)', 
            '${stats['recentScans'] ?? 0}',
            Icons.access_time,
            const Color(0xFF1A5ADE),
          ),
        ],
      ),
    );
  }
  Widget _buildQuickStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0D1F3C),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8FA6),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}