import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/l10n/general_stream.dart';

/// Widget that automatically translates text based on current locale
class TranslatedText extends StatefulWidget {
  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  /// If true, translates word-for-word for more literal translation
  /// If false, translates meaning-based (default)
  final bool wordForWord;
  /// If true, disables translation (useful for proper nouns like names)
  /// Text will be displayed as-is regardless of locale
  final bool disableTranslation;
  /// If true, forces translation even if language detection suggests it's not needed
  /// Useful for cases where detection might fail (e.g., notification titles from backend)
  final bool forceTranslation;

  const TranslatedText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.wordForWord = false,
    this.disableTranslation = false,
    this.forceTranslation = false,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? _translatedText;
  bool _isTranslating = false;
  StreamSubscription<dynamic>? _languageSubscription;
  Map<String, String> _namePlaceholders = {}; // Map of placeholder -> original name

  @override
  void initState() {
    super.initState();
    _translateText();

    // Listen to language changes for instant retranslation
    _languageSubscription = GeneralStream.instance.language.listen((_) {
      if (mounted) {
        _translateText();
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || 
        oldWidget.wordForWord != widget.wordForWord ||
        oldWidget.disableTranslation != widget.disableTranslation ||
        oldWidget.forceTranslation != widget.forceTranslation) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    if (widget.text == null || widget.text!.isEmpty) {
      setState(() {
        _translatedText = widget.text;
        _isTranslating = false;
      });
      return;
    }

    // If translation is disabled, show text as-is
    if (widget.disableTranslation) {
      setState(() {
        _translatedText = widget.text;
        _isTranslating = false;
      });
      return;
    }

    // Extract and preserve names before translation
    final textWithPlaceholders = _extractAndPreserveNames(widget.text ?? '');
    
    // If forceTranslation is true, always translate when app is in Hindi
    // This ensures notification titles like "Party Membership Request Submitted" are translated
    if (widget.forceTranslation) {
      final locale = GeneralStream.instance.locale;
      final isHindiLocale = locale.languageCode == 'hi';
      
      if (isHindiLocale && widget.text != null && widget.text!.trim().isNotEmpty) {
        // Show skeleton loading while translating
        setState(() {
          _isTranslating = true;
        });
        
        // Force translation by passing force=true to bypass language detection check
        // Use text with placeholders so names are not translated
        try {
          final translated = await TranslationHelper.translateText(
            textWithPlaceholders,
            wordForWord: widget.wordForWord,
            force: true,
          );
          if (mounted) {
            setState(() {
              // Restore names after translation
              _translatedText = _restoreNames(translated);
              _isTranslating = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _translatedText = widget.text; // Keep original on error
              _isTranslating = false;
            });
          }
        }
        return;
      }
    }

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(widget.text);
    
    if (!needsTranslation) {
      // No translation needed, show text immediately
      setState(() {
        _translatedText = widget.text;
        _isTranslating = false;
      });
      return;
    }

    // Show skeleton loading while translating
    setState(() {
      _isTranslating = true;
    });

    // Translate in background without blocking UI
    // Use text with placeholders so names are not translated
    try {
      final translated = await TranslationHelper.translateText(
        textWithPlaceholders,
        wordForWord: widget.wordForWord,
      );
      if (mounted) {
        setState(() {
          // Restore names after translation
          _translatedText = _restoreNames(translated);
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text; // Keep original on error
          _isTranslating = false;
        });
      }
    }
  }

  /// Extract names from text and replace with placeholders to preserve them during translation
  String _extractAndPreserveNames(String text) {
    _namePlaceholders.clear();
    String processedText = text;
    int placeholderIndex = 0;

    // Extract names from common patterns in notification titles/messages
    // Pattern: names in quotes or after "from/by" etc., or Hindi possessive patterns
    final namePatterns = [
      RegExp(r"'([A-Za-z\u0900-\u097F\s]{2,50})'", caseSensitive: false),
      RegExp(r'"([A-Za-z\u0900-\u097F\s]{2,50})"', caseSensitive: false),
      RegExp(r'\bfrom\s+([A-Za-z\u0900-\u097F\s]{2,50})\b', caseSensitive: false),
      RegExp(r'\bby\s+([A-Za-z\u0900-\u097F\s]{2,50})\b', caseSensitive: false),
      // Pattern for "Name's message" or "Name का संदेश" (Hindi possessive)
      RegExp(r'([A-Za-z\u0900-\u097F\s]{2,50})\s+(का|की|के)\s+', caseSensitive: false),
      // Pattern for "Message from Name" 
      RegExp(r'(Message|message|संदेश)\s+(from|from|से)\s+([A-Za-z\u0900-\u097F\s]{2,50})', caseSensitive: false),
    ];

    for (final pattern in namePatterns) {
      final matches = pattern.allMatches(processedText);
      for (final match in matches) {
        // For patterns with multiple groups, check all groups
        for (int i = 1; i <= match.groupCount; i++) {
          final potentialName = match.group(i)?.trim();
          if (potentialName != null &&
              potentialName.isNotEmpty &&
              potentialName.length >= 2 &&
              potentialName.length <= 50 &&
              !_namePlaceholders.values.contains(potentialName)) {
            // Check if it's likely a name (not a common word)
            final commonWords = [
              'the', 'and', 'has', 'was', 'your', 'this', 'that', 'with',
              'for', 'are', 'not', 'but', 'can', 'her', 'one', 'all',
              'would', 'there', 'their', 'what', 'said', 'each', 'which',
              'she', 'do', 'how', 'if', 'will', 'up', 'other', 'about',
              'out', 'many', 'then', 'them', 'these', 'so', 'some', 'would',
              'make', 'like', 'into', 'him', 'time', 'look', 'two', 'more',
              'write', 'go', 'see', 'number', 'no', 'way', 'could', 'people',
              'my', 'than', 'first', 'water', 'been', 'call', 'who', 'oil',
              'sit', 'now', 'find', 'down', 'day', 'did', 'get', 'come',
              'made', 'may', 'part', 'over', 'new', 'sound', 'take', 'only',
              'little', 'work', 'know', 'place', 'year', 'live', 'me', 'back',
              'give', 'most', 'very', 'after', 'thing', 'our', 'just', 'name',
              'good', 'sentence', 'man', 'think', 'say', 'great', 'where',
              'help', 'through', 'much', 'before', 'line', 'right', 'too',
              'mean', 'old', 'any', 'same', 'tell', 'boy', 'follow', 'came',
              'want', 'show', 'also', 'around', 'form', 'three', 'small', 'set',
              'put', 'end', 'does', 'another', 'well', 'large', 'must', 'big',
              'even', 'such', 'because', 'turn', 'here', 'why', 'ask', 'went',
              'men', 'read', 'need', 'land', 'different', 'home', 'us', 'move',
              'try', 'kind', 'hand', 'picture', 'again', 'change', 'off', 'play',
              'spell', 'air', 'away', 'animal', 'house', 'point', 'page', 'letter',
              'mother', 'answer', 'found', 'study', 'still', 'learn', 'should',
              'America', 'world', 'high', 'every', 'near', 'add', 'food',
              'between', 'own', 'below', 'country', 'plant', 'last', 'school',
              'father', 'keep', 'tree', 'never', 'start', 'city', 'earth', 'eye',
              'light', 'thought', 'head', 'under', 'story', 'saw', 'left',
              'don\'t', 'few', 'while', 'along', 'might', 'close', 'something',
              'seem', 'next', 'hard', 'open', 'example', 'begin', 'life', 'always',
              'those', 'both', 'paper', 'together', 'got', 'group', 'often', 'run',
              'important', 'until', 'children', 'side', 'feet', 'car', 'mile',
              'night', 'walk', 'white', 'sea', 'began', 'grow', 'took', 'river',
              'four', 'carry', 'state', 'once', 'book', 'hear', 'stop', 'without',
              'second', 'later', 'miss', 'idea', 'enough', 'eat', 'face', 'watch',
              'far', 'Indian', 'really', 'almost', 'let', 'above', 'girl',
              'sometimes', 'mountain', 'cut', 'young', 'talk', 'soon', 'list',
              'song', 'leave', 'family', 'it\'s', 'message', 'Message', 'संदेश',
              'from', 'From', 'से',
            ];
            final lowerName = potentialName.toLowerCase();
            // Check if it's not a common word and is likely a name
            if (!commonWords.contains(lowerName) &&
                (!lowerName.contains(' ') || (lowerName.split(' ').length <= 3))) {
              final placeholder = '__NAME_${placeholderIndex}__';
              _namePlaceholders[placeholder] = potentialName;
              // Replace the name within the matched pattern
              processedText = processedText.replaceFirst(
                match.group(0)!,
                match.group(0)!.replaceAll(potentialName, placeholder),
              );
              placeholderIndex++;
              break; // Only process first valid name from this match
            }
          }
        }
      }
    }

    return processedText;
  }

  /// Restore names from placeholders after translation
  String _restoreNames(String translatedText) {
    String result = translatedText;
    _namePlaceholders.forEach((placeholder, originalName) {
      result = result.replaceAll(placeholder, originalName);
    });
    return result;
  }

  /// Builds a skeleton loading widget that matches the text style
  Widget _buildSkeleton() {
    final style = widget.style ?? AppStyles.bodySmall;
    final fontSize = style.fontSize ?? 14.0;
    final lineHeight = style.height ?? 1.2;
    final maxLines = widget.maxLines ?? 1;
    final textLength = widget.text?.length ?? 10;
    final estimatedLineWidth = (textLength * fontSize * 0.6).clamp(50.0, 300.0);
    final lineHeightValue = fontSize * lineHeight;
    
    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
      period: const Duration(milliseconds: 1500),
      child: Column(
        crossAxisAlignment: widget.textAlign == TextAlign.center
            ? CrossAxisAlignment.center
            : widget.textAlign == TextAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          maxLines,
          (index) => Container(
            margin: EdgeInsets.only(
              bottom: index < maxLines - 1 ? lineHeightValue * 0.2 : 0,
            ),
            width: index == maxLines - 1 
                ? estimatedLineWidth * 0.7  // Last line is shorter
                : estimatedLineWidth,
            height: fontSize * 0.8,
            decoration: BoxDecoration(
              color: AppPalettes.liteGreyColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading while translating
    if (_isTranslating) {
      return _buildSkeleton();
    }
    
    // Show translated text or original if translation not needed
    final displayText = _translatedText ?? widget.text ?? '';
    
    return Text(
      displayText,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }
}