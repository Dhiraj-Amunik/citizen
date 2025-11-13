import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/nearest_member/view_model/nearest_member_view_model.dart';
import 'package:inldsevak/features/nearest_member/widgets/member_widget.dart';
import 'package:inldsevak/features/nearest_member/widgets/nm_appbar.dart';
import 'package:provider/provider.dart';

class NearestMemberView extends StatelessWidget {
  const NearestMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return ChangeNotifierProvider(
      create: (context) => NearestMemberViewModel(),
      builder: (_, _) {
        return Scaffold(
          body: Consumer<NearestMemberViewModel>(
            builder: (_, value, _) {
              if (value.isLoading) {
                return Center(child: CustomAnimatedLoading());
              }
              return NestedScrollView(
                headerSliverBuilder: (coo, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        coo,
                      ),
                      sliver: SliverSafeArea(
                        top: false,
                        bottom: false,
                        sliver: NearestMemberSilverAppbar(
                          markers: value.markers,
                          isScrolled: innerBoxIsScrolled,
                          membersList: value.membersList,
                        ),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.horizontalspacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX4,
                    children: [
                      SizeBox.size,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              localization.list_of_nearest_member,
                              style: textTheme.titleMedium?.copyWith(
                                color: AppPalettes.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              RouteManager.pushNamed(
                                Routes.myMembersMessagesListPage,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.paddingX2,
                                vertical: Dimens.paddingX1,
                              ),
                              decoration: boxDecorationRoundedWithShadow(
                                Dimens.radius100,
                                border: Border.all(width: 1),
                              ),
                              child: Row(
                                spacing: Dimens.gapX1B,
                                children: [
                                  CommonHelpers.buildIcons(
                                    path: AppImages.notificationIcon,
                                    iconSize: Dimens.scaleX1B,
                                    iconColor: AppPalettes.blackColor,
                                  ),
                                  Text(
                                    localization.inbox,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppPalettes.lightTextColor,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      value.membersList.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizeBox.sizeHX4,
                                CommonHelpers.buildIcons(
                                  path: AppImages.placeholderEmpty,
                                  iconSize: 0.25.screenWidth,
                                ),
                                Text(
                                  "No members found",
                                  style: AppStyles.titleSmall,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: value.membersList.length,
                              itemBuilder: (_, index) {
                                final data = value.membersList[index];
                                return MemberWidget(
                                  member: data,
                                  onTap: () => RouteManager.pushNamed(
                                    Routes.chatMemberPage,
                                    arguments: data,
                                  ),

                                  showIcon: true,
                                );
                              },
                              separatorBuilder: (_, _) => SizeBox.sizeHX3,
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
}
