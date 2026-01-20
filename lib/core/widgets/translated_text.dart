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
        try {
          final translated = await TranslationHelper.translateText(
            widget.text,
            wordForWord: widget.wordForWord,
            force: true,
          );
          if (mounted) {
            setState(() {
              _translatedText = translated;
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
    try {
      final translated = await TranslationHelper.translateText(
        widget.text,
        wordForWord: widget.wordForWord,
      );
      if (mounted) {
        setState(() {
          _translatedText = translated;
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