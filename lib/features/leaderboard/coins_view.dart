import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';

class CoinsInfoView extends StatelessWidget {
  const CoinsInfoView({super.key});

  static final List<_CoinInfoItem> _items = [
    _CoinInfoItem(
      title: 'Share App',
      coins: 100,
      icon: AppImages.shareIcon,
    ),
    _CoinInfoItem(
      title: 'Volunteer Form',
      coins: 80,
      icon: AppImages.clipBoardIcon,
    ),
    _CoinInfoItem(
      title: 'Appointments',
      coins: 40,
      icon: AppImages.calenderIcon,
    ),
    _CoinInfoItem(
      title: 'Share Content',
      coins: 60,
      icon: AppImages.shareIcon,
    ),
    _CoinInfoItem(
      title: 'Wall of Help',
      coins: 50,
      icon: AppImages.helpAccess,
    ),
    _CoinInfoItem(
      title: 'Surveys',
      coins: 30,
      icon: AppImages.clipBoardIcon,
    ),
    _CoinInfoItem(
      title: 'Donations',
      coins: 20,
      icon: AppImages.navDonateIcon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        title: 'Coins Info',
        iconColor: AppPalettes.blackColor,
      ),
      backgroundColor: AppPalettes.whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.verticalspacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Earn Coins ?',
              style: AppStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: Dimens.paddingX4),
            Column(
              children: List.generate(
                _items.length,
                (index) {
                  final item = _items[index];
                  return _CoinInfoTile(
                    item: item,
                    showDivider: index != _items.length - 1,
                  );
                },
              ),
            ),
            const Spacer(),
            _ViewCoinsButton(
              onTap: () => RouteManager.pushNamed(Routes.coinsHistoryPage),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinInfoTile extends StatelessWidget {
  const _CoinInfoTile({
    required this.item,
    required this.showDivider,
  });

  final _CoinInfoItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimens.paddingX3),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX2,
      ),
      decoration: BoxDecoration(
        color: Color(0xffF3F4F4),
        borderRadius: BorderRadius.circular(Dimens.radiusX4),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppPalettes.liteGreenColor,
            child: Center(
              child: CommonHelpers.buildIcons(
                path: item.icon,
                iconSize: 18.r,
                iconColor: AppPalettes.buttonColor,
               
              ),
            ),
          ),
          SizedBox(width: Dimens.paddingX3),
          Expanded(
            child: Text(
              item.title,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.paddingX2,
              vertical: Dimens.paddingX1,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECB3),
              borderRadius: BorderRadius.circular(Dimens.radiusX2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${item.coins}',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDE8F00),
                    fontSize: 10.sp,
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

class _ViewCoinsButton extends StatelessWidget {
  const _ViewCoinsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX4,
          vertical: Dimens.paddingX4,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF56C271),
              Color(0xFF2B7730),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Dimens.radiusX5),
          boxShadow: [
            BoxShadow(
              color: AppPalettes.primaryColor.withOpacityExt(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View My Coins',
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalettes.whiteColor,
              ),
            ),
            SizedBox(width: Dimens.paddingX3),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppPalettes.whiteColor,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinInfoItem {
  final String title;
  final int coins;
  final String icon;

  const _CoinInfoItem({
    required this.title,
    required this.coins,
    required this.icon,
  });
}

