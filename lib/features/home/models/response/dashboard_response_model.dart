import 'package:inldsevak/features/profile/models/response/user_profile_model.dart'
    as profile;

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
    this.isVolunteer,
    this.volunteerStatus,
    this.unReadNotificationsCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: json['user'] == null
          ? null
          : profile.Data.fromJson(json['user'] as Map<String, dynamic>),
      isVolunteer: json['isVolunteer'] as bool?,
      volunteerStatus: json['volunteerStatus'] as String?,
      unReadNotificationsCount: json['unReadNotificationsCount'] as int?,
    );
  }

  final profile.Data? user;
  final bool? isVolunteer;
  final String? volunteerStatus;
  final int? unReadNotificationsCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (user != null) 'user': user!.toJson(),
      'isVolunteer': isVolunteer,
      'volunteerStatus': volunteerStatus,
      'unReadNotificationsCount': unReadNotificationsCount,
    };
  }
}

