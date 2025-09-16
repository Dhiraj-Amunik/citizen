import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

final List<QuickAccessModel> userQuickAccess = [
  QuickAccessModel(
    icon: AppImages.complaintAccess,
    text: "Raise Complaint",
    route: Routes.complaintsPage,
  ),
  QuickAccessModel(
    icon: AppImages.appointmentAccess,
    text: "Appointment",
    route: Routes.requestAppointmentPage,
  ),
  QuickAccessModel(
    icon: AppImages.partySign,
    text: "Become a Team Member",
    route: Routes.becomePartMemberPage,
  ),
  QuickAccessModel(
    icon: AppImages.wallOFHelpAccess,
    text: "Wall of Help",
    route: Routes.userWallOfHelpPage,
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
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: Dimens.horizontalspacing,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimens.gapX2,
        children: [
          Text(
            localization.quick_access,
            style: textTheme.headlineSmall?.copyWith(
              color: AppPalettes.primaryColor,
            ),
          ),

          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Disables GridView's scrolling
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              crossAxisSpacing: Dimens.paddingX2,
              mainAxisSpacing: Dimens.paddingX2,
            ),
            itemCount: (showParty ? partyQuickAccess : userQuickAccess).length,
            itemBuilder: (context, index) => _getDialog(
              textTheme,
              (showParty ? partyQuickAccess : userQuickAccess)[index],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _getDialog(TextTheme style, QuickAccessModel data) {
  return GestureDetector(
    onTap: () => RouteManager.pushNamed(data.route),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX2,
      ),
      decoration: boxDecorationRoundedWithShadow(
        Dimens.radiusX4,
        border: Border.all(color: AppPalettes.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Dimens.gapX2,
        children: [
          Flexible(
            child: CommonHelpers.buildIcons(
              path: data.icon,
              iconSize: Dimens.scaleX2,
              iconColor: AppPalettes.blackColor,
            ),
          ),
          Text(data.text, style: style.bodyMedium),
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
