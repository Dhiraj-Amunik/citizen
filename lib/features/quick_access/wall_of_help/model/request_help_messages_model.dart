class RequestHelpMessageModel {
  final String? financialHelpRequestId;
  final String? messageID;
  final MessagesDetails? messagesDetails;

  RequestHelpMessageModel({
    required this.financialHelpRequestId,
    required this.messagesDetails,
    required this.messageID
  });

  Map<String, dynamic> toJson() {
    return {
      'financialHelpRequestId': financialHelpRequestId,
      'messageId':messageID,
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
