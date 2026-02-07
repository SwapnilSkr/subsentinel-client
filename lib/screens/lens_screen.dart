import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// Screen C: "The Lens" (AI Discovery)
class LensScreen extends StatefulWidget {
  const LensScreen({super.key});

  @override
  State<LensScreen> createState() => _LensScreenState();
}

class _LensScreenState extends State<LensScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCameraPermission = false;
  bool _isScanning = false;
  late AnimationController _scanLineController;
  final List<Map<String, dynamic>> _detectedItems = [];

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _hasCameraPermission = true);
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.high,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) setState(() => _isCameraInitialized = true);
        }
      } catch (e) {
        debugPrint('Camera error: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Lens',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 4),
                    Text(
                      'AI-powered discovery',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
                _buildScanButton(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    _buildCameraView(),
                    CustomPaint(
                      size: Size.infinite,
                      painter: _ViewfinderPainter(isScanning: _isScanning),
                    ),
                    if (_isScanning) _buildScanningLine(),
                    ..._buildDetectedChips(),
                    if (!_isScanning && _detectedItems.isEmpty)
                      _buildInstructions(),
                  ],
                ),
              ),
            ),
          ),
          if (_detectedItems.isNotEmpty) _buildDetectedList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _toggleScanning,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: (_isScanning ? AppColors.alert : AppColors.active).withValues(
            alpha: 0.2,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (_isScanning ? AppColors.alert : AppColors.active)
                .withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isScanning ? Icons.stop : Icons.qr_code_scanner,
              color: _isScanning ? AppColors.alert : AppColors.active,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isScanning ? 'Stop' : 'Scan',
              style: TextStyle(
                color: _isScanning ? AppColors.alert : AppColors.active,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCameraView() {
    if (!_hasCameraPermission) {
      return Container(
        color: AppColors.primaryCard,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Access Required',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.active,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_isCameraInitialized) {
      return Container(
        color: AppColors.primaryCard,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.active),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanLineController,
      builder: (context, child) => Positioned(
        top:
            _scanLineController.value *
            (MediaQuery.of(context).size.height * 0.5),
        left: 0,
        right: 0,
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.scanLine,
                AppColors.scanLine,
                Colors.transparent,
              ],
              stops: const [0, 0.2, 0.8, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.scanLine.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetectedChips() {
    return _detectedItems.map((item) {
      final offset = item['position'] as Offset;
      return Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GlassCard(
          accentColor: AppColors.active,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_money, color: AppColors.active, size: 16),
              Text(
                '\$${item['price']}',
                style: const TextStyle(
                  color: AppColors.active,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5)),
      );
    }).toList();
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryCard.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.scanLine.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.scanLine,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Point at receipts or screens',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI will detect subscription prices',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildDetectedList() {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _detectedItems.length,
        itemBuilder: (context, index) {
          final item = _detectedItems[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassCard(
              accentColor: AppColors.active,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Detected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${item['price']}/mo',
                    style: const TextStyle(
                      color: AppColors.active,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleScanning() {
    AppHaptics.navigation();
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scanLineController.repeat();
        Future.delayed(const Duration(seconds: 2), () {
          if (_isScanning && mounted) _simulateDetection();
        });
      } else {
        _scanLineController.stop();
      }
    });
  }

  void _simulateDetection() {
    HapticFeedback.lightImpact();
    setState(
      () => _detectedItems.add({
        'name': 'Netflix',
        'price': '15.99',
        'position': const Offset(50, 100),
      }),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_isScanning && mounted) {
        HapticFeedback.lightImpact();
        setState(
          () => _detectedItems.add({
            'name': 'Spotify',
            'price': '10.99',
            'position': const Offset(150, 200),
          }),
        );
      }
    });
  }
}

class _ViewfinderPainter extends CustomPainter {
  final bool isScanning;
  _ViewfinderPainter({required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isScanning ? AppColors.scanLine : AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const cornerLength = 30.0, cornerRadius = 8.0, padding = 40.0;
    final rect = Rect.fromLTRB(
      padding,
      padding,
      size.width - padding,
      size.height - padding,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLength)
        ..lineTo(rect.left, rect.top + cornerRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + cornerRadius,
          rect.top,
        )
        ..lineTo(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.top)
        ..lineTo(rect.right - cornerRadius, rect.top)
        ..quadraticBezierTo(
          rect.right,
          rect.top,
          rect.right,
          rect.top + cornerRadius,
        )
        ..lineTo(rect.right, rect.top + cornerLength),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLength)
        ..lineTo(rect.left, rect.bottom - cornerRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.bottom,
          rect.left + cornerRadius,
          rect.bottom,
        )
        ..lineTo(rect.left + cornerLength, rect.bottom),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.bottom)
        ..lineTo(rect.right - cornerRadius, rect.bottom)
        ..quadraticBezierTo(
          rect.right,
          rect.bottom,
          rect.right,
          rect.bottom - cornerRadius,
        )
        ..lineTo(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) =>
      oldDelegate.isScanning != isScanning;
}
