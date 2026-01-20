import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/dismiss_keyboard_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/notification_service.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/home/widgets/upcoming_home_events_widget.dart';
import 'package:inldsevak/features/home/widgets/my_latest_complaints_widgets.dart';
import 'package:inldsevak/features/home/widgets/quick_access_widget.dart';
import 'package:inldsevak/features/home/services/dashboard_repository.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/financial_help_messages_view_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/nearest_member_view_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/my_member_message_view_model.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inldsevak/core/mixin/cupertino_dialog_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Check and request location permission if denied
/// This is called when nearest member feature is accessed
/// Returns true if permission is granted, false otherwise
Future<bool> checkLocationPermissionForNearestMember(
  BuildContext context,
) async {
  try {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationDialog(
        context: context,
        content:
            "Location services are disabled. Please enable them in settings.",
        rightButton: "Open Settings",
        onTap: () async {
          RouteManager.pop();
          await Geolocator.openLocationSettings();
        },
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is already granted, return true
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    // If permission is denied, request it once
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // If still denied after request, show dialog to inform user
      if (permission == LocationPermission.denied) {
        await _showLocationDialog(
          context: context,
          content:
              "Location permission is required to find nearest members. Please grant permission in settings.",
          rightButton: "Open Settings",
          onTap: () async {
            RouteManager.pop();
            await Geolocator.openAppSettings();
          },
        );
        return false;
      }

      // If granted after request, return true
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }
    }

    // Handle permanently denied permission
    if (permission == LocationPermission.deniedForever) {
      await _showLocationDialog(
        context: context,
        content:
            "Location permission is denied permanently. Please enable it in settings.",
        rightButton: "Open Settings",
        onTap: () async {
          RouteManager.pop();
          await Geolocator.openAppSettings();
        },
      );
      return false;
    }

    return false;
  } catch (e) {
    debugPrint("⚠️ Error checking location permission: $e");
    return false;
  }
}

