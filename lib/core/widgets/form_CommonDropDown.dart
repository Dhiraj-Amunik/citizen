import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:flutter/cupertino.dart';

class FormCommonDropDown<T> extends StatefulWidget {
  final String? Function(T?)? validator;
  final String? heading;
  final String? hintText;
  final SingleSelectController<T>? controller;
  final List<T>? items;
  final T? initialData;
  final dynamic Function(T?)? onChanged;
  final String? prefixIcon;
  final Widget Function(BuildContext, T, bool, void Function())?
  listItemBuilder;
  final Widget Function(BuildContext, T, bool)? headerBuilder;
  final double? radius;
  final Color? backgroundColor;
  final bool? isRequired;
  final bool excludeSelected;

  const FormCommonDropDown({
    super.key,
    this.heading,
    this.hintText,
    this.items,
    this.validator,
    this.controller,
    this.onChanged,
    this.headerBuilder,
    this.listItemBuilder,
    this.prefixIcon,
    this.initialData,
    this.radius,
    this.backgroundColor = AppPalettes.whiteColor,
    this.isRequired,
    this.excludeSelected=true,
  });

  @override
  State<FormCommonDropDown<T>> createState() => _FormCommonDropDownState<T>();
}

class _FormCommonDropDownState<T> extends State<FormCommonDropDown<T>> {
  String? _translatedHintText;

  /// Helper method to get object ID (sId, id, or _id property) for comparison
  dynamic _getObjectId(dynamic obj) {
    if (obj == null) return null;
    try {
      // Try common ID property names using dynamic access
      final dynamic sId = (obj as dynamic).sId;
      if (sId != null) return sId;
      final dynamic id = (obj as dynamic).id;
      if (id != null) return id;
    } catch (e) {
      // Property doesn't exist or can't be accessed
    }
    return null;
  }

