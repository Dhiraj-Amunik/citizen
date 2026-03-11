import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;
import 'package:inldsevak/features/notification/models/notify_popup_model.dart';

class DashboardResponseModel {
  DashboardResponseModel({
    this.responseCode,
    this.message,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      responseCode: json['responseCode'] as int?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : DashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final int? responseCode;
  final String? message;
  final DashboardData? data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'responseCode': responseCode,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class DashboardData {
  DashboardData({
    this.user,
    this.userDetails,
    this.isVolunteer,
    this.volunteerStatus,
    this.unReadNotificationsCount,
    this.notifyPopup,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Handle both 'user' and 'userDetails' fields
    profile.Data? userData;
    if (json['user'] != null) {
      userData = profile.Data.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['userDetails'] != null) {
      userData = profile.Data.fromJson(json['userDetails'] as Map<String, dynamic>);
    }
    
    return DashboardData(
      user: userData,
      userDetails: userData, // Same data, accessible via both names
      isVolunteer: json['isVolunteer'] as bool?,
      volunteerStatus: json['volunteerStatus'] as String?,
      unReadNotificationsCount: json['unReadNotificationsCount'] as int?,
      notifyPopup: json['notifyPopup'] == null
          ? null
          : NotifyPopupItem.fromJson(json['notifyPopup'] as Map<String, dynamic>),
    );
  }

  final profile.Data? user;
  final profile.Data? userDetails; // Alias for user, for API response compatibility
  final bool? isVolunteer;
  final String? volunteerStatus;
  final int? unReadNotificationsCount;
  final NotifyPopupItem? notifyPopup;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (user != null) 'user': user!.toJson(),
      'isVolunteer': isVolunteer,
      'volunteerStatus': volunteerStatus,
      'unReadNotificationsCount': unReadNotificationsCount,
      if (notifyPopup != null) 'notifyPopup': notifyPopup!.toJson(),
    };
  }
}

