import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'result_screen.dart';
import '../services/settings_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _flashOn = false;
  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        Navigator.pop(context);
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );

      await _cameraController.initialize();
      await _settings.load();

      final flashOn = _settings.flashOnStart;
      if (flashOn) {
        try {
          await _cameraController.setFlashMode(FlashMode.torch);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _flashOn = flashOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _toggleFlash() async {
    final next = !_flashOn;
    try {
      await _cameraController.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      await _settings.setFlashOnStart(next);
      if (!mounted) return;
      setState(() => _flashOn = next);
    } catch (_) {}
  }

  Future<void> _captureImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(imagePath: image.path)),
      ).then((_) => setState(() => _isProcessing = false));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1F3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview full screen
          Positioned.fill(child: CameraPreview(_cameraController)),

          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Flash toggle button
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: _toggleFlash,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _flashOn
                      ? const Color(0xFFFFD54F)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _flashOn ? Icons.flash_on : Icons.flash_off,
                  color: _flashOn ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),

          // Title
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Scan Fish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Scanning frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  ..._buildCorners(),
                ],
              ),
            ),
          ),

          // Hint text
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Position the fish inside the frame',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _isProcessing ? null : _captureImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isProcessing
                            ? [Colors.grey, Colors.grey]
                            : [const Color(0xFF1A5ADE), const Color(0xFF1243B0)],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A5ADE).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 24.0;
    const thickness = 4.0;
    return [
      // Top-left
      Positioned(
        top: -1,
        left: -1,
        child: _Corner(Colors.white, size, thickness, topLeft: true),
      ),
      // Top-right
      Positioned(
        top: -1,
        right: -1,
        child: _Corner(Colors.white, size, thickness, topRight: true),
      ),
      // Bottom-left
      Positioned(
        bottom: -1,
        left: -1,
        child: _Corner(Colors.white, size, thickness, bottomLeft: true),
      ),
      // Bottom-right
      Positioned(
        bottom: -1,
        right: -1,
        child: _Corner(Colors.white, size, thickness, bottomRight: true),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size;
  final double thickness;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const _Corner(
    this.color,
    this.size,
    this.thickness, {
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(
        color, thickness, topLeft, topRight, bottomLeft, bottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  _CornerPainter(this.color, this.thickness, this.topLeft, this.topRight,
      this.bottomLeft, this.bottomRight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (topLeft) {
      canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), const Offset(0, 0), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(0, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