  /// Validate and fix controller value to ensure it exists in items list
  /// This prevents CustomDropdown assertion errors
  /// Returns true if controller value is valid, false if it needs to be cleared
  bool _validateControllerValue(List<T> effectiveItems) {
    if (widget.controller == null) return true;
    
    final currentValue = widget.controller!.value;
    
    // If controller has no value, it's valid
    if (currentValue == null) return true;
    
    // If items list is empty, value is invalid
    if (effectiveItems.isEmpty) return false;
    
    // First try object equality (fastest and most reliable)
    bool hasMatch = effectiveItems.contains(currentValue);
    
    // If no match by object equality, try to find by comparing ID properties
    // This handles cases where objects are different instances but represent the same item
    // (e.g., Constituency objects with same sId but different instances)
    if (!hasMatch) {
      try {
        // Check if the value has an sId property (for models like Constituency)
        final valueId = _getObjectId(currentValue);
        if (valueId != null && valueId is String) {
          // Find matching item by comparing IDs
          for (final item in effectiveItems) {
            if (item == null) continue;
            final itemId = _getObjectId(item);
            if (itemId != null && itemId == valueId) {
              // Found match by ID - schedule update after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && widget.controller != null) {
                  widget.controller!.value = item;
                }
              });
              return true; // Valid, will be updated after build
            }
          }
        }
      } catch (e) {
        // If ID comparison fails, value is invalid
        debugPrint('Error checking object ID in FormCommonDropDown: $e');
      }
    }
    
    return hasMatch;
  }
  
  /// Fix controller value after build if it was invalid
  void _fixControllerValueAfterBuild(List<T> effectiveItems) {
    if (widget.controller == null) return;
    
    final currentValue = widget.controller!.value;
    if (currentValue == null) return;
    
    // Defer controller operations to after build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.controller == null) return;
      
      // Re-check current value after frame callback
      final value = widget.controller!.value;
      if (value == null) return;
      
      // If items list is empty, clear controller
      if (effectiveItems.isEmpty) {
        widget.controller!.clear();
        return;
      }
      
      // Check if value is still invalid
      if (!effectiveItems.contains(value)) {
        // Try to find by ID
        bool found = false;
        try {
          final valueId = _getObjectId(value);
          if (valueId != null && valueId is String) {
            for (final item in effectiveItems) {
              if (item == null) continue;
              final itemId = _getObjectId(item);
              if (itemId != null && itemId == valueId) {
                widget.controller!.value = item;
                found = true;
                break;
              }
            }
          }
        } catch (e) {
          debugPrint('Error fixing controller value: $e');
        }
        
        // If still not found, clear the controller
        if (!found) {
          widget.controller!.clear();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _translateHintText();
  }

  @override
  void didUpdateWidget(FormCommonDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hintText != widget.hintText) {
      _translateHintText();
    }
  }

  Future<void> _translateHintText() async {
    if (widget.hintText == null || widget.hintText!.isEmpty) {
      setState(() {
        _translatedHintText = widget.hintText;
      });
      return;
    }

    // Check if translation is needed
    final needsTranslation = TranslationHelper.needsTranslation(widget.hintText);
    
    if (!needsTranslation) {
      setState(() {
        _translatedHintText = widget.hintText;
      });
      return;
    }

    // Show original text immediately while translating
    setState(() {
      _translatedHintText = widget.hintText;
    });

    // Translate in background
    try {
      final translated = await TranslationHelper.translateText(widget.hintText);
      if (mounted) {
        setState(() {
          _translatedHintText = translated;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedHintText = widget.hintText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final respRadius = widget.radius ?? Dimens.radiusX4;
    final border = Border.fromBorderSide(BorderSide.none);
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    final effectiveItems = widget.items ?? const [];

    // Validate controller value BEFORE building CustomDropdown
    // If invalid, temporarily use null to prevent assertion error
    final isValid = _validateControllerValue(effectiveItems);
    final controllerToUse = (isValid || widget.controller == null) 
        ? widget.controller 
        : null; // Temporarily use null if invalid
    
    // Schedule fix after build if needed
    if (!isValid && widget.controller != null) {
      _fixControllerValueAfterBuild(effectiveItems);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heading?.isNotEmpty == true)
          Text(
            "${widget.heading!} ${widget.isRequired ==true?'*':''}",
            style: context.textTheme.bodySmall,
          ).onlyPadding(bottom: Dimens.gapX1B),
        Listener(
          onPointerDown: (_) {
            // Dismiss keyboard when tapping on dropdown
            // This fires before the dropdown processes the tap, so it won't interfere
            FocusScope.of(context).unfocus();
            // Also hide system keyboard
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: Builder(
            builder: (context) {
              return CustomDropdown<T>(
                // overlayHeight: Dimens.screenHeight / 3,
                controller: controllerToUse,
                initialItem: widget.initialData,
          headerBuilder: widget.headerBuilder,
          listItemBuilder: widget.listItemBuilder,
          itemsListPadding: EdgeInsets.only(
            left: Dimens.paddingX5,
            right: Dimens.paddingX5,
          ),
          closedHeaderPadding: EdgeInsets.symmetric(
            vertical: Dimens.paddingX3,
            horizontal: Dimens.paddingX4,
          ),
          listItemPadding: EdgeInsets.only(bottom: Dimens.paddingX3),
          expandedHeaderPadding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX5,
            vertical: Dimens.paddingX3B,
          ),
          decoration: CustomDropdownDecoration(
            headerStyle: context.textTheme.bodySmall,
            listItemStyle: context.textTheme.bodySmall,
            hintStyle: context.textTheme.labelLarge?.copyWith(
              color: AppPalettes.lightTextColor,
            ),
            errorStyle: AppStyles.errorStyle,
            prefixIcon: widget.prefixIcon != null
                ? SvgPicture.asset(
                    widget.prefixIcon!,
                    colorFilter: iconColor,
                    height: 22.spMax,
                  ).onlyPadding(left: Dimens.paddingX1B)
                : null,
            closedFillColor: AppPalettes.liteGreyColor,
            expandedFillColor: widget.backgroundColor,
            closedBorderRadius: BorderRadius.circular(respRadius),
            expandedBorderRadius: BorderRadius.circular(respRadius),
            closedErrorBorderRadius: BorderRadius.circular(respRadius),
            closedErrorBorder: Border.fromBorderSide(
              BorderSide(width: 1, color: AppPalettes.redColor),
            ),
            expandedBorder: border,
            closedBorder: border,
          ),
                hintText: _translatedHintText ?? widget.hintText,
                items: effectiveItems,
                excludeSelected: widget.excludeSelected,
                onChanged: widget.onChanged,
                validator: widget.validator,
              );
            },
          ),
        ),
      ],
    );
  }
}
