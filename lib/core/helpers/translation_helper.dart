import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inldsevak/l10n/general_stream.dart';

class TranslationHelper {
  /// Translates text from English to Hindi if current locale is Hindi
  /// Uses Google Translate API (free tier) or returns original if translation fails
  static Future<String> translateText(String? text) async {
    if (text == null || text.isEmpty) {
      return text ?? '';
    }

    try {
      final locale = GeneralStream.instance.locale;
      
      // Only translate if current language is Hindi
      if (locale.languageCode != 'hi') {
        return text;
      }
      
      // Check if text is already in Hindi (contains Devanagari characters)
      if (_isHindi(text)) {
        return text; // Already in Hindi, no need to translate
      }
      
      // Use Google Translate free API
      try {
        final translated = await _translateWithGoogle(text);
        return translated.isNotEmpty ? translated : text;
      } catch (e) {
        // If translation fails, return original text
        return text;
      }
    } catch (e) {
      // Return original text on any error
      return text;
    }
  }

  /// Translate using Google Translate free API endpoint
  static Future<String> _translateWithGoogle(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=hi&dt=t&q=$encodedText';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data[0] != null && data[0][0] != null) {
          return data[0][0][0] ?? text;
        }
      }
      return text;
    } catch (e) {
      return text;
    }
  }

  /// Check if text contains Hindi/Devanagari characters
  static bool _isHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }

  /// Translates multiple strings in parallel (for better performance)
  static Future<List<String>> translateMultiple(List<String?> texts) async {
    if (texts.isEmpty) return [];
    
    final locale = GeneralStream.instance.locale;
    
    // If English, return as is
    if (locale.languageCode != 'hi') {
      return texts.map((t) => t ?? '').toList();
    }
    
    // Translate all texts
    final futures = texts.map((text) => translateText(text));
    return await Future.wait(futures);
  }

  /// Check if translation is needed for the given text
  /// Returns true if text needs translation (is English and locale is Hindi)
  static bool needsTranslation(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }

    try {
      final locale = GeneralStream.instance.locale;
      
      // Only translate if current language is Hindi
      if (locale.languageCode != 'hi') {
        return false;
      }
      
      // Check if text is already in Hindi (contains Devanagari characters)
      if (_isHindi(text)) {
        return false; // Already in Hindi, no need to translate
      }
      
      return true; // Needs translation
    } catch (e) {
      return false;
    }
  }
}

