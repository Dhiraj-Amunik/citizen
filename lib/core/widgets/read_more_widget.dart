import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';

class ReadMoreWidget extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String collapsedText;
  final String expandedText;
  final bool forceTranslation;

  /// Optional list of names to preserve (not translate)
  /// If provided, these names will be extracted and preserved during translation
  final List<String>? namesToPreserve;

  /// Optional image URL to display when expanded
  final String? imageUrl;

  const ReadMoreWidget({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    String? collapsedText,
    String? expandedText,
    this.forceTranslation = false,
    this.namesToPreserve,
    this.imageUrl,
  }) : collapsedText = collapsedText ?? 'Read more',
       expandedText = expandedText ?? 'Show less';

  @override
  State<ReadMoreWidget> createState() => _ReadMoreWidgetState();
}

class _ReadMoreWidgetState extends State<ReadMoreWidget> {
  String? _translatedText;
  String? _translatedCollapsed;
  String? _translatedExpanded;
  bool _isTranslating = false;
  StreamSubscription<dynamic>? _languageSubscription;
  Map<String, String> _namePlaceholders =
      {}; // Map of placeholder -> original name
  bool _isExpanded = false;

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
  void didUpdateWidget(ReadMoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.collapsedText != widget.collapsedText ||
        oldWidget.expandedText != widget.expandedText ||
        oldWidget.namesToPreserve != widget.namesToPreserve) {
      _translateText();
    }
  }

  /// Extract names from text and replace with placeholders to preserve them during translation
  String _extractAndPreserveNames(String text) {
    _namePlaceholders.clear();
    String processedText = text;
    int placeholderIndex = 0;

    // First, preserve names from namesToPreserve list if provided
    if (widget.namesToPreserve != null) {
      for (final name in widget.namesToPreserve!) {
        if (name.trim().isNotEmpty && processedText.contains(name)) {
          final placeholder = '__NAME_${placeholderIndex}__';
          _namePlaceholders[placeholder] = name;
          processedText = processedText.replaceAll(name, placeholder);
          placeholderIndex++;
        }
      }
    }

    // Extract names from common patterns in notification messages
    // Pattern: names in quotes or after "from/by" etc.
    final namePatterns = [
      RegExp(r"'([A-Za-z\u0900-\u097F\s]{2,50})'", caseSensitive: false),
      RegExp(r'"([A-Za-z\u0900-\u097F\s]{2,50})"', caseSensitive: false),
      RegExp(
        r'\bfrom\s+([A-Za-z\u0900-\u097F\s]{2,50})\b',
        caseSensitive: false,
      ),
      RegExp(r'\bby\s+([A-Za-z\u0900-\u097F\s]{2,50})\b', caseSensitive: false),
      // Pattern for "Name's message" or "Name का संदेश" (Hindi possessive)
      RegExp(
        r'([A-Za-z\u0900-\u097F\s]{2,50})\s+(का|की|के)\s+',
        caseSensitive: false,
      ),
    ];

    for (final pattern in namePatterns) {
      final matches = pattern.allMatches(processedText);
      for (final match in matches) {
        if (match.groupCount >= 1) {
          final potentialName = match.group(1)?.trim();
          if (potentialName != null &&
              potentialName.isNotEmpty &&
              potentialName.length >= 2 &&
              potentialName.length <= 50 &&
              !_namePlaceholders.values.contains(potentialName)) {
            // Check if it's likely a name (not a common word)
            final commonWords = [
              'the',
              'and',
              'has',
              'was',
              'your',
              'this',
              'that',
              'with',
              'for',
              'are',
              'not',
              'but',
              'can',
              'her',
              'one',
              'all',
              'would',
              'there',
              'their',
              'what',
              'said',
              'each',
              'which',
              'she',
              'do',
              'how',
              'if',
              'will',
              'up',
              'other',
              'about',
              'out',
              'many',
              'then',
              'them',
              'these',
              'so',
              'some',
              'would',
              'make',
              'like',
              'into',
              'him',
              'time',
              'look',
              'two',
              'more',
              'write',
              'go',
              'see',
              'number',
              'no',
              'way',
              'could',
              'people',
              'my',
              'than',
              'first',
              'water',
              'been',
              'call',
              'who',
              'oil',
              'sit',
              'now',
              'find',
              'down',
              'day',
              'did',
              'get',
              'come',
              'made',
              'may',
              'part',
              'over',
              'new',
              'sound',
              'take',
              'only',
              'little',
              'work',
              'know',
              'place',
              'year',
              'live',
              'me',
              'back',
              'give',
              'most',
              'very',
              'after',
              'thing',
              'our',
              'just',
              'name',
              'good',
              'sentence',
              'man',
              'think',
              'say',
              'great',
              'where',
              'help',
              'through',
              'much',
              'before',
              'line',
              'right',
              'too',
              'mean',
              'old',
              'any',
              'same',
              'tell',
              'boy',
              'follow',
              'came',
              'want',
              'show',
              'also',
              'around',
              'form',
              'three',
              'small',
              'set',
              'put',
              'end',
              'does',
              'another',
              'well',
              'large',
              'must',
              'big',
              'even',
              'such',
              'because',
              'turn',
              'here',
              'why',
              'ask',
              'went',
              'men',
              'read',
              'need',
              'land',
              'different',
              'home',
              'us',
              'move',
              'try',
              'kind',
              'hand',
              'picture',
              'again',
              'change',
              'off',
              'play',
              'spell',
              'air',
              'away',
              'animal',
              'house',
              'point',
              'page',
              'letter',
              'mother',
              'answer',
              'found',
              'study',
              'still',
              'learn',
              'should',
              'America',
              'world',
              'high',
              'every',
              'near',
              'add',
              'food',
              'between',
              'own',
              'below',
              'country',
              'plant',
              'last',
              'school',
              'father',
              'keep',
              'tree',
              'never',
              'start',
              'city',
              'earth',
              'eye',
              'light',
              'thought',
              'head',
              'under',
              'story',
              'saw',
              'left',
              'don\'t',
              'few',
              'while',
              'along',
              'might',
              'close',
              'something',
              'seem',
              'next',
              'hard',
              'open',
              'example',
              'begin',
              'life',
              'always',
              'those',
              'both',
              'paper',
              'together',
              'got',
              'group',
              'often',
              'run',
              'important',
              'until',
              'children',
              'side',
              'feet',
              'car',
              'mile',
              'night',
              'walk',
              'white',
              'sea',
              'began',
              'grow',
              'took',
              'river',
              'four',
              'carry',
              'state',
              'once',
              'book',
              'hear',
              'stop',
              'without',
              'second',
              'later',
              'miss',
              'idea',
              'enough',
              'eat',
              'face',
              'watch',
              'far',
              'Indian',
              'really',
              'almost',
              'let',
              'above',
              'girl',
              'sometimes',
              'mountain',
              'cut',
              'young',
              'talk',
              'soon',
              'list',
              'song',
              'leave',
              'family',
              'it\'s',
            ];
            final lowerName = potentialName.toLowerCase();
            // Check if it's not a common word and is likely a name
            if (!commonWords.contains(lowerName) &&
                (!lowerName.contains(' ') ||
                    (lowerName.split(' ').length <= 3))) {
              final placeholder = '__NAME_${placeholderIndex}__';
              _namePlaceholders[placeholder] = potentialName;
              // Replace the name within the matched pattern
              processedText = processedText.replaceFirst(
                match.group(0)!,
                match.group(0)!.replaceAll(potentialName, placeholder),
              );
              placeholderIndex++;
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

  Future<void> _translateText() async {
    // Extract and preserve names before translation
    final textWithPlaceholders = _extractAndPreserveNames(widget.text);

    // If forceTranslation is true, always translate when app is in Hindi
    // This ensures notification messages like "complaint raised successfully" are translated
    // Even if the message contains some Hindi characters (like user names), we still translate
    // the English parts to Hindi
    if (widget.forceTranslation) {
      final locale = GeneralStream.instance.locale;
      final isHindiLocale = locale.languageCode == 'hi';

      if (isHindiLocale && widget.text.trim().isNotEmpty) {
        // Force translation for Hindi locale - bypass language detection
        // This ensures notification messages like "complaint raised successfully" or
        // "Your notify representative '...' was created successfully" are translated
        // even if they contain Hindi characters (user names, etc.)
        setState(() {
          _isTranslating = true;
          _translatedText = null;
          _translatedCollapsed = null;
          _translatedExpanded = null;
        });

        try {
          // Force translation by passing force=true to bypass language detection check
          // This will translate English text to Hindi even if the message contains some Hindi characters
          // Use text with placeholders so names are not translated
          final translated = await TranslationHelper.translateText(
            textWithPlaceholders,
            wordForWord: false,
            force: true,
          );
          final translatedCollapsed = await TranslationHelper.translateText(
            widget.collapsedText,
            wordForWord: false,
            force: true,
          );
          final translatedExpanded = await TranslationHelper.translateText(
            widget.expandedText,
            wordForWord: false,
            force: true,
          );
          if (mounted) {
            setState(() {
              // Restore names after translation
              _translatedText = _restoreNames(translated);
              _translatedCollapsed = translatedCollapsed;
              _translatedExpanded = translatedExpanded;
              _isTranslating = false;
            });
          }
          return;
        } catch (e) {
          if (mounted) {
            setState(() {
              _translatedText = widget.text;
              _translatedCollapsed = widget.collapsedText;
              _translatedExpanded = widget.expandedText;
              _isTranslating = false;
            });
          }
          return;
        }
      } else if (!isHindiLocale &&
          widget.forceTranslation &&
          widget.text.trim().isNotEmpty) {
        // If forceTranslation is true but locale is English, translate Hindi to English
        setState(() {
          _isTranslating = true;
          _translatedText = null;
          _translatedCollapsed = null;
          _translatedExpanded = null;
        });

        try {
          // Use text with placeholders so names are not translated
          final translated = await TranslationHelper.translateText(
            textWithPlaceholders,
            wordForWord: false,
            force: true,
          );
          final translatedCollapsed = await TranslationHelper.translateText(
            widget.collapsedText,
            wordForWord: false,
            force: true,
          );
          final translatedExpanded = await TranslationHelper.translateText(
            widget.expandedText,
            wordForWord: false,
            force: true,
          );
          if (mounted) {
            setState(() {
              // Restore names after translation
              _translatedText = _restoreNames(translated);
              _translatedCollapsed = translatedCollapsed;
              _translatedExpanded = translatedExpanded;
              _isTranslating = false;
            });
          }
          return;
        } catch (e) {
          if (mounted) {
            setState(() {
              _translatedText = widget.text;
              _translatedCollapsed = widget.collapsedText;
              _translatedExpanded = widget.expandedText;
              _isTranslating = false;
            });
          }
          return;
        }
      }
    }

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(widget.text);

    // Also check if app is in Hindi and text appears to be primarily English
    // This handles edge cases where needsTranslation might miss mixed-language messages
    final locale = GeneralStream.instance.locale;
    final isHindiLocale = locale.languageCode == 'hi';

    // Check if text contains Hindi characters
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    final hasHindiChars = hindiRegex.hasMatch(widget.text);

    // For mixed-language messages, check if it's primarily English
    // Count Hindi vs English characters to determine primary language
    bool isPrimarilyEnglish = false;
    if (hasHindiChars && widget.text.trim().isNotEmpty) {
      final hindiCharCount = hindiRegex.allMatches(widget.text).length;
      final totalCharCount = widget.text.replaceAll(RegExp(r'\s'), '').length;
      // If less than 30% of characters are Hindi, consider it primarily English
      isPrimarilyEnglish =
          totalCharCount > 0 && (hindiCharCount / totalCharCount) < 0.3;
    } else if (!hasHindiChars) {
      // No Hindi characters means it's English
      isPrimarilyEnglish = true;
    }

    // Force translation if app is in Hindi and text is primarily English
    // This ensures English notification messages (even with some Hindi words) are translated
    final shouldTranslate =
        needsTranslation ||
        (isHindiLocale &&
            isPrimarilyEnglish &&
            widget.text.trim().isNotEmpty) ||
        widget.forceTranslation;

    if (!shouldTranslate) {
      // No translation needed, show text immediately
      setState(() {
        _translatedText = widget.text;
        _translatedCollapsed = widget.collapsedText;
        _translatedExpanded = widget.expandedText;
        _isTranslating = false;
      });
      return;
    }

    // Translation is needed, show loading state
    setState(() {
      _isTranslating = true;
      _translatedText = null;
      _translatedCollapsed = null;
      _translatedExpanded = null;
    });

    try {
      // Use text with placeholders so names are not translated
      final translated = await TranslationHelper.translateText(
        textWithPlaceholders,
      );
      final translatedCollapsed = await TranslationHelper.translateText(
        widget.collapsedText,
      );
      final translatedExpanded = await TranslationHelper.translateText(
        widget.expandedText,
      );
      if (mounted) {
        setState(() {
          // Restore names after translation
          _translatedText = _restoreNames(translated);
          _translatedCollapsed = translatedCollapsed;
          _translatedExpanded = translatedExpanded;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _translatedCollapsed = widget.collapsedText;
          _translatedExpanded = widget.expandedText;
          _isTranslating = false;
        });
      }
    }
  }

  /// Builds a skeleton loading widget that matches the text style
  Widget _buildSkeleton() {
    final style = widget.style ?? AppStyles.bodySmall;
    final fontSize = style.fontSize ?? 14.0;
    final lineHeight = style.height ?? 1.2;
    final maxLines = widget.maxLines;
    final textWidth = widget.text.length;
    final estimatedLineWidth = (textWidth * fontSize * 0.6).clamp(50.0, 300.0);
    final lineHeightValue = fontSize * lineHeight;

    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          maxLines,
          (index) => Container(
            margin: EdgeInsets.only(
              bottom: index < maxLines - 1 ? lineHeightValue * 0.2 : 0,
            ),
            width: index == maxLines - 1
                ? estimatedLineWidth *
                      0.7 // Last line is shorter
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

    final resolvedStyle = (widget.style ?? AppStyles.bodySmall).copyWith(
      color: widget.style?.color ?? AppPalettes.lightTextColor,
      fontWeight: widget.style?.fontWeight ?? FontWeight.w400,
    );
    final linkStyle = resolvedStyle.copyWith(
      color: AppPalettes.primaryColor,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppPalettes.primaryColor,
    );
    final displayText = _translatedText ?? widget.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: ReadMoreText(
            displayText,
            trimLines: widget.maxLines,
            trimMode: TrimMode.Line,
            textAlign: TextAlign.left,
            trimCollapsedText:
                ' ${_translatedCollapsed ?? widget.collapsedText}',
            trimExpandedText: ' ${_translatedExpanded ?? widget.expandedText}',
            moreStyle: linkStyle,
            lessStyle: linkStyle,
            style: resolvedStyle,
          ),
        ),
        if (_isExpanded && widget.imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}
