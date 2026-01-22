import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/animated_search_widget.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/my_member_message_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/financial_help_messages_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as woh;
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_helpers.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/l10n/general_stream.dart';
import 'package:provider/provider.dart';

class AllChatsView extends StatefulWidget {
  const AllChatsView({super.key});

  @override
  State<AllChatsView> createState() => _AllChatsViewState();
}

class _AllChatsViewState extends State<AllChatsView> {
  int _selectedTab =
      0; // 0 = Wall of Help, 1 = Nearest Member (if party member), 2 = Complaints
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastRefreshTime;
  DateTime? _lastComplaintsCallTime; // Track last time getComplaints was called
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<Locale>?
  _languageSubscription; // Listen to language changes
  bool _complaintsTabInitialized = false;
  bool _complaintsLoadAttempted =
      false; // Track if we've attempted to load complaints at least once
  DateTime?
  _pageOpenedTime; // Track when page was opened to show loading on initial load

  // Search provider
  late ShowSearchChatProvider _searchProvider;

  // Callbacks to refresh each tab's view model
  VoidCallback? _refreshWallOfHelpCallback;
  VoidCallback? _refreshNearestMemberCallback;
  VoidCallback? _refreshComplaintsCallback;

  // Timer for periodic unread count refresh
  Timer? _unreadCountRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Initialize search provider
    _searchProvider = ShowSearchChatProvider(
      clear: () {
        if (mounted) {
          try {
            _searchController.clear();
            setState(() {});
          } catch (e) {
            // Controller may already be disposed, ignore
          }
        }
      },
    );
    // Listen to Firebase Cloud Messaging for real-time message updates
    _setupMessageListener();
    // Listen to language changes to refresh data
    _setupLanguageListener();
    // Track when page was opened
    _pageOpenedTime = DateTime.now();

