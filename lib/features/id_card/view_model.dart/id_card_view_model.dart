import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrCodeViewModel extends BaseViewModel {
  GlobalKey qrKey = GlobalKey();

  Future<void> shareQrCode() async {
    try {
      // Capture the QR code widget as an image
      final RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');

      // Write the image to file
      await file.writeAsBytes(pngBytes);

      // Share the image file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my QR code!',
        subject: 'My QR Code',
      );
    } catch (e) {
      CommonSnackbar(
        text: "Failed to share QR code: ${e.toString()}",
      ).showSnackbar();
    }
  }
}
