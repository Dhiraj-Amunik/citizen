import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

final List<QuickAccessModel> userQuickAccess = [
  QuickAccessModel(
    icon: AppImages.wallOFHelpAccess,
    text: "Wall of Help",
    route: Routes.userWallOfHelpPage,
  ),
  QuickAccessModel(
    icon: AppImages.appointmentAccess,
    text: "Appointment",
    route: Routes.requestAppointmentPage,
  ),
  QuickAccessModel(
    icon: AppImages.memberShipAccess,
    text: "  Join Party  ",
    route: Routes.becomePartMemberPage,
  ),
];

final List<QuickAccessModel> partyQuickAccess = [
  QuickAccessModel(
    icon: AppImages.wallOFHelpAccess,
    text: "Wall of Help",
    route: Routes.partyWallOfHelpPage,
  ),
  QuickAccessModel(
    icon: AppImages.volunteerAccess,
    text: "Be a volunteer",
    route: Routes.beVolunteerPage,
  ),
  QuickAccessModel(
    icon: AppImages.appointmentAccess,
    text: "Appointment",
    route: Routes.requestAppointmentPage,
  ),
];

class QuickAccessWidget extends StatelessWidget {
  final bool showParty;
  const QuickAccessWidget({super.key, required this.showParty});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.gapX1,
      children: [
        Text(
          localization.quick_access,
          style: textTheme.bodyMedium?.copyWith(
            color: AppPalettes.primaryColor,
          ),
        ).horizontalPadding(Dimens.horizontalspacing),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX3B),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: Dimens.gapX3,
            children: List.generate(
              (showParty ? partyQuickAccess : userQuickAccess).length,
              (index) {
                return _getDialog(
                  textTheme,
                  (showParty ? partyQuickAccess : userQuickAccess)[index],
                );
              },
            ).toList(),
          ),
        ).horizontalPadding(Dimens.paddingX2),
      ],
    );
  }
}

Widget _getDialog(TextTheme style, QuickAccessModel data) {
  return GestureDetector(
    onTap: () => RouteManager.pushNamed(data.route),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: Dimens.paddingX1),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX6,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX2,
        spreadRadius: 2,
        blurRadius: 2,
        shadowColor: AppPalettes.blackColor.withOpacityExt(0.2),
        backgroundColor: AppPalettes.greenColor,
      ),
      child: Column(
        spacing: Dimens.gapX2,
        children: [
          CommonHelpers.buildIcons(path: data.icon, iconSize: Dimens.scaleX3),
          Text(
            data.text,
            style: style.bodySmall?.copyWith(color: AppPalettes.whiteColor),
          ),
        ],
      ),
    ),
  );
}

class QuickAccessModel {
  final String icon;
  final String text;
  final Routes route;

  const QuickAccessModel({
    required this.icon,
    required this.text,
    required this.route,
  });
}
