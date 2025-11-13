import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/volunter/view_model/volunteer_analytics_view_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class VolunteerEventScannerView extends StatefulWidget {
  const VolunteerEventScannerView({super.key});

  @override
  State<VolunteerEventScannerView> createState() =>
      _VolunteerEventScannerViewState();
}

class _VolunteerEventScannerViewState extends State<VolunteerEventScannerView> {
  late final MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _parseEventId(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['eventId'];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    } catch (_) {
      // Ignore JSON parse errors and treat the raw value as the fallback.
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final value = uri.queryParameters['eventId'];
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return trimmed;
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (!mounted || _isProcessing) {
      return;
    }

    String? eventId;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }
      eventId = _parseEventId(rawValue);
      if (eventId != null && eventId.isNotEmpty) {
        break;
      }
    }

    if (eventId == null || eventId.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await _controller.stop();

    final viewModel = context.read<VolunteerAnalyticsViewModel>();
    final success = await viewModel.attendEvent(eventId);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isProcessing = false;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = MediaQuery.of(context).size.width * 0.7;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppPalettes.blackColor,
      appBar: AppBar(
        backgroundColor: AppPalettes.blackColor,
        foregroundColor: AppPalettes.whiteColor,
        title: const Text("Scan Event QR"),
        actions: [
          ValueListenableBuilder<TorchState?>(
            valueListenable: _controller.torchState,
            builder: (context, state, _) {
              final isOn = state == TorchState.on;
              return IconButton(
                onPressed: state == null ? null : () => _controller.toggleTorch(),
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
              );
            },
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radiusX4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: Dimens.paddingX6,
            left: Dimens.horizontalspacing,
            right: Dimens.horizontalspacing,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Align the QR code within the frame",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppPalettes.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimens.paddingX2),
                if (_isProcessing)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


