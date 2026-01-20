class ComplaintCaseRequestModel {
  String? complaintId;
  String? response;
  FeedbackModel? feedback;
  String? date;

  ComplaintCaseRequestModel({
    this.complaintId,
    this.response,
    this.feedback,
    this.date,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (complaintId != null) {
      data['complaintId'] = complaintId;
    }
    if (response != null) {
      data['response'] = response;
    }
    // Always include feedback (even if empty) to ensure it's sent to API
    if (feedback != null) {
      data['feedback'] = feedback!.toJson();
    } else {
      // If feedback is null, create empty feedback object
      data['feedback'] = FeedbackModel(
        message: "",
        rating: 0,
        feedbackType: "",
      ).toJson();
    }
    if (date != null) {
      data['date'] = date;
    }
    return data;
  }
}

class FeedbackModel {
  String? message;
  int? rating;
  String? feedbackType;

  FeedbackModel({
    this.message,
    this.rating,
    this.feedbackType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Always include message (even if empty string)
    data['message'] = message ?? "";
    // Always include rating (even if 0)
    data['rating'] = rating ?? 0;
    // Always include feedbackType (even if empty string)
    data['feedbackType'] = feedbackType ?? "";
    return data;
  }
}































