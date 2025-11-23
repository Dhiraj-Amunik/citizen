import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final bool? showCursor;
  final String? hintText;

  final TextStyle? textStyle;
  final TextStyle? headingStyle;
  final TextStyle? labelStyle;

  final int? maxLines;
  final int? maxLength;
  final bool isPassword;
  final bool enabled;
  final String? suffixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focus;
  final FocusNode? nextFocus;
  final String? prefixIcon;
  final void Function(String?)? onChanged;
  final TextInputType? keyboardType;
  final Function()? onTap;
  final VoidCallback? onComplete;
  final String? headingText;
  final String? labelText;
  final Color? borderColor;
  final double borderWidth;
  final double? radius;
  final Color? cursorColor;
  final Color? fillColor;
  final bool? alignLabel;
  final double? fontSize;
  final double elevation;
  final Color? backgroundColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final bool? showCounterText;
  final bool? isRequired;
  final bool enableSpeechInput;
  final void Function(String message)? onMicAvailabilityDenied;
  final bool showDefaultSuffix;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final bool enforceFirstLetterUppercase;

  const FormTextFormField({
    super.key,
    this.onTap,
    this.controller,
    this.hintText,
    this.textStyle,
    this.headingStyle,
    this.showCursor = true,
    this.maxLength,
    this.headingText,
    this.radius,
    this.cursorColor = AppPalettes.blackColor,
    this.borderColor,
    this.borderWidth = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.alignLabel = false,
    this.keyboardType = TextInputType.emailAddress,
    this.isPassword = false,
    this.focus,
    this.enabled = true,
    this.nextFocus,
    this.onChanged,
    this.suffixIcon,
    this.suffixWidget,
    this.validator,
    this.fillColor,
    this.fontSize,
    this.initialValue,
    this.elevation = 0.0,
    this.backgroundColor = AppPalettes.whiteColor,
    this.shadowColor,
    this.contentPadding,
    this.showCounterText,
    this.onComplete,
    this.labelStyle,
    this.labelText,
    this.isRequired,
    this.enableSpeechInput = false,
    this.onMicAvailabilityDenied,
    this.showDefaultSuffix = true,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.sentences,
    this.enforceFirstLetterUppercase = false,
  });

  @override
  State<FormTextFormField> createState() => _FormTextFormFieldState();
}

