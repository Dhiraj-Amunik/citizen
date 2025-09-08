import 'package:flutter/material.dart';
import 'package:inldsevak/features/navigation/view_model/navigation_view_model.dart';
import 'package:inldsevak/features/navigation/view_model/role_view_model.dart';
import 'package:inldsevak/features/navigation/widgets/tab_icon_widget.dart';
import 'package:provider/provider.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationViewModel, RoleViewModel>(
      builder: (_, value, role, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              (role.isPartyMember
                      ? value.partyTabIconData
                      : value.userTabIconData)
                  .map(
                    (item) => TabIconWidget(
                      key: UniqueKey(),
                      data: item,
                      onTap: () => value.selectedTab =
                          (role.isPartyMember
                                  ? value.partyTabIconData
                                  : value.userTabIconData)
                              .indexOf(item),
                      isSelected:
                          (role.isPartyMember
                                  ? value.partyTabIconData
                                  : value.userTabIconData)
                              .indexOf(item) ==
                          value.selectedTab,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
