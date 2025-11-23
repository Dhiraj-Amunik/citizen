import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:shimmer/shimmer.dart';

class TopVolunteersLeaderboard extends StatelessWidget {
  const TopVolunteersLeaderboard({
    super.key,
    required this.entries,
  });

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) {
      return const SizedBox.shrink();
    }

    final sortedEntries = List<LeaderboardEntry>.from(entries)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    final firstPlace = sortedEntries[0];
    final secondPlace = sortedEntries[1];
    final thirdPlace = sortedEntries[2];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX5,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX5,
        backgroundColor: AppPalettes.whiteColor,
        border: Border.all(color: AppPalettes.borderColor),
        blurRadius: 4,
        spreadRadius: 2,
      ),
      child: Stack(
        children: [
          _buildConfettiBackground(),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildRankedAvatar(
                        entry: secondPlace,
                        rank: 2,
                        size: 80.sp,
                        borderColor: const Color(0xFFBDBDBD),
                        badgeColor: const Color(0xFFBDBDBD),
                      ),
                    ),
                    SizedBox(width: Dimens.paddingX2),
                    Expanded(
                      child: _buildFirstPlaceAvatar(
                        entry: firstPlace,
                        size: 100.sp,
                      ),
                    ),
                    SizedBox(width: Dimens.paddingX2),
                    Expanded(
                      child: _buildRankedAvatar(
                        entry: thirdPlace,
                        rank: 3,
                        size: 80.sp,
                        borderColor: const Color(0xFFcd7f32),
                        badgeColor: const Color(0xFfcd7f32),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5.sp,
                child: _buildCrown(),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildConfettiBackground() {
    return Positioned.fill(
      child: Image.asset(
        AppImages.topVolunteerBg,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(painter: ConfettiPainter());
        },
      ),
    );
  }

  Widget _buildCrown() {
    return Center(
      child: Image.asset(
        AppImages.crownImage,
        width: 40.r,
        height: 40.r,
        
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40.sp,
            height: 40.sp,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: AppPalettes.whiteColor,
              size: 24.r,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirstPlaceAvatar({
    required LeaderboardEntry entry,
    required double size,
  }) {
    final diameter = size;
    final borderWidth = 4.sp;
    final padding = 0.sp; // Padding for first place avatar
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFfFC303),
                  width: borderWidth,
                ),
                color: AppPalettes.whiteColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(diameter),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildAvatarContent(entry, size),
                ),
              ),
            ),
            Positioned(
              bottom: -8.r,
              child: Container(
                width: 26.sp,
                height: 26.sp,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFfFC303),
                ),
                alignment: Alignment.center,
                child: Text(
                  '1',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppPalettes.whiteColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimens.paddingX2),
        TranslatedText(
          text: entry.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppPalettes.blackColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRankedAvatar({
    required LeaderboardEntry entry,
    required int rank,
    required double size,
    required Color borderColor,
    required Color badgeColor,
    double? avatarPadding,
    double? badgeSize,
    TextStyle? nameStyle,
  }) {
    final diameter = size.sp;
    final borderWidth = rank == 1 ? 4.sp : 3.sp;
    final padding = avatarPadding ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                color: AppPalettes.whiteColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(diameter),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildAvatarContent(entry, size),
                ),
              ),
            ),
            Positioned(
              bottom: -6.r,
              child: Container(
                width: (badgeSize ?? 20.sp),
                height: (badgeSize ?? 20.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppPalettes.whiteColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimens.paddingX2),
        TranslatedText(
          text: entry.name,
     
          style: (nameStyle ??
              TextStyle(
                fontSize: rank == 1 ? 16.sp : 14.sp,
                fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
              )).copyWith(
            color: AppPalettes.blackColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInitialsPlaceholder(LeaderboardEntry entry, double size) {
    return Container(
      decoration: boxDecorationRoundedWithShadow(Dimens.radius100, backgroundColor: AppPalettes.liteGreyColor,),
      alignment: Alignment.center,
      child: Text(
        CommonHelpers.getInitials(entry.name),
        style: TextStyle(
          fontSize: (size - 6.sp) * 0.3,
          fontWeight: FontWeight.bold,
          color: AppPalettes.blackColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatarContent(LeaderboardEntry entry, double size) {
    final imageUrl = entry.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildInitialsPlaceholder(entry, size);
    }

    if (entry.isSvg) {
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _buildAvatarSkeleton(size),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return _buildAvatarSkeleton(size);
      },
      errorWidget: (context, url, error) {
        return _buildInitialsPlaceholder(entry, size);
      },
    );
  }

  Widget _buildAvatarSkeleton(double size) {
    return Shimmer.fromColors(
      baseColor: AppPalettes.liteGreyColor,
      highlightColor: AppPalettes.whiteColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppPalettes.liteGreyColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);

    final confettiColors = [
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.blue,
      Colors.pink,
    ];

    for (int i = 0; i < 30; i++) {
      paint.color = confettiColors[random.nextInt(confettiColors.length)]
          .withOpacityExt(0.6);

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8,
          height: 8,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LeaderboardEntry {
  LeaderboardEntry({
    required this.name,
    this.imageUrl,
    this.isSvg = false,
    required this.rank,
    this.coins,
  });

  final String name;
  final String? imageUrl;
  final bool isSvg;
  final int rank;
  final int? coins;
}
