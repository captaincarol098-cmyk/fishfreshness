import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'result_screen.dart';
import 'statistics_screen.dart';
import 'tips_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: picked.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Stack(
            children: [
              // Scrollable content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Hero Header ───────────────────────────────────────────
                      _HeroHeader(waveController: _waveController),

                      const SizedBox(height: 18),

                      // ─── Main CTA Card ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _CTACard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CameraScreen()),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ─── 3 Feature Cards ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _FeatureCard(
                                icon: Icons.camera_alt_outlined,
                                iconBg: const Color(0xFFE5EFFF),
                                iconColor: const Color(0xFF1E60E2),
                                title: 'Camera',
                                subtitle: 'Take a photo\nof the fish',
                                arrowColor: const Color(0xFF1E60E2),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CameraScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _FeatureCard(
                                icon: Icons.photo_library_outlined,
                                iconBg: const Color(0xFFE0F7F2),
                                iconColor: const Color(0xFF00BFA5),
                                title: 'Gallery',
                                subtitle: 'Upload from\nyour gallery',
                                arrowColor: const Color(0xFF00BFA5),
                                onTap: () => _pickFromGallery(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _FeatureCard(
                                icon: Icons.access_time_outlined,
                                iconBg: const Color(0xFFF1EAFF),
                                iconColor: const Color(0xFF8A4AF3),
                                title: 'History',
                                subtitle: 'View your past\nresults',
                                arrowColor: const Color(0xFF8A4AF3),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HistoryScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ─── About Fish Freshness Card ──────────────────────────────
                      const Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _AboutCard(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ─── Top App Bar Icons ─────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Color(0xFF0D1F3C), size: 28),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_outlined,
                              color: Color(0xFF0D1F3C), size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Floating Bottom Navigation Bar ────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: (i) => setState(() => _selectedIndex = i),
                  onCameraPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Hero Header with seamless wave, soft sky gradient & fish image
// ══════════════════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  final AnimationController waveController;
  const _HeroHeader({required this.waveController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Gradient
          Container(
            height: 380,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD6EAFF),
                  Color(0xFFC5E0FF),
                  Color(0xFFF2F6FC),
                ],
                stops: [0.0, 0.70, 1.0],
              ),
            ),
          ),

          // Fish Image seamlessly blended into the right half
          Positioned(
            top: 40,
            right: -25,
            width: 270,
            height: 290,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black26,
                    Colors.black,
                    Colors.black,
                  ],
                  stops: [0.0, 0.18, 0.45, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/fish_hero.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _FishIllustration(),
              ),
            ),
          ),

          // Translucent artistic wave ribbons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: waveController,
              builder: (_, __) => CustomPaint(
                painter: _WavePainter(waveController.value),
                child: const SizedBox(height: 120),
              ),
            ),
          ),

          // Text content
          Positioned(
            top: 92,
            left: 24,
            right: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Fish',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D1F3C),
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '🐟',
                      style: TextStyle(fontSize: 34),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Freshness',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D1F3C),
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI-Powered Freshness Detection',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF56769E),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Check the freshness of your fish\ninstantly using advanced AI.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1E3A5F),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

// ══════════════════════════════════════════════════════════════
// Smooth Wave Ribbon Painter
// ══════════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Back wave ribbon (light cyan translucent)
    final paint1 = Paint()
      ..color = const Color(0x3842A5F5)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.45 +
          math.sin((x / size.width * 2 * math.pi) + (progress * 2 * math.pi)) *
              14 +
          math.cos((x / size.width * 1.5 * math.pi) + (progress * math.pi)) * 8;
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Front solid wave (matching background color #F2F6FC)
    final paint2 = Paint()
      ..color = const Color(0xFFF2F6FC)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.68 +
          math.sin((x / size.width * 2.2 * math.pi) +
                  (progress * 2 * math.pi * 0.8)) *
              12;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// Fish illustration fallback
class _FishIllustration extends StatelessWidget {
  const _FishIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.set_meal, size: 80, color: Color(0xFF1565C0)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Main CTA Card ("Check Freshness Now")
// ══════════════════════════════════════════════════════════════
class _CTACard extends StatelessWidget {
  final VoidCallback onTap;
  const _CTACard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1659E8), Color(0xFF1040B2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1659E8).withOpacity(0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: [
            // Translucent camera badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            // Text details
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check Freshness Now',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Take a photo or upload an image\nof the fish to analyze its freshness.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // White circular chevron button
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right,
                  color: Color(0xFF1659E8), size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Feature Card (Camera, Gallery, History)
// ══════════════════════════════════════════════════════════════
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color arrowColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.arrowColor,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 188,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Icon circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1F3C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Bottom Arrow circle
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.arrowColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// About Fish Freshness Card with Custom Badge
// ══════════════════════════════════════════════════════════════
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue Shield Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF1659E8),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Fish Freshness',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1F3C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Our AI model analyzes key visual features of the fish to determine its freshness. Get results in seconds with high accuracy.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7088A5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Fish Inspection Badge Illustration
          _FishInspectionBadge(),
        ],
      ),
    );
  }
}

// Vector illustration badge: fish + magnifying glass with checkmark + sparkles
class _FishInspectionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F1FF),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blue Fish
          const Positioned(
            top: 14,
            left: 10,
            child: Icon(Icons.set_meal, color: Color(0xFF3B82F6), size: 40),
          ),
          // Magnifying Glass with Checkmark
          Positioned(
            right: 6,
            bottom: 6,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.search, color: Color(0xFF1E40AF), size: 30),
                Positioned(
                  left: 4,
                  top: 4,
                  child: Icon(Icons.check, color: Color(0xFF1E40AF), size: 13),
                ),
              ],
            ),
          ),
          // Little sparkle stars
          const Positioned(
            top: 8,
            right: 10,
            child: Text('✦', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 10)),
          ),
          const Positioned(
            bottom: 12,
            left: 6,
            child: Text('✦', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 8)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Bottom Navigation Bar with Center Floating Action Button
// ══════════════════════════════════════════════════════════════
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onCameraPressed;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF1659E8);
    const inactiveColor = Color(0xFF9EACB9);

    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Stats', 'onTap': () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
      )},
      null, // Center Camera FAB placeholder
      {'icon': Icons.lightbulb_outline_rounded, 'label': 'Tips', 'onTap': () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TipsScreen()),
      )},
      {'icon': Icons.settings_outlined, 'label': 'Settings', 'onTap': () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      )},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              if (items[i] == null) {
                // Elevated center camera FAB
                return GestureDetector(
                  onTap: onCameraPressed,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E60E2), Color(0xFF1044B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E60E2).withOpacity(0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 26),
                  ),
                );
              }

              final item = items[i]! as Map<String, dynamic>;
              final isSelected = selectedIndex == i;

              return GestureDetector(
                onTap: () {
                  if (item['onTap'] != null) {
                    item['onTap']();
                  } else {
                    onItemTapped(i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active indicator pill at top
                      if (isSelected)
                        Container(
                          width: 32,
                          height: 3.5,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 9.5),
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected ? activeColor : inactiveColor,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isSelected ? activeColor : inactiveColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
