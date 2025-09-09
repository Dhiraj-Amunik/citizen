import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/complaints/view_model/complaints_view_model.dart';
import 'package:inldsevak/features/home/widgets/upcoming_home_events_widget.dart';
import 'package:inldsevak/features/home/widgets/my_latest_complaints_widgets.dart';
import 'package:inldsevak/features/home/widgets/quick_access_widget.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class IndlView extends StatelessWidget {
  const IndlView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final roleProvider = context.read<RoleViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        elevation: 2,
        action: [
          //
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<ProfileViewModel>(
              builder: (context, value, _) {
                return Text(
                  "Hi, ${value.profile?.name ?? '...'}",
                  style: textTheme.headlineMedium,
                );
              },
            ),
            Row(
              spacing: Dimens.gapX1,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: Dimens.scaleX2,
                  color: AppPalettes.primaryColor,
                ),
                Text("Gurgaon Constituency", style: textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.widgetSpacing,
          children: [
            Container(
              margin: EdgeInsets.only(top: Dimens.appBarSpacing),
              padding: EdgeInsets.zero,
              decoration: boxDecorationRoundedWithShadow(
                Dimens.radiusX2,
                blurRadius: 2,
                spreadRadius: 2,
              ),
              child: Image.asset(
                "assets/banners/banner_1.png",
                fit: BoxFit.cover,
              ),
            ).horizontalPadding(Dimens.horizontalspacing),
            QuickAccessWidget(showParty: roleProvider.isPartyMember),

            UpComingHomeEventsWidget(),
            Consumer<ComplaintsViewModel>(
              builder: (_, value, _) {
                if (!roleProvider.isPartyMember &&
                    value.complaintsList.isNotEmpty) {
                  return MyLatestComplaintsWidgets(
                    complaintList: value.complaintsList,
                  );
                }
                return Container();
              },
            ),

            SizeBox.sizeHX4,
          ],
        ),
      ),
      backgroundColor: context.cardColor,
    );
  }
}
