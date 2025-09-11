import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';

class WallOfHelpPartyView extends StatelessWidget {
  const WallOfHelpPartyView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return Scaffold(
      appBar: commonAppBar(title: localization.wall_of_help),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.horizontalspacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CommonButton(
              text: "+ ${localization.request_help}",
              height: 40.height(),
              padding: EdgeInsets.symmetric(
                vertical: Dimens.paddingX2,
                horizontal: Dimens.paddingX4,
              ),
              fullWidth: false,
              onTap: () => RouteManager.pushNamed(Routes.requestWallOfHelpPage),
            ),
            SizeBox.widgetSpacing,
            Expanded(
              child: Consumer<WallOfHelpViewModel>(
                builder: (context, value, _) {
                  if (value.isLoading) {
                    return Center(child: CustomAnimatedLoading());
                  }

                  if (value.wallOFHelpLists.isEmpty) {
                    return WallOfHelpHelpers.emptyHelper(
                      text: "No requests found",
                      onRefresh: () => value.getWallOfHelpList(),
                    );
                  }
                  return ListView.separated(
                    itemCount: value.wallOFHelpLists.length,
                    itemBuilder: (context, index) {
                      return PartyHelpCard(
                        helpRequest: value.wallOFHelpLists[index],
                      );
                    },
                    separatorBuilder: (context, index) => SizeBox.widgetSpacing,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
