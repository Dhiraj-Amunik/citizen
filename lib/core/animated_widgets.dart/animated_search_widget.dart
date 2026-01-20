import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/hindi_keyboard.dart';
import 'package:inldsevak/l10n/general_stream.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String text) onChanged;
  final Function()? onClear;

  const AnimatedSearchBar({super.key, required this.onChanged, this.onClear ,required this.controller});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool showSearchField = true;
  bool _showHindiKeyboard = false;
  bool _isHindiLanguage = false;
  OverlayEntry? _keyboardOverlayEntry;
  StreamSubscription<Locale>? _languageSubscription;
  final FocusNode _focusNode = FocusNode();
  bool _isHandlingKeyboard = false; // Flag to prevent multiple simultaneous operations

  static final Color searchButtonColor = AppPalettes.liteGreenColor;

  Color get primaryColor => AppPalettes.liteGreenColor;

  @override
  void initState() {
    super.initState();
    // Initialize language check
    _isHindiLanguage = GeneralStream.instance.locale.languageCode == 'hi';
    
    // Listen to language changes
    _languageSubscription = GeneralStream.instance.language.listen((locale) {
      if (mounted) {
        final wasHindi = _isHindiLanguage;
        _isHindiLanguage = locale.languageCode == 'hi';
        
        // If language changed from Hindi to non-Hindi, hide keyboard
        if (wasHindi && !_isHindiLanguage) {
          _hideKeyboardOverlay();
          _focusNode.unfocus();
        }
      }
    });

    // Listen to focus changes
    _focusNode.addListener(_onFocusChange);
    
    // Listen to controller changes to trigger onChanged callback when Hindi keyboard updates text
    widget.controller.addListener(() {
      if (mounted && _showHindiKeyboard) {
        widget.onChanged(widget.controller.text);
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _hideKeyboardOverlay();
    super.dispose();
  }

  void _showKeyboardOverlay() {
    if (_keyboardOverlayEntry != null || !mounted) return;
    
    final overlay = Overlay.of(context);
    
    _keyboardOverlayEntry = OverlayEntry(
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              // Back button pressed - close keyboard instead of navigating
              _hideKeyboardOverlay();
              _focusNode.unfocus();
            }
          },
          child: Stack(
            children: [
              // Transparent barrier to catch taps outside keyboard
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _hideKeyboardOverlay();
                    _focusNode.unfocus();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Keyboard at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Material(
                  elevation: 8,
                  child: GestureDetector(
                    onTap: () {
                      // Prevent closing when tapping on keyboard itself
                    },
                    child: HindiKeyboard(
                      controller: widget.controller,
                      onDismiss: () {
                        _isHandlingKeyboard = true;
                        // Hide system keyboard first to prevent it from showing
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        _hideKeyboardOverlay();
                        // Unfocus after a small delay to ensure keyboard is hidden
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            _focusNode.unfocus();
                            _isHandlingKeyboard = false;
                          }
                        });
                      },
                      onEnter: () {
                        _isHandlingKeyboard = true;
                        // Hide system keyboard and dismiss Hindi keyboard first
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        _hideKeyboardOverlay();
                        // Unfocus the current field
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            _focusNode.unfocus();
                            _isHandlingKeyboard = false;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(_keyboardOverlayEntry!);
  }

  void _hideKeyboardOverlay({bool skipSetState = false}) {
    _keyboardOverlayEntry?.remove();
    _keyboardOverlayEntry = null;
    if (!skipSetState && mounted) {
      setState(() {
        _showHindiKeyboard = false;
      });
    } else {
      // If widget is disposed or skipSetState is true, just update the flag without setState
      _showHindiKeyboard = false;
    }
  }

  void _onFocusChange() {
    if (mounted && !_isHandlingKeyboard) {
      final hasFocus = _focusNode.hasFocus;
      
      if (hasFocus && _isHindiLanguage && !_showHindiKeyboard) {
        _isHandlingKeyboard = true;
        // Hide system keyboard first
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        // Wait a bit for system keyboard to hide before showing Hindi keyboard
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && _focusNode.hasFocus && !_showHindiKeyboard) {
            setState(() {
              _showHindiKeyboard = true;
            });
            _showKeyboardOverlay();
            _isHandlingKeyboard = false;
          } else {
            _isHandlingKeyboard = false;
          }
        });
      } else if (!hasFocus && _showHindiKeyboard) {
        // Close keyboard when focus is lost (e.g., tapping outside)
        _hideKeyboardOverlay();
        _isHandlingKeyboard = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: showSearchField ? Alignment.center : Alignment.centerRight,
      duration: Duration(milliseconds: 500), // Slightly slower - 500ms
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4
      ),
      child: Material(
        shadowColor: AppPalettes.shadowColor,
        borderRadius: BorderRadius.circular(360),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500), // Slightly slower - 500ms
          decoration: BoxDecoration(
            color: showSearchField ? primaryColor : searchButtonColor,
            borderRadius: BorderRadius.circular(360),
          ),
          child: CrossFade(
            show: showSearchField,
            hiddenChild: searchButton(),
            child: searchBar(),
          ),
        ),
      ),
    );
  }

  ///The [TextField & ClearButton] widgets will be placed in this row
  Widget searchBar() {
    return Row(
      children: [
        if (showSearchField)
          opacity(
            duration: Duration(milliseconds: 500), // Slightly slower - 500ms
            child: searchButton(enabled: false),
          ),
        searchField(),
        clearButton(),
      ],
    );
  }

  Widget searchField() {
    return Expanded(
      child: Builder(
        builder: (context) {
          final localization = context.localizations;
          return opacity(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              onChanged: widget.onChanged,
              // Remove onTap - let _onFocusChange handle it to avoid conflicts
              // Use keyboardType to prevent system keyboard when Hindi is active
              keyboardType: _isHindiLanguage ? TextInputType.none : TextInputType.text,
              readOnly: _isHindiLanguage && _showHindiKeyboard,
              style: AppStyles.bodyMedium,
              cursorColor: AppPalettes.blackColor,
              decoration: InputDecoration(
                hintText: localization.search,
                hintStyle: AppStyles.bodyMedium,
                border: InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchButton({bool enabled = true}) {
    return GestureDetector(
      onTap: enabled == false
          ? null
          : () {
              if (mounted) setState(() => showSearchField = true);
            },
      child: AnimatedPadding(
        padding: EdgeInsetsGeometry.all(Dimens.paddingX2B),
        duration: Duration(milliseconds: 500), // Slightly slower - 500ms
        child: Icon(
          CupertinoIcons.search,
          color: AppPalettes.primaryColor,
          size: Dimens.scaleX3,
        ),
      ),
    );
  }

  Widget clearButton() {
    return opacity(
      duration: Duration(milliseconds: 500), // Slightly slower - 500ms
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalettes.primaryColor,
          borderRadius: BorderRadius.circular(360),
        ),
        child: GestureDetector(
          onTap: () {
            widget.controller.clear();
            widget.onChanged('');
            if (_showHindiKeyboard) {
              _hideKeyboardOverlay();
              _focusNode.unfocus();
            }
            widget.onClear?.call();
          },
          child: Icon(
            CupertinoIcons.clear,
            color: AppPalettes.whiteColor,
            size: Dimens.scaleX2B,
          ).allPadding(Dimens.paddingX3),
        ),
      ),
    );
  }

  Widget opacity({required Widget child, Duration? duration}) {
    return AnimatedOpacity(
      opacity: showSearchField ? 1 : 0,
      duration:
          duration ?? Duration(milliseconds: 500), // Slightly slower - 500ms
      child: child,
    );
  }
}

class CrossFade extends StatelessWidget {
  final Widget child;
  final Widget? hiddenChild;
  final bool show;
  final EdgeInsets? padding;
  final bool useCenter;

  const CrossFade({
    super.key,
    required this.child,
    this.hiddenChild,
    this.show = false,
    this.padding,
    this.useCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: AnimatedCrossFade(
        firstChild: hiddenChild ?? Container(),
        secondChild: childX(),
        duration: Duration(milliseconds: 300), // Slightly slower cross-fade
        crossFadeState: show
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
      ),
    );
  }

  Widget childX() {
    if (useCenter) return Center(child: child);
    return child;
  }
}
