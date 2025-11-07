import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/party_help_card.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/my_help_requests_view_model.dart';
import 'package:provider/provider.dart';

class MyHelpRequestsView extends StatelessWidget {
  const MyHelpRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return ChangeNotifierProvider(
      create: (context) => MyHelpRequestsViewModel(),
      builder: (context, _) {
        return Scaffold(
          appBar: commonAppBar(title: localization.my_requests),
          body: Consumer<MyHelpRequestsViewModel>(
            builder: (context, value, _) {
              if (value.isLoading) {
                return Center(child: CustomAnimatedLoading());
              }
              if (value.myWallOFHelpLists.isEmpty) {
                return WallOfHelpHelpers.emptyHelper(
                  text: "No requests found",
                  onRefresh: () => value.getMyWallOfHelpList(),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.horizontalspacing,
                ).copyWith(bottom: Dimens.verticalspacing),
                controller: value.scrollController,
                itemCount: value.myWallOFHelpLists.length,
                itemBuilder: (context, index) {
                  return Column(
                    spacing: Dimens.gapX4,
                    children: [
                      PartyHelpCard(
                        closeRequest: () => value.closeMyFinancialHelp(index),
                        helpRequest: value.myWallOFHelpLists[index],
                        isEditable: true,
                      ),
                      if (value.isScrollLoading &&
                          value.myWallOFHelpLists.last ==
                              value.myWallOFHelpLists[index])
                        CustomAnimatedLoading(),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizeBox.widgetSpacing,
              );
            },
          ),
        );
      },
    );
  }
}
