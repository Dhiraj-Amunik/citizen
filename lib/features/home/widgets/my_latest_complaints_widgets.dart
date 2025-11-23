import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/complaints/widgets/complaint_widget.dart';
import 'package:inldsevak/features/complaints/model/response/complaints_model.dart';

class MyLatestComplaintsWidgets extends StatelessWidget {
  final List<Data> complaintList;
  const MyLatestComplaintsWidgets({super.key, required this.complaintList});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX2B,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localization.my_complaints,
              style: textTheme.headlineSmall?.copyWith(
                color: AppPalettes.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TranslatedText(
              text: "${complaintList.length} total",
              style: textTheme.titleMedium?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
          ],
        ).horizontalPadding(Dimens.horizontalspacing),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
          separatorBuilder: (_, index) => SizeBox.widgetSpacing,
          itemCount: complaintList.length,
          itemBuilder: (context, index) {
            final thread = complaintList[index];
            return ComplaintThreadWidget(
              thread: thread,
              showCompaint: true,
              onTap: () async {
                await RouteManager.pushNamed(
                  Routes.threadComplaintPage,
                  arguments: thread,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
