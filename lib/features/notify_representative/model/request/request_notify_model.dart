class RequestNotifytModel {
  String title;
  String location;
  String? eventDate;
  String eventTime;
  String description;
  String? id;
  List<String> documents;

  RequestNotifytModel({
    required this.title,
    required this.location,
    required this.eventDate,
    this.eventTime = "00:00",
    required this.description,
    required this.documents,
    this.id="",
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'date': eventDate,
      'time': eventTime,
      'description': description,
      'documents': documents,
      "NotifyRepresentativeId":id,
    };
  }
}
