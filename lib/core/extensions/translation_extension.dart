import 'package:inldsevak/core/helpers/translation_helper.dart';

/// Extension to easily translate strings from API responses
extension TranslationExtension on String? {
  /// Translates the string based on current locale
  /// Usage: await event.title?.translate()
  Future<String> translate() async {
    return await TranslationHelper.translateText(this);
  }
  
  /// Synchronous version - returns original if translation is needed
  /// Use this for immediate display, then call translate() for async update
  String get translated {
    // This is a placeholder - actual translation happens async
    // For now, return original. Use translate() method for actual translation
    return this ?? '';
  }
}

