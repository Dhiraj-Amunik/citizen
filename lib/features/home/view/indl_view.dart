import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/home/widgets/upcoming_home_events_widget.dart';
import 'package:inldsevak/features/home/widgets/my_latest_complaints_widgets.dart';
import 'package:inldsevak/features/home/widgets/quick_access_widget.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class IndlView extends StatelessWidget {
  const IndlView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final roleProvider = context.read<RoleViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        action: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: Dimens.scaleX6,
              width: Dimens.scaleX6,
              color: AppPalettes.liteGreyColor,
              child: Consumer<ProfileViewModel>(
                builder: (context, profile, _) {
                  return CommonHelpers.getCacheNetworkImage(
                    profile.profile?.avatar,
                    placeholder: CommonHelpers.showInitials(
                      profile.profile?.name ?? '',
                      style: textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        child: Consumer<ProfileViewModel>(
          builder: (context, profile, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX1,
              children: [
                Text(
                  "Hi, ${profile.profile?.name ?? '...'}",
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
                      child: Text(
                        profile.profile?.constituency?.name ?? "Not Found",
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
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
              ).copyWith(top: Dimens.paddingX2),
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                blurRadius: 2,
                spreadRadius: 2,
              ),
              child: Image.asset(
                "assets/banners/banner_1.png",
                fit: BoxFit.cover,
              ),
            ),
            QuickAccessWidget(showParty: roleProvider.isPartyMember),
            UpComingHomeEventsWidget(),
            Consumer<ComplaintsViewModel>(
              builder: (_, value, _) {
                if (!roleProvider.isPartyMember &&
                    value.complaintsList.isNotEmpty) {
                  return MyLatestComplaintsWidgets(
                    complaintList: value.complaintsList,
                  );
                }
                return Container();
              },
            ),

            SizeBox.sizeHX11,
          ],
        ),
      ),
      backgroundColor: context.cardColor,
    );
  }
}
