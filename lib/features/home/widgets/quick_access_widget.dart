import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';

class QuickAccessWidget extends StatelessWidget {
  final bool showParty;
  const QuickAccessWidget({super.key, required this.showParty});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;

    final List<QuickAccessModel> userQuickAccess = [
      QuickAccessModel(
        icon: AppImages.complaintAccess,
        text: localization.raise_complaint,
        route: Routes.complaintsPage,
        fullWidth: true,
        color: AppPalettes.liteRedColor,
      ),
      QuickAccessModel(
        icon: AppImages.partyAccess,
        text: localization.become_part_mem,
        route: Routes.becomePartMemberPage,
        fullWidth: true,
        color: AppPalettes.liteGreenColor,
      ),
      QuickAccessModel(
        icon: AppImages.appointmentAccess,
        text: localization.appointments,
        route: Routes.appointmentPage,
      ),
      QuickAccessModel(
        icon: AppImages.helpAccess,
        text: localization.wall_of_help,
        route: Routes.userWallOfHelpPage,
      ),
    ];

    final List<QuickAccessModel> partyQuickAccess = [
      QuickAccessModel(
        icon: AppImages.notifyAccess,
        text: "Notify Representative",
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
      QuickAccessModel(
        icon: AppImages.helpAccess,
        text: "Wall of Help",
        route: Routes.partyWallOfHelpPage,
      ),
      QuickAccessModel(
        icon: AppImages.helpAccess,
        text: "Survey",
        route: Routes.partyWallOfHelpPage,
      ),
      QuickAccessModel(
        icon: AppImages.volunteerAccess,
        text: "Nearest Member",
        route: Routes.partyWallOfHelpPage,
      ),
    ];
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
            localization.quick_links,
            style: textTheme.headlineSmall?.copyWith(
              color: AppPalettes.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: Dimens.gapX3,
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
        ],
      ),
    );
  }
}

Widget _getDialog(TextTheme style, QuickAccessModel data) {
  return GestureDetector(
    onTap: () => RouteManager.pushNamed(data.route),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: data.fullWidth == true
              ? null
              : constraints.maxWidth / 2 - Dimens.gapX1B,
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX4,
            vertical: Dimens.paddingX3B,
          ),
          decoration: boxDecorationRoundedWithShadow(
            Dimens.radiusX4,
            backgroundColor: data.color ?? AppPalettes.liteBlueColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: Dimens.gapX2,
            children: [
              SvgPicture.asset(
                data.icon,
                height: Dimens.scaleX2B,
                width: Dimens.scaleX2B,
                colorFilter: ColorFilter.mode(
                  AppPalettes.blackColor,
                  BlendMode.srcIn,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(data.text, style: style.bodyMedium),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class QuickAccessModel {
  final String icon;
  final String text;
  final Routes route;
  final Color? color;
  final bool? fullWidth;

  const QuickAccessModel({
    required this.icon,
    required this.text,
    required this.route,
    this.color,
    this.fullWidth,
  });
}
