import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/notification/models/notification_history_model.dart';
import 'package:inldsevak/features/notification/view_model/notification_history_view_model.dart';
import 'package:inldsevak/core/widgets/common_expanded_widget.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationHistoryContent();
  }
}

class _NotificationHistoryContent extends StatefulWidget {
  const _NotificationHistoryContent();

  @override
  State<_NotificationHistoryContent> createState() =>
      _NotificationHistoryContentState();
}

class _NotificationHistoryContentState
    extends State<_NotificationHistoryContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationHistoryViewModel>().getHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: AppPalettes.backGroundColor,
      appBar: commonAppBar(title: 'Official Announcements'),
      body: Consumer<NotificationHistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.notifications.isEmpty) {
            return Center(
              child: TranslatedText(
                text: "No official announcements",
                style: textTheme.titleMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.getHistory(isRefresh: true);
            },
            color: AppPalettes.primaryColor,
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                vertical: Dimens.verticalspacing,
                horizontal: Dimens.paddingX4,
              ),
              itemCount:
                  viewModel.notifications.length +
                  (viewModel.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) =>
                  SizedBox(height: Dimens.gapX2),
              itemBuilder: (context, index) {
                if (index == viewModel.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return NotificationHistoryItemCard(
                  notification: viewModel.notifications[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationHistoryItemCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationHistoryItemCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        notification.image != null && notification.image!.isNotEmpty;

    return CommonExpandedWidget(
      color: AppPalettes.whiteColor,
      radius: 20.r,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.paddingX4,
        vertical: Dimens.paddingX2,
      ),
      title: notification.title ?? "",
      subtTitle: notification.createdAt?.toRelativeTime() ?? "",
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppPalettes.liteGreyColor.withOpacityExt(0.5)),
              SizedBox(height: Dimens.gapX2),
              TranslatedText(
                text: notification.message ?? "",
                style: AppStyles.bodyMedium.copyWith(
                  color: AppPalettes.lightTextColor,
                  fontSize: 14.spMax,
                ),
                forceTranslation: true,
              ),
              if (hasImage) ...[
                SizedBox(height: Dimens.gapX3),
                SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radiusX2),
                    child: CommonHelpers.getCacheNetworkImage(
                      notification.image!,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
              SizedBox(height: Dimens.gapX3),
            ],
          ),
        ),
      ],
    );
  }
}
