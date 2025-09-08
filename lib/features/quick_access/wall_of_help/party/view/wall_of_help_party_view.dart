import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';

class WallOfHelpPartyView extends StatelessWidget {
  const WallOfHelpPartyView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return Scaffold(
      appBar: commonAppBar(title: localization.wall_of_help),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.horizontalspacing,
          vertical: Dimens.appBarSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CommonButton(
              text: "+ ${localization.request_help}",
              height: 0,
              padding: EdgeInsets.symmetric(
                vertical: Dimens.paddingX2,
                horizontal: Dimens.paddingX2,
              ),
              fullWidth: false,
              onTap: () => RouteManager.pushNamed(Routes.requestWallOfHelpPage),
            ),
            SizeBox.widgetSpacing,
            Expanded(
              child: ListView.separated(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return PartyHelpCard();
                },
                separatorBuilder: (context, index) => SizeBox.widgetSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
