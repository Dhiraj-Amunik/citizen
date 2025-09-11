import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/common_button.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/user/widgets/user_card_help_widget.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/view_model/wall_of_help_view_model.dart';
import 'package:provider/provider.dart';

class WallOfHelpUserView extends StatelessWidget {
  const WallOfHelpUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    final provider = context.read<WallOfHelpViewModel>();
    return Scaffold(
      appBar: commonAppBar(title: localization.wall_of_help),
      body: RefreshIndicator(
        onRefresh: () => provider.getWallOfHelpList(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.horizontalspacing,
            vertical: Dimens.paddingX2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimens.gapX4,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.paddingX3,
                  vertical: Dimens.paddingX3,
                ),
                decoration: boxDecorationRoundedWithShadow(
                  backgroundColor: AppPalettes.greenColor.withOpacityExt(0.2),
                  Dimens.radiusX5,
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "A Family That Cares",
                          style: textTheme.bodyMedium,
                        ),
                        SizedBox(height: Dimens.gapX2),
                        Text(
                          "Beyond politics, we build trust and support. With the Wall of Help, you are never alone assistance is always near.",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppPalettes.lightTextColor,
                          ),
                        ),
                        SizeBox.sizeHX8,
                      ],
                    ).onlyPadding(bottom: Dimens.paddingX2),
                    CommonButton(
                      fullWidth: false,
                      height: 30,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.paddingX1,
                        horizontal: Dimens.paddingX3,
                      ),
                      onTap: () =>
                          RouteManager.pushNamed(Routes.becomePartMemberPage),
                      text: 'Join Party Member',
                      color: AppPalettes.buttonColor,
                    ),
                  ],
                ),
              ),
              Text(
                'View how members Benefited ',
                style: textTheme.headlineSmall,
              ),
              Expanded(
                child: Consumer<WallOfHelpViewModel>(
                  builder: (context, value, _) {
                    if (provider.isLoading) {
                      return Center(child: CustomAnimatedLoading());
                    }
                    return ListView.separated(
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
            ],
          ),
        ),
      ),
    );
  }
}
