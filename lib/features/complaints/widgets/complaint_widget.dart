import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_helpers.dart';

class ComplaintThreadWidget extends StatelessWidget {
  final Data thread;
  final VoidCallback onTap;
  final bool showCompaint;
  final bool showAuthority;

  const ComplaintThreadWidget({
    super.key,
    required this.thread,
    required this.onTap,
    this.showCompaint = false,
    this.showAuthority = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radiusX6),
      child: Container(
        padding: EdgeInsetsGeometry.all(Dimens.paddingX3),
        decoration: boxDecorationRoundedWithShadow(
          Dimens.radiusX6,
          border: Border.all(color: AppPalettes.primaryColor),
        ),
        child: Column(
          spacing: Dimens.gapX1B,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: Dimens.gapX3,
              children: [
                CommonHelpers.buildIcons(
                  color: AppPalettes.liteGreenColor,
                  path: AppImages.emailIcon,
                  iconColor: AppPalettes.primaryColor,
                  iconSize: Dimens.scaleX2,
                  padding: Dimens.paddingX2B,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX1,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: Dimens.gapX2,
                        children: [
                          CommonHelpers.buildStatus(
                            thread.messages?.first.date?.toDdMmmYyyy() ?? "",
                            statusColor: AppPalettes.liteGreenColor,
                          ),
                          CommonHelpers.buildStatus(
                            thread.status?.capitalize() ?? "",
                            statusColor: ComplaintHelper.getStatusColor(
                              thread.status,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        thread.messages?.first.subject?.capitalize() ??
                            "No Subject found !",
                        style: textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizeBox.size,
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizeBox.sizeWX2,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX1,
                    children: [
                      Text(
                        thread.messages?.first.snippet ?? "Unknown Description",
                        maxLines: 2,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppPalettes.lightTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (showCompaint)
                        Row(
                          children: [
                            Text(
                              "Complaint ID : ",
                              maxLines: 2,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              thread.threadId ?? "",
                              maxLines: 2,
                              style: textTheme.labelMedium,
                            ),
                          ],
                        ),
                      if (showAuthority)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Submitted To : ",
                              maxLines: 2,
                              style: textTheme.labelMedium,
                            ),
                            Expanded(
                              child: Text(
                                '${thread.department?.name ?? "Department"} - ${thread.authorityName ?? "Authority"}',
                                maxLines: 2,
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppPalettes.lightTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
      ),
    );
  }
}
