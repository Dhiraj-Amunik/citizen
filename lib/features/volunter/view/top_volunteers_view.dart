import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/volunter/models/response/volunteer_analytics_response_model.dart';
import 'package:inldsevak/features/volunter/view_model/volunteer_analytics_view_model.dart';
import 'package:inldsevak/features/volunter/widgets/top_volunteers_leaderboard.dart';
import 'package:provider/provider.dart';

class TopVolunteersViewArgs {
  const TopVolunteersViewArgs({
    this.canApply = true,
    this.statusMessage,
  });

  final bool canApply;
  final String? statusMessage;
}

class TopVolunteersView extends StatelessWidget {
  const TopVolunteersView({
    super.key,
    this.canApply = true,
    this.statusMessage,
  });

  final bool canApply;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolunteerAnalyticsViewModel(),
      builder: (context, _) {
        return Scaffold(
          appBar: commonAppBar(title: "Be a Volunteer"),
          body: Consumer<VolunteerAnalyticsViewModel>(
            builder: (context, viewModel, __) {
              final topVolunteers = viewModel.topVolunteers
                  .where(
                    (volunteer) =>
                        volunteer.rank != null &&
                        (volunteer.name?.isNotEmpty ?? false),
                  )
                  .toList()
                ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

              if (viewModel.isLoading && topVolunteers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppPalettes.primaryColor,
                  ),
                );
              }

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
                    spacing: Dimens.widgetSpacing,
                    children: [
                      _buildHeroSection(context),
                      _buildLeaderboardSection(
                        context: context,
                        viewModel: viewModel,
                        volunteers: topVolunteers,
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

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        backgroundColor: AppPalettes.liteGreenColor,
        Dimens.radiusX5,
        spreadRadius: 2,
        blurRadius: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Together for a stronger Community",
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimens.gapX2),
          Text(
            "Volunteer with local programs, connect with others, and make your contribution count.",
            style: context.textTheme.labelMedium?.copyWith(
              color: AppPalettes.lightTextColor,
            ),
          ),
          SizeBox.sizeHX4,
          if (canApply)
            CommonButton(
              text: "+ Become a Volunteer",
              height: 40.height(),
              onTap: () {
                RouteManager.pushNamed(Routes.beVolunteerPage);
              },
              textColor: AppPalettes.whiteColor,
              radius: Dimens.radius100,
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.paddingX3,
                vertical: Dimens.paddingX2,
              ),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX3,
                backgroundColor: AppPalettes.gradientFirstColor,
              ),
              child: Center(
                child: Text(
                  statusMessage ?? "Volunteer request is pending",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppPalettes.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ).onlyPadding(bottom: Dimens.paddingX2),
    );
  }

  Widget _buildLeaderboardSection({
    required BuildContext context,
    required VolunteerAnalyticsViewModel viewModel,
    required List<TopVolunteer> volunteers,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX3,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Top Volunteers",
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              decoration: boxDecorationRoundedWithShadow(
                Dimens.paddingX1,
                border: Border.all(color: AppPalettes.blackColor),
              ),
              child: Text(
                viewModel.lastMonthLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppPalettes.blackColor,
                ),
              ).symmetricPadding(
                vertical: Dimens.gapX,
                horizontal: Dimens.paddingX1,
              ),
            )
          ],
        ),
        if (volunteers.length >= 3)
          TopVolunteersLeaderboard(
            entries: volunteers
                .take(3)
                .map((volunteer) {
                  final resolvedImage = _resolveImageUrl(volunteer.profileImage);
                  return LeaderboardEntry(
                    name: volunteer.name ?? "-",
                    imageUrl: resolvedImage,
                    isSvg: _isSvgImage(resolvedImage),
                    rank: volunteer.rank ?? 0,
                    coins: volunteer.coins,
                  );
                }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimens.paddingX4),
            decoration: boxDecorationRoundedWithShadow(
              Dimens.radiusX4,
              backgroundColor: AppPalettes.liteGreyColor,
            ),
            child: Text(
              viewModel.isLoading
                  ? "Loading volunteer leaderboard..."
                  : "Not enough data to display the leaderboard yet.",
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        if (volunteers.length > 3)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX2,
            children: [
              Text(
                "More Volunteers",
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...volunteers.skip(3).map(_VolunteerListTile.new).toList(),
            ],
          ),
      ],
    );
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

class _VolunteerListTile extends StatelessWidget {
  const _VolunteerListTile(this.volunteer);

  final TopVolunteer volunteer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX2,
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
          CircleAvatar(
            radius: Dimens.scaleX1B,
            backgroundColor: AppPalettes.liteGreenColor,
            child: Text(
              "${volunteer.rank ?? '-'}",
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalettes.blackColor,
              ),
            ),
          ),
          SizeBox.sizeWX2,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX * 0.5,
              children: [
                Text(
                  volunteer.name ?? "-",
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (volunteer.coins != null)
                  Text(
                    "${volunteer.coins} Coins",
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppPalettes.lightTextColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}