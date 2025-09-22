import 'package:flutter/widgets.dart';
import 'package:inldsevak/core/provider/base_view_model.dart';
import 'package:inldsevak/features/notification/models/notifications_model.dart';
import 'package:inldsevak/features/notification/services/notification_repository.dart';

class NotificationViewModel extends BaseViewModel {
  @override
  Future<void> onInit() {
    getNotifications();

    // debounce<String>(
    //   searchQuery,
    //   (query) => performSearch(query),
    //   time: Duration(milliseconds: 300),
    // );

    // Listen to search controller changes
    searchController.addListener(() {
      // searchQuery.value = searchController.text;
    });

    return super.onInit();
  }

  //   String? _token;
  final searchController = TextEditingController();

  //   void performSearch(String query) {
  //     if (query.isEmpty) {
  //       // Reset to original data when search is cleared
  //       filteredNotification.assignAll(notification);
  //       return;
  //     }

  //     filteredNotification.assignAll(
  //       notification.where((notification) {
  //         return notification.title?.toLowerCase().contains(
  //               query.toLowerCase(),
  //             ) ==
  //             true;
  //       }).toList(),
  //     );
  //   }

  void clearSearch() {
    searchController.clear();
    filteredNotificationsList.addAll(notificationsList);
  }

  void remove(Data item) {
    // notification.removeWhere((n) => n.id == item.id);
    // filteredNotification.removeWhere((n) => n.id == item.id);
  }

  List<Data> notificationsList = [];
  List<Data> filteredNotificationsList = [];

