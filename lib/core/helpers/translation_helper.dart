import 'dart:convert';
import 'dart:async';
import 'package:devlipi/devlipi.dart';
import 'package:http/http.dart' as http;
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationHelper {
  // In-memory cache for translations (locale -> original -> translated)
  static final Map<String, Map<String, String>> _memoryCache = {};

  // Pending translation requests to avoid duplicate API calls
  static final Map<String, Completer<String>> _pendingTranslations = {};

  // Maximum cache size to prevent memory issues
  static const int _maxCacheSize = 1000;

  /// Translates text based on current locale with caching for performance
  /// - If locale is Hindi: translates English to Hindi
  /// - If locale is English: translates Hindi to English
  /// Uses Google Translate API (free tier) with caching to improve performance
  ///
  /// [wordForWord] - If true, translates each word individually for more literal translation
  ///                 If false, translates the entire phrase for meaning-based translation
  /// [force] - If true, forces translation even if language detection suggests it's not needed
  ///           Useful for cases where detection might fail (e.g., mixed-language messages)
  static Future<String> translateText(
    String? text, {
    bool wordForWord = false,
    bool force = false,
  }) async {
    if (text == null || text.isEmpty) {
      return text ?? '';
    }

    try {
      final locale = GeneralStream.instance.locale;
      final localeKey = locale.languageCode;
      final isHindi = _isHindi(text);
      final isHindiLocale = localeKey == 'hi';

      // If force is true, bypass language detection check
      // Otherwise, if text language matches current locale, no translation needed
      if (!force &&
          ((isHindiLocale && isHindi) || (!isHindiLocale && !isHindi))) {
        return text;
      }

      // Determine translation direction
      // When force is true, translate based on locale:
      // - Hindi locale: translate from English to Hindi (explicitly use 'en' as source, even if text contains Hindi chars)
      // - English locale: translate from Hindi to English (explicitly use 'hi' as source, even if text contains English)
      bool fromHindi = false;
      bool useAutoDetect = false;
      if (force) {
        // Force translation direction based on locale
        // DON'T use auto-detect when force=true because Google Translate might detect mixed-language
        // messages as already being in the target language (e.g., detects Hindi chars and thinks it's Hindi)
        // Instead, explicitly specify source language based on locale to ensure translation happens
        useAutoDetect = false;
        fromHindi =
            !isHindiLocale; // If locale is Hindi, translate from English (fromHindi=false)
      } else {
        // Normal detection: translate from Hindi if text is Hindi and locale is English
        fromHindi = isHindi && !isHindiLocale;
      }

      // Check memory cache first
      // Include force in cache key to differentiate forced vs normal translations
      final cacheKey =
          '$localeKey:${wordForWord ? 'word' : 'phrase'}:${force ? 'force' : 'auto'}:$text';
      if (_memoryCache.containsKey(localeKey) &&
          _memoryCache[localeKey]!.containsKey(cacheKey)) {
        return _memoryCache[localeKey]![cacheKey]!;
      }

      // Check if translation is already in progress
      if (_pendingTranslations.containsKey(cacheKey)) {
        return await _pendingTranslations[cacheKey]!.future;
      }

      // Create completer for pending translation
      final completer = Completer<String>();
      _pendingTranslations[cacheKey] = completer;

      try {
        // Try to load from persistent cache
        final cached = await _loadFromCache(cacheKey);
        if (cached != null) {
          _addToMemoryCache(localeKey, cacheKey, cached);
          completer.complete(cached);
          _pendingTranslations.remove(cacheKey);
          return cached;
        }

        // Translate using Google Translate API
        final translated = wordForWord
            ? await _translateWordForWord(
                text,
                fromHindi: fromHindi,
                useAutoDetect: useAutoDetect,
              )
            : await _translateWithGoogle(
                text,
                fromHindi: fromHindi,
                useAutoDetect: useAutoDetect,
              );

        final result = translated.isNotEmpty ? translated : text;

        // Cache the result
        _addToMemoryCache(localeKey, cacheKey, result);
        await _saveToCache(cacheKey, result);

        completer.complete(result);
        _pendingTranslations.remove(cacheKey);
        return result;
      } catch (e) {
        // If translation fails, return original text
        final result = text;
        completer.complete(result);
        _pendingTranslations.remove(cacheKey);
        return result;
      }
    } catch (e) {
      // Return original text on any error
      return text;
    }
  }

  /// Add translation to memory cache
  static void _addToMemoryCache(
    String localeKey,
    String cacheKey,
    String translated,
  ) {
    if (!_memoryCache.containsKey(localeKey)) {
      _memoryCache[localeKey] = {};
    }

    // Limit cache size to prevent memory issues
    if (_memoryCache[localeKey]!.length >= _maxCacheSize) {
      // Remove oldest entry (simple FIFO)
      final firstKey = _memoryCache[localeKey]!.keys.first;
      _memoryCache[localeKey]!.remove(firstKey);
    }

    _memoryCache[localeKey]![cacheKey] = translated;
  }

  /// Load translation from persistent cache
  static Future<String?> _loadFromCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('translation_cache_$cacheKey');
    } catch (e) {
      return null;
    }
  }

  /// Save translation to persistent cache
  static Future<void> _saveToCache(String cacheKey, String translated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('translation_cache_$cacheKey', translated);
    } catch (e) {
      // Ignore cache save errors
    }
  }

  /// Clear all translation caches (useful when language changes)
  static Future<void> clearCache() async {
    _memoryCache.clear();
    _pendingTranslations.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith('translation_cache_'),
      );
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Translate using Google Translate free API endpoint (meaning-based translation)
  /// [fromHindi] - If true, translates from Hindi to English, otherwise from English to Hindi
  /// [useAutoDetect] - If true, uses 'auto' as source language for better handling of mixed-language messages
  static Future<String> _translateWithGoogle(
    String text, {
    bool fromHindi = false,
    bool useAutoDetect = false,
  }) async {
    try {
      // Split text by newlines to handle multi-paragraph text and avoid URL length limits
      final lines = text.split('\n');
      final translatedLines = <String>[];

      for (var line in lines) {
        if (line.trim().isEmpty) {
          translatedLines.add(line);
          continue;
        }

        final encodedText = Uri.encodeComponent(line);
        final locale = GeneralStream.instance.locale;
        final isHindiLocale = locale.languageCode == 'hi';
        final sourceLang = useAutoDetect ? 'auto' : (fromHindi ? 'hi' : 'en');
        final targetLang = isHindiLocale ? 'hi' : 'en';
        final url =
            'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=$encodedText';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data != null && data[0] != null && data[0] is List) {
            final StringBuffer sb = StringBuffer();
            for (var part in data[0]) {
              if (part != null &&
                  part is List &&
                  part.isNotEmpty &&
                  part[0] is String) {
                sb.write(part[0]);
              }
            }
            final result = sb.toString();
            translatedLines.add(result.isNotEmpty ? result : line);
          } else {
            translatedLines.add(line);
          }
        } else {
          translatedLines.add(line);
        }
      }

      return translatedLines.join('\n');
    } catch (e) {
      return text;
    }
  }

  /// Translate word-for-word for more literal translation
  /// Splits text into words and translates each word individually
  /// [fromHindi] - If true, translates from Hindi to English, otherwise from English to Hindi
  /// [useAutoDetect] - If true, uses 'auto' as source language for better handling of mixed-language messages
  static Future<String> _translateWordForWord(
    String text, {
    bool fromHindi = false,
    bool useAutoDetect = false,
  }) async {
    try {
      // Split text into words while preserving punctuation and spaces
      final words = text.split(RegExp(r'(\s+)'));
      final translatedWords = <String>[];

      for (final word in words) {
        if (word.trim().isEmpty) {
          // Preserve spaces
          translatedWords.add(word);
          continue;
        }

        // Check if word contains only punctuation or numbers
        if (RegExp(r'^[^\w]+$').hasMatch(word) ||
            RegExp(r'^\d+$').hasMatch(word)) {
          translatedWords.add(word);
          continue;
        }

        // Translate individual word
        try {
          final translated = await _translateWithGoogle(
            word.trim(),
            fromHindi: fromHindi,
            useAutoDetect: useAutoDetect,
          );
          translatedWords.add(translated);
        } catch (e) {
          // If translation fails for a word, keep original
          translatedWords.add(word);
        }
      }

      return translatedWords.join('');
    } catch (e) {
      // Fallback to regular translation if word-for-word fails
      return await _translateWithGoogle(
        text,
        fromHindi: fromHindi,
        useAutoDetect: useAutoDetect,
      );
    }
  }

  /// Check if text contains Hindi/Devanagari characters
  static bool _isHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }

  /// Translates multiple strings in parallel with batching for better performance
  /// Handles both English→Hindi and Hindi→English translation based on current locale
  /// Uses caching to avoid duplicate API calls
  static Future<List<String>> translateMultiple(List<String?> texts) async {
    if (texts.isEmpty) return [];

    // Filter out texts that don't need translation first
    final textsToTranslate = <String>[];
    final indices = <int>[];

    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];
      if (text != null && text.isNotEmpty && needsTranslation(text)) {
        textsToTranslate.add(text);
        indices.add(i);
      }
    }

    // Translate all texts in parallel (caching will prevent duplicate calls)
    final futures = textsToTranslate.map((text) => translateText(text));
    final translated = await Future.wait(futures);

    // Build result list with original texts and translated ones
    final result = <String>[];
    int translatedIndex = 0;

    for (int i = 0; i < texts.length; i++) {
      if (indices.contains(i)) {
        result.add(translated[translatedIndex++]);
      } else {
        result.add(texts[i] ?? '');
      }
    }

    return result;
  }

  /// Custom mapping for common names that are transliterated incorrectly
  /// Maps English name to correct Hindi transliteration
  static const Map<String, String> _nameCorrections = {
    'deep': 'दीप',
    'Deep': 'दीप',
    'DEEP': 'दीप',
    'dape': 'दीप', // Common incorrect transliteration
    'Dape': 'दीप',
  };

  /// Convert English name to Hindi script WITHOUT changing meaning.
  /// Example: "Harsha" → "हर्षा", "Deep" → "दीप", "Rahul" → "राहुल"
  /// Uses devlipi package for accurate transliteration with custom corrections
  static String transliterateToHindi(String input) {
    if (input.isEmpty) return input;

    try {
      final locale = GeneralStream.instance.locale;

      // Only transliterate if current language is Hindi
      if (locale.languageCode != 'hi') {
        return input;
      }

      // Check if text is already in Hindi (contains Devanagari characters)
      if (_isHindi(input)) {
        return input; // Already in Hindi, no need to transliterate
      }

      // Check for custom corrections first (case-insensitive)
      final lowerInput = input.toLowerCase().trim();
      if (_nameCorrections.containsKey(lowerInput) ||
          _nameCorrections.containsKey(input)) {
        return _nameCorrections[input] ?? _nameCorrections[lowerInput] ?? input;
      }

      // Use devlipi for transliteration
      final transliterated = Devlipi.transliterate(input);

      // Check if the transliteration result matches a known incorrect pattern
      // If it does, correct it
      final lowerTransliterated = transliterated.toLowerCase();
      if (_nameCorrections.values.any((correct) => correct == transliterated)) {
        // Already correct
        return transliterated;
      }

      // Check if transliterated result is in our corrections map (for incorrect results)
      if (_nameCorrections.containsKey(lowerTransliterated)) {
        return _nameCorrections[lowerTransliterated]!;
      }

      // Additional check: if input is "Deep" (case-insensitive) and result is "dape" or similar
      if (lowerInput == 'deep' &&
          (lowerTransliterated.contains('dape') ||
              lowerTransliterated.contains('डेप'))) {
        return 'दीप';
      }

      return transliterated;
    } catch (e) {
      // If transliteration fails, return original text
      return input;
    }
  }

  /// Check if translation is needed for the given text
  /// Returns true if text language doesn't match current locale:
  /// - Text is English and locale is Hindi (needs English→Hindi translation)
  /// - Text is Hindi and locale is English (needs Hindi→English translation)
  static bool needsTranslation(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }

    try {
      final locale = GeneralStream.instance.locale;
      final isHindiLocale = locale.languageCode == 'hi';
      final hasHindiChars = _isHindi(text);

      // For mixed-language messages, check if it's primarily English
      bool isPrimarilyHindi = false;
      if (hasHindiChars) {
        final hindiRegex = RegExp(r'[\u0900-\u097F]');
        final hindiCharCount = hindiRegex.allMatches(text).length;
        final totalCharCount = text.replaceAll(RegExp(r'\s'), '').length;
        // If 30% or more of characters are Hindi, consider it primarily Hindi
        isPrimarilyHindi =
            totalCharCount > 0 && (hindiCharCount / totalCharCount) >= 0.3;
      }

      // Translation needed if text language doesn't match locale
      // Primarily Hindi text with English locale OR primarily English text with Hindi locale
      return (isPrimarilyHindi && !isHindiLocale) ||
          (!isPrimarilyHindi && isHindiLocale);
    } catch (e) {
      return false;
    }
  }
}
