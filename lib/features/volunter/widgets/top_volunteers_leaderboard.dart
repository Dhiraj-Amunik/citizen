import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';

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
                        borderColor: const Color(0xFFC0C0C0),
                        badgeColor: const Color(0xFF808080),
                      ),
                    ),
                    SizedBox(width: Dimens.paddingX2),
                    Expanded(
                      child: _buildRankedAvatar(
                        entry: firstPlace,
                        rank: 1,
                        size: 100.sp,
                        borderColor: const Color(0xFFFFD700),
                        badgeColor: const Color(0xFFFFA500),
                        isFirstPlace: true,
                      ),
                    ),
                    SizedBox(width: Dimens.paddingX2),
                    Expanded(
                      child: _buildRankedAvatar(
                        entry: thirdPlace,
                        rank: 3,
                        size: 80.sp,
                        borderColor: const Color(0xFFCD7F32),
                        badgeColor: const Color(0xFF8B4513),
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

  Widget _buildRankedAvatar({
    required LeaderboardEntry entry,
    required int rank,
    required double size,
    required Color borderColor,
    required Color badgeColor,
    bool isFirstPlace = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: size.sp,
              height: size.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 3.sp,
                ),
                color: AppPalettes.liteGreyColor,
              ),
              child: ClipOval(
                child: isFirstPlace
                    ? Padding(
                        padding: EdgeInsets.all(4.r),
                        child: _buildAvatarContent(entry, size),
                      )
                    : _buildAvatarContent(entry, size),
              ),
            ),
            Positioned(
              bottom: -4.r,
              child: CircleAvatar(
                radius: 8.sp,
                backgroundColor: badgeColor,
                child: Text(
                  '$rank',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppPalettes.whiteColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimens.paddingX2),
        Text(
          entry.name,
          style: TextStyle(
            fontSize: isFirstPlace ? 16.sp : 14.sp,
            fontWeight: isFirstPlace ? FontWeight.bold : FontWeight.w500,
            color: AppPalettes.blackColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
}

Widget _buildInitialsPlaceholder(LeaderboardEntry entry, double size) {
  return Container(
    color: AppPalettes.liteGreyColor,
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
      placeholderBuilder: (_) => _buildInitialsPlaceholder(entry, size),
    );
  }

  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _buildInitialsPlaceholder(entry, size),
  );
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
