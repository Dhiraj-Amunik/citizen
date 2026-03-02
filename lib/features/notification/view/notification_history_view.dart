import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/relative_time_formatter_extension.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/features/notification/models/notification_history_model.dart';
import 'package:inldsevak/features/notification/view_model/notification_history_view_model.dart';

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationHistoryViewModel(),
      child: const _NotificationHistoryContent(),
    );
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
    final textTheme = context.textTheme;
    final hasImage =
        notification.image != null && notification.image!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(Dimens.paddingX4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppPalettes.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image logic
          if (hasImage)
            Container(
              width: 50.sp,
              height: 50.sp,
              margin: EdgeInsets.only(right: Dimens.gapX3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: NetworkImage(notification.image!),
                  fit: BoxFit.cover,
                  onError:
                      (_, __) {}, // Handle error silently or show placeholder
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: Dimens.gapX3),
              child: Image.asset(AppImages.logo, width: 50.w, height: 50.w),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  text: notification.title ?? "",
                  style: textTheme.titleMedium,
                  forceTranslation: true,
                ),
                SizedBox(height: Dimens.gapX),
                ReadMoreWidget(
                  text: notification.message ?? "",
                  maxLines: 3,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppPalettes.lightTextColor,
                    fontSize: 14.spMax,
                  ),
                  forceTranslation: true,
                ),
                SizedBox(height: Dimens.paddingX1),
                Align(
                  alignment: Alignment.centerRight,
                  child: TranslatedText(
                    text: notification.createdAt?.toRelativeTime() ?? "",
                    style: textTheme.labelMedium?.copyWith(
                      color: AppPalettes.lightTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
