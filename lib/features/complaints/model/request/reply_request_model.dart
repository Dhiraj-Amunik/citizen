class ReplyRequestModel {
  final String to;
  final String message;
  final String subject;
  final String threadId;
  final String inReplyTo;

  ReplyRequestModel({
    required this.to,
    required this.message,
    required this.subject,
    required this.threadId,
    required this.inReplyTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'message': message,
      'subject': subject,
      'threadId': threadId,
      'inReplyTo': inReplyTo,
    };
  }
}