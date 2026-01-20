import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:shimmer/shimmer.dart';

/// Widget that transliterates text (converts script without changing meaning)
/// Perfect for names and proper nouns - converts English to Devanagari script
/// Uses devlipi package for accurate transliteration
class TransliteratedText extends StatefulWidget {
  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const TransliteratedText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  State<TransliteratedText> createState() => _TransliteratedTextState();
}

class _TransliteratedTextState extends State<TransliteratedText> {
  String? _transliteratedText;
  bool _isTransliterating = false;
  StreamSubscription<dynamic>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _transliterateText();
    // Listen to language changes for instant retransliteration
    _languageSubscription = GeneralStream.instance.language.listen((_) {
      if (mounted) {
        _transliterateText();
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransliteratedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _transliterateText();
    }
  }

  void _transliterateText() {
    if (widget.text == null || widget.text!.isEmpty) {
      setState(() {
        _transliteratedText = widget.text;
        _isTransliterating = false;
      });
      return;
    }

    // Always use transliteration (transliterateToHindi handles locale check internally)
    // This ensures perfect transliteration, not translation
    try {
      final transliterated = TranslationHelper.transliterateToHindi(widget.text!);
      if (mounted) {
        setState(() {
          _transliteratedText = transliterated;
          _isTransliterating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transliteratedText = widget.text;
          _isTransliterating = false;
        });
      }
    }
  }

  /// Builds a skeleton loading widget that matches the text style
  Widget _buildSkeleton() {
    final style = widget.style ?? const TextStyle();
    final fontSize = style.fontSize ?? 14.0;
    final lineHeight = style.height ?? 1.2;
    final maxLines = widget.maxLines ?? 1;
    final textWidth = widget.text?.length ?? 50;
    final estimatedLineWidth = (textWidth * fontSize * 0.6).clamp(50.0, 300.0);
    final lineHeightValue = fontSize * lineHeight;
    
    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
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
    // Show skeleton loading while transliterating (shouldn't happen as it's instant)
    if (_isTransliterating) {
      return _buildSkeleton();
    }
    
    // Show transliterated text or original if transliteration not needed
    final displayText = _transliteratedText ?? widget.text ?? '';
    
    return Text(
      displayText,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }
}

