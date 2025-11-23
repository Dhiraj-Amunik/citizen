import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/home/widgets/upcoming_home_events_widget.dart';
import 'package:inldsevak/features/home/widgets/my_latest_complaints_widgets.dart';
import 'package:inldsevak/features/home/widgets/quick_access_widget.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class IndlView extends StatelessWidget {
  const IndlView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final roleProvider = context.watch<RoleViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        
        action: [
          CommonHelpers.buildIcons(
            path: AppImages.navDonateIcon,
            color: AppPalettes.primaryColor,
            iconColor: AppPalettes.whiteColor,
            padding: Dimens.paddingX3B,
            iconSize: Dimens.scaleX2B,
            onTap: () => RouteManager.pushNamed(Routes.donatePage),
          ),
            SizeBox.sizeWX2,
           Consumer<UpdateNotificationViewModel>(
            builder: (context, value, _) {
              return Stack(
                children: [
                  CommonHelpers.buildIcons(
                    path: AppImages.notificationIcon,
                    color: AppPalettes.liteGreenColor,
                    iconColor: AppPalettes.blackColor,
                    padding: Dimens.paddingX3B,
                    iconSize: Dimens.scaleX3,
                    onTap: () =>
                        RouteManager.pushNamed(Routes.notificationsPage),
                  ),
                  if (value.showNotification)
                    Container(
                      margin: EdgeInsets.all(
                        Dimens.paddingX3B,
                      ).copyWith(left: Dimens.paddingX6B),
                      height: 10,
                      width: 10,
                      decoration: boxDecorationRoundedWithShadow(
                        Dimens.radius100,
                        backgroundColor: AppPalettes.primaryColor,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        child: Consumer<ProfileViewModel>(
          builder: (context, profile, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimens.gapX1,
              children: [
                TranslatedText(
                  text: "Hi, ${profile.profile?.name ?? '...'}",
                  style: textTheme.headlineMedium,
                ),
                Row(
                  spacing: Dimens.gapX1,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: Dimens.scaleX2,
                      color: AppPalettes.primaryColor,
                    ),
                    Flexible(
                      child: TranslatedText(
                        text: profile.profile?.assemblyConstituency?.name ??
                            "Loading...",
                       
                        style: textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.widgetSpacing,
          children: [
            CarouselSlider(
              items: [
                "assets/banners/banner_1.png",
                "assets/banners/banner_1.png",
                "assets/banners/banner_1.png",
              ]
                  .map(
                    (asset) => Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Dimens.horizontalspacing,
                      ).copyWith(top: Dimens.paddingX2),
                      decoration: boxDecorationRoundedWithShadow(
                        Dimens.radiusX2,
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.radiusX2),
                        child: Image.asset(
                          asset,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1,
                enlargeCenterPage: false,
                height: 150,
                enableInfiniteScroll: true,
              ),
            ),
            QuickAccessWidget(showParty: roleProvider.isPartyMember),
            UpComingHomeEventsWidget(),
            Consumer<ComplaintsViewModel>(
              builder: (_, value, _) {
                if (value.complaintsList.isNotEmpty) {
                  return MyLatestComplaintsWidgets(
                    complaintList: value.complaintsList,
                  );
                }
                return Container();
              },
            ),
            SizeBox.sizeHX20,
          ],
        ),
      ),
      backgroundColor: context.cardColor,
    );
  }
}
