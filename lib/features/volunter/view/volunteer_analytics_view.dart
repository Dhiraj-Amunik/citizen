import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/volunter/models/response/volunteer_analytics_response_model.dart';
import 'package:inldsevak/features/volunter/view/volunteer_event_scanner_view.dart';
import 'package:inldsevak/features/volunter/view_model/volunteer_analytics_view_model.dart';
import 'package:inldsevak/features/volunter/widgets/top_volunteers_leaderboard.dart';
import 'package:provider/provider.dart';

class VolunteerAnalyticsView extends StatelessWidget {
  const VolunteerAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolunteerAnalyticsViewModel(),
      builder: (context, _) {
        final localization = context.localizations;
        return Scaffold(
          appBar: commonAppBar(
            title: localization.be_a_volunteer,
            action: [
              IconButton(
                onPressed: () => _onScanQr(context),
                icon: const Icon(Icons.qr_code_scanner_outlined),
                color: AppPalettes.primaryColor,
              ),
            ],
          ),
          body: Consumer<VolunteerAnalyticsViewModel>(
            builder: (context, viewModel, __) {
              if (viewModel.isLoading && !viewModel.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppPalettes.primaryColor,));
              }

              if (!viewModel.hasData) {
                return RefreshIndicator(
                  onRefresh: viewModel.fetchVolunteerAnalytics,
                  color: AppPalettes.primaryColor,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: TranslatedText(
                              text: localization.volunteer_analytics_data_not_available,
                              style: context.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ).symmetricPadding(
                              horizontal: Dimens.horizontalspacing,
                              vertical: Dimens.verticalspacing,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              final textTheme = context.textTheme;
              final topVolunteers = viewModel.topVolunteers
                  .where((volunteer) =>
                      volunteer.rank != null && (volunteer.name?.isNotEmpty ?? false))
                  .map((volunteer) {
                final resolvedImage = _resolveImageUrl(volunteer.profileImage);
                return LeaderboardEntry(
                  name: volunteer.name ?? "-",
                  imageUrl: resolvedImage,
                  isSvg: _isSvgImage(resolvedImage),
                  rank: volunteer.rank ?? 0,
                  coins: volunteer.coins,
                );
              }).toList();

              final MyVolunteerAnalytics myAnalytics =
                  viewModel.myAnalytics ?? MyVolunteerAnalytics();

              return RefreshIndicator(
                onRefresh: viewModel.fetchVolunteerAnalytics,
                color: AppPalettes.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.horizontalspacing,
                    vertical: Dimens.verticalspacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopVolunteersSection(
                        context: context,
                        textTheme: textTheme,
                        lastMonth: viewModel.lastMonthLabel,
                        entries: topVolunteers,
                      ),
                     
                      SizeBox.sizeHX6,
                      _buildMyAnalyticsSection(
                        context: context,
                        textTheme: textTheme,
                        analytics: myAnalytics,
                      ),
                      SizeBox.sizeHX6,
                      _buildReferralPercentageBar(
                        context: context,
                        textTheme: textTheme,
                        myAnalytics: myAnalytics,
                        shareEventGraph: viewModel.shareEventGraph,
                        topShareEventUsers: viewModel.topShareEventUsers,
                        topVolunteers: viewModel.topVolunteers,
                        myVolunteerRank: viewModel.myVolunteerRank,
                      ),
                      SizeBox.sizeHX6,
                      // _buildReferralGraphSection(
                      //   context: context,
                      //   textTheme: textTheme,
                      //   referralGraph: viewModel.referralGraph,
                      //   highestReward: viewModel.highestInviteReward,
                      // ),
                      // SizeBox.sizeHX6,
                      _buildEventsSection(
                        context: context,
                        title: localization.attended_events,
                        events: viewModel.attendedEvents,
                        textTheme: textTheme,
                        emptyMessage:
                            localization.no_attended_events_recently,
                        highlightColor: AppPalettes.liteGreenColor,
                        showCoinsEarned: true,
                      ),
                      SizeBox.sizeHX6,
                      _buildEventsSection(
                        context: context,
                        title: localization.upcoming_events,
                        events: viewModel.upcomingEvents,
                        textTheme: textTheme,
                        emptyMessage: localization.no_upcoming_events,
                        highlightColor: AppPalettes.liteBlueColor,
                        showRewardCoins: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopVolunteersSection({
    required BuildContext context,
    required TextTheme textTheme,
    required String lastMonth,
    required List<LeaderboardEntry> entries,
  }) {
    final localization = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TranslatedText(
              text: localization.top_volunteers,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
            ),
            Container(
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                border: Border.all(color: AppPalettes.blackColor),
              ),
              child: Text(
                lastMonth,
                style: textTheme.labelSmall?.copyWith(
                  color: AppPalettes.blackColor,
                  fontSize: 12.sp,
                ),
              ).symmetricPadding(
                vertical: Dimens.gapX,
                horizontal: Dimens.paddingX1,
              ),
            ),
          ],
        ),
        SizeBox.sizeHX4,
        if (entries.length >= 3)
          TopVolunteersLeaderboard(entries: entries)
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimens.paddingX4),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX4,
              backgroundColor: AppPalettes.liteGreyColor,
            ),
            child: TranslatedText(
              text: localization.not_enough_data_leaderboard,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildMyAnalyticsSection({
    required BuildContext context,
    required TextTheme textTheme,
    required MyVolunteerAnalytics analytics,
  }) {
    final localization = context.localizations;
    final cards = [
      _AnalyticsCardData(
        icon: AppImages.userIcon,
        iconColor: const Color(0xffFFEDC0),
        backgroundColor: const Color(0xffFFF8E6),
        number: analytics.referedUsers?.toString() ?? "-",
        label: localization.refered_users,
      ),
      _AnalyticsCardData(
        icon: AppImages.clipBoardChecked,
        iconColor: const Color(0xffC8E2D1),
        backgroundColor: const Color(0xffE9F8EE),
        number: analytics.attendedEvents?.toString() ?? "-",
        label: localization.events_attended_volunteer,
      ),
      // _AnalyticsCardData(
      //   icon: AppImages.rankIcon,
      //   iconColor: const Color(0xffFFD700),
      //   backgroundColor: const Color(0xffFFF9E6),
      //   number: _calculateUserLevel(analytics).toString(),
      //   label: "Current Level",
      //   showLevelScale: true,
      //   levelProgress: _calculateLevelProgress(analytics),
      // ),
      // _AnalyticsCardData(
      //   icon: AppImages.clockIcon,
      //   iconColor: const Color(0xffD8D8D8),
      //   backgroundColor: const Color(0xffEDEDED),
      //   title: analytics.activeSince ?? "-",
      //   label: localization.active_since,
      // ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          text: localization.my_analytics,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
          ),
        ),
        SizeBox.sizeHX4,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Dimens.paddingX3,
            mainAxisSpacing: Dimens.paddingX3,
            childAspectRatio: 1.4,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildAnalyticsCard(context: context, cardData: card);
          },
        ),  
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required BuildContext context,
    required _AnalyticsCardData cardData,
  }) {
    final textTheme = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX5,
        backgroundColor: cardData.backgroundColor,
        border:
            Border.all(color: AppPalettes.borderColor.withOpacityExt(0.2)),
        shadowColor: AppPalettes.shadowColor,
        blurRadius: 2,
        spreadRadius: 1,
      ),
      child: cardData.showLevelScale == true
          ? _buildLevelScaleCard(cardData)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: cardData.iconColor,
                  child: CommonHelpers.buildIcons(
                    path: cardData.icon,
                    iconSize: Dimens.scaleX2,
                    iconColor: AppPalettes.blackColor,
                  ),
                ),
                SizedBox(height: Dimens.paddingX1),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (cardData.number != null)
                      Text(
                        cardData.number!,
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppPalettes.blackColor,
                        ),
                      ),
                    if (cardData.title != null)
                      Text(
                        cardData.title!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppPalettes.blackColor,
                        ),
                      ),
                    SizedBox(height: Dimens.gapX),
                    TranslatedText(
                      text: cardData.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.sp,
                        color: AppPalettes.blackColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLevelScaleCard(_AnalyticsCardData cardData) {
    final currentLevel = int.tryParse(cardData.number ?? "1") ?? 1;
    final progress = cardData.levelProgress ?? 0.0;
    
    // Check if this is a content share card (has lok varta in label)
    final isContentShareCard = cardData.label.toLowerCase().contains('lok varta') || 
                                cardData.label.toLowerCase().contains('content');
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: cardData.iconColor,
          child: CommonHelpers.buildIcons(
            path: cardData.icon,
            iconSize: Dimens.scaleX2,
            iconColor: AppPalettes.blackColor,
          ),
        ),
        SizedBox(height: Dimens.paddingX1),
        if (isContentShareCard)
          // For content shares, show the number
          Text(
            cardData.number ?? "0",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppPalettes.blackColor,
            ),
          )
        else
          // For level cards, show "Level X"
          TranslatedText(
            text: "Level $currentLevel",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppPalettes.blackColor,
            ),
          ),
        SizedBox(height: Dimens.gapX),
        if (isContentShareCard)
          // Progress bar for content shares with percentage
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.radiusX2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: AppPalettes.borderColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppPalettes.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: Dimens.gapX / 2),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalettes.blackColor.withOpacity(0.7),
                ),
              ),
            ],
          )
        else
          // Level scale with 5 segments
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final level = index + 1;
              final isActive = level <= currentLevel;
              final isCurrent = level == currentLevel && progress > 0;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppPalettes.primaryColor
                        : AppPalettes.borderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Dimens.radiusX1),
                  ),
                  child: isCurrent && progress < 1.0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.radiusX1),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppPalettes.borderColor.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppPalettes.primaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        SizedBox(height: Dimens.gapX),
        TranslatedText(
          text: cardData.label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppPalettes.blackColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEventsSection({
    required BuildContext context,
    required String title,
    required List<VolunteerEvent> events,
    required TextTheme textTheme,
    required String emptyMessage,
    required Color highlightColor,
    bool showCoinsEarned = false,
    bool showRewardCoins = false,
  }) {
    final localization = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          text: title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
          ),
        ),
        SizeBox.sizeHX4,
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimens.paddingX3),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX3,
              backgroundColor: AppPalettes.liteGreyColor,
            ),
            child: TranslatedText(
              text: emptyMessage,
              style: textTheme.bodyMedium,
            ),
          )
        else
          Column(
            spacing: Dimens.gapX2,
            children: events.map((event) {
              final formattedDate =
                  event.eventDate?.toDdMmmYyyy() ?? localization.date_not_available;
              final subtitle = event.location ?? localization.location_not_available;
              // ignore: unused_local_variable
              final chipText = showCoinsEarned
                  ? "${event.eventType ?? ''} • ${event.coinsEarned ?? 0} Coins"
                  : showRewardCoins
                      ? "${event.eventType ?? ''} • ${event.rewardCoins ?? 0} Coins"
                      : event.eventType ?? "";
                      
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimens.paddingX4),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX5,
                  backgroundColor: highlightColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimens.gapX,
                  children: [
                    TranslatedText(
                      text: event.eventName ?? localization.event_name_not_available,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TranslatedText(
                      text: subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TranslatedText(
                      text: formattedDate,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // if (chipText.trim().isNotEmpty)
                    //   Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: Dimens.paddingX4,
                    //         vertical: Dimens.paddingX1,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: AppPalettes.whiteColor,
                    //         borderRadius:
                    //             BorderRadius.circular(Dimens.radius100),
                    //       ),
                    //       child: Text(
                    //         chipText,
                    //         style: textTheme.labelSmall?.copyWith(
                    //           color: AppPalettes.blackColor,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _onScanQr(BuildContext context) async {
    final localization = context.localizations;
    if (!_isScannerSupported()) {
      CommonSnackbar(
        text: localization.qr_scanning_supported_android_ios,
      ).showToast();
      return;
    }

    final viewModel = context.read<VolunteerAnalyticsViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const VolunteerEventScannerView(),
        ),
      ),
    );
  }

  bool _isScannerSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final trimmed = path.trim();

    if (trimmed.contains('api.dicebear.com')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        final segments = List<String>.from(uri.pathSegments);
        final svgIndex = segments.indexOf('svg');
        if (svgIndex != -1) {
          segments[svgIndex] = 'png';
        }
        final updatedQuery = Map<String, String>.from(uri.queryParameters);
        updatedQuery.putIfAbsent('size', () => '256');
        final newUri = uri.replace(
          pathSegments: segments,
          queryParameters: updatedQuery,
        );
        return newUri.toString();
      }
    }
    if (trimmed.startsWith('http')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return "${URLs.baseURL}$trimmed";
    }

    return "${URLs.baseURL}/$trimmed";
  }

  bool _isSvgImage(String? url) {
    if (url == null) return false;
    final normalized = url.toLowerCase();
    return normalized.contains(".svg") || normalized.contains("format=svg");
  }

  // Get rank badge color: gold for rank 1, silver for rank 2, bronze for rank 3, primaryColor for others
  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppPalettes.primaryColor;
    }
  }

  // Calculate user level based on analytics data
  int _calculateUserLevel(MyVolunteerAnalytics analytics) {
    // Calculate level based on multiple factors
    final totalCoins = analytics.totalCoins ?? 0;
    final attendedEvents = analytics.attendedEvents ?? 0;
    final referedUsers = analytics.referedUsers ?? 0;
    
    // Level calculation: 
    // - Base level from coins (100 coins = level 1, 300 = level 2, etc.)
    // - Bonus from events (5 events = +1 level)
    // - Bonus from referrals (3 referrals = +1 level)
    
    int level = 1;
    
    // Base level from coins (100, 300, 600, 1000, 1500)
    if (totalCoins >= 1500) level = 5;
    else if (totalCoins >= 1000) level = 4;
    else if (totalCoins >= 600) level = 3;
    else if (totalCoins >= 300) level = 2;
    else if (totalCoins >= 100) level = 1;
    
    // Bonus levels from events (5 events = +1 level, max 2 bonus levels)
    final eventBonus = (attendedEvents / 5).floor().clamp(0, 2);
    
    // Bonus levels from referrals (3 referrals = +1 level, max 2 bonus levels)
    final referralBonus = (referedUsers / 3).floor().clamp(0, 2);
    
    // Total level capped at 10
    level = (level + eventBonus + referralBonus).clamp(1, 10);
    
    return level;
  }

  // Calculate progress within current level (0.0 to 1.0)
  double _calculateLevelProgress(MyVolunteerAnalytics analytics) {
    final currentLevel = _calculateUserLevel(analytics);
    final totalCoins = analytics.totalCoins ?? 0;
    
    // Define coin thresholds for each level
    final levelThresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5000, 6000];
    
    if (currentLevel >= 10) return 1.0; // Max level
    
    final currentThreshold = levelThresholds[currentLevel];
    final nextThreshold = levelThresholds[currentLevel + 1];
    
    if (totalCoins >= nextThreshold) return 1.0;
    if (totalCoins <= currentThreshold) return 0.0;
    
    final progress = (totalCoins - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }

  Widget _buildReferralPercentageBar({
    required BuildContext context,
    required TextTheme textTheme,
    required MyVolunteerAnalytics? myAnalytics,
    required List<ShareEventGraphItem> shareEventGraph,
    required List<TopShareEventUser> topShareEventUsers,
    required List<TopVolunteer> topVolunteers,
    MyVolunteerRank? myVolunteerRank,
  }) {
    // Calculate user's content share performance percentage based on content shares (Lok Varta)
    double calculateUserPercentage() {
      // Use sharedEvents if available, otherwise fallback to totalShares
      final contentShares = myAnalytics?.sharedEvents ?? myAnalytics?.totalShares ?? 0;
      
      // Debug logging
      debugPrint("📊 Referral Performance - sharedEvents: ${myAnalytics?.sharedEvents}, totalShares: ${myAnalytics?.totalShares}, using: $contentShares");
      
      // Use a scale based on content shares: milestones at 10, 25, 50, 100, 200+
      // Calculate percentage based on milestones
      final milestones = [10, 25, 50, 100, 200];
      
      // If reached max milestone, return 100%
      if (contentShares >= milestones.last) return 100.0;
      
      // Find current and next milestone
      int currentMilestone = 0;
      int nextMilestone = milestones.first;
      int milestoneIndex = -1; // Track which milestone index we're at
      
      for (int i = 0; i < milestones.length; i++) {
        if (contentShares >= milestones[i]) {
          currentMilestone = milestones[i];
          milestoneIndex = i;
          nextMilestone = i < milestones.length - 1 ? milestones[i + 1] : milestones.last;
        } else {
          // Found the range - contentShares is between currentMilestone and milestones[i]
          if (milestoneIndex == -1) {
            // We're before the first milestone (0 to 10)
            currentMilestone = 0;
            nextMilestone = milestones[i];
            milestoneIndex = -1; // Special case: before first milestone
          } else {
            // We're between two milestones
            nextMilestone = milestones[i];
          }
          break;
        }
      }
      
      // Handle case when we're before the first milestone (0 to 10)
      if (milestoneIndex == -1) {
        // Calculate progress from 0 to first milestone (0 to 10)
        final progress = contentShares / nextMilestone; // progress from 0 to 1
        final rangePercentage = progress * 20.0; // First 20% range
        return rangePercentage.clamp(0.0, 100.0);
      }
      
      // Calculate progress between current and next milestone
      final progress = (contentShares - currentMilestone) / (nextMilestone - currentMilestone);
      final basePercentage = milestoneIndex * 20.0; // Each milestone = 20%
      final rangePercentage = progress * 20.0; // Progress within current range
      
      return (basePercentage + rangePercentage).clamp(0.0, 100.0);
    }

    final overallPercentage = calculateUserPercentage();

    // Determine color based on percentage
    Color getColor(double percentage) {
      if (percentage >= 80) return Colors.green.shade600;
      if (percentage >= 60) return Colors.green.shade400;
      if (percentage >= 40) return Colors.yellow.shade600;
      if (percentage >= 20) return Colors.orange.shade600;
      return Colors.orange.shade700;
    }

    final color = getColor(overallPercentage);
    
    // Create rating segments with 5 parts
    final ratings = [
      _RatingSegment(
        text: "Let's Start",
        label: '0-20%',
        color: Colors.orange.shade700,
        isFilled: overallPercentage >= 20,
        isActive: overallPercentage >= 0 && overallPercentage < 20,
      ),
      _RatingSegment(
        text: 'Try Hard',
        label: '20-40%',
        color: Colors.orange.shade600,
        isFilled: overallPercentage >= 40,
        isActive: overallPercentage >= 20 && overallPercentage < 40,
      ),
      _RatingSegment(
        text: 'Average',
        label: '40-60%',
        color: Colors.yellow.shade600,
        isFilled: overallPercentage >= 60,
        isActive: overallPercentage >= 40 && overallPercentage < 60,
      ),
      _RatingSegment(
        text: 'Good',
        label: '60-80%',
        color: Colors.green.shade400,
        isFilled: overallPercentage >= 80,
        isActive: overallPercentage >= 60 && overallPercentage < 80,
      ),
      _RatingSegment(
        text: 'Excellent',
        label: '80-100%',
        color: Colors.green.shade600,
        isFilled: overallPercentage >= 100,
        isActive: overallPercentage >= 80,
      ),
    ];

    final referralPerformanceCard = Container(
      padding: EdgeInsets.all(Dimens.paddingX4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimens.radiusX4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TranslatedText(
                  text: "My App Content Referral Performance",
            
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${overallPercentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizeBox.sizeHX4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ratings.map((rating) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.paddingX2,
                    horizontal: Dimens.paddingX1,
                  ),
                  decoration: BoxDecoration(
                    color: rating.isActive || rating.isFilled
                        ? rating.color // Full color when active or filled
                        : rating.color.withOpacityExt(0.3), // Reduced opacity when not active/filled
                    borderRadius: BorderRadius.circular(Dimens.radiusX2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TranslatedText(
                        text: rating.text,
                       
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: rating.isFilled || rating.isActive
                              ? Colors.white
                              : AppPalettes.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TranslatedText(
                        text: 
                        rating.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w500,
                          color: rating.isFilled || rating.isActive
                              ? Colors.white.withOpacityExt(0.9)
                              : AppPalettes.blackColor.withOpacityExt(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizeBox.sizeHX3,
          // Segmented progress bar with 5 parts - each with its own color
          Row(
            children: ratings.asMap().entries.map((entry) {
              final index = entry.key;
              final rating = entry.value;
              final segmentWidth = 1.0 / 5; // Each segment is 20%
              final segmentStart = index * segmentWidth;
              final segmentEnd = (index + 1) * segmentWidth;
              
              // Calculate how much of this segment is filled
              double segmentProgress = 0.0;
              final percentageDecimal = overallPercentage / 100;
              
              if (percentageDecimal >= segmentEnd) {
                segmentProgress = 1.0; // Fully filled
              } else if (percentageDecimal > segmentStart) {
                segmentProgress = (percentageDecimal - segmentStart) / segmentWidth;
              }
              final isFilled = segmentProgress >= 1.0;
              final isPartiallyFilled = segmentProgress > 0.0 && segmentProgress < 1.0;
              
              return Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusX2),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: rating.color.withOpacity(0.3), // Background with opacity for all segments
                      borderRadius: BorderRadius.circular(Dimens.radiusX2),
                    ),
                    child: isFilled
                        ? Container(
                            // Fully filled - show full color
                            decoration: BoxDecoration(
                              color: rating.color, // Full color (no opacity)
                              borderRadius: BorderRadius.circular(Dimens.radiusX2),
                            ),
                          )
                        : isPartiallyFilled
                            ? Stack(
                                children: [
                                  // Background with opacity
                                  Container(
                                    color: rating.color.withOpacity(0.3),
                                  ),
                                  // Filled portion with full color
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: segmentProgress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: rating.color, // Full color (no opacity) for filled portion
                                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                  ),
                ),
              );
            }).toList(),
          ),
          SizeBox.sizeHX2,
       
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        referralPerformanceCard,
        SizeBox.sizeHX6,
        // Show Top Volunteers in Referral Champion section
        if (topVolunteers.isNotEmpty) ...[
          TranslatedText(
            text: "Referral Champion",
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
            ),
          ),
          SizeBox.sizeHX4,
          Column(
            spacing: Dimens.gapX2,
            children: topVolunteers
                .where((volunteer) => volunteer.name?.isNotEmpty ?? false)
                .take(10) // Limit to top 10
                .map((volunteer) {
              final imageUrl = _resolveImageUrl(volunteer.profileImage);
              final userName = volunteer.name ?? "-";
              final coins = volunteer.coins ?? 0;
              final rank = volunteer.rank;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX3,
                  vertical: Dimens.paddingX3,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radiusX4,
                  backgroundColor: AppPalettes.whiteColor,
                  border: Border.all(
                    color: AppPalettes.borderColor.withOpacityExt(0.4),
                  ),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
                child: Row(
                  children: [
                    // Rank badge (only show if rank is a valid number, not null which means "-" in API)
                    // Use gold, silver, bronze for top 3 ranks
                    if (rank != null)
                      Container(
                        width: 32.sp,
                        height: 32.sp,
                        decoration: BoxDecoration(
                          color: _getRankBadgeColor(rank),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: TranslatedText(
                            text: "$rank",
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppPalettes.whiteColor,
                              fontSize: 14.sp,
                            ),
                            disableTranslation: true,
                          ),
                        ),
                      ),
                    if (rank != null)
                      SizeBox.sizeWX3,
                    // Profile image
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.radius100),
                          child: Container(
                            width: Dimens.scaleX1B * 2,
                            height: Dimens.scaleX1B * 2,
                            color: AppPalettes.liteGreyColor,
                            child: imageUrl != null
                                ? CommonHelpers.getCacheNetworkImage(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: Center(
                                      child: TranslatedText(
                                        text: CommonHelpers.getInitials(userName),
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppPalettes.blackColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  
                                : Center(
                                    child: TranslatedText(
                                      text: CommonHelpers.getInitials(userName),
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppPalettes.blackColor,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizeBox.sizeWX3,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimens.gapX * 0.5,
                        children: [
                          TranslatedText(
                            text: userName,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppPalettes.blackColor,
                            ),
                            disableTranslation: true,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                size: 14.r,
                                color: AppPalettes.primaryColor,
                              ),
                              SizedBox(width: Dimens.paddingX1),
                              TranslatedText(
                                text: "$coins Coins",
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppPalettes.primaryColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                disableTranslation: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          // Show user's own rank below the list
          // If rank is in top 3, use same design as top volunteers; otherwise use highlighted design
          if (myVolunteerRank != null) ...[
            SizeBox.sizeHX4,
            Builder(
              builder: (context) {
                final rank = myVolunteerRank!;
                final imageUrl = _resolveImageUrl(rank.profileImage);
                final userName = rank.name ?? "-";
                final coins = rank.coins ?? 0;
                final rankValue = rank.rank;
                
                // Check if user's rank is in top 3
                final isTopThree = rankValue != null && rankValue >= 1 && rankValue <= 3;
                
                // Use same design as top volunteers if rank is in top 3, otherwise use highlighted design
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.paddingX3,
                    vertical: Dimens.paddingX3,
                  ),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX4,
                    backgroundColor: isTopThree 
                        ? AppPalettes.whiteColor 
                        : AppPalettes.liteGreenColor.withOpacity(0.3),
                    border: Border.all(
                      color: isTopThree 
                          ? AppPalettes.borderColor.withOpacityExt(0.4)
                          : AppPalettes.primaryColor,
                      width: isTopThree ? 1 : 2,
                    ),
                    blurRadius: isTopThree ? 2 : 4,
                    spreadRadius: isTopThree ? 1 : 2,
                  ),
                  child: Row(
                    children: [
                      // Rank badge (only show if rank is a valid number)
                      // Use gold/silver/bronze for top 3, primaryColor for others
                      if (rankValue != null)
                        Container(
                          width: 32.sp,
                          height: 32.sp,
                          decoration: BoxDecoration(
                            color: _getRankBadgeColor(rankValue),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: TranslatedText(
                              text: "$rankValue",
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppPalettes.whiteColor,
                                fontSize: 14.sp,
                              ),
                              disableTranslation: true,
                            ),
                          ),
                        ),
                      if (rankValue != null)
                        SizeBox.sizeWX3,
                      // Profile image - show initials if no image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.radius100),
                        child: Container(
                          width: Dimens.scaleX1B * 2,
                          height: Dimens.scaleX1B * 2,
                          color: AppPalettes.liteGreyColor,
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? CommonHelpers.getCacheNetworkImage(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: Center(
                                    child: TranslatedText(
                                      text: CommonHelpers.getInitials(userName),
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppPalettes.blackColor,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: TranslatedText(
                                    text: CommonHelpers.getInitials(userName),
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppPalettes.blackColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizeBox.sizeWX3,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Dimens.gapX * 0.5,
                          children: [
                            TranslatedText(
                              text: userName,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppPalettes.blackColor,
                              ),
                              disableTranslation: true,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  size: 14.r,
                                  color: AppPalettes.primaryColor,
                                ),
                                SizedBox(width: Dimens.paddingX1),
                                TranslatedText(
                                  text: "$coins Coins",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppPalettes.primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  disableTranslation: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildReferralGraphSection({
    required BuildContext context,
    required TextTheme textTheme,
    required List<ReferralGraphItem> referralGraph,
    int? highestReward,
  }) {
    if (referralGraph.isEmpty && highestReward == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          text: "Referral Performance",
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
          ),
        ),
        if (highestReward != null) ...[
          SizeBox.sizeHX2,
          Container(
            padding: EdgeInsets.all(Dimens.paddingX3),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX4,
              backgroundColor: AppPalettes.liteGreenColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TranslatedText(
                  text: "Highest Invite Reward",
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "$highestReward Coins",
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalettes.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (referralGraph.isNotEmpty) ...[
          SizeBox.sizeHX4,
          ...referralGraph.map((item) {
            final percentage = double.tryParse(item.percentage ?? "0") ?? 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: Dimens.paddingX2),
              padding: EdgeInsets.all(Dimens.paddingX3),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX4,
                backgroundColor: AppPalettes.liteGreyColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name ?? "-",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "${item.coins ?? 0} Coins",
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppPalettes.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizeBox.sizeHX2,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.radiusX2),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8.h,
                            backgroundColor: AppPalettes.greyColor.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppPalettes.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Dimens.paddingX2),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}

class _RatingSegment {
  final String text;
  final String label;
  final Color color;
  final bool isActive;
  final bool isFilled;

  _RatingSegment({
    required this.text,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isFilled,
  });
}

class _AnalyticsCardData {
  const _AnalyticsCardData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    this.number,
    this.title,
    this.showLevelScale = false,
    this.levelProgress,
  });

  final String icon;
  final Color iconColor;
  final Color backgroundColor;
  final String? number;
  final String? title;
  final String label;
  final bool showLevelScale;
  final double? levelProgress;
}
