import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inldsevak/core/helpers/image_helper.dart';
import 'package:inldsevak/core/mixin/transparent_mixin.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrCodeViewModel extends BaseViewModel with TransparentCircular {
  bool isSharing = false;

  GlobalKey qrKey = GlobalKey();

  Future<void> shareQrCode() async {
    if (isSharing) return;
    isSharing = true;
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
    } finally {
      isSharing = false;
    }
  }

  Future<void> downloadFile() async {
    if (isSharing) return;
    isSharing = true;
    showCustomDialogTransperent(isShowing: true);
    try {
      final RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      String fileName = 'qr_code';
      String? path = await getFilePath();
      int i = 1;
      while (await File('$path/$fileName.png').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }
      final filePath = '$path/$fileName.png';
      /* // Check if Directory Path exists or not
      dirExists = await File(externalDir).exists();
      //if not then create the path
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }*/
      final file = await File(filePath).create();
      await file.writeAsBytes(pngBytes);
      await OpenFile.open(filePath, type: 'image');
    } catch (err, stackTrace) {
      CommonSnackbar(text: "Failed to download QR code").showSnackbar();
      debugPrint("Error: $err");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isSharing = false;
      RouteManager.pop();
    }
  }
}
