import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/notification/widget/dismissable_widget.dart';
import 'package:provider/provider.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<UpdateNotificationViewModel>();
      if (notificationProvider.showNotification != false) {
        notificationProvider.disableNotificationIcon();
        notificationProvider.showNotification = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: AppPalettes.backGroundColor,
      appBar: commonAppBar(title: 'Notification'),
      body: Consumer<NotificationViewModel>(
        builder: (context, value, _) {
          if (value.isLoading) {
            return Center(child: CustomAnimatedLoading());
          }
          if (value.notificationsList.isEmpty) {
            return Center(
              child: Text("No notifications", style: textTheme.titleMedium),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: Dimens.verticalspacing),
            itemCount: value.notificationsList.length,
            separatorBuilder: (context, index) => SizeBox.sizeHX2,
            itemBuilder: (context, index) {
              return NotificationCard(
                notification: value.notificationsList[index],
              );
            },
          );
        },
      ).symmetricPadding(horizontal: Dimens.paddingX4),
    );
  }
}
