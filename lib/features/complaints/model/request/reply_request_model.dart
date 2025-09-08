class ReplyRequestModel {
  final String message;
  final String complaintId;

  ReplyRequestModel({
    required this.message,
    required this.complaintId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'complaintId': complaintId,
    };
  }
}