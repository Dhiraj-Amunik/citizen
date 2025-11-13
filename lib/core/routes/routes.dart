import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/custom_page_route.dart';
import 'package:inldsevak/features/auth/view/login_view.dart';
import 'package:inldsevak/features/auth/view/user_register_view.dart';
import 'package:inldsevak/features/auth/view/verify_otp_view.dart';
import 'package:inldsevak/features/chat/view/chat_view.dart';
import 'package:inldsevak/features/complaints/view/complaints_view.dart';
import 'package:inldsevak/features/complaints/view/lodge_complaint_view.dart';
import 'package:inldsevak/features/complaints/view/thread_complaint_view.dart';
import 'package:inldsevak/features/donation/view/donate_view.dart';
import 'package:inldsevak/features/events/view/event_details_view.dart';
import 'package:inldsevak/features/events/view/events_view.dart';
import 'package:inldsevak/features/id_card/view/id_card_view.dart';
import 'package:inldsevak/features/leaderboard/coins_history_view.dart';
import 'package:inldsevak/features/leaderboard/coins_view.dart';
import 'package:inldsevak/features/leaderboard/leader_board_view.dart';
import 'package:inldsevak/features/lok_varta/widgets/interview_detailed_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_details_view.dart';
import 'package:inldsevak/features/lok_varta/widgets/press_releases_detailed_view.dart';
import 'package:inldsevak/features/notification/view/notifications_view.dart';
import 'package:inldsevak/features/notify_representative/view/create_notify_representative_view.dart';
import 'package:inldsevak/features/notify_representative/view/notify_representative_view.dart';
import 'package:inldsevak/features/notify_representative/view/update_notify_representative_view.dart';
import 'package:inldsevak/features/profile_tabs/view/about_view.dart';
import 'package:inldsevak/features/profile_tabs/view/leadership_info_view.dart';
import 'package:inldsevak/features/profile_tabs/view/party_information_view.dart';
import 'package:inldsevak/features/quick_access/appointments/view/appointment_details_view.dart';
import 'package:inldsevak/features/quick_access/appointments/view/appointments_view.dart';
import 'package:inldsevak/features/quick_access/appointments/view/request_appoinment_view.dart';
import 'package:inldsevak/features/home/view/request_membership_view.dart';
import 'package:inldsevak/features/quick_access/be_volunteer/view/be_a_volunteer_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/chat_contribute_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/contribute_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/my_help_messages_list_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/my_help_request_edit_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/my_help_requests_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/widgets/request_wall_of_help_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/wall_of_help_details_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/user/view/wall_of_help_user_view.dart';
import 'package:inldsevak/features/profile_tabs/view/emergency_contacts_view.dart';
import 'package:inldsevak/features/profile_tabs/view/help_and_support_view.dart';
import 'package:inldsevak/features/home/view/home_view.dart';
import 'package:inldsevak/features/party_member/view/become_part_member_view.dart';
import 'package:inldsevak/features/profile/view/profile_edit_view.dart';
import 'package:inldsevak/features/quick_access/wall_of_help/party/view/wall_of_help_party_view.dart';
import 'package:inldsevak/features/surveys/view/survey_view.dart';
import 'package:inldsevak/features/volunter/view/top_volunteers_view.dart';
import 'package:inldsevak/features/volunter/view/volunteer_analytics_view.dart';
import 'package:inldsevak/wrapper_view.dart';
part "./enum.dart";

class RouteManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final BuildContext context = navigatorKey.currentContext!;

  static RouteFactory _factory = CustomRouteFactory();

  static void setFactory(RouteFactory factory) => _factory = factory;

  static Route<dynamic> onGenerateRoute(RouteSettings? settings) {
    try {
      final route = Routes.values.firstWhere((r) => r.path == settings?.name);
      return _factory.createRoute(route, settings);
    } catch (error) {
      log("$error");
      return _factory.createRoute(
        Routes.loginPage,
        settings,
      ); // Add a NotFoundPage
    }
  }

  static Future<T?> pushNamed<T>(Routes route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      route.path,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveAll<T>(
    Routes route, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      route.path,
      (route) => false,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntilDashboard<T>(
    Routes route, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      route.path,
      (pushNamed) => pushNamed.isFirst,
      arguments: arguments,
    );
  }

  static void popUntil<T>(Routes route) {
    return navigatorKey.currentState!.popUntil(ModalRoute.withName(route.path));
  }

  static void popUntilHome<T>() {
    return navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  static void pop<T>([T? result]) => navigatorKey.currentState!.pop<T>(result);
}

abstract class RouteFactory {
  PageRoute createRoute(Routes route, RouteSettings? settings);
}

class MaterialRouteFactory implements RouteFactory {
  @override
  PageRoute createRoute(Routes route, RouteSettings? settings) {
    return MaterialPageRoute(
      builder: (_) => getPage(route, arguments: settings?.arguments),
      settings: settings,
    );
  }
}

class CupertinoRouteFactory implements RouteFactory {
  @override
  PageRoute createRoute(Routes route, RouteSettings? settings) {
    return CupertinoPageRoute(
      builder: (_) => getPage(route, arguments: settings?.arguments),
      settings: settings,
    );
  }
}

class CustomRouteFactory implements RouteFactory {
  @override
  PageRoute createRoute(Routes route, RouteSettings? settings) {
    return CustomPageRoute(
      child: getPage(route, arguments: settings?.arguments),
      direction: route.direction,
      settings: settings,
    );
  }
}
