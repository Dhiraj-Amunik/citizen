import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class HindiKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onBackspace;
  final VoidCallback? onEnter;
  final VoidCallback? onSpace;
  final VoidCallback? onDismiss;

  const HindiKeyboard({
    super.key,
    required this.controller,
    this.onBackspace,
    this.onEnter,
    this.onSpace,
    this.onDismiss,
  });

  @override
  State<HindiKeyboard> createState() => _HindiKeyboardState();
}

class _HindiKeyboardState extends State<HindiKeyboard> {
  bool _isNumbersMode = false;

  // Hindi keyboard layout - QWERTY style
  // Standalone vowels (swar) - first row
  final List<String> _standaloneVowels = [
    'अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ',
  ];
  
  // Additional standalone vowels and special characters
  final List<String> _specialVowels = [
    'अं', 'अः', 'ऋ', 'ॠ',
  ];
  
  // Consonants (vyanjan) - main keyboard
  final List<List<String>> _hindiKeys = [
    ['क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ'],
    ['ट', 'ठ', 'ड', 'ढ', 'ण', 'त', 'थ', 'द', 'ध', 'न'],
    ['प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श'],
    ['ष', 'स', 'ह', 'क्ष', 'त्र', 'ज्ञ'],
  ];

  final List<List<String>> _numberKeys = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  ];

  // Special characters for email and address input
  final List<String> _specialChars = ['@', '.', ',', '/', '-'];

  final List<String> _vowels = ['ा', 'ि', 'ी', 'ु', 'ू', 'े', 'ै', 'ो', 'ौ', 'ं', 'ः', '्'];

  void _insertText(String text) {
    final selection = widget.controller.selection;
    final textValue = widget.controller.text;
    
    String newText;
    int newCursorPosition;
    
    if (selection.isValid) {
      // Replace selected text
      newText = textValue.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      newCursorPosition = selection.start + text.length;
    } else {
      // Insert at cursor or append
      final cursorPosition = selection.baseOffset;
      if (cursorPosition >= 0 && cursorPosition <= textValue.length) {
        newText = textValue.replaceRange(
          cursorPosition,
          cursorPosition,
          text,
        );
        newCursorPosition = cursorPosition + text.length;
      } else {
        // Append to end
        newText = textValue + text;
        newCursorPosition = newText.length;
      }
    }
    
    // Always use value setter to ensure listeners are triggered
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  void _handleKeyPress(String key) {
    HapticFeedback.lightImpact();
    _insertText(key);
  }

  void _handleBackspace() {
    HapticFeedback.lightImpact();
    final selection = widget.controller.selection;
    final textValue = widget.controller.text;
    
    if (selection.isValid && selection.start > 0) {
      final newText = textValue.replaceRange(
        selection.start - 1,
        selection.end,
        '',
      );
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    } else if (textValue.isNotEmpty) {
      widget.controller.text = textValue.substring(0, textValue.length - 1);
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }
    widget.onBackspace?.call();
  }

  void _handleSpace() {
    HapticFeedback.lightImpact();
    _insertText(' ');
    widget.onSpace?.call();
  }

  void _handleEnter() {
    HapticFeedback.lightImpact();
    // onEnter now handles dismissing the keyboard and calling onComplete
    // This prevents the system keyboard from showing
    widget.onEnter?.call();
  }

  Widget _buildKey({
    required String text,
    VoidCallback? onTap,
    double? width,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 35.sp,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppPalettes.whiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppPalettes.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalettes.blackColor.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: context.textTheme.labelMedium?.copyWith(
             
              fontWeight: FontWeight.w500,
              color: textColor ?? AppPalettes.blackColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 38,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: AppPalettes.greyColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppPalettes.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalettes.blackColor.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
                      child: Icon(
                        icon,
                        size: 18,
                        color: AppPalettes.blackColor,
                      ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keysToShow = _isNumbersMode ? _numberKeys : _hindiKeys;

    return Container(
      decoration: BoxDecoration(
        color: AppPalettes.liteGreyColor,
        border: Border(
          top: BorderSide(
            color: AppPalettes.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalettes.blackColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with numbers/symbols toggle and dismiss
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX2,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Numbers toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isNumbersMode = !_isNumbersMode;
                    });
                    HapticFeedback.lightImpact();
                  },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.paddingX2,
                        vertical: 4,
                      ),
                    decoration: BoxDecoration(
                      color: _isNumbersMode
                          ? AppPalettes.primaryColor
                          : AppPalettes.whiteColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppPalettes.borderColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _isNumbersMode ? 'क' : '123',
                      style: context.textTheme.labelMedium?.copyWith(
                   
                        fontWeight: FontWeight.w600,
                        color: _isNumbersMode
                            ? AppPalettes.whiteColor
                            : AppPalettes.blackColor,
                      ),
                    ),
                  ),
                ),
                // Dismiss button
                if (widget.onDismiss != null)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onDismiss?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.all(Dimens.paddingX2),
                      decoration: BoxDecoration(
                        color: AppPalettes.whiteColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppPalettes.borderColor.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.keyboard_hide,
                        size: 16,
                        color: AppPalettes.blackColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Main keyboard rows
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX2,
              vertical: Dimens.paddingX1,
            ),
            child: Column(
              children: [
                // Standalone vowels row (only show when not in numbers mode)
                if (!_isNumbersMode)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _standaloneVowels.map((vowel) {
                              return Expanded(
                                child: _buildKey(
                                  text: vowel,
                                  onTap: () => _handleKeyPress(vowel),
                                  fontSize: 16,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Special vowels row (अं, अः, ऋ, ॠ)
                if (!_isNumbersMode)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _specialVowels.map((vowel) {
                              return Expanded(
                                child: _buildKey(
                                  text: vowel,
                                  onTap: () => _handleKeyPress(vowel),
                                  fontSize: 14,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Hindi/Number keys (consonants or numbers)
                for (final row in keysToShow)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: row.map((key) {
                              return Expanded(
                                child: _buildKey(
                                  text: key,
                                  onTap: () => _handleKeyPress(key),
                                  fontSize: 16,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Special characters row (only show in numbers mode)
                if (_isNumbersMode)
                  Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _specialChars.map((char) {
                              return Expanded(
                                child: _buildKey(
                                  text: char,
                                  onTap: () => _handleKeyPress(char),
                                  fontSize: 16,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Vowel matras row
                if (!_isNumbersMode)
                  Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _vowels.map((vowel) {
                              return Expanded(
                                child: _buildKey(
                                  text: vowel,
                                  onTap: () => _handleKeyPress(vowel),
                                  fontSize: 14,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Bottom row with special keys
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      // Backspace
                      _buildSpecialKey(
                        text: '',
                        icon: Icons.backspace_outlined,
                        onTap: _handleBackspace,
                        width: 50,
                      ),
                      SizedBox(width: 3),
                      // Space
                      Expanded(
                        child: _buildKey(
                          text: 'Space',
                          onTap: _handleSpace,
                          backgroundColor: AppPalettes.whiteColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 3),
                      // Enter
                      _buildSpecialKey(
                        text: '',
                        icon: Icons.keyboard_return,
                        onTap: _handleEnter,
                        width: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

