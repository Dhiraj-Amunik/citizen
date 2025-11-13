import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class LeaderBoardView extends StatefulWidget {
  const LeaderBoardView({super.key});

  @override
  State<LeaderBoardView> createState() => _LeaderBoardViewState();
}

class _LeaderBoardViewState extends State<LeaderBoardView> {
  final List<String> _periods = const [
    'Oct 2025',
    'Sep 2025',
    'Aug 2025',
  ];

  late String _selectedPeriod = _periods.first;

  final List<_LeaderboardEntry> _entries = const [
    _LeaderboardEntry(
      rank: 1,
      name: 'John',
      coins: 12400,
      avatar: 'https://i.pravatar.cc/150?img=12',
      highlightColor: Color(0xffFFF7E0)
    ),
    _LeaderboardEntry(
      rank: 2,
      name: 'John',
      coins: 11000,
      avatar: 'https://i.pravatar.cc/150?img=5',
      highlightColor: Color(0xffF4F4F4)
    ),
    _LeaderboardEntry(
      rank: 3,
      name: 'John',
      coins: 10500,
      avatar: 'https://i.pravatar.cc/150?img=8',
      highlightColor: Color(0xffFFF3E6)
    ),
    _LeaderboardEntry(
      rank: 4,
      name: 'John',
      coins: 9000,
      avatar: 'https://i.pravatar.cc/150?img=20',
    ),
    _LeaderboardEntry(
      rank: 5,
      name: 'John',
      coins: 8000,
      avatar: 'https://i.pravatar.cc/150?img=18',
    ),
    _LeaderboardEntry(
      rank: 6,
      name: 'John',
      coins: 8000,
      avatar: 'https://i.pravatar.cc/150?img=36',
    ),
    _LeaderboardEntry(
      rank: 7,
      name: 'John',
      coins: 8000,
      avatar: 'https://i.pravatar.cc/150?img=14',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topThree = _entries.take(3).toList();
    final remaining = _entries.skip(3).toList();

    return Scaffold(
      appBar: commonAppBar(title: 'Leaderboard'),
      backgroundColor: AppPalettes.whiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
        ),
        child: GestureDetector(
          onTap: () {
            RouteManager.pushNamed(Routes.coinsHistoryPage);
          },
          child: _BottomSummary(
            rank: 12,
            coins: 7400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.verticalspacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               
                _PeriodSelector(
                  periods: _periods,
                  selected: _selectedPeriod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: Dimens.paddingX5),
            if (topThree.isNotEmpty) ...[
              _TopCard(entry: topThree[0]),
              SizedBox(height: Dimens.paddingX4),
              Row(
                children: [
                  Expanded(child: _TopCard(entry: topThree[1], compact: true)),
                  SizedBox(width: Dimens.paddingX3),
                  Expanded(child: _TopCard(entry: topThree[2], compact: true)),
                ],
              ),
            ],
            SizedBox(height: Dimens.paddingX5),
            ...List.generate(
              remaining.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: Dimens.paddingX3),
                child: _RankListTile(entry: remaining[index]),
              ),
            ),
            SizedBox(height: Dimens.paddingX10 + 70.h),
          ],
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({
    required this.entry,
    this.compact = false,
  });

  final _LeaderboardEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Color background;
    if (entry.highlightColor != null) {
      background = entry.highlightColor!;
    } else if (compact) {
      background = AppPalettes.whiteColor;
    } else {
      background = AppPalettes.liteGreyColor;
    }

    Color borderColor;
    switch (entry.rank) {
      case 1:
        borderColor = const Color(0xFFE6BB4E);
        break;
      case 2:
        borderColor = const Color(0xFFBDBDBD);
        break;
      case 3:
        borderColor = const Color(0xFFD7A56D);
        break;
      default:
        borderColor = AppPalettes.primaryColor.withOpacityExt(0.6);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: compact ? Dimens.paddingX4 : Dimens.paddingX6,
            horizontal: Dimens.paddingX3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(Dimens.radiusX5),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: compact ? 28.r : 36.r,
                backgroundColor: AppPalettes.whiteColor,
                backgroundImage: NetworkImage(entry.avatar),
              ),
              SizedBox(height: Dimens.paddingX3),
              Text(
                entry.name,
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 14.sp : 16.sp,
                ),
              ),
              SizedBox(height: Dimens.paddingX2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    color: AppPalettes.yellowColor,
                    size: 16.r,
                  ),
                  SizedBox(width: Dimens.paddingX2),
                  Text(
                    '${entry.coins} Coins',
                    style: AppStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppPalettes.blackColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: compact ? Dimens.paddingX2 : Dimens.paddingX3,
          top: compact ? Dimens.paddingX2 : Dimens.paddingX3,
          child: _RankBadge(
            rank: entry.rank,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _RankListTile extends StatelessWidget {
  const _RankListTile({required this.entry});

  final _LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.paddingX3,
        horizontal: Dimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: AppPalettes.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX3),
        border: Border.all(
          color: AppPalettes.primaryColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(entry.avatar),
          ),
          SizedBox(width: Dimens.paddingX3),
          Expanded(
            child: Text(
              '${entry.rank}   ${entry.name}',
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                color: AppPalettes.yellowColor,
                size: 16.r,
              ),
              SizedBox(width: Dimens.paddingX2),
              Text(
                '${entry.coins} Coins',
                style: AppStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    this.compact = false,
  });

  final int rank;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? Dimens.paddingX1 : Dimens.paddingX2,
        horizontal: compact ? Dimens.paddingX2 : Dimens.paddingX3,
      ),
      decoration: BoxDecoration(
        color: AppPalettes.liteGreenColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
         CommonHelpers.buildIcons(path: AppImages.rankIcon, iconSize: 14.r),
          SizedBox(width: Dimens.paddingX),
          Text(
            '$rank',
            style: AppStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppPalettes.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  final List<String> periods;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
        final selectedPeriod = ValueNotifier<String>('Oct 2025');
    return  ValueListenableBuilder<String>(
                  valueListenable: selectedPeriod,
                  builder: (context, value, _) {
                    return PopupMenuButton<String>(
                      onSelected: (selected) {
                        selectedPeriod.value = selected;
                      },
                      itemBuilder: (context) => [
                        'Last Month',
                        'Last 3 Months',
                        'Last 6 Months',
                      ].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList(),
                      child: Container(
                        decoration: boxDecorationRoundedWithShadow(
                          Dimens.radiusX2,
                          border: Border.all(color: AppPalettes.blackColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppPalettes.blackColor,
                                fontSize: 14.sp,
                              ),
                            ).symmetricPadding(
                              vertical: Dimens.gapX,
                              horizontal: Dimens.paddingX1,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16.r,
                              color: AppPalettes.blackColor,
                            ),
                            SizedBox(width: Dimens.paddingX1),
                          ],
                        ).verticalPadding( Dimens.paddingX1),
                      ),
                    );
                  },
                );
  }
}

class _BottomSummary extends StatelessWidget {
  const _BottomSummary({
    required this.rank,
    required this.coins,
  });

  final int rank;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX2,
      ),
      decoration: BoxDecoration(
        color: AppPalettes.greenColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX3),
       
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Rank',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppPalettes.whiteColor,
                  ),
                ),
                SizedBox(height: Dimens.paddingX2),
                Text(
                  '$rank',
                  style: AppStyles.headlineLarge.copyWith(
                    color: AppPalettes.whiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
         
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Coins',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppPalettes.whiteColor,
                  ),
                ),
                SizedBox(height: Dimens.paddingX2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppPalettes.whiteColor,
                      size: 18.r,
                    ),
                    SizedBox(width: Dimens.paddingX2),
                    Text(
                      coins.toString(),
                      style: AppStyles.headlineLarge.copyWith(
                        color: AppPalettes.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  final int rank;
  final String name;
  final int coins;
  final String avatar;
  final Color? highlightColor;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.coins,
    required this.avatar,
    this.highlightColor,
  });
}

