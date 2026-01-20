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
import 'package:inldsevak/core/widgets/translated_text.dart';
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
                        final chatItem = value.myChatsList[index];
                        final message = chatItem.lastMessage;
                        final user = chatItem.chatWith;
                        final unreadCount = chatItem.unreadMessages ?? 0;
                        final isUnread = message?.isRead == false || unreadCount > 0;
                        
                        final PartyMember partyMember = PartyMember(
                          name: user?.name,
                          email: user?.email,
                          phone: user?.phone,
                          avatar: user?.avatar,
                          partyMemberDetails: PartyMemberDetails(
                            sId: user?.sId,
                            type: chatItem.chatWithType,
                          ),
                        );

                        return _buildChatItem(
                          avatar: user?.avatar,
                          name: user?.name?.capitalize() ?? "+91 ${user?.phone}",
                          lastMessage: message?.text ?? "Open to see new message",
                          timestamp: message?.date ?? chatItem.updatedAt,
                          onTap: () async {
                            await RouteManager.pushNamed(
                              Routes.chatMemberPage,
                              arguments: partyMember,
                            );
                            // Refresh after returning from chat to update unread count
                            if (context.mounted) {
                              value.getAllChats();
                            }
                          },
                          textTheme: textTheme,
                          unreadCount: unreadCount,
                          isUnread: isUnread,
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

  Widget _buildChatItem({
    required String? avatar,
    required String name,
    required String lastMessage,
    required String? timestamp,
    required VoidCallback onTap,
    required TextTheme textTheme,
    int unreadCount = 0,
    bool isUnread = false,
  }) {
    String formattedTime = "";
    if (timestamp != null) {
      try {
        final dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
        final adjustedTime = dateTime.add(Duration(hours: 5, minutes: 30));
        formattedTime = adjustedTime.toString().to12HourTime();
      } catch (e) {
        formattedTime = "";
      }
    }
    
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
        onTap: onTap,
        leading: Stack(
          children: [
            SizedBox(
              width: Dimens.scaleX6,
              height: Dimens.scaleX6,
              child: avatar != null && avatar.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(
                        Dimens.radius100,
                      ),
                      child: CommonHelpers.getCacheNetworkImage(avatar),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppPalettes.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppPalettes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          
          ],
        ),
        title: Row(
          spacing: Dimens.gapX4,
          children: [
            Expanded(
              child: Text(
                 name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (formattedTime.isNotEmpty)
                  Text(
                    formattedTime,
                    style: textTheme.bodySmall?.copyWith(
                      color: isUnread
                          ? AppPalettes.primaryColor
                          : AppPalettes.lightTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (unreadCount > 0)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalettes.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? "99+" : "$unreadCount",
                        style: TextStyle(
                          color: AppPalettes.whiteColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        subtitle: TranslatedText(
          text: lastMessage,
          style: textTheme.bodySmall?.copyWith(
            color: AppPalettes.lightTextColor,
            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
