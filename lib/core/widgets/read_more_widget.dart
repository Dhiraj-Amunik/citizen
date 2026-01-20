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
  const ReadMoreWidget({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.style,
    String? collapsedText,
    String? expandedText,
    this.forceTranslation = false,
  })  : collapsedText = collapsedText ?? 'Read more',
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
        oldWidget.expandedText != widget.expandedText) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
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
          final translated = await TranslationHelper.translateText(widget.text, wordForWord: false, force: true);
          final translatedCollapsed = await TranslationHelper.translateText(widget.collapsedText, wordForWord: false, force: true);
          final translatedExpanded = await TranslationHelper.translateText(widget.expandedText, wordForWord: false, force: true);
          if (mounted) {
            setState(() {
              _translatedText = translated;
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
      } else if (!isHindiLocale && widget.forceTranslation && widget.text.trim().isNotEmpty) {
        // If forceTranslation is true but locale is English, translate Hindi to English
        setState(() {
          _isTranslating = true;
          _translatedText = null;
          _translatedCollapsed = null;
          _translatedExpanded = null;
        });
        
        try {
          final translated = await TranslationHelper.translateText(widget.text, wordForWord: false, force: true);
          final translatedCollapsed = await TranslationHelper.translateText(widget.collapsedText, wordForWord: false, force: true);
          final translatedExpanded = await TranslationHelper.translateText(widget.expandedText, wordForWord: false, force: true);
          if (mounted) {
            setState(() {
              _translatedText = translated;
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
      isPrimarilyEnglish = totalCharCount > 0 && (hindiCharCount / totalCharCount) < 0.3;
    } else if (!hasHindiChars) {
      // No Hindi characters means it's English
      isPrimarilyEnglish = true;
    }
    
    // Force translation if app is in Hindi and text is primarily English
    // This ensures English notification messages (even with some Hindi words) are translated
    final shouldTranslate = needsTranslation || (isHindiLocale && isPrimarilyEnglish && widget.text.trim().isNotEmpty) || widget.forceTranslation;
    
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
      final translated = await TranslationHelper.translateText(widget.text);
      final translatedCollapsed =
          await TranslationHelper.translateText(widget.collapsedText);
      final translatedExpanded =
          await TranslationHelper.translateText(widget.expandedText);
      if (mounted) {
        setState(() {
          _translatedText = translated;
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
    return ReadMoreText(
      displayText,
      trimLines: widget.maxLines,
      trimMode: TrimMode.Line,
      textAlign: TextAlign.left,
      trimCollapsedText: ' ${_translatedCollapsed ?? widget.collapsedText}',
      trimExpandedText: ' ${_translatedExpanded ?? widget.expandedText}',
      moreStyle: linkStyle,
      lessStyle: linkStyle,
      style: resolvedStyle,
    );
  }
}