  Future<void> getNotifications() async {
    try {
      isLoading = true;
      final response = await NotificationRepository().getNotifications(
        token: token,
      );

      if (response.data?.responseCode == 200) {
        final data = response.data?.data;
        notificationsList.addAll(List.from(data as List));
        filteredNotificationsList.addAll(List.from(data as List));
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  //   List<NotificationItem> _convertToNotificationItems(NotificationModel data) {
  //     final items = <NotificationItem>[];

  //     // Convert Activities
  //     items.addAll(
  //       data.activities?.map(
  //             (a) => NotificationItem(
  //               id: 'activity_${a.id}',
  //               title: getTitle(type: a.activityType ?? ''),
  //               description: getDescription(
  //                 type: a.activityType ?? '',
  //                 data: a.activityData,
  //               ),
  //               date: a.createdAt,
  //               image: null,
  //               type: NotificationType.general,
  //             ),
  //           ) ??
  //           [],
  //     );

  //     // Convert CommunityActivities
  //     items.addAll(
  //       data.communityActivities?.map(
  //             (c) => NotificationItem(
  //               id: 'community_${c.communityName}_${c.modifiedAt}',
  //               title: getCommunityTitle(
  //                 c.activityTypeAction ?? "",
  //                 c.communityName,
  //                 c.roleName ?? [],
  //               ),
  //               description: getCommunityDescription(
  //                 c.activityTypeAction ?? "",
  //                 c.communityName,
  //                 c.roleName ?? [],
  //               ),
  //               date: c.modifiedAt,
  //               image: c.communityImage,
  //               type: NotificationType.community,
  //             ),
  //           ) ??
  //           [],
  //     );

  //     // Convert EventActivities
  //     items.addAll(
  //       data.eventActivities?.map(
  //             (e) => NotificationItem(
  //               id: 'event_${e.eventName}_${e.createdAt}',
  //               title: getEventTitle(
  //                 e.enrollAs?.trim() ?? '',
  //                 e.eventName?.trim() ?? '',
  //                 e.communityName?.trim() ?? '',
  //               ),
  //               description: getEventDescription(
  //                 e.enrollAs?.trim() ?? '',
  //                 e.eventName?.trim() ?? '',
  //                 e.communityName?.trim() ?? '',
  //               ),
  //               date: e.createdAt,
  //               image: e.communityImage,
  //               type: NotificationType.event,
  //             ),
  //           ) ??
  //           [],
  //     );

  //     // Sort by date descending
  //     items.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));

  //     return items;
  //   }

  //   DateTime _parseDate(String? dateString) {
  //     if (dateString == null) return DateTime(1970);
  //     try {
  //       // Handle API date format: "Fri, 25 Apr 2025 09:08:14 GMT"
  //       final cleanedDate = dateString.replaceAll("GMT", "").trim();
  //       return DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(cleanedDate);
  //     } catch (e) {
  //       return DateTime.tryParse(dateString) ?? DateTime(1970);
  //     }
  //   }

  //   String _formatDate(String? date) {
  //     if (date == null) return 'Unknown Date';
  //     final parsed = _parseDate(date);
  //     return DateFormat('dd MMM yyyy').format(parsed);
  //   }

  //   Map<String, List<NotificationItem>> get groupedNotifications {
  //     final grouped = <String, List<NotificationItem>>{};

  //     for (final item in filteredNotification) {
  //       final dateKey = _formatDate(item.date);
  //       grouped.putIfAbsent(dateKey, () => []).add(item);
  //     }

  //     // Sort groups by date (newest first)
  //     final sortedKeys =
  //         grouped.keys.toList()..sort((a, b) {
  //           if (a == 'Unknown Date') return 1;
  //           if (b == 'Unknown Date') return -1;
  //           return _parseDate(b).compareTo(_parseDate(a));
  //         });

  //     return Map.fromEntries(
  //       sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
  //     );
  //   }
  // }

  // enum NotificationType { general, community, event }

  // class NotificationItem {
  //   final String id;
  //   final String? title;
  //   final String? description;
  //   final String? date;
  //   final String? image;
  //   final NotificationType type;

  //   NotificationItem({
  //     required this.id,
  //     this.title,
  //     this.description,
  //     this.date,
  //     this.image,
  //     required this.type,
  //   });
  // }

  // String getEventDescription(
  //   String eventType,
  //   String eventName,
  //   String? communityName,
  // ) {
  //   switch (eventType.toLowerCase()) {
  //     case 'volunteer':
  //       return 'You have enrolled as a Volunteer for "$eventName" in $communityName. Thank you for your contribution!';
  //     case 'sponsor':
  //       return 'You have enrolled as a Sponsor for "$eventName" in $communityName. Your support makes a difference!';
  //     case 'participant':
  //       return 'You have successfully enrolled as a Participant for "$eventName" in $communityName. Get ready for an amazing experience!';
  //     default:
  //       return 'You have enrolled as $eventType for "$eventName" in $communityName.';
  //   }
  // }

  // String getEventTitle(
  //   String eventType,
  //   String eventName,
  //   String? communityName,
  // ) {
  //   switch (eventType.toLowerCase()) {
  //     case 'volunteer':
  //       return 'Volunteering Opportunity';
  //     case 'sponsor':
  //       return 'Sponsorship Confirmed';
  //     case 'participant':
  //       return 'Event Enrollment';
  //     default:
  //       return 'Event Update';
  //   }
  // }

  // String getCommunityDescription(
  //   String communityType,
  //   String? communityName,
  //   List<String> roles,
  // ) {
  //   switch (communityType.toLowerCase()) {
  //     case 'joined':
  //       return 'You have successfully joined the $communityName community. Start exploring and connecting with fellow members!';
  //     case 'added':
  //       if (roles.isNotEmpty) {
  //         return 'Congratulations! You have been assigned the role of ${roles.map((e) => e).join(" , ")} in $communityName.';
  //       } else {
  //         return "There has been an update in your $communityName community membership.";
  //       }
  //     default:
  //       return 'New activity in your $communityName community: ${communityType.capitalizeFirst}';
  //   }
  // }

  // String getCommunityTitle(
  //   String communityType,
  //   String? communityName,
  //   List<String> roles,
  // ) {
  //   switch (communityType.toLowerCase()) {
  //     case 'joined':
  //       return "Welcome to $communityName!";
  //     case 'added':
  //       if (roles.isNotEmpty) {
  //         return "New Role in $communityName";
  //       } else {
  //         return "Update from $communityName";
  //       }
  //     default:
  //       return "$communityName Update";
  //   }
  // }

  // String getTitle({required String type}) {
  //   switch (type.toLowerCase()) {
  //     case 'signup':
  //       return "Welcome to Clokam!";
  //     case 'login':
  //       return "Welcome Back!";
  //     case 'profile':
  //       return "Profile Updated";
  //     case 'password':
  //       return "Security Update";
  //     case 'email':
  //       return "Email Verification";
  //     default:
  //       return type;
  //   }
  // }

  // String getDescription({required String type, String? data}) {
  //   switch (type.toLowerCase()) {
  //     case 'signup':
  //       return "Your account has been successfully created. Welcome to the Clokam community!";
  //     case 'login':
  //       return "You have successfully logged into your Clokam account.";
  //     case 'profile':
  //       return "Your profile information has been updated successfully.";
  //     case 'password':
  //       return "Your password has been updated for enhanced security.";
  //     case 'email':
  //       return "Your email address has been verified successfully.";
  //     default:
  //       return "Your account has been updated: $data";
  //   }
}
