import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/l10n/app_localizations.dart';

import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;

class UserCardHelpWidget extends StatelessWidget {
  final model.FinancialRequest help;
  const UserCardHelpWidget({super.key, required this.help});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final localization = context.localizations;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: BoxBorder.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonHelpers.buildStatus(
               
                _resolveStatusLabel(localization),
                statusColor: _resolveStatusColor(),
              ),
            ],
          ),
          Row(
            spacing: Dimens.gapX3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(textTheme),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      text: help.title ?? "Unknow subject",
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizeBox.sizeHX1,
                    ReadMoreWidget(
                      text: help.description.isNull(localization.not_found),
                      style: AppStyles.labelMedium.copyWith(
                        color: AppPalettes.lightTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizeBox.sizeHX1,
                    Row(
                      spacing: Dimens.gapX1B,
                      children: [
                        CommonHelpers.buildIcons(
                          path: AppImages.calenderIcon,
                          iconColor: context.iconsColor,
                          iconSize: Dimens.scaleX1B,
                        ),
                        Text(
                          "Submitted : ${help.createdAt?.toDdMmmYyyy()}",
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TextTheme textTheme) {
    final avatarUrl = _resolveAvatarUrl();
    final fallbackText = help.title?.trim().isNotEmpty == true
        ? help.title!.trim()
        : help.name ?? "";
    final initials = fallbackText.isNotEmpty
        ? CommonHelpers.getInitials(fallbackText)
        : "A";
    final double radius = 16.sp;

    if (avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppPalettes.primaryColor.withOpacityExt(0.1),
      child: Text(
        initials,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppPalettes.primaryColor,
        ),
      ),
    );
  }

  String? _resolveAvatarUrl() {
    String? candidate = help.partyMember?.user?.avatar;
    if (!(candidate.showDataNull)) {
      final docs = help.documents;
      if (docs != null && docs.isNotEmpty && docs.first.showDataNull) {
        candidate = docs.first;
      }
    }
    if (!(candidate.showDataNull)) return null;

    final trimmed = candidate!.trim();
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }

  String _resolveStatusLabel(AppLocalizations localization) {
    final rawStatus = help.status?.trim().toLowerCase();
    if (rawStatus == 'approved') {
      return localization.solved;
    }
    return help.status?.capitalize() ?? 'Pending';
  }

  Color _resolveStatusColor() {
    final rawStatus = help.status?.trim().toLowerCase();
    if (rawStatus == 'approved') {
      return AppPalettes.greenColor;
    }
    return AppPalettes.liteGreenColor;
  }
}
