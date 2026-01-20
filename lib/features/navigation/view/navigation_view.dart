import 'package:flutter/material.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:inldsevak/features/navigation/widgets/tab_icon_widget.dart';
import 'package:provider/provider.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Container(height: Dimens.scaleX7, color: AppPalettes.whiteColor),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX3,
          ).copyWith(bottom: Dimens.paddingX4),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.paddingX4,
            vertical: Dimens.paddingX4B,
          ),
          decoration: boxDecorationRoundedWithShadow(
            Dimens.radius100,
            backgroundColor: AppPalettes.liteGreenColor,
          ),
          height: Dimens.scaleX9,
          child: Selector<NavigationViewModel, int>(
            selector: (context, viewModel) => viewModel.selectedTab,
            builder: (context, selectedTab, child) {
              final viewModel = Provider.of<NavigationViewModel>(context, listen: false);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: viewModel.userTabIconData
                    .asMap()
                    .entries
                    .map(
                      (entry) => TabIconWidget(
                        key: ValueKey(entry.value.text),
                        data: entry.value,
                        onTap: () => viewModel.selectedTab = entry.key,
                        isSelected: entry.key == selectedTab,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DummyNav extends StatelessWidget {
  const DummyNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: Dimens.scaleX5);
  }
}
