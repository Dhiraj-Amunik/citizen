import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:shimmer/shimmer.dart';

/// Widget that automatically translates text based on current locale
class TranslatedText extends StatefulWidget {
  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const TranslatedText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? _translatedText;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
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

    // Translation is needed, show loading state
    setState(() {
      _isTranslating = true;
      _translatedText = null;
    });

    try {
      final translated = await TranslationHelper.translateText(widget.text);
      if (mounted) {
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isTranslating = false;
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

