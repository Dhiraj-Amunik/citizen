class RequestEventDetailsModel {
  String eventId;

  RequestEventDetailsModel({
    required this.eventId,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
    };
  }
}