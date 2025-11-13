import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/secure/secure_storage.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/common_snackbar.dart';
import 'package:inldsevak/features/home/models/response/dashboard_response_model.dart';
import 'package:inldsevak/features/home/services/dashboard_repository.dart';
import 'package:inldsevak/features/volunter/view/top_volunteers_view.dart';

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
        icon: AppImages.complaintAccess,
        text: localization.raise_complaint,
        route: Routes.complaintsPage,
        fullWidth: true,
        color: AppPalettes.liteRedColor,
      ),
      QuickAccessModel(
        icon: AppImages.notifyAccess,
        text: localization.notify_representative,
        route: Routes.notifyRepresentativePage,
        fullWidth: true,
        color: AppPalettes.liteGreenColor,
      ),
      QuickAccessModel(
        icon: AppImages.volunteerAccess,
        text: localization.be_a_volunteer,
        route: Routes.topVolunteersPage,
        fullWidth: true,
      ),
      QuickAccessModel(
        icon: AppImages.appointmentAccess,
        text: localization.appointments,
        route: Routes.appointmentPage,
      ),
      QuickAccessModel(
        icon: AppImages.helpAccess,
        text: localization.wall_of_help,
        route: Routes.partyWallOfHelpPage,
      ),
      QuickAccessModel(
        icon: AppImages.surveyAccess,
        text: localization.survey,
        route: Routes.surveyPage,
      ),
      QuickAccessModel(
        icon: AppImages.nearestAccess,
        text: localization.nearest_member,
        route: Routes.nearestMemberPage,
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
                  context,
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


Widget _getDialog(
  BuildContext context,
  TextTheme style,
  QuickAccessModel data,
) {
  return GestureDetector(
    onTap: () => _handleQuickAccessTap(context, data),
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

Future<void> _handleQuickAccessTap(
  BuildContext context,
  QuickAccessModel data,
) async {
  if (data.route == Routes.topVolunteersPage) {
    await _handleVolunteerTap(context);
    return;
  }
  if (data.route == Routes.nearestMemberPage) {
    CommonSnackbar(text: "Updating soon...").showToast();
    return;
  }
  RouteManager.pushNamed(data.route);
}

Future<void> _handleVolunteerTap(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  var isDialogVisible = false;

  void closeDialog() {
    if (isDialogVisible && navigator.mounted && navigator.canPop()) {
      navigator.pop();
      isDialogVisible = false;
    }
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        color: AppPalettes.primaryColor,
      ),
    ),
  );
  isDialogVisible = true;

  try {
    final token = await SessionController.instance.getToken();
    final response =
        await DashboardRepository().fetchDashboard(token: token);

    closeDialog();

    if (response.error != null) {
      CommonSnackbar(text: response.error?.message ?? "Unable to fetch status")
          .showToast();
      return;
    }

    final dashboard = response.data;
    if (dashboard?.responseCode != 200 || dashboard?.data == null) {
      CommonSnackbar(
        text: dashboard?.message ?? "Unable to fetch status",
      ).showToast();
      return;
    }

    final DashboardData? data = dashboard?.data;
    final status = data?.volunteerStatus?.toLowerCase().trim();
    final isVolunteer = data?.isVolunteer == true;

    if (status == 'approved' || isVolunteer) {
      RouteManager.pushNamed(Routes.volunteerAnalyticsPage);
      return;
    }

    if (status == 'pending') {
      RouteManager.pushNamed(
        Routes.topVolunteersPage,
        arguments: const TopVolunteersViewArgs(
          canApply: false,
          statusMessage: "Volunteer request is pending",
        ),
      );
      return;
    }

    RouteManager.pushNamed(Routes.topVolunteersPage);
  } catch (error, stackTrace) {
    closeDialog();
    debugPrint("Error fetching volunteer status: $error");
    debugPrint(stackTrace.toString());
    CommonSnackbar(
      text: "Something went wrong, please try again later",
    ).showToast();
  }
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
