import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/notification/view_model/notification_view_model.dart';
import 'package:inldsevak/features/notification/widget/dismissable_widget.dart';
import 'package:provider/provider.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationViewModel>();
    final textTheme = context.textTheme;
    // final RxBool isSearchExpanded = false.obs;

    // void _toggleSearch() {
    //   isSearchExpanded.value = !isSearchExpanded.value;
    //   if (!isSearchExpanded.value) {
    //     // Clear search when collapsing
    //     controller.clearSearch();
    //   }
    // }

    return Scaffold(
      backgroundColor: AppPalettes.backGroundColor,
      appBar: commonAppBar(
        title: 'Notification',
        action: [
          // AnimatedSwitcher(
          //   duration: Duration(milliseconds: 300),
          //   child: isSearchExpanded.value
          //       ? Container() // Empty container when search is expanded
          //       : Container(
          //           // margin: EdgeInsets.only(right: 10.spMax),
          //           // child: AppbarHelper.getIcon(
          //           //   icon: AppImages.search,
          //           //   backgroundColor: AppPalette.backGroundColor,
          //           //   padding: 0,
          //           //   size: 18.spMax,
          //           //   onTap: _toggleSearch,
          //           // ),
          //         ),
          // ),
        ],
      ),
      body: Column(
        children: [
          // AnimatedContainer(
          //   duration: Duration(milliseconds: 300),
          //   // height: isSearchExpanded.value ? 54.0 : 0.0,
          //   child: AnimatedOpacity(
          //     duration: Duration(milliseconds: 300),
          //     opacity: 1.0,
          //     //  isSearchExpanded.value ? 1.0 : 0.0,
          //     child: Container(
          //       child: Row(
          //         children: [
          //           // Expanded(
          //           //   child: CommonTextFormField(
          //           //     height: 38,
          //           //     controller: controller.searchController,
          //           //     borderColor: AppPalette.transparentColor,
          //           //     shadowColor: AppPalette.liteGreyColor.withOpacityExt(
          //           //       0.2,
          //           //     ),
          //           //     elevation: 1.2,
          //           //     radius: 22.spMax,
          //           //     hintText: 'Search....',
          //           //     prefixIcon: Padding(
          //           //       padding: EdgeInsets.only(left: 8.0.spMax),
          //           //       child: CommonHelpers.newIcon(
          //           //         icon: AppImages.search,
          //           //         height: 18.spMax,
          //           //       ),
          //           //     ),
          //           //   ),
          //           // ),
          //           // 8.horizontalSpace,
          //           GestureDetector(
          //             // onTap: _toggleSearch,
          //             child: Container(
          //               width: 36.spMax,
          //               height: 36.spMax,
          //               decoration: BoxDecoration(
          //                 color: AppPalettes.whiteColor,
          //                 shape: BoxShape.circle,
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: AppPalettes.liteGreyColor.withOpacityExt(
          //                       0.4,
          //                     ),
          //                     offset: Offset(0, 1),
          //                     blurRadius: 2,
          //                   ),
          //                 ],
          //               ),
          //               child: Icon(
          //                 Icons.close,
          //                 size: 20.spMax,
          //                 color: AppPalettes.blackColor,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Consumer<NotificationViewModel>(
              builder: (context, value, _) {
                if (value.isLoading) {
                  return Center(child: CustomAnimatedLoading());
                }

                if (value.filteredNotificationsList.isEmpty) {
                  return Center(
                    child: Text(
                      "No notifications",
                      style: textTheme.titleMedium,
                    ),
                  );
                }
                return SlidableAutoCloseBehavior(
                  child: ListView(
                    children: provider.filteredNotificationsList.map((entry) {
                      return NotificationDateGroup(
                        key: ValueKey(entry.sId), // Important for list updates
                        date: entry.createdAt ?? "",
                        notifications: provider.filteredNotificationsList,
                        onDismiss: (a) {},
                        // onDismiss: (item) => controller.remove(item),
                      ).onlyPadding(top: Dimens.paddingX3);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ).symmetricPadding(horizontal: Dimens.paddingX4),
    );
  }
}
