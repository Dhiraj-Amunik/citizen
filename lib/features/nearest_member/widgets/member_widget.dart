import 'package:flutter/cupertino.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';

class MemberWidget extends StatelessWidget {
  final PartyMember member;
  final bool showIcon;
  final Function() onTap;
  const MemberWidget({
    super.key,
    required this.member,
    required this.onTap,
    required this.showIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.paddingX3,
          vertical: Dimens.paddingX3,
        ),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX4,
          border: Border.all(color: AppPalettes.primaryColor, width: 1),
        ),
        child: Stack(
          alignment: AlignmentGeometry.centerRight,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX2,
              children: [
                SizedBox(
                  height: Dimens.scaleX6,
                  width: Dimens.scaleX6,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(
                      Dimens.radius100,
                    ),
                    child: CommonHelpers.getCacheNetworkImage(member.avatar),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: Dimens.gapX,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name.isNull(localization.not_found),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // if (member.phone?.isNotEmpty == true)
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         "${localization.phone_no} : ",
                      //         style: textTheme.bodySmall?.copyWith(
                      //           color: AppPalettes.lightTextColor,
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Text(
                      //           member.phone ?? "",
                      //           style: textTheme.bodySmall,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${localization.email} : ",
                            style: textTheme.bodySmall?.copyWith(
                              color: AppPalettes.lightTextColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              member.email.isNull(localization.not_found),
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimens.gapX1,
                        children: [
                          CommonHelpers.buildIcons(
                            path: AppImages.locationIcon,
                            iconSize: Dimens.scaleX2,
                            iconColor: AppPalettes.blackColor,
                          ),
                          Expanded(
                            child: Text(
                              member.address.isNull(localization.not_found),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showIcon)
                  Icon(
                    CupertinoIcons.captions_bubble,
                    size: Dimens.scaleX2,
                    color: AppPalettes.transparentColor,
                  ).allPadding(Dimens.paddingX2),
              ],
            ),
            if (showIcon)
              Container(
                decoration: boxDecorationRoundedWithShadow(
                  Dimens.radius100,
                  backgroundColor: AppPalettes.liteGreenColor,
                ),
                padding: EdgeInsets.all(Dimens.paddingX2),
                child: Icon(
                  CupertinoIcons.captions_bubble,
                  size: Dimens.scaleX2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
