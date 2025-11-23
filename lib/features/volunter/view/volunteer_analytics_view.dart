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
                return const Center(child: CircularProgressIndicator());
              }

              if (!viewModel.hasData) {
                return RefreshIndicator(
                  onRefresh: viewModel.fetchVolunteerAnalytics,
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
      _AnalyticsCardData(
        icon: AppImages.shareIcon,
        iconColor: const Color(0xffBAD4DE),
        backgroundColor: const Color(0xffE8F6FB),
        number: analytics.sharedEvents?.toString() ?? "-",
        label: localization.content_shared_volunteer,
      ),
      _AnalyticsCardData(
        icon: AppImages.clockIcon,
        iconColor: const Color(0xffD8D8D8),
        backgroundColor: const Color(0xffEDEDED),
        title: analytics.activeSince ?? "-",
        label: localization.active_since,
      ),
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
            return _buildAnalyticsCard(cardData: card);
          },
        ),  
      ],
    );
  }

  Widget _buildAnalyticsCard({required _AnalyticsCardData cardData}) {
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
      child: Column(
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
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalettes.blackColor,
                  ),
                ),
              if (cardData.title != null)
                Text(
                  cardData.title!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppPalettes.blackColor,
                  ),
                ),
              SizedBox(height: Dimens.gapX),
              TranslatedText(
                text: cardData.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppPalettes.blackColor,
                ),
              ),
            ],
          ),
        ],
      ),
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
}

class _AnalyticsCardData {
  const _AnalyticsCardData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    this.number,
    this.title,
  });

  final String icon;
  final Color iconColor;
  final Color backgroundColor;
  final String? number;
  final String? title;
  final String label;
}
