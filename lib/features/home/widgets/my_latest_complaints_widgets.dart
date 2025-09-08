import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/home/complaints_utils/complaints_widget.dart';

class MyLatestComplaintsWidgets extends StatelessWidget {
  const MyLatestComplaintsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX3,
      children: [
        Text(
          localization.my_complaints,
          style: textTheme.bodyMedium?.copyWith(
            color: AppPalettes.primaryColor,
          ),
        ).horizontalPadding(Dimens.horizontalspacing),
        ComplaintsWidget(
          color: AppPalettes.blueColor,
          icon: AppImages.electricBoardIcon,
          title: "Broken Street light on main road",
          date: "15",
          description:
              "The street light near the bus stop has been broken for a issue",
          status: "In progress",
        ),
         ComplaintsWidget(
          color: AppPalettes.yellowColor,
          icon: AppImages.waterDeptIcon,
          title: "Water leakage in residential area",
          date: "12",
          description:
              "Continues water leakage causing road damage and flood the area due to which facing multiple issues.",
          status: "Pending",
        ),
      ],
    );
  }
}
