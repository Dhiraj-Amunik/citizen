class ComplaintCaseResponseModel {
  int? responseCode;
  String? message;
  ComplaintCaseData? data;

  ComplaintCaseResponseModel({
    this.responseCode,
    this.message,
    this.data,
  });

  factory ComplaintCaseResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintCaseResponseModel(
      responseCode: json['responseCode'],
      message: json['message'],
      data: json['data'] != null
          ? ComplaintCaseData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ComplaintCaseData {
  String? sId;
  bool? isFollowUpDue;
  String? followUpQuestion;
  List<String>? followUpOptions;
  String? nextAction;
  String? status;

  ComplaintCaseData({
    this.sId,
    this.isFollowUpDue,
    this.followUpQuestion,
    this.followUpOptions,
    this.nextAction,
    this.status,
  });

  factory ComplaintCaseData.fromJson(Map<String, dynamic> json) {
    return ComplaintCaseData(
      sId: json['_id'],
      isFollowUpDue: json['isFollowUpDue'],
      followUpQuestion: json['followUpQuestion'],
      followUpOptions: json['followUpOptions'] != null
          ? List<String>.from(json['followUpOptions'])
          : null,
      nextAction: json['nextAction'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (isFollowUpDue != null) {
      data['isFollowUpDue'] = isFollowUpDue;
    }
    if (followUpQuestion != null) {
      data['followUpQuestion'] = followUpQuestion;
    }
    if (followUpOptions != null) {
      data['followUpOptions'] = followUpOptions;
    }
    if (nextAction != null) {
      data['nextAction'] = nextAction;
    }
    if (status != null) {
      data['status'] = status;
    }
    return data;
  }
}