/// Helper function to show location permission dialog
Future<void> _showLocationDialog({
  required BuildContext context,
  required String content,
  required String rightButton,
  Function()? onTap,
}) async {
  final localization = context.localizations;
  return showCupertinoDialog(
    context: context,
    builder: (BuildContext dialogContext) => CupertinoAlertDialog(
      content: Text(content, style: dialogContext.textTheme.titleSmall),
      actions: [
        CupertinoDialogAction(
          child: Text(
            localization.cancel,
            style: dialogContext.textTheme.labelLarge,
          ),
          onPressed: () {
            RouteManager.pop();
          },
        ),
        CupertinoDialogAction(
          onPressed: () {
            if (onTap != null) {
              onTap();
            } else {
              RouteManager.pop();
            }
          },
          child: Text(
            rightButton,
            style: dialogContext.textTheme.labelLarge?.copyWith(
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

class IndlView extends StatefulWidget {
  const IndlView({super.key});

  @override
  State<IndlView> createState() => _IndlViewState();
}

class _IndlViewState extends State<IndlView>
    with
        TickerProviderStateMixin,
        CupertinoDialogMixin,
        WidgetsBindingObserver {
  late AnimationController _zoomAnimationController;
  late Animation<double> _zoomAnimation;
  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkAnimation;
  bool _isLoadingNotifications = false;
  bool _isLoadingChats = false;
  Timer? _unreadCountRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Initialize zoom animation
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    // Initialize blink animation for badge
    _blinkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _blinkAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    // Animation will be started when there are unread messages

    // Add app lifecycle observer to detect when app comes back from background
    WidgetsBinding.instance.addObserver(this);

    // Load complaints when INLD view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refreshUnreadCounts();
      // Start periodic timer to refresh unread counts every 30 seconds
      _startUnreadCountRefreshTimer();

      // ANTI-FLASH LOGIC: Load notification dot from SharedPreferences ONLY (instant, no flash)
      // Don't verify with API automatically - let the notifications view handle verification
      // This prevents the dot from disappearing prematurely before user opens notifications
      try {
        final updateNotificationVm = context
            .read<UpdateNotificationViewModel>();

        // Optimistic update from SharedPreferences (instant, prevents flash)
        // This shows the dot immediately if a notification was received while app was closed
        // The dot will be verified/hidden only when user opens the notifications view
        await updateNotificationVm.refreshFromSharedPreferences();
        debugPrint(
          "📬 [IndlView] ✅ Notification dot loaded from SharedPreferences (instant, no flash)",
        );
        debugPrint(
          "📬 [IndlView] ℹ️ Dot will be verified when user opens notifications view",
        );
      } catch (e) {
        debugPrint("❌ [IndlView] Error loading notification dot: $e");
      }

      // Check if data needs to be refreshed (notification received while app was closed)
      // This will update view models and trigger GIF animation update
      NotificationService.checkAndRefreshDataIfNeeded();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes back from background/sleep, refresh unread counts and notification dot
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        "📱 App resumed from background/sleep - refreshing unread counts and notification dot",
      );

      // Small delay to ensure app is fully resumed and SharedPreferences is synchronized
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!mounted) return;

        // CRITICAL: Refresh notification dot from SharedPreferences with retry mechanism
        // Background isolate writes might not be immediately visible, so we retry with delays
        await _refreshNotificationDotOnResume();

        // Refresh all unread counts to update GIF animation
        _refreshUnreadCounts();

        // Also check if data needs to be refreshed (notification received while in background)
        NotificationService.checkAndRefreshDataIfNeeded();
      });
    }
  }

  /// Refresh notification dot on app resume with retry mechanism
  /// This handles the case where SharedPreferences writes from background isolate
  /// might not be immediately visible to the main isolate
  Future<void> _refreshNotificationDotOnResume() async {
    if (!mounted) return;

    try {
      final updateNotificationVm = context.read<UpdateNotificationViewModel>();

      // Retry mechanism: Try reading SharedPreferences multiple times with delays
      // Background isolate writes might need time to sync
      bool flagFound = false;
      for (int attempt = 0; attempt < 5; attempt++) {
        try {
          final prefs = await SharedPreferences.getInstance();
          
          // CRITICAL: Reload SharedPreferences to ensure we get the latest values
          // This is important because background isolate writes might not be immediately visible
          await prefs.reload();
          
          final showNotificationFlag = prefs.getBool('showNotification') ?? false;
          debugPrint(
            "📬 [IndlView] Attempt ${attempt + 1}: SharedPreferences showNotification flag on resume: $showNotificationFlag",
          );

          // Also check for stored background notifications as additional indicator
          final storedNotifications = await NotificationService.getStoredBackgroundNotifications();
          final hasStoredNotifications = storedNotifications.isNotEmpty;
          
          debugPrint(
            "📬 [IndlView] Stored background notifications count: ${storedNotifications.length}",
          );

          // If flag is true OR there are stored notifications, show the dot
          if (showNotificationFlag || hasStoredNotifications) {
            updateNotificationVm.showNotification = true;
            flagFound = true;
            debugPrint(
              "📬 [IndlView] ✅ Notification dot set to TRUE (flag: $showNotificationFlag, stored: $hasStoredNotifications)",
            );
            break;
          }

          // If flag is false and no stored notifications, update accordingly
          if (attempt == 0) {
            // On first attempt, refresh from SharedPreferences anyway
            await updateNotificationVm.refreshFromSharedPreferences();
            debugPrint(
              "📬 [IndlView] Refreshed from SharedPreferences, current state: ${updateNotificationVm.showNotification}",
            );
          }

          // If we found the flag (even if false), we can stop retrying
          if (attempt >= 2) {
            // After 2 attempts, if still false, accept it
            break;
          }

          // Wait before next attempt (only if flag is false)
          if (!showNotificationFlag && attempt < 4) {
            await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
          }
        } catch (e) {
          debugPrint(
            "❌ [IndlView] Error reading SharedPreferences on attempt ${attempt + 1}: $e",
          );
          if (attempt < 4) {
            await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
          }
        }
      }

      if (!flagFound && mounted) {
        // Final refresh attempt
        await updateNotificationVm.refreshFromSharedPreferences();
        debugPrint(
          "📬 [IndlView] Final refresh - Current dot state: ${updateNotificationVm.showNotification}",
        );
      }
    } catch (e) {
      debugPrint(
        "❌ [IndlView] Error refreshing notification dot on resume: $e",
      );
      // Fallback: try to refresh one more time
      try {
        if (mounted) {
          final updateNotificationVm = context.read<UpdateNotificationViewModel>();
          await updateNotificationVm.refreshFromSharedPreferences();
          debugPrint(
            "📬 [IndlView] ✅ Fallback refresh completed",
          );
        }
      } catch (fallbackError) {
        debugPrint("❌ [IndlView] Error in fallback: $fallbackError");
      }
    }
  }

  /// Refresh all unread counts
  void _refreshUnreadCounts() {
    if (!mounted) return;

    try {
      // Load complaints to get unread count
      context.read<ComplaintsViewModel>().getComplaints(
        showLoader: false,
        preserveSearch: true,
      );
      // Load financial help messages to check for unread count
      context
          .read<FinancialHelpMessagesViewModel>()
          .getMyFinancialHelpRequestMessages();
      // Load nearest member unread count
      context.read<NearestMemberViewModel>().getUnreadChatCount();
      // Load nearest member chats to get totalUnreadCount from getAllChats API
      final nearestMemberVm = context.read<MyMemberMessageViewModel>();
      if (nearestMemberVm.token != null && nearestMemberVm.token!.isNotEmpty) {
        nearestMemberVm.getAllChats();
      }
    } catch (e) {
      debugPrint("Error refreshing unread counts: $e");
    }
  }

  /// Start periodic timer to refresh unread counts every 30 seconds
  void _startUnreadCountRefreshTimer() {
    _unreadCountRefreshTimer?.cancel();
    _unreadCountRefreshTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _refreshUnreadCounts();
    });
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _unreadCountRefreshTimer?.cancel();
    _zoomAnimationController.dispose();
    _blinkAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshPage() async {
    try {
      final context = this.context;

      // Refresh dashboard to update party member status
      await _refreshDashboard(context);

      // Refresh profile
      await context.read<ProfileViewModel>().getUserProfile();

      // Refresh complaints
      await context.read<ComplaintsViewModel>().loadComplaintsIfNeeded();

      // RoleViewModel will automatically update via stream listener when party member status changes

      if (mounted) {
        CommonSnackbar(text: "Page refreshed successfully").showToast();
      }
    } catch (e) {
      debugPrint("Error refreshing page: $e");
      if (mounted) {
        CommonSnackbar(text: "Error refreshing page").showToast();
      }
    }
  }

  Future<void> _refreshDashboard(BuildContext context) async {
    try {
      final token = await SessionController.instance.getToken();
      final response = await DashboardRepository().fetchDashboard(token: token);

      if (response.error != null) {
        debugPrint("Error fetching dashboard: ${response.error?.message}");
        return;
      }

      final dashboard = response.data;
      if (dashboard?.responseCode == 200 && dashboard?.data != null) {
        final data = dashboard!.data!;

        // Update party member status from dashboard response
        if (data.user?.isPartyMember != null ||
            data.userDetails?.isPartyMember != null) {
          final isPartyMember =
              data.user?.isPartyMember ??
              data.userDetails?.isPartyMember ??
              false;
          await SessionController.instance.setPartyMember(
            isPartyMember: isPartyMember,
          );
          debugPrint("✅ Party member status updated: $isPartyMember");
        }
      }
    } catch (e) {
      debugPrint("Error refreshing dashboard: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load complaints when view becomes visible (e.g., when navigating back from another tab)
    // The loadComplaintsIfNeeded method has guards to prevent unnecessary API calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final complaintsViewModel = context.read<ComplaintsViewModel>();
      // Only try to load if complaints list is empty
      if (complaintsViewModel.complaintsList.isEmpty) {
        complaintsViewModel.loadComplaintsIfNeeded();
      }
      // Refresh unread counts when returning to this view
      context
          .read<FinancialHelpMessagesViewModel>()
          .getMyFinancialHelpRequestMessages();
      context.read<NearestMemberViewModel>().getUnreadChatCount();
      // Refresh complaints unread count
      context.read<ComplaintsViewModel>().getComplaints(
        showLoader: false,
        preserveSearch: true,
      );
      // Refresh nearest member chats to get totalUnreadCount
      final nearestMemberVm = context.read<MyMemberMessageViewModel>();
      if (nearestMemberVm.token != null && nearestMemberVm.token!.isNotEmpty) {
        nearestMemberVm.getAllChats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final roleProvider = context.watch<RoleViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        showBackButton: false,
        action: [
          Consumer3<
            FinancialHelpMessagesViewModel,
            MyMemberMessageViewModel,
            ComplaintsViewModel
          >(
            builder: (context, financialHelpVm, nearestMemberVm, complaintsVm, _) {
              // totalUnreadCount already includes followUpDueCount from ComplaintsViewModel
              final totalUnreadCount =
                  financialHelpVm.totalUnreadCount +
                  nearestMemberVm.totalUnreadCount +
                  complaintsVm.totalUnreadCount;
              final hasUnreadMessages = totalUnreadCount > 0;

              // Control animation based on unread messages
              if (hasUnreadMessages) {
                if (!_zoomAnimationController.isAnimating) {
                  _zoomAnimationController.repeat(reverse: true);
                }
                if (!_blinkAnimationController.isAnimating) {
                  _blinkAnimationController.repeat(reverse: true);
                }
              } else {
                if (_zoomAnimationController.isAnimating) {
                  _zoomAnimationController.stop();
                  _zoomAnimationController.reset();
                }
                if (_blinkAnimationController.isAnimating) {
                  _blinkAnimationController.stop();
                  _blinkAnimationController.reset();
                }
              }
              
              return GestureDetector(
                onTap: () async {
                  if (_isLoadingChats) return; // Prevent multiple taps

                  setState(() {
                    _isLoadingChats = true;
                  });

                  try {
                    // Start loading all chat data before navigating
                    final roleProvider = context.read<RoleViewModel>();

                    // Start loading complaints first (most important for count)
                    final complaintsVm = context.read<ComplaintsViewModel>();
                    final complaintsFuture = complaintsVm.getComplaints(
                      showLoader: false,
                      preserveSearch: true,
                    );

                    // Start loading Wall of Help
                    final wallOfHelpFuture = financialHelpVm
                        .getMyFinancialHelpRequestMessages();

                    // Start loading Nearest Member if party member
                    Future<void>? nearestMemberFuture;
                    if (roleProvider.isPartyMember) {
                      final nearestMemberVm = context
                          .read<MyMemberMessageViewModel>();
                      if (nearestMemberVm.token != null &&
                          nearestMemberVm.token!.isNotEmpty) {
                        nearestMemberFuture = nearestMemberVm.getAllChats();
                      }
                    }

                    // Start complaints loading - don't wait for completion
                    // Complaints will show immediately with raw data, translation happens in background
                    complaintsFuture.catchError(
                      (e) => debugPrint("Error loading complaints: $e"),
                    );

                    // Small delay to show loading indicator (50ms is enough)
                    await Future.delayed(const Duration(milliseconds: 50));

                    // Navigate after complaints start loading
                    if (mounted) {
                      await RouteManager.pushNamed(Routes.allChatsPage);
                    }

                    // Continue loading other data in background
                    Future.microtask(() async {
                      try {
                        await wallOfHelpFuture;
                        if (nearestMemberFuture != null) {
                          await nearestMemberFuture;
                        }
                      } catch (e) {
                        debugPrint("Error loading chats in background: $e");
                      }
                    });
                  } catch (e) {
                    debugPrint("Error loading chats: $e");
                    // Still navigate even if there's an error
                    if (mounted) {
                      await RouteManager.pushNamed(Routes.allChatsPage);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoadingChats = false;
                      });
                    }
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _isLoadingChats
                        ? Container(
                            width: 52.sp,
                            height: 52.sp,
                            decoration: BoxDecoration(
                              color: AppPalettes.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: Dimens.scaleX2,
                                height: Dimens.scaleX2,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppPalettes.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : hasUnreadMessages
                        ? CircleAvatar(
                            radius: 26.sp,
                            backgroundColor: AppPalettes.primaryColor,
                            child: AnimatedBuilder(
                              animation: _zoomAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _zoomAnimation.value,
                                  child: Image.asset(
                                    "assets/banners/notify_animation.gif",
                                    height: 38.sp,
                                    width: 38.sp,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          )
                        : CommonHelpers.buildIcons(
                            path: AppImages.chatIcon,
                            color: AppPalettes.primaryColor,
                            iconColor: AppPalettes.whiteColor,
                            padding: Dimens.paddingX3B,
                            iconSize: Dimens.scaleX2B,
                          ),
                    if (hasUnreadMessages)
                      Positioned(
                        right: 10,
                        top: 13,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _blinkAnimation.value,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppPalettes.redColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppPalettes.whiteColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          SizeBox.sizeWX2,
          Consumer<UpdateNotificationViewModel>(
            builder: (context, value, _) {
              return Stack(
                children: [
                  CommonHelpers.buildIcons(
                    path: AppImages.notificationIcon,
                    color: AppPalettes.liteGreenColor,
                    iconColor: AppPalettes.blackColor,
                    padding: Dimens.paddingX3B,
                    iconSize: Dimens.scaleX3,
                    onTap: () async {
                      if (_isLoadingNotifications) return;

                      setState(() {
                        _isLoadingNotifications = true;
                      });
                      try {
                        // Navigate immediately - notifications will load automatically in the view
                        RouteManager.pushNamed(Routes.notificationsPage);
                      } finally {
                        // Reset loading state after a short delay to show feedback
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            setState(() {
                              _isLoadingNotifications = false;
                            });
                          }
                        });
                      }
                    },
                  ),
                  if (value.showNotification)
                    Container(
                      margin: EdgeInsets.all(
                        Dimens.paddingX3B,
                      ).copyWith(left: Dimens.paddingX6B),
                      height: 10,
                      width: 10,
                      decoration: boxDecorationRoundedWithShadow(
                        Dimens.radius100,
                        backgroundColor: AppPalettes.primaryColor,
                      ),
                    ),
                  if (_isLoadingNotifications)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppPalettes.liteGreenColor,
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: Dimens.scaleX2,
                            height: Dimens.scaleX2,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppPalettes.blackColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        child: Consumer<ProfileViewModel>(
          builder: (context, profile, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimens.gapX1,
              children: [
                Row(
                  children: [
                    TranslatedText(
                      text: "Hi, ",
                      style: textTheme.headlineMedium,
                    ),
                    Builder(
                      builder: (context) {
                        final profileName = profile.profile?.name ?? '...';
                        final displayText = profileName.length > 10
                            ? "${profileName.substring(0, 10)}..."
                            : profileName;
                        return TranslatedText(
                          text: displayText,
                          style: textTheme.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                          disableTranslation: true,
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  spacing: Dimens.gapX1,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: Dimens.scaleX2,
                      color: AppPalettes.primaryColor,
                    ),
                    Flexible(
                      child: Builder(
                        builder: (context) {
                          final constituencyName =
                              profile.profile?.assemblyConstituency?.name ??
                              "Loading...";
                          final displayText = constituencyName.length > 12
                              ? "${constituencyName.substring(0, 8)}..."
                              : constituencyName;
                          return TranslatedText(
                            text: displayText,
                            style: textTheme.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: DismissKeyboardWidget(
        child: RefreshIndicator(
          onRefresh: _refreshPage,
          color: AppPalettes.primaryColor,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is short
            child: Column(
              spacing: Dimens.widgetSpacing,
              children: [
                CarouselSlider(
                  items:
                      [
                            "assets/banners/banner_1.png",
                            "assets/banners/banner_1.png",
                            "assets/banners/banner_1.png",
                          ]
                          .map(
                            (asset) =>
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimens.radiusX2,
                                  ),
                                  child: Image.asset(
                                    asset,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                  ),
                                ).symmetricPadding(
                                  horizontal: Dimens.horizontalspacing,
                                ),
                          )
                          .toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    height: 150,
                    enableInfiniteScroll: true,
                  ),
                ),
                QuickAccessWidget(showParty: roleProvider.isPartyMember),
                UpComingHomeEventsWidget(),
                Consumer<ComplaintsViewModel>(
                  builder: (_, value, _) {
                    // Show loading when complaints are loading initially
                    if (value.isLoading && value.complaintsList.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.paddingX4,
                        ),
                        child: Center(child: CustomAnimatedLoading()),
                      );
                    }
                    // Show complaints widget if list is not empty (limit to 10)
                    if (value.complaintsList.isNotEmpty) {
                      final limitedComplaints = value.complaintsList
                          .take(10)
                          .toList();
                      return MyLatestComplaintsWidgets(
                        complaintList: limitedComplaints,
                        totalCount: value.complaintsList.length,
                      );
                    }
                    return Container();
                  },
                ),
                SizeBox.sizeHX20,
              ],
            ),
          ),
        ),
      ),
      backgroundColor: context.cardColor,
    );
  }
}