    // Initialize view models to ensure unread counts are loaded
    // Always refresh when opening the chats view to get latest counts
    // Use microtask to avoid blocking UI initialization
    Future.microtask(() {
      if (mounted) {
        _refreshUnreadCounts();
        // Start periodic timer to refresh unread counts every 30 seconds
        _startUnreadCountRefreshTimer();
      }
    });
  }

  /// Refresh all unread counts
  void _refreshUnreadCounts() {
    if (!mounted) return;

    try {
      // Always call all three APIs when landing on all_chats_view
      final financialHelpVm = context.read<FinancialHelpMessagesViewModel>();
      // Always refresh to get latest unread count
      financialHelpVm.getMyFinancialHelpRequestMessages();

      // Load wall of help list to get request names for display
      try {
        final wallOfHelpVm = context.read<WallOfHelpViewModel>();
        if (wallOfHelpVm.wallOFHelpLists.isEmpty) {
          wallOfHelpVm.getWallOfHelpList();
        }
      } catch (e) {
        debugPrint("Error loading wall of help list: $e");
      }

      final nearestMemberVm = context.read<MyMemberMessageViewModel>();
      // Always refresh if token is available
      if (nearestMemberVm.token != null && nearestMemberVm.token!.isNotEmpty) {
        nearestMemberVm.getAllChats();
      }

      // Always call getComplaints API when landing on all_chats_view
      // This ensures isFollowUpDue is checked every time the page is opened
      final complaintsVm = context.read<ComplaintsViewModel>();
      complaintsVm.getComplaints(showLoader: false, preserveSearch: true);
      _lastComplaintsCallTime = DateTime.now();
      debugPrint("🔄 Called getComplaints to check isFollowUpDue");
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
    // Cancel timer first
    _unreadCountRefreshTimer?.cancel();
    // Dispose provider first to avoid using disposed controller
    _searchProvider.dispose();
    _messageSubscription?.cancel();
    _languageSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setupLanguageListener() {
    // Listen to language changes and refresh all data
    _languageSubscription = GeneralStream.instance.language.listen((locale) {
      debugPrint(
        "🌐 Language changed to: ${locale.languageCode}, refreshing all chat data...",
      );
      if (mounted) {
        // Refresh all view models when language changes to ensure correct unread counts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              // Refresh Wall of Help
              final financialHelpVm = context
                  .read<FinancialHelpMessagesViewModel>();
              financialHelpVm.getMyFinancialHelpRequestMessages();

              // Refresh Nearest Member if party member
              final roleProvider = context.read<RoleViewModel>();
              if (roleProvider.isPartyMember) {
                final nearestMemberVm = context
                    .read<MyMemberMessageViewModel>();
                if (nearestMemberVm.token != null &&
                    nearestMemberVm.token!.isNotEmpty) {
                  nearestMemberVm.getAllChats();
                }
              }

              // Refresh Complaints - this will re-translate and recalculate unread count
              final complaintsVm = context.read<ComplaintsViewModel>();
              complaintsVm.getComplaints(
                showLoader: false,
                preserveSearch: true,
              );
              _lastComplaintsCallTime = DateTime.now();
              debugPrint("🔄 Refreshed all chat data after language change");
            } catch (e) {
              debugPrint("Error refreshing data on language change: $e");
            }
          }
        });
      }
    });
  }

  void _setupMessageListener() {
    // Listen to foreground messages
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      debugPrint("=== FCM Message Received ===");
      debugPrint("Notification Title: ${message.notification?.title}");
      debugPrint("Notification Body: ${message.notification?.body}");
      debugPrint("Data: ${message.data}");

      // Check if notification is related to complaints
      final messageData = message.data;
      final isComplaintNotification =
          messageData.containsKey('complaintId') ||
          messageData.containsKey('complaint_id') ||
          messageData.containsKey('type') &&
              (messageData['type']?.toString().toLowerCase().contains(
                        'complaint',
                      ) ==
                      true ||
                  messageData['type']?.toString().toLowerCase().contains(
                        'complaint',
                      ) ==
                      true);

      // Check if notification is related to wall of help
      final isWallOfHelpNotification =
          messageData.containsKey('financialHelpRequest') ||
          messageData.containsKey('financial_help_request') ||
          messageData.containsKey('type') &&
              messageData['type']?.toString().toLowerCase().contains('wall') ==
                  true;

      // Check if notification is related to nearest member
      final isNearestMemberNotification =
          messageData.containsKey('chatId') ||
          messageData.containsKey('chat_id') ||
          messageData.containsKey('type') &&
              messageData['type']?.toString().toLowerCase().contains(
                    'member',
                  ) ==
                  true;

      // Refresh on ANY notification when on the chats page
      // This ensures we catch all message notifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshCurrentTabOnMessage();

          // If complaint notification, refresh complaints list
          if (isComplaintNotification) {
            try {
              final complaintsVm = context.read<ComplaintsViewModel>();
              complaintsVm.getComplaints(
                showLoader: false,
                preserveSearch: true,
              );
              debugPrint(
                "📬 Complaint notification received - refreshing complaints list",
              );
            } catch (e) {
              debugPrint("Error refreshing complaints on notification: $e");
            }
          }

          // If wall of help notification, refresh wall of help list
          if (isWallOfHelpNotification) {
            try {
              final financialHelpVm = context
                  .read<FinancialHelpMessagesViewModel>();
              financialHelpVm.getMyFinancialHelpRequestMessages();
              debugPrint(
                "📬 Wall of Help notification received - refreshing wall of help list",
              );
            } catch (e) {
              debugPrint("Error refreshing wall of help on notification: $e");
            }
          }

          // If nearest member notification, refresh nearest member list
          if (isNearestMemberNotification) {
            try {
              final nearestMemberVm = context.read<MyMemberMessageViewModel>();
              if (nearestMemberVm.token != null &&
                  nearestMemberVm.token!.isNotEmpty) {
                nearestMemberVm.getAllChats();
                debugPrint(
                  "📬 Nearest Member notification received - refreshing nearest member list",
                );
              }
            } catch (e) {
              debugPrint("Error refreshing nearest member on notification: $e");
            }
          }
        }
      });
    });
  }

  void _refreshCurrentTabOnMessage() {
    if (!mounted) return;

    debugPrint("=== Refreshing chat list on message ===");
    debugPrint("Current tab: $_selectedTab");

    // Always refresh unread counts for all tabs when a message is received
    try {
      // Refresh Wall of Help unread count
      final financialHelpVm = context.read<FinancialHelpMessagesViewModel>();
      financialHelpVm.getMyFinancialHelpRequestMessages();

      // Refresh Nearest Member unread count if user is party member
      final roleProvider = context.read<RoleViewModel>();
      if (roleProvider.isPartyMember) {
        final nearestMemberVm = context.read<MyMemberMessageViewModel>();
        if (nearestMemberVm.token != null &&
            nearestMemberVm.token!.isNotEmpty) {
          nearestMemberVm.getAllChats();
        }
      }

      // Refresh Complaints unread count
      final complaintsVm = context.read<ComplaintsViewModel>();
      complaintsVm.getComplaints(showLoader: false, preserveSearch: true);
    } catch (e) {
      debugPrint("Error refreshing unread count: $e");
    }

    // Use a small delay to ensure the backend has processed the message
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Use the registered callbacks to refresh
      if (_selectedTab == 0 && _refreshWallOfHelpCallback != null) {
        debugPrint("Refreshing Wall of Help chats");
        _refreshWallOfHelpCallback!();
      } else if (_selectedTab == 1) {
        final roleProvider = context.read<RoleViewModel>();
        if (roleProvider.isPartyMember &&
            _refreshNearestMemberCallback != null) {
          debugPrint("Refreshing Nearest Member chats");
          _refreshNearestMemberCallback!();
        } else if (!roleProvider.isPartyMember &&
            _refreshComplaintsCallback != null) {
          debugPrint("Refreshing Complaints chats");
          _refreshComplaintsCallback!();
        }
      } else if (_selectedTab == 2 && _refreshComplaintsCallback != null) {
        debugPrint("Refreshing Complaints chats");
        _refreshComplaintsCallback!();
      } else {
        debugPrint(
          "No refresh callback available for tab $_selectedTab, using setState",
        );
        // Fallback: trigger setState to rebuild
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always call all three APIs when landing on all_chats_view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          // Always refresh Wall of Help unread count to ensure it's up to date
          final financialHelpVm = context
              .read<FinancialHelpMessagesViewModel>();
          financialHelpVm.getMyFinancialHelpRequestMessages();

          // Always refresh Nearest Member chats if token is available
          final nearestMemberVm = context.read<MyMemberMessageViewModel>();
          if (nearestMemberVm.token != null &&
              nearestMemberVm.token!.isNotEmpty) {
            nearestMemberVm.getAllChats();
          }

          // Always call getComplaints API when landing on all_chats_view
          // This ensures isFollowUpDue is checked every time
          final complaintsVm = context.read<ComplaintsViewModel>();
          complaintsVm.getComplaints(showLoader: false, preserveSearch: true);
          _lastComplaintsCallTime = DateTime.now();
          debugPrint(
            "🔄 Called getComplaints on didChangeDependencies to check isFollowUpDue",
          );
        } catch (e) {
          debugPrint("Error accessing view models: $e");
        }
      }
    });
    // Refresh when returning to this route (e.g., after opening a chat)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      final now = DateTime.now();
      // Only refresh if it's been more than 1 second since last refresh
      // This prevents excessive refreshes while allowing refresh on return
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > const Duration(seconds: 1)) {
        _lastRefreshTime = now;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshCurrentTab();
            // Also refresh all three APIs when returning to ensure counts are up to date
            try {
              // Refresh Wall of Help
              final financialHelpVm = context
                  .read<FinancialHelpMessagesViewModel>();
              financialHelpVm.getMyFinancialHelpRequestMessages();

              // Refresh Nearest Member
              final nearestMemberVm = context.read<MyMemberMessageViewModel>();
              if (nearestMemberVm.token != null &&
                  nearestMemberVm.token!.isNotEmpty) {
                nearestMemberVm.getAllChats();
              }

              // Refresh Complaints - always check isFollowUpDue
              final complaintsVm = context.read<ComplaintsViewModel>();
              complaintsVm.getComplaints(
                showLoader: false,
                preserveSearch: true,
              );
              _lastComplaintsCallTime = DateTime.now();
              debugPrint(
                "🔄 Called getComplaints on route return to check isFollowUpDue",
              );
            } catch (e) {
              debugPrint("Error refreshing unread counts: $e");
            }
          }
        });
      }
    }
  }

  void _refreshCurrentTab() {
    if (!mounted) return;

    // Use setState to trigger a rebuild, which will cause the providers to refresh
    // The providers will call their init methods when rebuilt
    setState(() {
      // This will trigger a rebuild of the widget tree
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final roleProvider = context.read<RoleViewModel>();
    final isPartyMember = roleProvider.isPartyMember;

    // Always call getComplaints when build is called to ensure isFollowUpDue is checked
    // This ensures it's called every time the page is shown/rendered
    // Use debounce to prevent excessive calls (max once per second)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final now = DateTime.now();
        // Only call if it's been more than 1 second since last call
        if (_lastComplaintsCallTime == null ||
            now.difference(_lastComplaintsCallTime!) >
                const Duration(seconds: 1)) {
          _lastComplaintsCallTime = now;
          try {
            final complaintsVm = context.read<ComplaintsViewModel>();
            complaintsVm.getComplaints(showLoader: false, preserveSearch: true);
            debugPrint(
              "🔄 Called getComplaints in build() to check isFollowUpDue",
            );
          } catch (e) {
            debugPrint("Error calling getComplaints in build: $e");
          }
        }
      }
    });

    // Reset tab if out of bounds when party member status changes
    // For non-party members: tab 0 = Wall of Help, tab 1 = Complaints (valid)
    // For party members: tab 0 = Wall of Help, tab 1 = Nearest Member, tab 2 = Complaints
    // Only reset if trying to access tab 2 when not a party member
    if (!isPartyMember && _selectedTab == 2) {
      // If user is not party member but selected tab 2, reset to tab 1 (Complaints)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedTab = 1);
        }
      });
    }
    // Note: For non-party members, tab 1 is Complaints, so we don't reset it

    return ChangeNotifierProvider.value(
      value: _searchProvider,
      child: Scaffold(
        appBar: commonAppBar(
          title: localization.my_chat,
          action: [
            Consumer<ShowSearchChatProvider>(
              builder: (context, search, _) {
                return !search.showSearchWidget
                    ? CommonHelpers.buildIcons(
                        color: AppPalettes.liteGreenColor,
                        padding: Dimens.paddingX2,
                        path: AppImages.searchIcon,
                        onTap: () => search.showSearchWidget = true,
                      )
                    : SizedBox();
              },
            ),
          ],
        ),
        body: Column(
          spacing: Dimens.gapX1,
          children: [
            SizeBox.sizeHX3,
            // Search Bar / Tabs with AnimatedSwitcher
            Consumer<ShowSearchChatProvider>(
              builder: (context, search, _) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: search.showSearchWidget
                      ? AnimatedSearchBar(
                          key: ValueKey('search_bar'),
                          controller: _searchController,
                          onChanged: (text) => setState(() {}),
                          onClear: () {
                            _searchController.clear();
                            setState(() {});
                            search.showSearchWidget = false;
                          },
                        )
                      : Consumer2<
                          FinancialHelpMessagesViewModel,
                          MyMemberMessageViewModel
                        >(
                          key: ValueKey('tabs'),
                          builder: (context, financialHelpVm, nearestMemberVm, _) {
                            final roleProvider = context.read<RoleViewModel>();
                            final isPartyMember = roleProvider.isPartyMember;
                            return SizedBox(
                              height: 25.height(),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior:
                                    Clip.none, // Allow badges to overflow
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.horizontalspacing,
                                ),
                                children: [
                                  _buildFilterChip(
                                    label: TranslatedText(
                                      text: localization.wall_of_help,
                                      style: TextStyle(
                                        color: _selectedTab == 0
                                            ? AppPalettes.primaryColor
                                            : AppPalettes.blackColor,
                                        fontWeight: _selectedTab == 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    isSelected: _selectedTab == 0,
                                    onTap: () {
                                      setState(() => _selectedTab = 0);
                                    },
                                    badgeCount:
                                        financialHelpVm.totalUnreadCount > 0
                                        ? financialHelpVm.totalUnreadCount
                                        : null,
                                  ),
                                  SizeBox.sizeWX2,
                                  if (isPartyMember) ...[
                                    _buildFilterChip(
                                      label: TranslatedText(
                                        text: localization.nearest_member,
                                        style: TextStyle(
                                          color: _selectedTab == 1
                                              ? AppPalettes.primaryColor
                                              : AppPalettes.blackColor,
                                          fontWeight: _selectedTab == 1
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                      isSelected: _selectedTab == 1,
                                      onTap: () {
                                        setState(() => _selectedTab = 1);
                                      },
                                      badgeCount:
                                          nearestMemberVm.totalUnreadCount > 0
                                          ? nearestMemberVm.totalUnreadCount
                                          : null,
                                    ),
                                    SizeBox.sizeWX2,
                                  ],
                                  Consumer<ComplaintsViewModel>(
                                    builder: (context, complaintsVm, _) {
                                      // totalUnreadCount already includes followUpDueCount
                                      final totalBadgeCount =
                                          complaintsVm.totalUnreadCount > 0
                                          ? complaintsVm.totalUnreadCount
                                          : null;
                                      return _buildFilterChip(
                                        label: TranslatedText(
                                          text: localization.my_complaints,
                                          style: TextStyle(
                                            color:
                                                (isPartyMember
                                                    ? _selectedTab == 2
                                                    : _selectedTab == 1)
                                                ? AppPalettes.primaryColor
                                                : AppPalettes.blackColor,
                                            fontWeight:
                                                (isPartyMember
                                                    ? _selectedTab == 2
                                                    : _selectedTab == 1)
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                        isSelected: isPartyMember
                                            ? _selectedTab == 2
                                            : _selectedTab == 1,
                                        onTap: () {
                                          final complaintsTabIndex =
                                              isPartyMember ? 2 : 1;
                                          // Reset initialization flag when switching to complaints tab
                                          _complaintsTabInitialized = false;
                                          _complaintsLoadAttempted = false;
                                          setState(() {
                                            _selectedTab = complaintsTabIndex;
                                          });
                                          // Load complaints when tab is selected - do it immediately
                                          WidgetsBinding.instance.addPostFrameCallback((
                                            _,
                                          ) {
                                            if (mounted) {
                                              try {
                                                final complaintsVm = context
                                                    .read<
                                                      ComplaintsViewModel
                                                    >();
                                                debugPrint(
                                                  "Complaints tab selected - loading complaints...",
                                                );
                                                _complaintsLoadAttempted = true;
                                                complaintsVm
                                                    .loadComplaintsIfNeeded()
                                                    .catchError((error) {
                                                      debugPrint(
                                                        "Error loading complaints on tab select: $error",
                                                      );
                                                      _complaintsTabInitialized =
                                                          false; // Allow retry on error
                                                    });
                                              } catch (e) {
                                                debugPrint(
                                                  "Error accessing ComplaintsViewModel: $e",
                                                );
                                                _complaintsTabInitialized =
                                                    false;
                                              }
                                            }
                                          });
                                        },
                                        badgeCount: totalBadgeCount,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                );
              },
            ),
            SizeBox.sizeHX2,
            // Chat List
            Expanded(
              child: Consumer<RoleViewModel>(
                builder: (context, roleProvider, _) {
                  final isPartyMember = roleProvider.isPartyMember;

                  // Determine which tab to show based on selected tab and party member status
                  if (_selectedTab == 0) {
                    return _buildWallOfHelpChats(textTheme);
                  } else if (_selectedTab == 1) {
                    if (isPartyMember) {
                      return _buildNearestMemberChats(textTheme);
                    } else {
                      // Non-party member: tab 1 is Complaints
                      return _buildComplaintsChats(textTheme);
                    }
                  } else {
                    // Tab 2 (only for party members): Complaints
                    return _buildComplaintsChats(textTheme);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required Widget label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final hasBadge = badgeCount != null && badgeCount > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radiusX6),
      child: Container(
        padding: EdgeInsets.only(
          top: Dimens.paddingX1,
          bottom: Dimens.paddingX1,
          left: Dimens.paddingX3,
          right: hasBadge
              ? Dimens.paddingX5
              : Dimens.paddingX3, // Extra right padding for badge
        ),
        constraints: BoxConstraints(minWidth: 100),
        decoration: BoxDecoration(
          color: isSelected
              ? AppPalettes.primaryColor.withOpacityExt(0.3)
              : AppPalettes.liteGreyColor,
          borderRadius: BorderRadius.circular(Dimens.radiusX6),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: hasBadge
                    ? 10
                    : 0, // Add right padding to label when badge exists
              ),
              child: label,
            ),
            if (hasBadge)
              Positioned(
                right: -6, // Position badge slightly outside container
                top: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: badgeCount > 99 ? 4 : 3,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalettes.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallOfHelpChats(TextTheme textTheme) {
    return Consumer2<FinancialHelpMessagesViewModel, WallOfHelpViewModel>(
      builder: (context, value, wallOfHelpVm, _) {
        // Register refresh callback directly
        _refreshWallOfHelpCallback = () {
          if (mounted) {
            value.onRefresh();
          }
        };

        // Helper function to get the correct name from financial help request
        String? _getRequestName(String? requestId) {
          if (requestId == null || requestId.isEmpty) return null;

          try {
            // Try to find the request in WallOfHelpViewModel list
            final request = wallOfHelpVm.wallOFHelpLists.firstWhere(
              (req) => req.sId == requestId,
              orElse: () => woh.FinancialRequest(),
            );

            // Return the name from the request if found
            if (request.sId != null &&
                request.name != null &&
                request.name!.isNotEmpty) {
              return request.name;
            }
          } catch (e) {
            // Request not found in list, will fall back to relatedUser name
          }

          return null;
        }

        // Filter chats based on search query with Hindi support
        final searchQuery = _searchController.text.trim();
        final filteredChats = searchQuery.isEmpty
            ? value.myFinancialHelpChats
            : value.myFinancialHelpChats.where((chatData) {
                // Get the correct name from request API
                final requestName = _getRequestName(
                  chatData.financialHelpRequest,
                );
                final displayName =
                    requestName ?? chatData.relatedUser?.userName ?? '';
                final userName = displayName.toLowerCase();
                final lastMessage =
                    chatData.lastMessage?.message?.toLowerCase() ?? '';

                // Convert Hindi search to English for matching
                final englishQuery = _convertHindiToEnglish(
                  searchQuery,
                ).toLowerCase();
                final originalQuery = searchQuery.toLowerCase();

                return userName.contains(englishQuery) ||
                    lastMessage.contains(englishQuery) ||
                    userName.contains(originalQuery) ||
                    lastMessage.contains(originalQuery);
              }).toList();

        return RefreshIndicator(
          color: AppPalettes.primaryColor,
          onRefresh: () async {
            await value.onRefresh();
            // Also refresh wall of help list to ensure we have latest request names
            if (mounted) {
              try {
                await wallOfHelpVm.getWallOfHelpList();
              } catch (e) {
                debugPrint("Error refreshing wall of help list: $e");
              }
            }
          },
          child: value.isLoading && value.myFinancialHelpChats.isEmpty
              ? Center(child: CustomAnimatedLoading())
              : filteredChats.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 0.6.screenHeight,
                    child: WallOfHelpHelpers.emptyHelper(
                      text: searchQuery.isEmpty
                          ? "No Messages found"
                          : "No results found",
                      onRefresh: () async {
                        await value.onRefresh();
                      },
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final chatData = filteredChats[index];
                    final lastMessage = chatData.lastMessage;
                    final relatedUser = chatData.relatedUser;
                    final unreadCount = chatData.unreadCount ?? 0;
                    final isUnread = unreadCount > 0;
                    // Get the correct name from financial help request API
                    final requestName = _getRequestName(
                      chatData.financialHelpRequest,
                    );
                    final displayName =
                        requestName ?? relatedUser?.userName ?? "User";

                    // Create FinancialRequest object with available data from chat
                    // Note: Some fields may be missing and will need to be fetched in ChatContributeView
                    final helpRequest = woh.FinancialRequest(
                      sId: chatData.financialHelpRequest,
                      messageId: chatData.messageId,
                      name: requestName ?? relatedUser?.userName,
                      updatedAt: chatData.updatedAt,
                      description: relatedUser
                          ?.reason, // Use reason as description if available
                      // address and typeOfHelp will need to be fetched in ChatContributeView
                    );
                    return _buildChatItem(
                      avatar: null, // Avatar not available in relatedUser
                      name: displayName.capitalize(),
                      lastMessage:
                          lastMessage?.message ?? "Open to see new message",
                      timestamp: chatData.updatedAt ?? lastMessage?.date,
                      onTap: () async {
                        await RouteManager.pushNamed(
                          Routes.chatContributePage,
                          arguments: helpRequest,
                        );
                        // Refresh after returning from chat
                        if (mounted) {
                          value.onRefresh();
                        }
                      },
                      textTheme: textTheme,
                      unreadCount: unreadCount,
                      isUnread: isUnread,
                      disableNameTranslation:
                          true, // User names should stay in English
                    );
                  },
                  itemCount: filteredChats.length,
                  separatorBuilder: (_, _) => SizeBox.sizeHX4,
                ),
        );
      },
    );
  }

  Widget _buildNearestMemberChats(TextTheme textTheme) {
    return Consumer<MyMemberMessageViewModel>(
      builder: (context, value, _) {
        // Register refresh callback directly
        _refreshNearestMemberCallback = () {
          if (mounted) {
            value.getAllChats();
          }
        };

        // Filter chats based on search query with Hindi support
        final searchQuery = _searchController.text.trim();
        final filteredChats = searchQuery.isEmpty
            ? value.myChatsList
            : value.myChatsList.where((chatItem) {
                final name = chatItem.chatWith?.name?.toLowerCase() ?? '';
                final phone = chatItem.chatWith?.phone?.toLowerCase() ?? '';
                final lastMessage =
                    chatItem.lastMessage?.text?.toLowerCase() ?? '';

                // Convert Hindi search to English for matching
                final englishQuery = _convertHindiToEnglish(
                  searchQuery,
                ).toLowerCase();
                final originalQuery = searchQuery.toLowerCase();

                return name.contains(englishQuery) ||
                    phone.contains(englishQuery) ||
                    lastMessage.contains(englishQuery) ||
                    name.contains(originalQuery) ||
                    phone.contains(originalQuery) ||
                    lastMessage.contains(originalQuery);
              }).toList();

        return RefreshIndicator(
          color: AppPalettes.primaryColor,
          onRefresh: () async {
            await value.getAllChats();
          },
          child: value.isLoading && value.myChatsList.isEmpty
              ? Center(child: CustomAnimatedLoading())
              : filteredChats.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 0.6.screenHeight,
                    child: WallOfHelpHelpers.emptyHelper(
                      text: searchQuery.isEmpty
                          ? "No Messages found"
                          : "No results found",
                      onRefresh: () async {
                        await value.getAllChats();
                      },
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final chatItem = filteredChats[index];
                    final message = chatItem.lastMessage;
                    final user = chatItem.chatWith;
                    final unreadCount = chatItem.unreadMessages ?? 0;
                    final isUnread = unreadCount > 0;

                    final PartyMember partyMember = PartyMember(
                      sId: user?.sId, // Ensure sId is set for location fetching
                      name: user?.name,
                      email: user?.email,
                      phone: user?.phone,
                      avatar: user?.avatar,
                      partyMemberDetails: PartyMemberDetails(
                        sId: user?.sId,
                        type: chatItem.chatWithType,
                      ),
                    );

                    return _buildChatItem(
                      avatar: user?.avatar,
                      name: user?.name?.capitalize() ?? "+91 ${user?.phone}",
                      lastMessage: message?.text ?? "Open to see new message",
                      timestamp: message?.date,
                      onTap: () async {
                        await RouteManager.pushNamed(
                          Routes.chatMemberPage,
                          arguments: partyMember,
                        );
                        // Refresh after returning from chat to update unread count
                        if (mounted) {
                          value.getAllChats();
                        }
                      },
                      textTheme: textTheme,
                      unreadCount: unreadCount,
                      isUnread: isUnread,
                      disableNameTranslation:
                          true, // User names should stay in English
                    );
                  },
                  itemCount: filteredChats.length,
                  separatorBuilder: (_, _) => SizeBox.sizeHX4,
                ),
        );
      },
    );
  }

  Widget _buildComplaintsChats(TextTheme textTheme) {
    return Consumer<ComplaintsViewModel>(
      builder: (context, value, _) {
        // Register refresh callback directly
        _refreshComplaintsCallback = () {
          if (mounted) {
            value.getComplaints(showLoader: false, preserveSearch: true);
          }
        };

        // Load complaints if not already loaded - ensure initialization happens immediately
        // Only initialize once per tab selection to avoid multiple calls
        if (!_complaintsTabInitialized ||
            (value.complaintsList.isEmpty &&
                !value.isLoading &&
                !_complaintsLoadAttempted)) {
          _complaintsTabInitialized = true;
          // Load immediately without postFrameCallback to show loading state faster
          if (mounted) {
            debugPrint("Loading complaints for complaints tab...");
            value
                .loadComplaintsIfNeeded()
                .then((_) {
                  // Mark as attempted only after load completes (success or failure)
                  if (mounted) {
                    _complaintsLoadAttempted = true;
                  }
                })
                .catchError((error) {
                  debugPrint("Error loading complaints: $error");
                  if (mounted) {
                    _complaintsTabInitialized = false; // Allow retry on error
                    _complaintsLoadAttempted =
                        true; // Still mark as attempted to prevent infinite loading
                  }
                });
          }
        }

        // Filter complaints based on search query with Hindi support
        final searchQuery = _searchController.text.trim();
        final filteredComplaints = searchQuery.isEmpty
            ? value.complaintsList
            : value.complaintsList.where((complaint) {
                final departmentName =
                    complaint.department?.name?.toLowerCase() ?? '';
                final subject =
                    ComplaintHelper.decodeUtf8(
                      complaint.messages?.first.subject,
                    )?.toLowerCase() ??
                    '';
                final status = complaint.status?.toLowerCase() ?? '';
                final lastMessage = complaint.messages?.isNotEmpty == true
                    ? (complaint.messages!.last.snippet ??
                          complaint.messages!.last.subject ??
                          complaint.messages!.last.body ??
                          '')
                    : '';
                final lastMessageLower = lastMessage.toLowerCase();

                // Convert Hindi search to English for matching
                final englishQuery = _convertHindiToEnglish(
                  searchQuery,
                ).toLowerCase();
                final originalQuery = searchQuery.toLowerCase();

                return departmentName.contains(englishQuery) ||
                    subject.contains(englishQuery) ||
                    status.contains(englishQuery) ||
                    lastMessageLower.contains(englishQuery) ||
                    departmentName.contains(originalQuery) ||
                    subject.contains(originalQuery) ||
                    status.contains(originalQuery) ||
                    lastMessageLower.contains(originalQuery);
              }).toList();

        // Show loading state when:
        // 1. Actively loading AND list is empty AND we haven't attempted load yet, OR
        // 2. Actively loading AND list is empty AND page was just opened (within last 5 seconds)
        final isRecentPageOpen =
            _pageOpenedTime != null &&
            DateTime.now().difference(_pageOpenedTime!) <
                const Duration(seconds: 5);
        final shouldShowLoading =
            value.isLoading &&
            value.complaintsList.isEmpty &&
            (!_complaintsLoadAttempted || isRecentPageOpen);

        return RefreshIndicator(
          color: AppPalettes.primaryColor,
          onRefresh: () async {
            _complaintsLoadAttempted = true;
            await value.getComplaints(showLoader: false, preserveSearch: true);
          },
          // Show loading when actively loading complaints
          child: shouldShowLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomAnimatedLoading(),
                      SizeBox.sizeHX2,
                      Text(
                        "Loading complaints...",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPalettes.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredComplaints.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 0.6.screenHeight,
                    child: WallOfHelpHelpers.emptyHelper(
                      text: searchQuery.isEmpty
                          ? "No Complaints found"
                          : "No results found",
                      onRefresh: () async {
                        await value.getComplaints(
                          showLoader: false,
                          preserveSearch: true,
                        );
                      },
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final complaint = filteredComplaints[index];
                    final lastMessage = complaint.messages?.isNotEmpty == true
                        ? complaint.messages?.last
                        : null;
                    final subject =
                        ComplaintHelper.decodeUtf8(
                          (complaint.messages?.isNotEmpty == true)
                              ? complaint.messages!.first.subject
                              : null,
                        ) ??
                        "No Subject";
                    final status = complaint.status ?? "Pending";
                    final lastMessageText =
                        lastMessage?.snippet ??
                        lastMessage?.subject ??
                        lastMessage?.body ??
                        "No messages yet";
                    final timestamp =
                        lastMessage?.date ??
                        complaint.updatedAt ??
                        complaint.createdAt;

                    final avatarUrl = complaint.user?.avatar;
                    final subjectInitial = subject.isNotEmpty
                        ? subject.substring(0, 1).toUpperCase()
                        : "C";

                    return _buildChatItem(
                      avatar: avatarUrl,
                      name: subject,
                      lastMessage: lastMessageText,
                      timestamp: timestamp,
                      onTap: () async {
                        await RouteManager.pushNamed(
                          Routes.threadComplaintPage,
                          arguments: complaint,
                        );
                        // Refresh after returning from chat
                        if (mounted) {
                          value.getComplaints(
                            showLoader: false,
                            preserveSearch: true,
                          );
                        }
                      },
                      textTheme: textTheme,
                      unreadCount: complaint.unreadMessageCount ?? 0,
                      isUnread: (complaint.unreadMessageCount ?? 0) > 0,
                      status: status,
                      fallbackText: subjectInitial,
                      disableNameTranslation:
                          false, // Department names can be translated to Hindi
                      isFollowUpDue:
                          complaint.isFollowUpDue ==
                          true, // Show notification badge for follow-up due
                    );
                  },
                  itemCount: filteredComplaints.length,
                  separatorBuilder: (_, _) => SizeBox.sizeHX4,
                ),
        );
      },
    );
  }

  Widget _buildChatItem({
    required String? avatar,
    required String name,
    required String lastMessage,
    required String? timestamp,
    required VoidCallback onTap,
    required TextTheme textTheme,
    int unreadCount = 0,
    bool isUnread = false,
    String? status,
    String? fallbackText,
    bool disableNameTranslation =
        false, // Set to true for user names, false for department names
    bool isFollowUpDue = false, // Whether this complaint has follow-up due
  }) {
    String formattedTime = "";
    if (timestamp != null) {
      try {
        final dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
        final adjustedTime = dateTime.add(Duration(hours: 5, minutes: 30));
        formattedTime = adjustedTime.toString().to12HourTime();
      } catch (e) {
        formattedTime = "";
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
      padding: EdgeInsets.symmetric(
        vertical: Dimens.padding,
        horizontal: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Stack(
          children: [
            SizedBox(
              width: Dimens.scaleX6,
              height: Dimens.scaleX6,
              child: avatar != null && avatar.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(
                        Dimens.radius100,
                      ),
                      child: CommonHelpers.getCacheNetworkImage(avatar),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppPalettes.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          fallbackText ?? name.substring(0, 1).toUpperCase(),

                          style: TextStyle(
                            color: AppPalettes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
            if (unreadCount > 0 || isFollowUpDue)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppPalettes.redColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalettes.whiteColor, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              spacing: Dimens.gapX4,
              children: [
                Expanded(
                  child: TranslatedText(
                    text: name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    disableTranslation:
                        disableNameTranslation, // User names stay in English, department names can be translated
                  ),
                ),
                if (formattedTime.isNotEmpty)
                  Text(
                    formattedTime,
                    style: textTheme.bodySmall?.copyWith(
                      color: unreadCount > 0
                          ? AppPalettes.primaryColor
                          : AppPalettes.lightTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 22.height(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppPalettes.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? "99+" : "$unreadCount",
                      style: TextStyle(
                        color: AppPalettes.whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TranslatedText(
                    text: lastMessage,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppPalettes.lightTextColor,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Add spacing to prevent overlap with unread count badge
                if (unreadCount > 0) SizedBox(width: 30),
              ],
            ),
            if (status != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TranslatedText(
                    text: status,
                    style: textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppPalettes.yellowColor;
      case 'in-progress':
        return AppPalettes.blueColor;
      case 'resolved':
        return AppPalettes.greenColor;
      case 'closed':
        return AppPalettes.greyColor;
      case 'escalated':
        return AppPalettes.redColor;
      default:
        return AppPalettes.lightTextColor;
    }
  }

  /// Convert Hindi text to English for search matching
  String _convertHindiToEnglish(String hindiText) {
    if (hindiText.isEmpty) return hindiText;

    // Check if text contains Hindi characters
    if (!_isHindi(hindiText)) {
      return hindiText; // Already in English, return as is
    }

    // Use transliteration mapping for common Hindi to English conversions
    return _transliterateHindiToEnglish(hindiText);
  }

  /// Transliterate Hindi to English using phonetic conversion
  String _transliterateHindiToEnglish(String hindiText) {
    // Common Hindi to English transliteration mapping
    final Map<String, String> hindiToEnglish = {
      'संदेश': 'message',
      'चैट': 'chat',
      'वार्तालाप': 'conversation',
      'उपयोगकर्ता': 'user',
      'नाम': 'name',
      'फोन': 'phone',
      'विभाग': 'department',
      'स्थिति': 'status',
      'लंबित': 'pending',
      'प्रगति में': 'in-progress',
      'हल': 'resolved',
      'बंद': 'closed',
    };

    // Check if entire word matches
    final lowerHindi = hindiText.toLowerCase().trim();
    if (hindiToEnglish.containsKey(lowerHindi)) {
      return hindiToEnglish[lowerHindi]!;
    }

    // For partial matches or unknown words, try character-by-character transliteration
    return _phoneticTransliteration(hindiText);
  }

  /// Phonetic transliteration for Hindi to English
  String _phoneticTransliteration(String hindiText) {
    // Basic phonetic mapping for common Hindi characters to English
    final Map<String, String> charMap = {
      'अ': 'a',
      'आ': 'aa',
      'इ': 'i',
      'ई': 'ee',
      'उ': 'u',
      'ऊ': 'oo',
      'ए': 'e',
      'ऐ': 'ai',
      'ओ': 'o',
      'औ': 'au',
      'क': 'k',
      'ख': 'kh',
      'ग': 'g',
      'घ': 'gh',
      'ङ': 'ng',
      'च': 'ch',
      'छ': 'chh',
      'ज': 'j',
      'झ': 'jh',
      'ञ': 'ny',
      'ट': 't',
      'ठ': 'th',
      'ड': 'd',
      'ढ': 'dh',
      'ण': 'n',
      'त': 't',
      'थ': 'th',
      'द': 'd',
      'ध': 'dh',
      'न': 'n',
      'प': 'p',
      'फ': 'ph',
      'ब': 'b',
      'भ': 'bh',
      'म': 'm',
      'य': 'y',
      'र': 'r',
      'ल': 'l',
      'व': 'v',
      'श': 'sh',
      'ष': 'sh',
      'स': 's',
      'ह': 'h',
    };

    String result = '';
    for (int i = 0; i < hindiText.length; i++) {
      final char = hindiText[i];
      if (charMap.containsKey(char)) {
        result += charMap[char]!;
      } else if (RegExp(r'[a-zA-Z0-9\s]').hasMatch(char)) {
        result += char; // Keep English characters and numbers
      }
    }

    return result.isNotEmpty ? result : hindiText;
  }

  /// Check if text contains Hindi/Devanagari characters
  bool _isHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }
}

// Search provider for chat view
class ShowSearchChatProvider extends ChangeNotifier {
  final Function() clear;

  ShowSearchChatProvider({required this.clear});
  bool _showSearchWidget = false;

  bool get showSearchWidget => _showSearchWidget;

  set showSearchWidget(bool value) {
    _showSearchWidget = value;
    notifyListeners();
  }

  @override
  void dispose() {
    // Only clear if the callback is still valid (widget is still mounted)
    try {
      clear();
    } catch (e) {
      // Ignore errors if controller is already disposed
    }
    super.dispose();
  }
}
