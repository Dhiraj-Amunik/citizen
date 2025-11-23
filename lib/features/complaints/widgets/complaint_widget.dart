import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimens.gapX1,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: Dimens.gapX2,
                runSpacing: Dimens.gapX1,
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
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX3,
              children: [
              CircleAvatar(
                radius: Dimens.scaleX2B,
                backgroundColor: AppPalettes.liteGreenColor,
                child: CommonHelpers.buildIcons(
                  path: AppImages.emailIcon,
                  iconColor: AppPalettes.primaryColor,
                  iconSize: Dimens.scaleX1B,
                ),
              ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimens.gapX1,
                    children: [
                      ReadMoreWidget(
                        text: thread.messages?.first.subject?.capitalize() ??
                            "No Subject found !",
                        maxLines: 2,
                        style: textTheme.bodyMedium,
                      ),
                      ReadMoreWidget(
                        text: thread.messages?.first.snippet ??
                            "Unknown Description",
                        maxLines: 2,
                       
                      ),
                      if (showCompaint)
                        Row(
                          children: [
                            TranslatedText(
                              text: "Complaint ID : ",
                              maxLines: 2,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              thread.threadId ?? "",
                              maxLines: 2,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppPalettes.lightTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      if (showAuthority)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TranslatedText(
                              text: "Submitted To : ",
                              maxLines: 2,
                              style: textTheme.labelMedium,
                            ),
                            Expanded(
                              child: TranslatedText(
                                text: '${thread.department?.name ?? "Department"} - ${thread.authorityName ?? "Authority"}',
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
