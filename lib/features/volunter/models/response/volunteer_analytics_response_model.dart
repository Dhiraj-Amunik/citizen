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
    this.highestInviteReward,
    List<TopReferralUser>? topReferralUsers,
    List<ReferralGraphItem>? referralGraph,
    this.highestShareEvent,
    List<TopShareEventUser>? topShareEventUsers,
    List<ShareEventGraphItem>? shareEventGraph,
  })  : topVolunteers = topVolunteers ?? const <TopVolunteer>[],
        attendedEvents = attendedEvents ?? const <VolunteerEvent>[],
        upcomingEvents = upcomingEvents ?? const <VolunteerEvent>[],
        topReferralUsers = topReferralUsers ?? const <TopReferralUser>[],
        referralGraph = referralGraph ?? const <ReferralGraphItem>[],
        topShareEventUsers = topShareEventUsers ?? const <TopShareEventUser>[],
        shareEventGraph = shareEventGraph ?? const <ShareEventGraphItem>[];

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
      highestInviteReward: (json['highestInviteReward'] as num?)?.toInt(),
      topReferralUsers: (json['topReferralUsers'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                TopReferralUser.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      referralGraph: (json['referralGraph'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                ReferralGraphItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      highestShareEvent: (json['highestShareEvent'] as num?)?.toInt(),
      topShareEventUsers: (json['topShareEventUsers'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                TopShareEventUser.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      shareEventGraph: (json['shareEventGraph'] as List<dynamic>?)
          ?.map(
            (dynamic item) =>
                ShareEventGraphItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<TopVolunteer> topVolunteers;
  final MyVolunteerAnalytics? myAnalytics;
  final List<VolunteerEvent> attendedEvents;
  final List<VolunteerEvent> upcomingEvents;
  final int? highestInviteReward;
  final List<TopReferralUser> topReferralUsers;
  final List<ReferralGraphItem> referralGraph;
  final int? highestShareEvent;
  final List<TopShareEventUser> topShareEventUsers;
  final List<ShareEventGraphItem> shareEventGraph;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'topVolunteers': topVolunteers.map((TopVolunteer v) => v.toJson()).toList(),
      'myAnalytics': myAnalytics?.toJson(),
      'attendedEvents':
          attendedEvents.map((VolunteerEvent e) => e.toJson()).toList(),
      'upcomingEvents':
          upcomingEvents.map((VolunteerEvent e) => e.toJson()).toList(),
      'highestInviteReward': highestInviteReward,
      'topReferralUsers': topReferralUsers.map((TopReferralUser u) => u.toJson()).toList(),
      'referralGraph': referralGraph.map((ReferralGraphItem g) => g.toJson()).toList(),
      'highestShareEvent': highestShareEvent,
      'topShareEventUsers': topShareEventUsers.map((TopShareEventUser u) => u.toJson()).toList(),
      'shareEventGraph': shareEventGraph.map((ShareEventGraphItem g) => g.toJson()).toList(),
    };
  }
}

class TopShareEventUser {
  TopShareEventUser({
    this.rank,
    this.userId,
    this.name,
    this.profileImage,
    this.shareEventCoins,
  });

  factory TopShareEventUser.fromJson(Map<String, dynamic> json) {
    int? parseRank(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    int? parseCoins(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return TopShareEventUser(
      rank: parseRank(json['rank']),
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      profileImage: json['profileImage'] as String?,
      shareEventCoins: parseCoins(json['shareEventCoins']),
    );
  }

  final int? rank;
  final String? userId;
  final String? name;
  final String? profileImage;
  final int? shareEventCoins;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rank': rank,
      'userId': userId,
      'name': name,
      'profileImage': profileImage,
      'shareEventCoins': shareEventCoins,
    };
  }
}

class ShareEventGraphItem {
  ShareEventGraphItem({
    this.name,
    this.coins,
    this.percentage,
  });

  factory ShareEventGraphItem.fromJson(Map<String, dynamic> json) {
    int? parseCoins(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ShareEventGraphItem(
      name: json['name'] as String?,
      coins: parseCoins(json['coins']),
      percentage: json['percentage'] as String?,
    );
  }

  final String? name;
  final int? coins;
  final String? percentage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'coins': coins,
      'percentage': percentage,
    };
  }
}

class TopReferralUser {
  TopReferralUser({
    this.rank,
    this.userId,
    this.name,
    this.profileImage,
    this.inviteRewardCoins,
  });

  factory TopReferralUser.fromJson(Map<String, dynamic> json) {
    int? parseRank(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    int? parseCoins(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return TopReferralUser(
      rank: parseRank(json['rank']),
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      profileImage: json['profileImage'] as String?,
      inviteRewardCoins: parseCoins(json['inviteRewardCoins']),
    );
  }

  final int? rank;
  final String? userId;
  final String? name;
  final String? profileImage;
  final int? inviteRewardCoins;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rank': rank,
      'userId': userId,
      'name': name,
      'profileImage': profileImage,
      'inviteRewardCoins': inviteRewardCoins,
    };
  }
}

class ReferralGraphItem {
  ReferralGraphItem({
    this.name,
    this.coins,
    this.percentage,
  });

  factory ReferralGraphItem.fromJson(Map<String, dynamic> json) {
    int? parseCoins(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ReferralGraphItem(
      name: json['name'] as String?,
      coins: parseCoins(json['coins']),
      percentage: json['percentage'] as String?,
    );
  }

  final String? name;
  final int? coins;
  final String? percentage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'coins': coins,
      'percentage': percentage,
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
    this.totalCoins,
    this.totalTransactions,
  });

  factory MyVolunteerAnalytics.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return MyVolunteerAnalytics(
      totalEvents: parseInt(json['totalEvents']),
      attendedEvents: parseInt(json['attendedEvents']),
      totalShares: parseInt(json['totalShares']),
      activeSince: json['activeSince'] as String?,
      lastMonth: json['lastMonth'] as String?,
      referedUsers: parseInt(json['referedUsers']),
      sharedEvents: parseInt(json['sharedEvents']),
      totalCoins: parseInt(json['totalCoins']),
      totalTransactions: parseInt(json['totalTransactions']),
    );
  }

  final int? totalEvents;
  final int? attendedEvents;
  final int? totalShares;
  final String? activeSince;
  final String? lastMonth;
  final int? referedUsers;
  final int? sharedEvents;
  final int? totalCoins;
  final int? totalTransactions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalEvents': totalEvents,
      'attendedEvents': attendedEvents,
      'totalShares': totalShares,
      'activeSince': activeSince,
      'lastMonth': lastMonth,
      'referedUsers': referedUsers,
      'sharedEvents': sharedEvents,
      'totalCoins': totalCoins,
      'totalTransactions': totalTransactions,
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

