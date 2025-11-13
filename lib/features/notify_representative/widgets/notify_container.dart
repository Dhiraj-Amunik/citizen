import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inldsevak/core/extensions/string_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/utils/urls.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/notify_representative/model/response/notify_lists_model.dart';

class NotifyContainer extends StatelessWidget {
  final NotifyRepresentative model;
  final Function? onDelete;
  const NotifyContainer({super.key, this.onDelete, required this.model});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX3,
        vertical: Dimens.paddingX3,
      ),
      width: double.infinity,
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX3,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: Dimens.gapX2,
              runSpacing: Dimens.gapX1,
              alignment: WrapAlignment.end,
              children: [
                CommonHelpers.buildStatus(
                  model.dateAndTime?.toRelativeTime() ?? "",
                  statusColor: AppPalettes.liteBlueColor,
                ),
                CommonHelpers.buildStatus(
                  model.isDeleted == true
                      ? "Closed"
                      : model.isActive == true
                          ? "Pending"
                          : "Completed",
                  textColor: AppPalettes.blackColor,
                  statusColor: model.isDeleted == true
                      ? AppPalettes.redColor
                      : model.isActive == true
                          ? AppPalettes.yellowColor
                          : AppPalettes.greenColor,
                ),
              ],
            ),
          ),
          SizeBox.sizeHX1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX,
            children: [
              // Text(
              //   model.partyMember?.user?.name?.capitalize() ??
              //       localization.not_found,
              //   style: textTheme.bodySmall?.copyWith(
              //     color: AppPalettes.lightTextColor,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              Text(
                model.title?.capitalize() ?? "Unknown Title",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                spacing: Dimens.gapX1,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: Dimens.scaleX1B,
                    color: AppPalettes.blackColor,
                  ),
                  Expanded(
                    child: Text(
                      model.location ?? localization.not_found,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              ReadMoreWidget(
                text: model.description.isNull(localization.not_found),
                style: AppStyles.bodySmall.copyWith(
                  color: AppPalettes.lightTextColor,
                ),
              ),
              SizeBox.sizeHX,
              if (model.documents != null && model.documents!.isNotEmpty)
                _DocumentPreviewGrid(documents: model.documents!),
            ],
          ),
          SizeBox.sizeHX3,
          if (onDelete != null)
            Row(
              spacing: Dimens.gapX2,
              children: [
                Expanded(
                  child: CommonButton(
                    onTap: onDelete,
                    color: AppPalettes.whiteColor,
                    borderColor: AppPalettes.primaryColor,
                    textColor: AppPalettes.primaryColor,
                    text: localization.delete,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
                Expanded(
                  child: CommonButton(
                    onTap: () => RouteManager.pushNamed(
                      Routes.updateNotifyRepresentativePage,
                      arguments: model,
                    ),
                    text: localization.edit,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: Dimens.paddingX2),
                    radius: Dimens.radiusX2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DocumentPreviewGrid extends StatelessWidget {
  const _DocumentPreviewGrid({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: Dimens.gapX1,
      runSpacing: Dimens.gapX1,
      children: documents.map((url) {
        final resolvedUrl = _resolveUrl(url);
        if (resolvedUrl == null) {
          return const SizedBox.shrink();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.radiusX2),
          child: CachedNetworkImage(
            imageUrl: resolvedUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              color: AppPalettes.liteGreyColor,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 64,
              height: 64,
              color: AppPalettes.liteGreyColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: AppPalettes.lightTextColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String? _resolveUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('/')) return "${URLs.baseURL}$trimmed";
    return "${URLs.baseURL}/$trimmed";
  }
}
