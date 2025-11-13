import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class CoinsHistoryView extends StatelessWidget {
  const CoinsHistoryView({super.key});

  static const _totalCoins = 7400;
  static const _lastEarned = 'Oct 24';

  static final List<_CoinHistoryItem> _history = [
    _CoinHistoryItem(title: 'Share Content', date: 'Oct 24', coins: 50),
    _CoinHistoryItem(title: 'Share App', date: 'Oct 24', coins: 50),
    _CoinHistoryItem(
      title: 'Submit Volunteer Form',
      date: 'Oct 23',
      coins: 50,
    ),
    _CoinHistoryItem(
      title: 'Wall of Help Contribution',
      date: 'Oct 21',
      coins: 50,
    ),
    _CoinHistoryItem(title: 'Request Appointment', date: 'Oct 20', coins: 50),
    _CoinHistoryItem(title: 'Share Content', date: 'Oct 20', coins: 50),
    _CoinHistoryItem(title: 'Share Content', date: 'Oct 18', coins: 50),
    _CoinHistoryItem(title: 'Share Content', date: 'Oct 15', coins: 50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        title: 'Coins History',
        action: [
          IconButton(
            onPressed: () {
              RouteManager.pushNamed(Routes.coinsInfoPage);
            },
            icon: Icon(
              Icons.info_outline_rounded,
              color: AppPalettes.greenColor,
              size: 20.r,
            ),
          ),
        ],
      ),
      backgroundColor: AppPalettes.whiteColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.verticalspacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Earning Summary',
              style: AppStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: Dimens.paddingX4),
            _SummaryCard(
              totalCoins: _totalCoins,
              lastEarned: _lastEarned,
            ),
            SizedBox(height: Dimens.paddingX5),
            ..._history.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: Dimens.paddingX3),
                child: _HistoryTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCoins,
    required this.lastEarned,
  });

  final int totalCoins;
  final String lastEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX5,
      ),
      decoration: BoxDecoration(
        color: AppPalettes.liteGreenColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX5),
        border: Border.all(
          color: AppPalettes.primaryColor.withOpacityExt(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Coins',
            style: AppStyles.bodyMedium.copyWith(
              color: AppPalettes.blackColor.withOpacityExt(0.7),
            ),
          ),
          SizedBox(height: Dimens.paddingX2),
          Row(
            children: [
              Text(
                '$totalCoins',
                style: AppStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                  color: AppPalettes.blackColor,
                ),
              ),
              SizedBox(width: Dimens.paddingX2),
              Icon(
                Icons.monetization_on_outlined,
                color: AppPalettes.yellowColor,
                size: 20.r,
              ),
            ],
          ),
          SizedBox(height: Dimens.paddingX2),
          Text(
            'Last Earned : $lastEarned',
            style: AppStyles.bodyMedium.copyWith(
              color: AppPalettes.blackColor.withOpacityExt(0.7),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final _CoinHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX3,
      ),
      decoration: BoxDecoration(
        color: AppPalettes.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.radiusX3),
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Dimens.paddingX1),
                Text(
                  item.date,
                  style: AppStyles.labelLarge.copyWith(
                    color: AppPalettes.blackColor.withOpacityExt(0.6),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+${item.coins}',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPalettes.primaryColor,
                ),
              ),
              SizedBox(width: Dimens.paddingX1),
              Icon(
                Icons.monetization_on_outlined,
                color: AppPalettes.yellowColor,
                size: 16.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinHistoryItem {
  final String title;
  final String date;
  final int coins;

  const _CoinHistoryItem({
    required this.title,
    required this.date,
    required this.coins,
  });
}

