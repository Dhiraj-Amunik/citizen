class RequestFinancialHelpModel {
  final String? subject;
  final String? reason;
  final String? amountRequested;
  final String? additionalDetails;
  final List<Document>? documents;

  RequestFinancialHelpModel({
    required this.subject,
    required this.reason,
    required this.amountRequested,
    required this.additionalDetails,
     this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'reason': reason,
      'amountRequested': amountRequested,
      'additionalDetails': additionalDetails,
      'documents': documents?.map((doc) => doc.toJson()).toList(),
    };
  }
}

class Document {
  final String fileName;
  final String fileUrl;

  Document({
    required this.fileName,
    required this.fileUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
    };
  }
}