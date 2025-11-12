import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/capitalise_string.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/helpers/decoration.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/nearest_member/model/nearest_members_model.dart';
import 'package:inldsevak/features/nearest_member/view_model/my_member_message_view_model.dart';

import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/wall_of_help_helpers.dart';
import 'package:provider/provider.dart';

class MyMembersMessagesListView extends StatelessWidget {
  const MyMembersMessagesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    final textTheme = context.textTheme;
    return ChangeNotifierProvider(
      create: (context) => MyMemberMessageViewModel(),
      builder: (context, _) {
        return Scaffold(
          appBar: commonAppBar(title: localization.my_chat),
          body: Consumer<MyMemberMessageViewModel>(
            builder: (_, value, _) {
              if (value.isLoading) {
                return Center(child: CustomAnimatedLoading());
              }
              return value.myChatsList.isEmpty
                  ? WallOfHelpHelpers.emptyHelper(
                      text: "No Messages found",
                      onRefresh: () async {},
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final message = value.myChatsList[index].lastMessage;
                        final user = value.myChatsList[index].chatWith;
                        final PartyMember partyMember = PartyMember(
                          name: user?.name,
                          email: user?.email,
                          phone: user?.phone,
                          avatar: user?.avatar,
                          partyMemberDetails: PartyMemberDetails(
                            sId: user?.sId,
                            type: value.myChatsList[index].chatWithType,
                          ),
                        );

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
                              RouteManager.pushNamed(
                                Routes.chatMemberPage,
                                arguments: partyMember,
                              );
                            },
                            leading: SizedBox(
                              width: Dimens.scaleX6,
                              height: Dimens.scaleX6,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(
                                  Dimens.radius100,
                                ),
                                child: CommonHelpers.getCacheNetworkImage(
                                  user?.avatar,
                                ),
                              ),
                            ),
                            title: Row(
                              spacing: Dimens.gapX4,
                              children: [
                                Expanded(
                                  child: Text(
                                    user?.name?.capitalize() ??
                                        "+91 ${user?.phone}",
                                    style: textTheme.bodyMedium,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  (DateTime.tryParse(message?.date ?? "") ??
                                          DateTime.now())
                                      .add(Duration(hours: 5, minutes: 30))
                                      .toString()
                                      .to12HourTime(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppPalettes.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              message?.text ?? "Open to see new message",
                              style: textTheme.bodySmall?.copyWith(
                                color: AppPalettes.lightTextColor,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: value.myChatsList.length,
                      separatorBuilder: (_, _) => SizeBox.sizeHX4,
                    );
            },
          ),
        );
      },
    );
  }
}
