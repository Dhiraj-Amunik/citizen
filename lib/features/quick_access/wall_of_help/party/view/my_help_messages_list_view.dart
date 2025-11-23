import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/model/wall_of_help_model.dart'
    as model;
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';

class MyHelpMessagesListView extends StatelessWidget {
  final model.FinancialRequest helpRequests;
  const MyHelpMessagesListView({super.key, required this.helpRequests});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    log(helpRequests.toJson().toString());
    return Scaffold(
      appBar: commonAppBar(title: localization.my_chat),
      body: helpRequests.messageDetails?.isEmpty == true
          ? WallOfHelpHelpers.emptyHelper(
              text: "No Messages found",
              onRefresh: () async {},
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final data = helpRequests.messageDetails?[index];
                final user =
                    helpRequests.messageDetails?[index].relatedDetails?.user;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimens.horizontalspacing,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.padding,
                    horizontal: Dimens.paddingX3,
                  ),
                  decoration: boxDecorationRoundedWithShadow(
                    Dimens.radiusX4,
                    border: Border.all(color: AppPalettes.primaryColor),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      final newModel = helpRequests;
                      newModel.messageId = data?.messageId;
                      RouteManager.pushNamed(
                        Routes.chatContributePage,
                        arguments: helpRequests,
                      );
                    },
                    leading: SizedBox(
                      width: Dimens.scaleX6,
                      height: Dimens.scaleX6,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(
                          Dimens.radius100,
                        ),
                        child: CommonHelpers.getCacheNetworkImage(user?.avatar),
                      ),
                    ),
                    title: TranslatedText(
                      text: user?.name?.capitalize() ?? "+91 ${user?.phone}",
                      style: textTheme.bodyMedium,
                    ),
                    subtitle: TranslatedText(
                      text: "Open to see new message",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ),
                );
              },
              itemCount: helpRequests.messageDetails?.length ?? 0,
              separatorBuilder: (_, _) => SizeBox.sizeHX4,
            ),
    );
  }
}
