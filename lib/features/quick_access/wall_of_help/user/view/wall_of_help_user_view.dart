import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/user/widgets/user_card_help_widget.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_user_view_model.dart';
import 'package:provider/provider.dart';

class WallOfHelpUserView extends StatelessWidget {
  const WallOfHelpUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final provider = context.read<WallOfHelpUserViewModel>();
    return Scaffold(
      appBar: commonAppBar(
        elevation: Dimens.elevation,
        title: localization.wall_of_help,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.getWallOfHelpList(),
        child: Consumer<WallOfHelpUserViewModel>(
          builder: (context, value, _) {
            if (provider.isLoading) {
              return Center(child: CustomAnimatedLoading());
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.horizontalspacing,
                vertical: Dimens.appBarSpacing,
              ),
              itemBuilder: (_, index) {
                return UserCardHelpWidget(
                  help: provider.wallOFHelpLists[index],
                );
              },
              separatorBuilder: (_, _) => SizeBox.widgetSpacing,
              itemCount: provider.wallOFHelpLists.length,
            );
          },
        ),
      ),
    );
  }
}
