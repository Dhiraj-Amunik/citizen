import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';

class ComplaintHelper {
  ComplaintHelper._privateConstructor();

  static Color getStatusColor(String? status) {
    switch (status) {
      case "pending":
        return AppPalettes.liteOrangeColor;
      case "in-progress":
        return AppPalettes.yellowColor;
      case "resolved":
        return AppPalettes.liteGreyColor;

      default:
        return AppPalettes.liteRedColor;
    }
  }

  /// Decode UTF-8 encoded text that may be double-encoded
  /// Handles cases where Hindi/Unicode text is incorrectly encoded as Latin-1
  /// This ensures consistent decoding across all complaint views
  static String? decodeUtf8(String? value) {
    if (value == null || value.isEmpty) return value;
    
    // Check if text contains double-encoded UTF-8 indicators
    final hasDoubleEncoding = value.contains('Ã') || 
                             value.contains('Â') ||
                             value.contains('â€');
    
    if (!hasDoubleEncoding) {
      // Text appears to be properly encoded, return as-is
      return value;
    }
    
    try {
      // Attempt to decode double-encoded UTF-8
      // First encode as Latin-1 (which treats each byte as a character)
      // Then decode as UTF-8 (which interprets the bytes correctly)
      final bytes = latin1.encode(value);
      final decoded = utf8.decode(bytes, allowMalformed: false);
      
      // Verify the decoded text is valid (contains proper Unicode characters)
      // If decoding produced garbage, return original
      if (decoded.contains('�') || decoded == value) {
        return value;
      }
      
      return decoded;
    } catch (e) {
      // If decoding fails, return original value
      debugPrint("UTF-8 decode error: $e");
      return value;
    }
  }
}
