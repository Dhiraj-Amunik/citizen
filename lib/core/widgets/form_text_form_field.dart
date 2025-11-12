import 'dart:async';
import 'dart:developer';

import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final bool? disableVoiceText;

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

    //Material
    this.elevation = 0.0,
    this.backgroundColor = AppPalettes.whiteColor,
    this.shadowColor,
    this.contentPadding,
    this.showCounterText,
    this.onComplete,
    this.labelStyle,
    this.labelText,
    this.isRequired,
    this.disableVoiceText,
  });

  @override
  State<FormTextFormField> createState() => _FormTextFormFieldState();
}

class _FormTextFormFieldState extends State<FormTextFormField> {
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  Timer? _statusCheckTimer;
  DateTime? _lastSpeechTime;

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    _resetSpeechState();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final respRadius = widget.radius ?? Dimens.radiusX4;
    final border = OutlineInputBorder(
      borderSide: widget.borderColor == null
          ? BorderSide.none
          : BorderSide(
              color: widget.borderColor ?? AppPalettes.transparentColor,
            ),
      borderRadius: BorderRadius.circular(respRadius),
    );
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.headingText != null)
          Text(
            "${widget.headingText!} ${widget.isRequired == true ? '*' : ''}",
            style: widget.headingStyle ?? context.textTheme.bodySmall,
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
          enabled: widget.enabled,
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
            hintText: widget.hintText,
            hintStyle:
                widget.textStyle ??
                context.textTheme.labelLarge?.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
            errorStyle: AppStyles.errorStyle,
            border: border,
            enabledBorder: border.copyWith(
              borderSide: BorderSide(
                color: isListening
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
                widget.maxLines == 1 ? 0 : (-(widget.maxLines! * 5) + 0.0),
              ),
              child:
                  widget.suffixWidget ??
                  GestureDetector(
                    onTap: _captureVoice,
                    child: Container(
                      child:
                          SvgPicture.asset(
                            widget.suffixIcon ?? AppImages.microphoneIcon,
                            colorFilter: isListening
                                ? ColorFilter.mode(
                                    AppPalettes.redColor,
                                    BlendMode.srcIn,
                                  )
                                : iconColor,
                            width: Dimens.scaleX2B,
                          ).onlyPadding(
                            left: Dimens.paddingX2,
                            right: Dimens.paddingX4,
                            top: Dimens.paddingX3B,
                            bottom: Dimens.paddingX3B,
                          ),
                    ),
                  ),
            ),
          ),
          maxLines: widget.maxLines,
          obscureText: widget.isPassword,
          obscuringCharacter: '.',
          validator: widget.validator,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onComplete,
          onFieldSubmitted: (submitValue) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          },
        ),
      ],
    );
  }

  void _captureVoice() async {
    if (widget.disableVoiceText == true) return;

    FocusScope.of(context).unfocus();

    if (isListening) {
      _resetSpeechState();
      return;
    }

    bool listen = await _speechToText.initialize(
      onStatus: (status) {
        log('Speech status: $status');

        final normalizedStatus = status.trim().toLowerCase();

        if (normalizedStatus !=
                stt.SpeechToText.listeningStatus.toLowerCase() &&
            !normalizedStatus.contains('listening') &&
            !normalizedStatus.contains('receiving')) {
          log('Resetting due to status: $status');
          _resetSpeechState();
        }

        if (normalizedStatus == stt.SpeechToText.doneStatus.toLowerCase() ||
            normalizedStatus.contains('done') ||
            normalizedStatus.contains('finished') ||
            normalizedStatus.contains('complete') ||
            normalizedStatus.contains('not listening')) {
          log('Resetting due to completion status: $status');
          _resetSpeechState();
        }
      },
      onError: (error) {
        log('Speech error: ${error.errorMsg}');
        _resetSpeechState();
        CommonSnackbar(
          text: 'Speech recognition error: ${error.errorMsg}',
        ).showToast();
      },
    );

    if (listen) {
      setState(() {
        isListening = true;
        _lastSpeechTime = DateTime.now();
      });

      _startStatusCheckTimer();

      await _speechToText
          .listen(
            onResult: (result) {
              widget.controller?.text = result.recognizedWords;
              _lastSpeechTime = DateTime.now();

              if (result.finalResult) {
                _resetSpeechState();
              }
            },
            listenFor: const Duration(
              minutes: 5,
            ), // Very long timeout as backup only
            pauseFor: const Duration(
              seconds: 3,
            ), // Auto-pause after 3 seconds of silence
          )
          .catchError((error) {
            log('Listen error: $error');
            _resetSpeechState();
          });
    } else {
      CommonSnackbar(text: 'Speech recognition not available').showToast();
    }
  }

  void _startStatusCheckTimer() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isListening) {
        timer.cancel();
        return;
      }

      if (_lastSpeechTime != null &&
          DateTime.now().difference(_lastSpeechTime!).inSeconds > 10) {
        log('No speech activity for 10 seconds, forcing reset');
        _resetSpeechState();
        timer.cancel();
        return;
      }

      try {
        log('Status check: speech recognition active check');
      } catch (e) {
        log('Status check error: $e');
      }
    });
  }

  void _resetSpeechState() {
    _statusCheckTimer?.cancel();

    if (isListening) {
      log('Resetting speech state from listening to false');
      setState(() => isListening = false);
    }

    try {
      _speechToText.stop();
    } catch (e) {
      log('Error stopping speech: $e');
    }

    _lastSpeechTime = null;
  }
}
