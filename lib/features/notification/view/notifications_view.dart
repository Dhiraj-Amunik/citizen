import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/notification/widget/dismissable_widget.dart';
import 'package:inldsevak/core/helpers/translation_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with WidgetsBindingObserver {
  DateTime? _lastRefreshTime;
  bool _isInitialLoad = true;
  bool _hasClearedDotOnOpen =
      false; // Track if we've cleared the dot on this open
  int _lastNotificationCount = 0;
  int _lastUnreadCount =
      0; // Track last unread count to avoid unnecessary updates
  NotificationViewModel?
  _notificationProvider; // Store provider reference for disposal

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer to detect when app resumes from sleep/background
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Always load notifications when view is opened
      _notificationProvider = context.read<NotificationViewModel>();

      // CRITICAL: Clear the dot IMMEDIATELY and PERSISTENTLY when notifications view is opened
      // User has "seen" the notifications by opening the view, so clear the dot
      // This must happen BEFORE loading notifications to prevent race conditions
      final updateNotificationVm = context.read<UpdateNotificationViewModel>();
      updateNotificationVm.showNotification = false;

      // CRITICAL: Update SharedPreferences IMMEDIATELY and wait for it to complete
      // This ensures the cleared state persists even if notifications load and try to update the dot
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setBool('showNotification', false);
      await sharedPrefs.reload(); // Reload to ensure write is committed

      _hasClearedDotOnOpen = true; // Mark that we've cleared the dot
      debugPrint(
        "📬 [NotificationsView] ✅ Dot cleared immediately on view open and persisted",
      );

      // CLEAR CACHE once to ensure long notifications get full re-translation
      await TranslationHelper.clearCache();

      // Now load notifications - but the dot should stay cleared
      await _notificationProvider!.getNotifications();

      // CRITICAL: After notifications load, ensure dot stays cleared
      // Even if there are unread notifications, user has seen them by opening the view
      // The dot should only show again if NEW notifications arrive AFTER this
      if (mounted) {
        final updateNotificationVmAfterLoad = context
            .read<UpdateNotificationViewModel>();
        if (updateNotificationVmAfterLoad.showNotification) {
          // If dot got set back to true (shouldn't happen, but just in case), clear it again
          updateNotificationVmAfterLoad.showNotification = false;
          await sharedPrefs.setBool('showNotification', false);
          debugPrint(
            "📬 [NotificationsView] ✅ Dot re-cleared after notifications load",
          );
        }
      }

      // Don't re-update dot based on unread status here - user has already seen notifications
      // The dot will only show again if new notifications arrive after this
      // Add listener to automatically refresh when notifications change
      // This ensures instant updates when new push notifications arrive
      _notificationProvider!.addListener(_onNotificationUpdate);
    });
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    // Remove listener to prevent memory leaks
    _notificationProvider?.removeListener(_onNotificationUpdate);
    // Reset flag for next time view is opened
    _hasClearedDotOnOpen = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background/sleep, refresh notifications
    // This handles the case where user is on notifications view, phone goes to sleep,
    // notification arrives, and user unlocks phone
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        "📬 [NotificationsView] App resumed - refreshing notifications",
      );

      // Small delay to ensure app is fully resumed
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _notificationProvider != null) {
          // ANTI-FLASH: Don't update the dot immediately - let the anti-flash logic
          // in IndlView and notification_service handle it
          // We only refresh the notifications list here
          _notificationProvider!
              .getNotifications()
              .then((_) {
                debugPrint(
                  "📬 [NotificationsView] ✅ Notifications refreshed after app resume",
                );
                // Note: We don't update the dot here to prevent flash
                // The dot is already being managed by the anti-flash logic in IndlView
              })
              .catchError((e) {
                debugPrint(
                  "❌ [NotificationsView] Error refreshing notifications after resume: $e",
                );
              });
        }
      });
    }
  }

  // Callback when notifications are updated (e.g., new push notification arrives)
  void _onNotificationUpdate() {
    if (mounted) {
      // Force rebuild to show new notifications instantly
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this route (e.g., after navigating back)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // Skip the initial load since initState() already handles it
      if (_isInitialLoad) {
        _isInitialLoad = false;
        _lastRefreshTime = DateTime.now();
        return;
      }

      final now = DateTime.now();
      // Only refresh if it's been more than 1 second since last refresh
      // This prevents excessive refreshes while allowing refresh on return
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > const Duration(seconds: 1)) {
        _lastRefreshTime = now;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            // Clear the dot immediately when returning to notifications view
            // User has "seen" the notifications by opening the view again
            final updateNotificationVm = context
                .read<UpdateNotificationViewModel>();
            updateNotificationVm.showNotification = false;

            // CRITICAL: Update SharedPreferences IMMEDIATELY and wait for it to complete
            final sharedPrefs = await SharedPreferences.getInstance();
            await sharedPrefs.setBool('showNotification', false);
            await sharedPrefs.reload(); // Reload to ensure write is committed

            _hasClearedDotOnOpen = true; // Mark that we've cleared the dot
            debugPrint(
              "📬 [NotificationsView] ✅ Dot cleared on return to view and persisted",
            );

            final provider = context.read<NotificationViewModel>();
            await provider.getNotifications();

            // CRITICAL: After notifications load, ensure dot stays cleared
            if (mounted) {
              final updateNotificationVmAfterLoad = context
                  .read<UpdateNotificationViewModel>();
              if (updateNotificationVmAfterLoad.showNotification) {
                updateNotificationVmAfterLoad.showNotification = false;
                await sharedPrefs.setBool('showNotification', false);
                debugPrint(
                  "📬 [NotificationsView] ✅ Dot re-cleared after notifications load on return",
                );
              }
            }
            // Don't re-update dot based on unread status - user has already seen notifications
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: AppPalettes.backGroundColor,
      appBar: commonAppBar(title: 'Notification'),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<NotificationViewModel>();
          await provider.getNotifications();
          // Don't update dot on refresh - user has already seen notifications by opening the view
          // The dot should stay cleared once the view is opened
        },

        color: AppPalettes.primaryColor,
        child: Consumer<NotificationViewModel>(
          builder: (context, value, _) {
            // ANTI-FLASH LOGIC: Only update dot when user manually interacts
            // Don't update during automatic refreshes (app resume) to prevent flash
            // The anti-flash logic in IndlView handles dot visibility on app resume
            if (value.hasInitialLoadCompleted && !value.isLoading) {
              final currentCount = value.notificationsList.length;
              final currentUnreadCount = value.notificationsList
                  .where((n) => n.read == false || n.read == null)
                  .length;

              // CRITICAL: If dot was cleared on open, NEVER update it based on unread count
              // User has seen the notifications by opening the view, so dot should stay cleared
              // The dot will only show again if NEW notifications arrive AFTER the view is opened
              if (_hasClearedDotOnOpen) {
                // Dot was cleared on open - ensure it stays cleared
                // Don't update based on unread count - user has already seen notifications
                if (currentCount != _lastNotificationCount ||
                    currentUnreadCount != _lastUnreadCount) {
                  _lastNotificationCount = currentCount;
                  _lastUnreadCount = currentUnreadCount;
                  debugPrint(
                    "📬 [NotificationsView] Dot cleared on open - skipping update (counts: $currentCount total, $currentUnreadCount unread)",
                  );
                }
              } else {
                // Dot was NOT cleared on open (shouldn't happen, but handle it)
                // Only update dot when counts change
                if (currentCount != _lastNotificationCount ||
                    currentUnreadCount != _lastUnreadCount) {
                  final previousUnreadCount = _lastUnreadCount;
                  _lastNotificationCount = currentCount;
                  _lastUnreadCount = currentUnreadCount;

                  // Only update dot if unread count DECREASED (user read notifications)
                  if (previousUnreadCount == 0 ||
                      currentUnreadCount < previousUnreadCount) {
                    // Update dot immediately when user reads notifications
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        try {
                          final updateNotificationVm = context
                              .read<UpdateNotificationViewModel>();
                          updateNotificationVm.updateDotFromNotificationsList(
                            value.notificationsList,
                          );
                          debugPrint(
                            "📬 [NotificationsView] Dot updated (user read): $currentCount notifications, $currentUnreadCount unread",
                          );
                        } catch (e) {
                          debugPrint(
                            "❌ [NotificationsView] Error updating dot: $e",
                          );
                        }
                      }
                    });
                  }
                }
              }
            }
            // Show loading only if initial load hasn't completed
            if (value.isLoading && !value.hasInitialLoadCompleted) {
              return Center(child: CustomAnimatedLoading());
            }

            // Show empty state only if initial load has completed and list is empty
            if (value.hasInitialLoadCompleted &&
                value.notificationsList.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: TranslatedText(
                      text: "No notifications",
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
              );
            }
            // Show list if we have data or if still loading (preserve existing data during refresh)
            if (value.notificationsList.isNotEmpty ||
                !value.hasInitialLoadCompleted) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: Dimens.verticalspacing),
                itemCount: value.notificationsList.length,
                separatorBuilder: (context, index) => SizeBox.sizeHX2,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: value.notificationsList[index],
                  );
                },
              );
            }
            // Fallback to empty state
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Text("No notifications", style: textTheme.titleMedium),
                ),
              ),
            );
          },
        ).symmetricPadding(horizontal: Dimens.paddingX4),
      ),
    );
  }
}
