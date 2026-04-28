import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Opens a full-screen scanner and returns the first decoded string (IMEI / serial / QR payload).
Future<String?> showImeiScanner(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.black,
    builder: (ctx) => const _ImeiScannerBody(),
  );
}

class _ImeiScannerBody extends StatefulWidget {
  const _ImeiScannerBody();

  @override
  State<_ImeiScannerBody> createState() => _ImeiScannerBodyState();
}

class _ImeiScannerBodyState extends State<_ImeiScannerBody> {
  late final MobileScannerController _controller;
  bool _closed = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_closed || !mounted) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue ?? codes.first.displayValue;
    if (raw == null || raw.trim().isEmpty) return;
    _closed = true;
    Navigator.of(context).pop(_normalizeScan(raw));
  }

  static String _normalizeScan(String raw) {
    var s = raw.trim();
    if (s.length > 20 && RegExp(r'^\d+$').hasMatch(s)) {
      return s;
    }
    final uri = Uri.tryParse(s);
    if (uri != null && uri.hasQuery) {
      for (final key in ['imei', 'serial', 'id', 'code']) {
        final v = uri.queryParameters[key];
        if (v != null && v.trim().isNotEmpty) return v.trim();
      }
    }
    return s.replaceAll(RegExp(r'\s+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.72;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Scan IMEI / barcode / QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _controller.toggleTorch();
                    if (mounted) setState(() => _torchOn = !_torchOn);
                  },
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  return ColoredBox(
                    color: Colors.black87,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography, color: Colors.white70, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              error.errorDetails?.message ?? error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Point the camera at a barcode or QR code. Grant camera access if prompted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
