class RequestMemberMessageModel {
  final String? receiverId;
  final MessagesDetails? messagesDetails;

  RequestMemberMessageModel({
    required this.receiverId,
    required this.messagesDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'messagesDetails': messagesDetails?.toJson(),
    };
  }
}

class MessagesDetails {
  final String? message;
  final List<String>? documents;

  MessagesDetails({this.message, this.documents});

  Map<String, dynamic> toJson() {
    return {'message': message, 'documents': documents ?? []};
  }
}