class _FormTextFormFieldState extends State<FormTextFormField>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  late final AnimationController _micPulseController;
  late final Animation<double> _micPulseAnimation;
  bool _isApplyingFormattedText = false;
  String _micSessionBaseText = '';

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _micPulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _handleMicTap() async {
    if (!widget.enableSpeechInput || widget.controller == null) return;

    if (!_isListening) {
      try {
        final available = await _speech.initialize(
          onStatus: _onSpeechStatus,
          onError: _onSpeechError,
        );
        if (!available) {
          final hasPermission = await _speech.hasPermission;
          final message = hasPermission
              ? 'Speech recognition is not supported on this device.'
              : 'Microphone permission is required for speech input.';
          _handleMicAvailabilityDenied(message);
          return;
        }
      } on PlatformException catch (error, _) {
        final message = _mapSpeechErrorToMessage(error);
        _handleMicAvailabilityDenied(message);
        return;
      } catch (_) {
        _handleMicAvailabilityDenied(
          'Something went wrong while starting speech input.',
        );
        return;
      }

      _micSessionBaseText = widget.controller?.text ?? '';
      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        );
      } on PlatformException catch (error, _) {
        if (error.code == 'notListening') {
          await _speech.stop();
        }
        final message = _mapSpeechErrorToMessage(error);
        _handleMicAvailabilityDenied(message);
        return;
      }
      setState(() {
        _isListening = true;
      });
      _micPulseController
        ..reset()
        ..repeat(reverse: true);
    } else {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      _stopMicAnimation();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.trim();
    final controller = widget.controller;
    if (controller != null) {
      var updatedText = _micSessionBaseText;

      if (updatedText.isNotEmpty && !_endsWithWhitespace(updatedText)) {
        updatedText += ' ';
      }

      if (recognizedWords.isNotEmpty) {
        updatedText += recognizedWords;
      }

      if (widget.enforceFirstLetterUppercase) {
        updatedText = _ensureFirstLetterUppercase(updatedText);
      }

      _updateControllerText(
        updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
      );

      widget.onChanged?.call(updatedText);
    }

    if (result.finalResult) {
      if (_isListening) {
        _speech.stop();
        setState(() {
          _isListening = false;
        });
        _stopMicAnimation();
      }
      _micSessionBaseText = widget.controller?.text ?? '';
    }
  }

  void _stopMicAnimation() {
    if (_micPulseController.isAnimating || _micPulseController.value != 0) {
      _micPulseController
        ..stop()
        ..reset();
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
      _stopMicAnimation();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    setState(() {
      _isListening = false;
    });
    _stopMicAnimation();
    _handleMicAvailabilityDenied(_mapSpeechError(error));
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _speech.stop();
    super.dispose();
  }
  Widget build(BuildContext context) {
    final respRadius = widget.radius ?? Dimens.radiusX4;
    final border = OutlineInputBorder(
      borderSide: widget.borderColor == null
          ? BorderSide.none
          : BorderSide(color: widget.borderColor ?? AppPalettes.transparentColor),
      borderRadius: BorderRadius.circular(respRadius),
    );
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.headingText != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TranslatedText(
                text: widget.headingText!,
                style: widget.headingStyle ?? context.textTheme.bodySmall,
              ),
              if (widget.isRequired == true)
                Text(
                  ' *',
                  style: widget.headingStyle ?? context.textTheme.bodySmall,
                ),
            ],
          ).onlyPadding(bottom: Dimens.gapX1B),
        TextFormField(
          initialValue: widget.initialValue,
          showCursor: widget.showCursor,
          cursorColor: widget.cursorColor,
          cursorErrorColor: widget.cursorColor,
          onTap: widget.onTap,
          maxLength: widget.maxLength,
          cursorHeight: Dimens.paddingX5,
          style: widget.textStyle ?? context.textTheme.bodySmall,
          focusNode: widget.focus,
          textCapitalization: widget.textCapitalization,
          enabled: widget.enabled,
          autovalidateMode: widget.autovalidateMode,
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: widget.fillColor,
            alignLabelWithHint: widget.alignLabel,
            counterText: widget.showCounterText == true ? null : "",
            counterStyle: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(
                  vertical: Dimens.paddingX3,
                  horizontal: Dimens.paddingX4,
                ),
            labelText: widget.labelText,
            labelStyle: widget.labelStyle ?? context.textTheme.bodySmall,
            hint: widget.hintText == null
                ? null
                : TranslatedText(
                    text: widget.hintText!,
                    style: widget.textStyle ??
                        context.textTheme.labelLarge?.copyWith(
                          color: AppPalettes.lightTextColor,
                        ),
                  ),
            errorStyle: AppStyles.errorStyle,
            border: border,
            enabledBorder: border.copyWith(
              borderSide: BorderSide(
                color: _isListening
                    ? AppPalettes.blackColor
                    : widget.fillColor != null
                    ? AppPalettes.blackColor
                    : AppPalettes.transparentColor,
              ),
            ),

            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppPalettes.blackColor),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: AppPalettes.redColor),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: AppPalettes.redColor),
            ),
            prefixIcon: widget.prefixIcon != null
                ? SvgPicture.asset(
                    widget.prefixIcon!,
                    colorFilter: iconColor,
                    height: 0,
                  ).onlyPadding(
                    left: Dimens.paddingX4,
                    right: Dimens.paddingX2,
                    top: Dimens.paddingX4,
                    bottom: Dimens.paddingX3B,
                  )
                : null,
            suffixIcon: Transform.translate(
              offset: Offset(
                0,
                widget.maxLines == 1
                    ? 0
                    : (-(widget.maxLines! * 5) + 0.0),
              ),
              child: widget.suffixWidget ??
                  (widget.showDefaultSuffix
                      ? _buildMicIcon(
                          iconColor: iconColor,
                        )
                      : const SizedBox.shrink()),
            ),
          ),
          maxLines: widget.maxLines,
          obscureText: widget.isPassword,
          obscuringCharacter: '.',
          validator: widget.validator,
          onChanged: (value) {
            if (_isApplyingFormattedText) {
              widget.onChanged?.call(value);
              return;
            }

            var updatedValue = value;

            if (widget.enforceFirstLetterUppercase &&
                value.trimLeft().isNotEmpty &&
                widget.controller != null) {
              final controller = widget.controller!;
              final selection = controller.selection;
              final formattedValue = _ensureFirstLetterUppercase(value);

              if (formattedValue != value) {
                _updateControllerText(
                  formattedValue,
                  selection: selection,
                );
                updatedValue = formattedValue;
              }
            }

            widget.onChanged?.call(updatedValue);
            _micSessionBaseText = updatedValue;
          },
          onEditingComplete: widget.onComplete,
          onFieldSubmitted: (submitValue) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          },
        ),
      ],
    );
  }

  Widget _buildMicIcon({required ColorFilter iconColor}) {
    final mic = SvgPicture.asset(
      widget.suffixIcon ?? AppImages.microphoneIcon,
      colorFilter: iconColor,
      width: Dimens.scaleX2B,
    ).onlyPadding(
      left: Dimens.paddingX2,
      right: Dimens.paddingX4,
      top: Dimens.paddingX3B,
      bottom: Dimens.paddingX3B,
    );

    if (!widget.enableSpeechInput || widget.suffixWidget != null) {
      return mic;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleMicTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimens.paddingX2,
          right: Dimens.paddingX4,
          top: Dimens.paddingX3B,
          bottom: Dimens.paddingX3B,
        ),
        child: SizedBox(
          width: Dimens.paddingX6,
          height: Dimens.paddingX6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                AnimatedBuilder(
                  animation: _micPulseController,
                  builder: (context, child) {
                    final scale = _micPulseAnimation.value;
                    final opacity =
                        ((1.3 - scale) / 0.3).clamp(0.0, 1.0).toDouble();
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: Dimens.paddingX6,
                        height: Dimens.paddingX6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalettes.primaryColor
                              .withOpacityExt(0.25 * opacity),
                        ),
                      ),
                    );
                  },
                ),
              if (_isListening)
                AnimatedBuilder(
                  animation: _micPulseController,
                  builder: (context, child) {
                    final scale = 1 + (_micPulseAnimation.value - 1) * 1.4;
                    final opacity =
                        ((_micPulseAnimation.value - 1) / 0.25).clamp(0.0, 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: Dimens.paddingX6,
                        height: Dimens.paddingX6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppPalettes.primaryColor
                                .withOpacityExt(0.35 * opacity),
                            width: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              SvgPicture.asset(
                widget.suffixIcon ?? AppImages.microphoneIcon,
                colorFilter: _isListening
                    ? ColorFilter.mode(AppPalettes.primaryColor, BlendMode.srcIn)
                    : iconColor,
                width: Dimens.scaleX2B,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mapSpeechErrorToMessage(PlatformException exception) {
    switch (exception.code) {
      case 'recognizerNotAvailable':
      case 'notAvailableOnDevice':
        return 'Speech recognition is not available on this device.';
      case 'notListening':
        return 'Unable to start listening. Please try again.';
      case 'audioError':
        return 'Microphone is unavailable.';
      case 'network':
        return 'Network error occurred while using speech recognition.';
      default:
        return exception.message ??
            'Unable to start speech recognition. Please try again.';
    }
  }

  String _mapSpeechError(SpeechRecognitionError error) {
    switch (error.errorMsg) {
      case 'error_network':
      case 'error_network_timeout':
        return 'Network error occurred while using speech recognition.';
      case 'error_audio':
        return 'Microphone is unavailable.';
      case 'error_no_match':
        return 'No speech recognized. Please try speaking again.';
      case 'error_insufficient_permissions':
        return 'Microphone permission is required for speech input.';
      case 'error_client':
      case 'client_error':
        return 'Speech recognition client error occurred.';
      default:
        return error.errorMsg.isNotEmpty
            ? error.errorMsg
            : 'Unable to continue speech recognition. Please try again.';
    }
  }

  void _handleMicAvailabilityDenied(String message) {
    final safeMessage = message.trim().isEmpty
        ? 'Voice input is currently unavailable.'
        : message.trim();
    if (widget.onMicAvailabilityDenied != null) {
      widget.onMicAvailabilityDenied!(safeMessage);
    } else {
      CommonSnackbar(text: safeMessage).showSnackbar();
    }
  }

  String _ensureFirstLetterUppercase(String value) {
    if (value.isEmpty) return value;

    final trimmedLeft = value.trimLeft();
    if (trimmedLeft.isEmpty) return value;

    final leadingSpaceCount = value.length - trimmedLeft.length;
    final leadingSpaces =
        leadingSpaceCount > 0 ? value.substring(0, leadingSpaceCount) : '';
    final firstChar = trimmedLeft[0];
    final remaining = trimmedLeft.substring(1);

    if (_isLetter(firstChar) && firstChar != firstChar.toUpperCase()) {
      return '$leadingSpaces${firstChar.toUpperCase()}$remaining';
    }

    return value;
  }

  bool _isLetter(String character) {
    if (character.isEmpty) return false;
    final codeUnit = character.codeUnitAt(0);
    return (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }

  bool _endsWithWhitespace(String value) {
    if (value.isEmpty) return false;
    final lastChar = value[value.length - 1];
    return lastChar.trim().isEmpty;
  }

  void _updateControllerText(
    String text, {
    TextSelection? selection,
  }) {
    if (widget.controller == null) return;

    _isApplyingFormattedText = true;

    final validatedSelection = selection != null
        ? selection.copyWith(
            baseOffset: _clampSelectionOffset(selection.baseOffset, text.length),
            extentOffset:
                _clampSelectionOffset(selection.extentOffset, text.length),
          )
        : TextSelection.collapsed(offset: text.length);

    widget.controller!.value = widget.controller!.value.copyWith(
      text: text,
      selection: validatedSelection,
      composing: TextRange.empty,
    );

    _isApplyingFormattedText = false;
  }

  int _clampSelectionOffset(int offset, int max) {
    if (offset < 0) return 0;
    if (offset > max) return max;
    return offset;
  }
}