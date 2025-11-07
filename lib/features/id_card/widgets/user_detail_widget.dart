import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/profile/models/response/user_profile_model.dart';

class UserDetailWidget extends StatelessWidget {
  final double scale;
  final Data? profile;
  final TextStyle? heading;
  const UserDetailWidget({
    super.key,
    required this.profile,
    required this.scale,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Flexible(
      child: Row(
        spacing: Dimens.gapX4,
        children: [
          SizedBox(
            height: scale,
            width: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius100)),
              child: Container(
                color: AppPalettes.liteGreenColor,
                child: CommonHelpers.getCacheNetworkImage(
                  profile?.avatar,
                  // placeholder: CommonHelpers.showInitials(
                  //   profile?.name ?? '',
                  //   style: textTheme.bodyLarge,
                  // ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: Dimens.gapX,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${profile?.name}",
                  style: heading?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${localization.membership_id} : ${profile?.membershipId}",
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${profile?.phone}",
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
