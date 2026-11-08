import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

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
          'Scan History',
          style: TextStyle(
            color: Color(0xFF0D1F3C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, hp, _) => hp.history.isEmpty
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined,
                        color: Color(0xFF0D1F3C)),
                    onPressed: () => _showClearDialog(context),
                  ),
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          final history = historyProvider.history;

          if (history.isEmpty) {
            return _buildEmpty(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final scan = history[index];
              final isFresh = scan.classification == 'fresh';
              final isUncertain = scan.classification == 'uncertain';
              final confidence = scan.getConfidencePercentage();

              return _HistoryCard(
                isFresh: isFresh,
                isUncertain: isUncertain,
                confidence: confidence,
                timestamp: scan.timestamp,
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear History?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will delete all scan records. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<HistoryProvider>(context, listen: false)
                  .clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEAFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history,
                size: 48, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No scan history yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning fish to see results here',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5ADE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final bool isFresh;
  final bool isUncertain;
  final double confidence;
  final DateTime timestamp;

  const _HistoryCard({
    required this.isFresh,
    required this.isUncertain,
    required this.confidence,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFresh
        ? const Color(0xFF1B8C4E)
        : isUncertain
            ? const Color(0xFFF57C00)
            : const Color(0xFFB71C1C);
    final bgColor = isFresh
        ? const Color(0xFFD4F4E8)
        : isUncertain
            ? const Color(0xFFFFF1E0)
            : const Color(0xFFFFE5E5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFresh
                    ? Icons.check_circle
                    : isUncertain
                        ? Icons.help_outline
                        : Icons.cancel,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFresh
                        ? '🐟 Fresh Fish'
                        : isUncertain
                            ? '⚠ Uncertain'
                            : '🚫 Not Fresh',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('MMM dd, yyyy  •  HH:mm').format(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8FA6),
                    ),
                  ),
                ],
              ),
            ),
            // Confidence badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
