import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/managers/speech_input_manager.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/hindi_keyboard.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:shimmer/shimmer.dart';
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
  final int? minChar;
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
  final bool showBorder;
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
  final List<TextInputFormatter>? inputFormatters;
  final bool useEnglishKeyboard;
  final bool disableHindiKeyboardOverlay; // When true, keyboard won't be shown as overlay (parent will handle it)

  const FormTextFormField({
    super.key,
    this.onTap,
    this.controller,
    this.hintText,
    this.textStyle,
    this.headingStyle,
    this.showCursor = true,
    this.maxLength,
    this.minChar,
    this.headingText,
    this.radius,
    this.cursorColor = AppPalettes.blackColor,
    this.borderColor,
    this.borderWidth = 1,
    this.showBorder = true,
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
    this.inputFormatters,
    this.useEnglishKeyboard = false,
    this.disableHindiKeyboardOverlay = false,
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
  String _lastRecognizedWords = ''; // Track last recognized words to prevent duplication
  int _micInsertOffset = 0; // Track where mic session text starts in controller
  bool _isTranslating = false;
  StreamSubscription<Locale>? _languageSubscription;
  StreamSubscription<Object?>? _stopListeningSubscription;
  bool _showHindiKeyboard = false;
  bool _isHindiLanguage = false;
  OverlayEntry? _keyboardOverlayEntry;
  Timer? _keyboardHideTimer; // Timer to continuously hide system keyboard when Hindi keyboard is shown
  bool _speechInitialized = false; // Track if speech recognition is initialized
  bool _isInitializingSpeech = false; // Track if initialization is in progress
  
  // Unique identifier for this widget instance
  final Object _listenerId = Object();
  
  // Static set to track all active Hindi keyboard overlays
  static final Set<_FormTextFormFieldState> _activeHindiKeyboards = {};

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
          // Unfocus to hide system keyboard if needed
          widget.focus?.unfocus();
        } else if (!wasHindi && _isHindiLanguage) {
          // Language changed to Hindi - set up focus interception
          _interceptFocusForHindiKeyboard();
        }
      }
    });

    // Listen to stop listening notifications from manager
    // This ensures only one mic is active at a time
    _stopListeningSubscription = SpeechInputManager.instance.stopListeningStream.listen(
      (stoppedListenerId) {
        // Stop listening if:
        // - Notification is null (stop all listeners), OR
        // - Notification is for another listener (a new listener started)
        // Don't stop if notification is for us (we're the new listener)
        if (mounted && 
            (stoppedListenerId == null || stoppedListenerId != _listenerId) &&
            _isListening) {
          _stopListening();
        }
      },
    );

    // Listen to focus changes
    widget.focus?.addListener(_onFocusChange);
    
    // Intercept focus requests to hide keyboard immediately when Hindi keyboard should be shown
    if (widget.focus != null && !widget.useEnglishKeyboard && _isHindiLanguage) {
      _interceptFocusForHindiKeyboard();
    }
    
    // Listen to controller changes to trigger onChanged when Hindi keyboard updates text
    if (widget.controller != null) {
      widget.controller!.addListener(_onControllerChanged);
    }
    
    // Pre-initialize speech recognition if speech input is enabled
    // This prevents initialization issues on first mic tap
    if (widget.enableSpeechInput) {
      _initializeSpeechRecognition();
    }
  }
  
  /// Initialize speech recognition service early to prevent first-use issues
  Future<void> _initializeSpeechRecognition() async {
    if (_speechInitialized || _isInitializingSpeech) {
      return; // Already initialized or in progress
    }
    
    _isInitializingSpeech = true;
    
    try {
      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      
      if (mounted) {
        _speechInitialized = available;
        if (!available) {
          developer.log('⚠️ [FormTextFormField] Speech recognition not available during pre-initialization');
        } else {
          developer.log('✅ [FormTextFormField] Speech recognition pre-initialized successfully');
        }
      }
    } catch (e) {
      developer.log('⚠️ [FormTextFormField] Speech recognition pre-initialization failed: $e');
      // Don't set _speechInitialized to true on error - will retry on mic tap
    } finally {
      if (mounted) {
        _isInitializingSpeech = false;
      }
    }
  }
  
  void _onControllerChanged() {
    // Manually trigger onChanged callback when controller is updated programmatically
    // This is needed when Hindi keyboard updates the controller
    if (widget.onChanged != null && widget.controller != null) {
      widget.onChanged!(widget.controller!.text);
    }
  }

  bool _shouldShowHindiKeyboard() {
    // Don't show Hindi keyboard if useEnglishKeyboard is true
    if (widget.useEnglishKeyboard) return false;
    
    // Don't show Hindi keyboard for:
    // - Fields with no keyboard
    // - Numeric input types (number, phone, etc.)
    // - Date/time pickers
    if (widget.keyboardType == null) return false;
    
    final keyboardType = widget.keyboardType!;
    
    // Exclude standard numeric keyboard types
    if (keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.none) {
      return false;
    }
    
    // Check for numberWithOptions and other numeric variants
    // by examining the string representation (most reliable cross-platform method)
    final typeString = keyboardType.toString().toLowerCase();
    if (typeString.contains('number') || 
        typeString.contains('phone') ||
        typeString.contains('numeric')) {
      return false;
    }
    
    return true;
  }

  /// Check if the keyboard type is a number field
  bool _isNumberField(TextInputType? keyboardType) {
    if (keyboardType == null) return false;
    
    // Check standard numeric keyboard types
    if (keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone) {
      return true;
    }
    
    // Check for numberWithOptions and other numeric variants
    // by examining the string representation (most reliable cross-platform method)
    final typeString = keyboardType.toString().toLowerCase();
    if (typeString.contains('number') || 
        typeString.contains('phone') ||
        typeString.contains('numeric')) {
      return true;
    }
    
    return false;
  }

  void _showKeyboardOverlay() {
    if (_keyboardOverlayEntry != null) {
      developer.log('🟡 [FormTextFormField] _showKeyboardOverlay: Already showing, skipping');
      return;
    }
    
    developer.log('🟢 [FormTextFormField] _showKeyboardOverlay: Showing Hindi keyboard overlay');
    
    // Close all other active Hindi keyboards first to prevent conflicts
    _closeAllOtherHindiKeyboards();
    
    // Register this instance as active
    _activeHindiKeyboards.add(this);
    
    // CRITICAL: Hide system keyboard IMMEDIATELY and SYNCHRONOUSLY before showing overlay
    // This prevents the flash of English keyboard
    developer.log('🔴 [FormTextFormField] _showKeyboardOverlay: Hiding system keyboard (immediate synchronous)');
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    final overlay = Overlay.of(context);
    
    // Scroll focused field into view after a short delay to account for keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.focus?.hasFocus == true) {
        // Hide system keyboard again after frame is built (use microtask for immediate execution)
        Future.microtask(() {
          if (mounted) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        
        // Wait a bit for overlay to be fully rendered
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && widget.focus?.hasFocus == true) {
            // Hide system keyboard one more time to ensure it stays hidden
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            
            final renderObject = context.findRenderObject();
            if (renderObject != null) {
              final mediaQuery = MediaQuery.of(context);
              final screenHeight = mediaQuery.size.height;
              // Estimate keyboard height (approximately 280-300px)
              const keyboardHeight = 300.0;
              
              // Calculate alignment to show field above keyboard
              // We want the field to be visible in the top portion of the visible area
              final availableHeight = screenHeight - keyboardHeight;
              final alignment = (availableHeight / screenHeight).clamp(0.1, 0.4);
              
              // Scroll field into view with space for keyboard
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: alignment,
                alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              );
            }
          }
        });
      }
    });
    
    _keyboardOverlayEntry = OverlayEntry(
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Back button pressed - close keyboard instead of navigating
              // Hide system keyboard first
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              _hideKeyboardOverlay();
              // Unfocus after a small delay to ensure keyboard is hidden
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  widget.focus?.unfocus();
                }
              });
            }
          },
          child: Stack(
                children: [
                  // No barrier - allows scrolling to work normally
                  // Users can dismiss via back button (handled by PopScope) or dismiss button on keyboard
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
                          controller: widget.controller ?? TextEditingController(),
                          onDismiss: () {
                            // Hide system keyboard first to prevent it from showing
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                            _hideKeyboardOverlay();
                            // Unfocus after a small delay to ensure keyboard is hidden
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted) {
                                widget.focus?.unfocus();
                              }
                            });
                          },
                          onEnter: () {
                            // Hide system keyboard and dismiss Hindi keyboard first
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                            _hideKeyboardOverlay();
                            // Unfocus the current field
                            widget.focus?.unfocus();
                            // Call onComplete after ensuring keyboard is dismissed
                            Future.delayed(const Duration(milliseconds: 150), () {
                              if (mounted) {
                                widget.onComplete?.call();
                                // If there's a nextFocus and it's Hindi, prevent system keyboard
                                if (widget.nextFocus != null && _isHindiLanguage) {
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    if (mounted) {
                                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                                    }
                                  });
                                }
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
    // Remove from active keyboards set
    _activeHindiKeyboards.remove(this);
    
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
  
  // Close all other active Hindi keyboards except this one
  void _closeAllOtherHindiKeyboards() {
    final otherKeyboards = _activeHindiKeyboards.where((state) => state != this).toList();
    for (final state in otherKeyboards) {
      if (state.mounted) {
        state._hideKeyboardOverlay(skipSetState: true);
      } else {
        _activeHindiKeyboards.remove(state);
      }
    }
  }

  void _startKeyboardHideTimer() {
    _stopKeyboardHideTimer();
    developer.log('🟢 [FormTextFormField] Starting keyboard hide timer');
    // Continuously hide system keyboard when Hindi keyboard should be shown
    _keyboardHideTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        developer.log('🟡 [FormTextFormField] Timer cancelled (not mounted)');
        timer.cancel();
        return;
      }
      
      final hasFocus = widget.focus?.hasFocus ?? false;
      final shouldHideSystemKeyboard = !widget.useEnglishKeyboard &&
          _isHindiLanguage &&
          hasFocus &&
          widget.controller != null &&
          _shouldShowHindiKeyboard() &&
          (_showHindiKeyboard || widget.disableHindiKeyboardOverlay);
      
      if (shouldHideSystemKeyboard) {
        // Aggressively hide system keyboard
        developer.log('🔴 [FormTextFormField] Timer: Hiding system keyboard (periodic)');
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      } else {
        developer.log('🟡 [FormTextFormField] Timer: Stopping (conditions not met: hasFocus=$hasFocus, _showHindiKeyboard=$_showHindiKeyboard, disableHindiKeyboardOverlay=${widget.disableHindiKeyboardOverlay})');
        timer.cancel();
        _keyboardHideTimer = null;
      }
    });
  }

  void _stopKeyboardHideTimer() {
    if (_keyboardHideTimer != null) {
      developer.log('🟡 [FormTextFormField] Stopping keyboard hide timer');
      _keyboardHideTimer?.cancel();
      _keyboardHideTimer = null;
    }
  }
  
  void _interceptFocusForHindiKeyboard() {
    // This method sets up aggressive keyboard hiding when focus is about to be gained
    // We can't directly intercept focus, but we can hide keyboard very early
    if (widget.focus != null && !widget.useEnglishKeyboard && _isHindiLanguage) {
      // Hide keyboard immediately when focus node is created/attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.focus?.hasFocus == true && 
            widget.controller != null && _shouldShowHindiKeyboard()) {
          // Hide keyboard immediately
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          scheduleMicrotask(() {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          });
        }
      });
    }
  }

  void _onFocusChange() {
    if (mounted) {
      final hasFocus = widget.focus?.hasFocus ?? false;
      developer.log('🔵 [FormTextFormField] _onFocusChange: hasFocus=$hasFocus, _isHindiLanguage=$_isHindiLanguage, useEnglishKeyboard=${widget.useEnglishKeyboard}, disableHindiKeyboardOverlay=${widget.disableHindiKeyboardOverlay}, _showHindiKeyboard=$_showHindiKeyboard, _shouldShowHindiKeyboard=${_shouldShowHindiKeyboard()}');
      
      // Handle Hindi keyboard when overlay is enabled
      if (!widget.useEnglishKeyboard &&
          !widget.disableHindiKeyboardOverlay &&
          hasFocus && 
          _isHindiLanguage && 
          widget.controller != null && 
          _shouldShowHindiKeyboard() && 
          !_showHindiKeyboard) {
        developer.log('🟢 [FormTextFormField] Showing Hindi keyboard overlay (focus gained)');
        
        // CRITICAL: Hide system keyboard IMMEDIATELY and SYNCHRONOUSLY
        // This prevents the flash of English keyboard
        developer.log('🔴 [FormTextFormField] Hiding system keyboard (immediate synchronous)');
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        
        // Hide keyboard multiple times synchronously using scheduleMicrotask
        // This ensures it runs before any other code
        scheduleMicrotask(() {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
        
        // Close all other Hindi keyboards first to prevent controller conflicts
        _closeAllOtherHindiKeyboards();
        
        // Show Hindi keyboard immediately
        setState(() {
          _showHindiKeyboard = true;
        });
        _showKeyboardOverlay();
        
        // Start timer to continuously hide system keyboard
        _startKeyboardHideTimer();
        
        // Hide system keyboard multiple times aggressively to prevent any flash
        // Use microtask to ensure it runs before any other async operations
        Future.microtask(() {
          if (mounted) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 0), () {
          if (mounted) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 1), () {
          if (mounted) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (1ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (10ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && widget.focus?.hasFocus == true) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (50ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.focus?.hasFocus == true) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (100ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && widget.focus?.hasFocus == true) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (200ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
      } 
      // Handle Hindi keyboard when overlay is disabled (parent handles display)
      else if (!widget.useEnglishKeyboard &&
          widget.disableHindiKeyboardOverlay &&
          hasFocus &&
          _isHindiLanguage &&
          widget.controller != null &&
          _shouldShowHindiKeyboard()) {
        developer.log('🟢 [FormTextFormField] Hindi keyboard should be shown (parent handles)');
        
        // Immediately hide system keyboard to prevent it from appearing
        developer.log('🔴 [FormTextFormField] Hiding system keyboard (parent mode)');
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        
        // Start timer to continuously hide system keyboard
        _startKeyboardHideTimer();
        
        // Hide system keyboard again after a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && widget.focus?.hasFocus == true) {
            developer.log('🔴 [FormTextFormField] Hiding system keyboard (parent mode, 50ms delay)');
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
      } 
      else if (!hasFocus) {
        developer.log('🟡 [FormTextFormField] Focus lost');
        
        // Stop speech recognition if active when focus is lost
        if (_isListening) {
          _stopListening();
        }
        
        // Stop keyboard hide timer
        _stopKeyboardHideTimer();
        
        // Immediately close keyboard when focus is lost (e.g., tapping another field)
        if (_showHindiKeyboard) {
          developer.log('🟡 [FormTextFormField] Hiding Hindi keyboard overlay (focus lost)');
          _hideKeyboardOverlay();
        }
      }
    }
  }

  Future<void> _handleMicTap() async {
    if (!widget.enableSpeechInput || widget.controller == null) return;

    if (!_isListening) {
      // Register with manager - this will stop any other active listener
      final registered = await SpeechInputManager.instance.registerListener(
        _listenerId,
        _stopListening,
      );
      
      if (!registered) {
        // Another listener is active, wait a moment for it to stop
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Ensure speech recognition is initialized before using it
      // If pre-initialization failed or wasn't done, initialize now
      if (!_speechInitialized && !_isInitializingSpeech) {
        await _initializeSpeechRecognition();
      }
      
      // Wait for initialization to complete if it's in progress
      int retryCount = 0;
      while (_isInitializingSpeech && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }

      try {
        // Only initialize if not already initialized
        // Re-initialize if previous initialization failed
        if (!_speechInitialized) {
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
            // Unregister since we failed to start
            SpeechInputManager.instance.unregisterListener(_listenerId);
            return;
          }
          _speechInitialized = true;
        }
        
        // Check if Hindi locale is available when app is in Hindi
        if (_isHindiLanguage) {
          final locales = await _speech.locales();
          final hindiLocale = locales.firstWhere(
            (locale) => locale.localeId == 'hi-IN' || locale.localeId.startsWith('hi'),
            orElse: () => locales.first, // Fallback to first available locale
          );
          debugPrint('Available locales: ${locales.map((l) => l.localeId).join(', ')}');
          debugPrint('Using locale for Hindi: ${hindiLocale.localeId}');
        }
      } on PlatformException catch (error, _) {
        final message = _mapSpeechErrorToMessage(error);
        _handleMicAvailabilityDenied(message);
        // Reset initialization state to allow retry
        _speechInitialized = false;
        // Unregister since we failed to start
        SpeechInputManager.instance.unregisterListener(_listenerId);
        return;
      } catch (e) {
        developer.log('❌ [FormTextFormField] Speech initialization error: $e');
        _handleMicAvailabilityDenied(
          'Something went wrong while starting speech input.',
        );
        // Reset initialization state to allow retry
        _speechInitialized = false;
        // Unregister since we failed to start
        SpeechInputManager.instance.unregisterListener(_listenerId);
        return;
      }

      _micSessionBaseText = widget.controller?.text ?? '';
      _micInsertOffset = _micSessionBaseText.length; // Track where mic session starts
      _lastRecognizedWords = ''; // Reset for new session
      try {
        // Set locale based on current app language
        String localeId = 'en-US'; // Default to English
        
        if (_isHindiLanguage) {
          // Try to find the best Hindi locale available
          try {
            final locales = await _speech.locales();
            debugPrint('Available speech locales: ${locales.map((l) => '${l.localeId} (${l.name})').join(', ')}');
            
            final hindiLocale = locales.firstWhere(
              (locale) => locale.localeId == 'hi-IN',
              orElse: () => locales.firstWhere(
                (locale) => locale.localeId.startsWith('hi'),
                orElse: () => locales.firstWhere(
                  (locale) => locale.localeId.toLowerCase().contains('hindi'),
                  orElse: () => locales.first, // Fallback to first available
                ),
              ),
            );
            localeId = hindiLocale.localeId;
            debugPrint('Using speech locale: $localeId (${hindiLocale.name}) for Hindi');
          } catch (e) {
            debugPrint('Error getting locales, using default: $e');
            // If we can't get locales, try hi-IN anyway
            localeId = 'hi-IN';
          }
        }
        
        await _speech.listen(
          onResult: _onSpeechResult,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          localeId: localeId,
        );
      } on PlatformException catch (error, _) {
        if (error.code == 'notListening') {
          await _speech.stop();
        }
        final message = _mapSpeechErrorToMessage(error);
        _handleMicAvailabilityDenied(message);
        // Unregister since we failed to start
        SpeechInputManager.instance.unregisterListener(_listenerId);
        return;
      }
      setState(() {
        _isListening = true;
      });
      _micPulseController
        ..reset()
        ..repeat(reverse: true);
    } else {
      // Stop listening when mic is tapped again
      await _stopListening();
    }
  }

  /// Stop listening and clean up state
  Future<void> _stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
    } catch (e) {
      // Ignore errors - might already be stopped
    }
    
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
    
      _stopMicAnimation();
    
    // Save the current text as base for next session
    _micSessionBaseText = widget.controller?.text ?? '';
    _micInsertOffset = _micSessionBaseText.length; // Reset offset
    _lastRecognizedWords = ''; // Reset for next session
    
    // Unregister from manager
    SpeechInputManager.instance.unregisterListener(_listenerId);
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    // Safety guard: prevent late async events from mutating text after stop
    if (!_isListening) {
      return;
    }
    
    final recognizedWords = result.recognizedWords;
    final controller = widget.controller;
    
    // Guard: skip if empty
    if (recognizedWords.trim().isEmpty) {
      return;
    }
    
    if (controller != null) {
      // Normalize both strings for comparison (handles whitespace variations from Android)
      final normalizedRecognized = _normalizeSpeech(recognizedWords);
      final normalizedLast = _normalizeSpeech(_lastRecognizedWords);
      
      // Skip if this is the same result as before (no change, accounting for whitespace variations)
      if (normalizedRecognized == normalizedLast) {
        return;
      }
      
      // recognizedWords contains ALL words recognized so far (cumulative)
      // Extract only the NEW words since the last update
      String newWords = '';
      bool isCorrection = false;
      
      if (_lastRecognizedWords.isEmpty) {
        // First result: all words are new
        newWords = recognizedWords.trim();
      } else {
        // Subsequent result: extract only what's new
        // Use normalized comparison to handle whitespace variations
        if (normalizedRecognized.startsWith(normalizedLast)) {
          // Extract only the new part (use original strings for substring)
          newWords = recognizedWords.substring(_lastRecognizedWords.length).trim();
        } else {
          // If it doesn't start with last recognized, it's a correction
          // NEVER append - replace only the mic session portion
          isCorrection = true;
        }
      }
      
        // Handle correction: replace mic session text instead of appending
      if (isCorrection) {
        final baseText = _micSessionBaseText;
        var trimmedRecognized = recognizedWords.trim();
        
        // For number fields, extract only digits from speech input
        final isNumberField = _isNumberField(widget.keyboardType);
        if (isNumberField) {
          trimmedRecognized = _extractDigitsOnly(trimmedRecognized);
        }
        
        // Edge case #2: Check if baseText already ends with recognizedWords (typed + spoken overlap)
        // Prevents duplication when user types "Hello" then mic says "hello world"
        if (baseText.toLowerCase().endsWith(trimmedRecognized.toLowerCase())) {
          // Base text already contains the recognized words, just update tracking
          _lastRecognizedWords = trimmedRecognized;
          return;
        }
        
        var correctedText = baseText;
        
        // Add space if needed (only for non-number fields)
        if (!isNumberField && baseText.isNotEmpty &&
            !_endsWithWhitespace(baseText) &&
            trimmedRecognized.isNotEmpty) {
          correctedText += ' ';
        }
        
        correctedText += trimmedRecognized;
        
        if (widget.enforceFirstLetterUppercase &&
            !_containsNonAsciiCharacters(correctedText)) {
          correctedText = _ensureFirstLetterUppercase(correctedText);
        }
        
        _updateControllerText(
          correctedText,
          selection: TextSelection.collapsed(offset: correctedText.length),
        );
        
        widget.onChanged?.call(correctedText);
        
        // Update tracking (use trimmed version)
        _lastRecognizedWords = trimmedRecognized;
        return; // Exit early - correction handled
      }
      
      // If no new words after extraction, don't update
      if (newWords.isEmpty) {
        return;
      }

      // Check if translation is needed for the new words
      // When app is in Hindi, always translate speech recognition results (which are in English)
      final locale = GeneralStream.instance.locale;
      final isHindiLocale = locale.languageCode == 'hi';
      
      // Check if text contains Hindi characters
      final hindiRegex = RegExp(r'[\u0900-\u097F]');
      final hasHindiChars = hindiRegex.hasMatch(newWords);
      
      // Force translation when app is in Hindi and speech recognition returns English (no Hindi chars)
      final needsTranslation = TranslationHelper.needsTranslation(newWords) || 
          (isHindiLocale && !hasHindiChars && newWords.trim().isNotEmpty);
      
      if (needsTranslation) {
        // Show skeleton loading while translating
        setState(() {
          _isTranslating = true;
        });
        
        // Get current controller text (already has previous results)
        // Remove any existing skeleton text (▮ or ॥) from current text before adding new skeleton
        var currentText = controller.text.replaceAll(RegExp(r'[▮॥]+'), '').trim();
        
        // Show skeleton placeholder: current text + skeleton for new words
        final skeletonText = _generateSkeletonText(newWords);
        var skeletonFullText = currentText;
        
        // For number fields, don't add spaces in skeleton text
        final isNumberField = _isNumberField(widget.keyboardType);
        if (!isNumberField && skeletonFullText.isNotEmpty && !_endsWithWhitespace(skeletonFullText) && skeletonText.isNotEmpty) {
          skeletonFullText += ' ';
        }
        skeletonFullText += skeletonText;
        
        if (widget.enforceFirstLetterUppercase &&
            !_containsNonAsciiCharacters(skeletonFullText)) {
          skeletonFullText = _ensureFirstLetterUppercase(skeletonFullText);
        }
        _updateControllerText(
          skeletonFullText,
          selection: TextSelection.collapsed(offset: skeletonFullText.length),
        );

        // Translate only the new words and append to current text (use trimmed)
        // Force translation when app is in Hindi to ensure English speech results are translated
        _translateAndUpdateText(currentText, newWords, recognizedWords.trim(), forceTranslation: isHindiLocale);
      } else {
        // No translation needed, append ONLY new words to current controller text
        setState(() {
          _isTranslating = false;
        });
        
        // Get current controller text (already has previous results + baseText)
        var updatedText = controller.text;
        
        // For number fields, extract only digits from speech input
        final isNumberField = _isNumberField(widget.keyboardType);
        if (isNumberField) {
          newWords = _extractDigitsOnly(newWords);
        }
        
        // Add space if needed before appending new words (only for non-number fields)
        if (!isNumberField && updatedText.isNotEmpty && 
            !_endsWithWhitespace(updatedText) && 
            newWords.isNotEmpty) {
          updatedText += ' ';
        }
        
        // Append ONLY the new words (not the full cumulative recognizedWords)
        updatedText += newWords;

        if (widget.enforceFirstLetterUppercase &&
            !_containsNonAsciiCharacters(updatedText)) {
          updatedText = _ensureFirstLetterUppercase(updatedText);
        }
        
        _updateControllerText(
          updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
        
        widget.onChanged?.call(updatedText);
        
        // IMPORTANT: update last recognized words to track what we've added (use trimmed)
        _lastRecognizedWords = recognizedWords.trim();
      }
    }

    if (result.finalResult) {
      if (_isListening) {
        await _stopListening();
      }
      // Reset for next session - DO NOT append again
      _micSessionBaseText = widget.controller?.text ?? '';
      _micInsertOffset = _micSessionBaseText.length; // Reset offset
      _lastRecognizedWords = '';
    }
  }

  // Force translation when app is in Hindi
  Future<void> _translateAndUpdateText(
    String currentText,
    String newWords,
    String fullRecognizedText, {
    bool forceTranslation = false,
  }) async {
    try {
      // Translate only the new words, force translation if needed
      final translatedWords = await TranslationHelper.translateText(
        newWords,
        force: forceTranslation,
      );
      
      if (mounted && widget.controller != null) {
        setState(() {
          _isTranslating = false;
        });

        // Append translated words to current text
        var updatedText = currentText;
        
        // For number fields, extract only digits from translated words
        final isNumberField = _isNumberField(widget.keyboardType);
        var processedTranslatedWords = translatedWords;
        if (isNumberField) {
          processedTranslatedWords = _extractDigitsOnly(translatedWords);
        }
        
        // Add space if needed before appending (only for non-number fields)
        if (!isNumberField && updatedText.isNotEmpty && 
            !_endsWithWhitespace(updatedText) && 
            processedTranslatedWords.isNotEmpty) {
          updatedText += ' ';
        }
        updatedText += processedTranslatedWords;

        if (widget.enforceFirstLetterUppercase &&
            !_containsNonAsciiCharacters(updatedText)) {
          updatedText = _ensureFirstLetterUppercase(updatedText);
        }

        _updateControllerText(
          updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
        
        widget.onChanged?.call(updatedText);
        
        // Update last recognized words to full recognized text (original English, not translated)
        // This is important because speech recognition returns English words
        _lastRecognizedWords = fullRecognizedText.trim();
      }
    } catch (e) {
      // If translation fails, use original text
      if (mounted && widget.controller != null) {
        setState(() {
          _isTranslating = false;
        });
        
        // Remove any skeleton text that might be in currentText
        var cleanCurrentText = currentText.replaceAll(RegExp(r'[▮॥]+'), '').trim();
        
        // Append original new words to current text
        var updatedText = cleanCurrentText;
        
        // For number fields, extract only digits from speech input
        final isNumberField = _isNumberField(widget.keyboardType);
        var processedNewWords = newWords;
        if (isNumberField) {
          processedNewWords = _extractDigitsOnly(newWords);
        }
        
        // Add space if needed (only for non-number fields)
        if (!isNumberField && updatedText.isNotEmpty && 
            !_endsWithWhitespace(updatedText) && 
            processedNewWords.isNotEmpty) {
          updatedText += ' ';
        }
        updatedText += processedNewWords;

        if (widget.enforceFirstLetterUppercase &&
            !_containsNonAsciiCharacters(updatedText)) {
          updatedText = _ensureFirstLetterUppercase(updatedText);
        }

        _updateControllerText(
          updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );

        widget.onChanged?.call(updatedText);
        
        // Update last recognized words
        _lastRecognizedWords = fullRecognizedText.trim();
      }
    }
  }

  String _generateSkeletonText(String text) {
    // Generate skeleton placeholder characters (▮) based on text length
    // Preserve spaces and punctuation for better visual feedback
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ' ') {
        buffer.write(' ');
      } else if (RegExp(r'[^\w\s]').hasMatch(char)) {
        buffer.write(char); // Preserve punctuation
      } else {
        buffer.write('▮'); // Use skeleton character for letters/numbers
      }
    }
    return buffer.toString();
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
      if (_isListening) {
        _stopListening();
      }
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech recognition error: ${error.errorMsg} (permanent: ${error.permanent})');
    
    if (_isListening) {
      _stopListening();
    }
    
    // Provide more specific error messages for Hindi
    String errorMessage = _mapSpeechError(error);
    
    // If Hindi locale failed, suggest fallback
    if (_isHindiLanguage && (error.errorMsg.contains('locale') || error.errorMsg.contains('language'))) {
      errorMessage = 'Hindi speech recognition is not available on this device. Please try typing instead.';
    }
    
    _handleMicAvailabilityDenied(errorMessage);
  }

  @override
  void dispose() {
    // Remove from active keyboards set
    _activeHindiKeyboards.remove(this);

    // Clean up overlay without setState during disposal
    _hideKeyboardOverlay(skipSetState: true);

    // Stop keyboard hide timer
    _stopKeyboardHideTimer();

    // Stop listening if active
    if (_isListening) {
      _speech.stop();
      SpeechInputManager.instance.unregisterListener(_listenerId);
    }

    _languageSubscription?.cancel();
    _stopListeningSubscription?.cancel();
    widget.focus?.removeListener(_onFocusChange);
    widget.controller?.removeListener(_onControllerChanged);
    _micPulseController.dispose();
    
    // Note: Don't dispose _speech here as it might be shared or needed by other instances
    // The speech_to_text package handles cleanup internally
    _speechInitialized = false;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug log for build
    final isReadOnly = !widget.useEnglishKeyboard && 
        _isHindiLanguage && 
        widget.controller != null &&
        _shouldShowHindiKeyboard() &&
        (widget.focus?.hasFocus == true || _showHindiKeyboard);
    if (isReadOnly || _showHindiKeyboard) {
      developer.log('🔵 [FormTextFormField] build: isReadOnly=$isReadOnly, _showHindiKeyboard=$_showHindiKeyboard, hasFocus=${widget.focus?.hasFocus}, _isHindiLanguage=$_isHindiLanguage');
    }
    final respRadius = widget.radius ?? Dimens.radiusX4;
    final border = OutlineInputBorder(
      borderSide: !widget.showBorder || widget.borderColor == null
          ? BorderSide.none
          : BorderSide(color: widget.borderColor ?? AppPalettes.transparentColor),
      borderRadius: BorderRadius.circular(respRadius),
    );
    final iconColor = ColorFilter.mode(context.iconsColor, BlendMode.srcIn);
    return PopScope(
      canPop: !_showHindiKeyboard,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showHindiKeyboard) {
          // Back button pressed while keyboard is open - close keyboard instead of navigating
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          _hideKeyboardOverlay();
          // Unfocus after a small delay to ensure keyboard is hidden
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              widget.focus?.unfocus();
            }
          });
        }
      },
      child: Column(
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
        Stack(
          children: [
            // Wrap in GestureDetector to intercept taps before TextFormField gets focus
            GestureDetector(
              onTap: () {
                // If Hindi keyboard should be shown, hide system keyboard BEFORE focus is gained
                if (!widget.useEnglishKeyboard && 
                    !widget.disableHindiKeyboardOverlay &&
                    _isHindiLanguage && 
                    widget.controller != null && 
                    _shouldShowHindiKeyboard()) {
                  // Hide keyboard immediately before TextFormField can request it
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  scheduleMicrotask(() {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  });
                }
              },
              behavior: HitTestBehavior.translucent,
              child: TextFormField(
              initialValue: widget.initialValue,
              showCursor: (widget.showCursor ?? true) && !_isTranslating,
              cursorColor: widget.cursorColor,
              cursorErrorColor: widget.cursorColor,
              onTap: () {
                developer.log('🟣 [FormTextFormField] onTap called: _isHindiLanguage=$_isHindiLanguage, useEnglishKeyboard=${widget.useEnglishKeyboard}, disableHindiKeyboardOverlay=${widget.disableHindiKeyboardOverlay}, _shouldShowHindiKeyboard=${_shouldShowHindiKeyboard()}, _showHindiKeyboard=$_showHindiKeyboard');
                
                // Only show Hindi keyboard if useEnglishKeyboard is false and overlay is not disabled
                if (!widget.useEnglishKeyboard && 
                    !widget.disableHindiKeyboardOverlay &&
                    _isHindiLanguage && 
                    widget.controller != null && 
                    _shouldShowHindiKeyboard()) {
                  developer.log('🟢 [FormTextFormField] onTap: Showing Hindi keyboard overlay');
                  
                  // CRITICAL: Hide system keyboard IMMEDIATELY and SYNCHRONOUSLY before anything else
                  // This prevents the flash of English keyboard
                  developer.log('🔴 [FormTextFormField] onTap: Hiding system keyboard (immediate synchronous)');
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  
                  // Hide keyboard multiple times synchronously using scheduleMicrotask
                  // This ensures it runs before any other code
                  scheduleMicrotask(() {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  });
                  // Close all other Hindi keyboards first to prevent controller conflicts
                  _closeAllOtherHindiKeyboards();
                  // Show Hindi keyboard immediately
                  if (!_showHindiKeyboard) {
                    setState(() {
                      _showHindiKeyboard = true;
                    });
                    _showKeyboardOverlay();
                    
                    // Start timer to continuously hide system keyboard
                    _startKeyboardHideTimer();
                  }
                  
                  // Hide system keyboard multiple times aggressively to prevent any flash
                  // Use microtask to ensure it runs before any other async operations
                  Future.microtask(() {
                    if (mounted) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 0), () {
                    if (mounted) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 1), () {
                    if (mounted) {
                      developer.log('🔴 [FormTextFormField] onTap: Hiding system keyboard (1ms delay)');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 10), () {
                    if (mounted) {
                      developer.log('🔴 [FormTextFormField] onTap: Hiding system keyboard (10ms delay)');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted && widget.focus?.hasFocus == true) {
                      developer.log('🔴 [FormTextFormField] onTap: Hiding system keyboard (50ms delay)');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted && widget.focus?.hasFocus == true) {
                      developer.log('🔴 [FormTextFormField] onTap: Hiding system keyboard (100ms delay)');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    }
                  });
                } else {
                  developer.log('🟡 [FormTextFormField] onTap: Conditions not met for Hindi keyboard');
                }
                widget.onTap?.call();
              },
              readOnly: () {
                // Set readOnly when Hindi keyboard should be shown, even before focus is gained
                // This prevents the system keyboard from appearing in the first place
                final shouldBeReadOnly = !widget.useEnglishKeyboard && 
                    _isHindiLanguage && 
                    widget.controller != null &&
                    _shouldShowHindiKeyboard() &&
                    !widget.disableHindiKeyboardOverlay;
                if (shouldBeReadOnly) {
                  developer.log('🔒 [FormTextFormField] Setting readOnly=true: hasFocus=${widget.focus?.hasFocus}, _showHindiKeyboard=$_showHindiKeyboard');
                }
                return shouldBeReadOnly;
              }(),
              enableInteractiveSelection: () {
                // Disable interactive selection when Hindi keyboard should be shown
                // This helps prevent system keyboard from appearing
                final shouldDisable = !widget.useEnglishKeyboard && 
                    _isHindiLanguage && 
                    widget.controller != null &&
                    _shouldShowHindiKeyboard() &&
                    !widget.disableHindiKeyboardOverlay;
                return !shouldDisable;
              }(),
              enableSuggestions: () {
                // Disable suggestions when Hindi keyboard should be shown
                final shouldDisable = !widget.useEnglishKeyboard && 
                    _isHindiLanguage && 
                    widget.controller != null &&
                    _shouldShowHindiKeyboard() &&
                    !widget.disableHindiKeyboardOverlay;
                return !shouldDisable;
              }(),
              maxLength: widget.maxLength,
              cursorHeight: Dimens.paddingX5,
              style: (_isTranslating
                  ? (widget.textStyle ?? context.textTheme.bodySmall)?.copyWith(
                      color: AppPalettes.liteGreyColor,
                    )
                  : widget.textStyle ?? context.textTheme.bodySmall),
          focusNode: widget.focus,
          textCapitalization: widget.textCapitalization,
          enabled: widget.enabled,
          autovalidateMode: widget.autovalidateMode,
          // Set keyboardType to none when Hindi keyboard should be shown to prevent system keyboard flash
          // Check conditions without requiring focus to be gained first
          keyboardType: (!widget.useEnglishKeyboard && 
                  !widget.disableHindiKeyboardOverlay &&
                  _isHindiLanguage && 
                  widget.controller != null &&
                  _shouldShowHindiKeyboard())
              ? TextInputType.none
              : widget.keyboardType,
          inputFormatters: widget.inputFormatters,
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
            suffixIcon: widget.suffixWidget ??
                  (widget.showDefaultSuffix
                      ? _buildMicIcon(
                          iconColor: iconColor,
                        verticalOffset: widget.maxLines == 1
                            ? 0
                            : (-(widget.maxLines! * 5) + 0.0),
                        )
                      : const SizedBox.shrink()),
          ),
          maxLines: widget.maxLines,
          obscureText: widget.isPassword,
          obscuringCharacter: '.',
          validator: (value) {
            // Check minimum character requirement first
            if (widget.minChar != null && (value?.length ?? 0) < widget.minChar!) {
              return context.localizations.please_enter_at_least_characters(widget.minChar!);
            }
            // Then run custom validator if provided
            return widget.validator?.call(value);
          },
          onChanged: (value) {
            if (_isApplyingFormattedText) {
              widget.onChanged?.call(value);
              return;
            }

            var updatedValue = value;

            if (widget.enforceFirstLetterUppercase &&
                value.trimLeft().isNotEmpty &&
                widget.controller != null &&
                !_containsNonAsciiCharacters(value)) {
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
        ),
            if (_isTranslating && widget.controller != null && widget.controller!.text.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Shimmer.fromColors(
                    baseColor: AppPalettes.liteGreyColor.withOpacity(0.3),
                    highlightColor: AppPalettes.whiteColor.withOpacity(0.5),
                    period: const Duration(milliseconds: 1200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppPalettes.whiteColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
      ),
    );
  }

  Widget _buildMicIcon({required ColorFilter iconColor, double verticalOffset = 0}) {
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
      return Transform.translate(
        offset: Offset(0, verticalOffset),
        child: mic,
      );
    }

    // Calculate tap area size - increase when maxLines > 1 for better tap detection
    final isMultiLine = (widget.maxLines ?? 1) > 1;
    final baseHeight = Dimens.paddingX6 + Dimens.paddingX3B + Dimens.paddingX3B;
    // Increase height significantly for multi-line fields to ensure tap area covers the offset icon
    final tapAreaHeight = isMultiLine 
        ? baseHeight + (widget.maxLines! * 8.0).abs() + Dimens.paddingX4
        : baseHeight;
    final tapAreaWidth = Dimens.paddingX6 + Dimens.paddingX2 + Dimens.paddingX4;
    
    // For multi-line, also increase width slightly for better tap detection
    final finalTapAreaWidth = isMultiLine 
        ? tapAreaWidth + Dimens.paddingX2 
        : tapAreaWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleMicTap,
      child: Container(
        // Outer container with larger tap area, especially for multi-line fields
        width: finalTapAreaWidth,
        height: tapAreaHeight,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Container(
            // Inner container for icon positioning
            width: tapAreaWidth,
            height: baseHeight,
            padding: EdgeInsets.only(
              left: Dimens.paddingX2,
              right: Dimens.paddingX4,
              top: Dimens.paddingX3B,
              bottom: Dimens.paddingX3B,
            ),
            alignment: Alignment.center,
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
    debugPrint('Speech error details: ${error.errorMsg}, permanent: ${error.permanent}');
    
    switch (error.errorMsg) {
      case 'error_network':
      case 'error_network_timeout':
        return 'Network error occurred while using speech recognition.';
      case 'error_audio':
        return 'Microphone is unavailable.';
      case 'error_no_match':
        if (_isHindiLanguage) {
          return 'No Hindi speech recognized. Please speak clearly in Hindi or try typing instead.';
        }
        return 'No speech recognized. Please try speaking again.';
      case 'error_insufficient_permissions':
        return 'Microphone permission is required for speech input.';
      case 'error_client':
      case 'client_error':
        return 'Speech recognition client error occurred.';
      case 'error_speech_timeout':
        if (_isHindiLanguage) {
          return 'Speech timeout. Please try speaking in Hindi again or use typing.';
        }
        return 'Speech timeout. Please try speaking again.';
      default:
        if (_isHindiLanguage && error.errorMsg.toLowerCase().contains('locale')) {
          return 'Hindi speech recognition is not supported on this device. Please use typing instead.';
        }
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

  bool _containsNonAsciiCharacters(String text) {
    if (text.isEmpty) return false;
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      // Check if character is outside ASCII range (0-127)
      // This includes Hindi and other Unicode characters
      if (codeUnit > 127) {
        return true;
      }
    }
    return false;
  }

  bool _endsWithWhitespace(String value) {
    if (value.isEmpty) return false;
    final lastChar = value[value.length - 1];
    return lastChar.trim().isEmpty;
  }

  /// Normalize speech text for comparison (handles whitespace variations)
  /// Android sometimes sends double spaces or trailing spaces that cause false corrections
  String _normalizeSpeech(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  /// Extract only numeric digits from speech input for number fields
  /// This ensures that only integers are accepted when using microphone input
  String _extractDigitsOnly(String text) {
    // Remove all non-digit characters, keeping only 0-9
    return text.replaceAll(RegExp(r'[^\d]'), '');
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