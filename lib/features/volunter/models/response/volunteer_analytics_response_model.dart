class VolunteerAnalyticsResponseModel {
  VolunteerAnalyticsResponseModel({
    this.responseCode,
    this.message,
    this.data,
  });

  factory VolunteerAnalyticsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VolunteerAnalyticsResponseModel(
      responseCode: json['responseCode'] as int?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : VolunteerAnalyticsData.fromJson(
              json['data'] as Map<String, dynamic>,
            ),
    );
  }

  final int? responseCode;
  final String? message;
  final VolunteerAnalyticsData? data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'responseCode': responseCode,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class VolunteerAnalyticsData {
  VolunteerAnalyticsData({
    List<TopVolunteer>? topVolunteers,
    this.myAnalytics,
    List<VolunteerEvent>? attendedEvents,
    List<VolunteerEvent>? upcomingEvents,
  })  : topVolunteers = topVolunteers ?? const <TopVolunteer>[],
        attendedEvents = attendedEvents ?? const <VolunteerEvent>[],
        upcomingEvents = upcomingEvents ?? const <VolunteerEvent>[];

  factory VolunteerAnalyticsData.fromJson(Map<String, dynamic> json) {
    return VolunteerAnalyticsData(
      topVolunteers: (json['topVolunteers'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                TopVolunteer.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      myAnalytics: json['myAnalytics'] == null
          ? null
          : MyVolunteerAnalytics.fromJson(
              json['myAnalytics'] as Map<String, dynamic>,
            ),
      attendedEvents: (json['attendedEvents'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                VolunteerEvent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      upcomingEvents: (json['upcomingEvents'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                VolunteerEvent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<TopVolunteer> topVolunteers;
  final MyVolunteerAnalytics? myAnalytics;
  final List<VolunteerEvent> attendedEvents;
  final List<VolunteerEvent> upcomingEvents;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'topVolunteers': topVolunteers.map((TopVolunteer v) => v.toJson()).toList(),
      'myAnalytics': myAnalytics?.toJson(),
      'attendedEvents':
          attendedEvents.map((VolunteerEvent e) => e.toJson()).toList(),
      'upcomingEvents':
          upcomingEvents.map((VolunteerEvent e) => e.toJson()).toList(),
    };
  }
}

class TopVolunteer {
  TopVolunteer({
    this.rank,
    this.name,
    this.profileImage,
    this.coins,
  });

  factory TopVolunteer.fromJson(Map<String, dynamic> json) {
    return TopVolunteer(
      rank: json['rank'] as int?,
      name: json['name'] as String?,
      profileImage: json['profileImage'] as String?,
      coins: (json['coins'] as num?)?.toInt(),
    );
  }

  final int? rank;
  final String? name;
  final String? profileImage;
  final int? coins;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rank': rank,
      'name': name,
      'profileImage': profileImage,
      'coins': coins,
    };
  }
}

class MyVolunteerAnalytics {
  MyVolunteerAnalytics({
    this.totalEvents,
    this.attendedEvents,
    this.totalShares,
    this.activeSince,
    this.lastMonth,
    this.referedUsers,
    this.sharedEvents,
  });

  factory MyVolunteerAnalytics.fromJson(Map<String, dynamic> json) {
    return MyVolunteerAnalytics(
      totalEvents: (json['totalEvents'] as num?)?.toInt(),
      attendedEvents: (json['attendedEvents'] as num?)?.toInt(),
      totalShares: (json['totalShares'] as num?)?.toInt(),
      activeSince: json['activeSince'] as String?,
      lastMonth: json['lastMonth'] as String?,
      referedUsers: (json['referedUsers'] as num?)?.toInt(),
      sharedEvents: (json['sharedEvents'] as num?)?.toInt(),
    );
  }

  final int? totalEvents;
  final int? attendedEvents;
  final int? totalShares;
  final String? activeSince;
  final String? lastMonth;
  final int? referedUsers;
  final int? sharedEvents;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalEvents': totalEvents,
      'attendedEvents': attendedEvents,
      'totalShares': totalShares,
      'activeSince': activeSince,
      'lastMonth': lastMonth,
      'referedUsers': referedUsers,
      'sharedEvents': sharedEvents,
    };
  }
}

class VolunteerEvent {
  VolunteerEvent({
    this.eventName,
    this.eventType,
    this.eventDate,
    this.location,
    this.coinsEarned,
    this.rewardCoins,
  });

  factory VolunteerEvent.fromJson(Map<String, dynamic> json) {
    return VolunteerEvent(
      eventName: json['eventName'] as String?,
      eventType: json['eventType'] as String?,
      eventDate: json['eventDate'] as String?,
      location: json['location'] as String?,
      coinsEarned: (json['coinsEarned'] as num?)?.toInt(),
      rewardCoins: (json['rewardCoins'] as num?)?.toInt(),
    );
  }

  final String? eventName;
  final String? eventType;
  final String? eventDate;
  final String? location;
  final int? coinsEarned;
  final int? rewardCoins;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eventName': eventName,
      'eventType': eventType,
      'eventDate': eventDate,
      'location': location,
      'coinsEarned': coinsEarned,
      'rewardCoins': rewardCoins,
    };
  }
}

